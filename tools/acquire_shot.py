#!/usr/bin/env python3
"""Fail-closed source-run acquisition. Raw output and derived summaries are separate."""
import argparse
import hashlib
import json
import math
import pathlib
import statistics
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def finite_number(value, minimum=0, positive=False):
    return (not isinstance(value, bool) and isinstance(value, (int, float))
            and math.isfinite(value) and (value > minimum if positive else value >= minimum))


def integer(value, minimum, maximum):
    return finite_number(value, minimum) and value <= maximum and value == int(value)


def validate_inventory(states, identities=None):
    if not isinstance(states, list) or len(states) != 16:
        raise ValueError('invalid ball inventory size')
    for state in states:
        if not isinstance(state, list) or len(state) != 17 or any(
                isinstance(v, bool) or not isinstance(v, (int, float)) or not math.isfinite(v) for v in state):
            raise ValueError('invalid canonical ball state')
        if not all(integer(state[i], 0, 15) for i in (0, 1)) or not integer(state[15], 0, 4) or not integer(state[16], -1, 5):
            raise ValueError('invalid ball identity/phase/pocket')
        if not math.isclose(sum(v*v for v in state[11:15]), 1.0, abs_tol=2e-5):
            raise ValueError('invalid ball orientation')
        if state[15] in (0, 1) and state[16] != -1:
            raise ValueError('on-table ball has pocket identity')
        if state[15] in (2, 3) and state[16] == -1:
            raise ValueError('falling/pocketed ball lacks pocket identity')
        if state[15] == 3 and (state[4] > -.12 or any(v != 0 for v in state[5:11])):
            raise ValueError('invalid pocketed state')
    actual = [(s[0], s[1]) for s in states]
    if len({s[0] for s in states}) != 16 or len({s[1] for s in states}) != 16:
        raise ValueError('duplicate ball identity')
    if identities is not None and actual != identities:
        raise ValueError('inventory identity changed')
    return actual


def clock_report(items, kind=None):
    stamps = [r['wall_usec'] for r in items if kind is None or r['kind'] == kind]
    diffs = [b-a for a, b in zip(stamps, stamps[1:])]
    if not diffs:
        raise ValueError('empty clock acquisition')
    ordered = sorted(diffs)
    return dict(samples=len(stamps), median_ms=statistics.median(diffs)/1000,
                p95_ms=ordered[min(len(ordered)-1, int(.95*len(ordered)))]/1000,
                worst_ms=max(diffs)/1000,
                backwards_intervals=[dict(index=i, delta_usec=d) for i, d in enumerate(diffs) if d < 0],
                equal_timestamp_intervals=sum(d == 0 for d in diffs),
                over_50ms=[dict(index=i, delta_usec=d) for i, d in enumerate(diffs) if d > 50000])


def validate_trace(records, ticks, dt, identities, native=False):
    if not isinstance(records, list) or not records or len(records) > 30000:
        raise ValueError('empty/overflow trace')
    allowed = {'state', 'event'}
    if native:
        allowed |= {'input_request', 'cue_contact_observed', 'frame_process', 'frame_post_draw', 'termination'}
    states, events = [], []
    previous_tick = 0
    for record in records:
        tick = record['tick']
        if record['kind'] not in allowed or not isinstance(record['payload'], dict):
            raise ValueError('invalid trace record kind/payload')
        if not integer(tick, 0, ticks) or tick < previous_tick:
            raise ValueError('trace tick outside domain or backwards')
        previous_tick = tick
        if not finite_number(record['wall_usec']) or not finite_number(record['simulation_seconds']):
            raise ValueError('invalid trace clocks')
        if not math.isclose(record['simulation_seconds'], tick*dt, rel_tol=0, abs_tol=1e-10):
            raise ValueError('simulation clock/tick disagreement')
        if record['kind'] == 'state':
            validate_inventory(record['payload']['balls'], identities)
            states.append(record)
        elif record['kind'] == 'event':
            payload = record['payload']
            event = payload['event']
            if event['kind'] not in ('ball_contact', 'rail', 'pocket', 'off_table') or not integer(event['tick'], 1, tick):
                raise ValueError('invalid event kind/tick')
            if not finite_number(event['speed']) or not finite_number(payload['event_tick_seconds']):
                raise ValueError('invalid event speed/time')
            if not math.isclose(payload['event_tick_seconds'], event['tick']*dt, rel_tol=0, abs_tol=1e-10):
                raise ValueError('event clock/tick disagreement')
            if event['kind'] == 'ball_contact':
                if not integer(event['a'], 0, 15) or not integer(event['b'], 0, 15) or event['a'] == event['b']:
                    raise ValueError('invalid event ball identities')
            elif not integer(event['number'], 0, 15):
                raise ValueError('invalid event ball identity')
            if event['kind'] == 'pocket' and not integer(event['pocket_id'], 0, 5):
                raise ValueError('invalid event pocket identity')
            events.append(event)
    if [r['tick'] for r in states] != list(range(1, ticks+1)):
        raise ValueError('incomplete sampled tick trace')
    return states, events


def balls_settled(states, config):
    # This mirrors only the declared active stepper's stop predicate, not its physics.
    for s in states:
        if s[15] in (1, 2) or (s[15] == 4 and s[4] > -.12):
            return False
        if s[15] == 0 and (math.hypot(s[5], s[6]) > config['sleep_speed_threshold']
                          or math.sqrt(sum(v*v for v in s[8:11])) > config['sleep_spin_threshold']):
            return False
    return True


def _summarize(raw):
    if raw.get('schema') != 'long-rail-acquisition/1' or raw.get('status') != 'PASS' or raw.get('failures') != []:
        raise ValueError('invalid or failed acquisition')
    horizon = raw['fixture']['ticks']
    if not integer(horizon, 1, 9600):
        raise ValueError('invalid replay horizon')
    ticks = int(horizon)
    dt = raw['config']['fixed_step']
    if not finite_number(dt, positive=True):
        raise ValueError('invalid simulation step')
    identities = validate_inventory(raw['initial'])
    if raw['initial'] != raw['fixture']['balls']:
        raise ValueError('initial/fixture disagreement')
    validate_inventory(raw['terminal'], identities)
    states, events = validate_trace(raw['records'], ticks, dt, identities)
    if raw['terminal'] != states[-1]['payload']['balls']:
        raise ValueError('terminal/final sampled state disagreement')
    if raw['events'] != events:
        raise ValueError('event list/trace disagreement')
    event_counts = {}
    for event in events:
        event_counts[event['kind']] = event_counts.get(event['kind'], 0)+1
    expected = raw['fixture']['expected_events']
    if not isinstance(expected, list) or not expected or any(k not in ('ball_contact', 'rail', 'pocket') for k in expected):
        raise ValueError('missing/invalid expected event policy')
    missing = [k for k in expected if not event_counts.get(k)]
    if missing:
        raise ValueError('missing replay events: '+str(missing))
    trials = raw['paired_replay_timings']
    if not isinstance(trials, list) or len(trials) != 5:
        raise ValueError('require exactly five paired overhead trials')
    ratios = []
    for trial in trials:
        if not isinstance(trial, dict) or any(not finite_number(trial[k], positive=True) for k in ('plain_usec', 'traced_usec')):
            raise ValueError('invalid paired overhead duration')
        ratio = trial['traced_usec']/trial['plain_usec']
        if not finite_number(ratio, positive=True):
            raise ValueError('invalid overhead ratio')
        ratios.append(ratio)
    summary = dict(status='PASS', scope='same-build active-solver replay and acquisition integrity only',
                   fixture=raw['fixture']['id'], replay_ticks=ticks, event_counts=event_counts,
                   missing_expected_events=missing, paired_overhead_ratio_median=statistics.median(ratios),
                   replay_clocks=clock_report(raw['records']),
                   acquisition_loaded_by_gameplay=False, limitations=raw['limitations'])
    if not isinstance(raw['native'], bool):
        raise ValueError('invalid native flag')
    if raw['native']:
        native_ticks = raw['native_ticks']
        if not integer(native_ticks, 1, 30000):
            raise ValueError('invalid native horizon')
        native = raw['native_records']
        native_states, native_events = validate_trace(native, int(native_ticks), dt, identities, native=True)
        validate_inventory(raw['native_terminal'], identities)
        if raw['native_terminal'] != native_states[-1]['payload']['balls']:
            raise ValueError('native terminal/final sampled state disagreement')
        for kind in ('input_request', 'cue_contact_observed', 'termination'):
            if sum(r['kind'] == kind for r in native) != 1:
                raise ValueError('missing/duplicate native '+kind)
        termination = raw['native_termination']
        if native[-1]['kind'] != 'termination' or native[-1]['payload'] != termination or termination['tick'] != native_ticks:
            raise ValueError('native termination/trace disagreement')
        if termination['reason'] not in ('horizon', 'settled'):
            raise ValueError('native acquisition timed out or has invalid termination')
        if not finite_number(termination['elapsed_wall_usec'], positive=True) or termination['deadline_usec'] != 12000000 or termination['elapsed_wall_usec'] >= termination['deadline_usec']:
            raise ValueError('native acquisition exceeded deadline')
        for key in ('controller_moving', 'controller_pending', 'balls_settled'):
            if not isinstance(termination[key], bool):
                raise ValueError('invalid native terminal controller state')
        for key in ('sleep_speed_threshold', 'sleep_spin_threshold'):
            if not finite_number(raw['config'][key], positive=True):
                raise ValueError('invalid settlement threshold')
        if termination['balls_settled'] != balls_settled(raw['native_terminal'], raw['config']):
            raise ValueError('native settlement/state disagreement')
        if termination['controller_pending']:
            raise ValueError('native stroke remains pending')
        if termination['controller_moving'] == termination['balls_settled']:
            raise ValueError('native controller/settlement disagreement')
        if termination['reason'] == 'horizon' and native_ticks < ticks:
            raise ValueError('native horizon incomplete')
        if termination['reason'] == 'settled' and (native_ticks >= ticks or termination['controller_moving'] or not termination['balls_settled']):
            raise ValueError('invalid early native settlement')
        input_record = next(r for r in native if r['kind'] == 'input_request')
        if input_record['tick'] != 0 or input_record['payload']['input'] != raw['fixture']['input']:
            raise ValueError('native input/fixture disagreement')
        frames = [r for r in native if r['kind'] == 'frame_process']
        for frame in frames:
            payload = frame['payload']
            if not isinstance(payload['moving'], bool) or not isinstance(payload['pending'], bool) or not finite_number(payload['process_delta_seconds'], positive=True):
                raise ValueError('invalid native frame controller state')
        # process_frame fires before the controller's _process; termination is
        # captured after frame_post_draw. Their flags may legitimately differ.
        native_counts = {}
        for event in native_events:
            k = event['kind']
            native_counts[k] = native_counts.get(k, 0)+1
        if any(not native_counts.get(k) for k in expected):
            raise ValueError('missing native event')
        summary.update(native_ticks=native_ticks, native_event_counts=native_counts,
                       native_termination=termination, native_clocks=clock_report(native),
                       frame_process=clock_report(native, 'frame_process'), frame_post_draw=clock_report(native, 'frame_post_draw'))
    return summary


def summarize(raw):
    try:
        return _summarize(raw)
    except (KeyError, TypeError, IndexError, AttributeError, OverflowError, ZeroDivisionError) as error:
        raise ValueError("malformed acquisition: "+str(error)) from error


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=pathlib.Path,required=True,help='new output directory; never overwrites a baseline')
    parser.add_argument('--fixture',type=pathlib.Path,default=ROOT/'tests/fixtures/three_ball_v1.json')
    parser.add_argument('--native',action='store_true')
    args=parser.parse_args()
    output=args.output.resolve()
    output.mkdir(parents=True,exist_ok=False)
    raw_path=output/'raw.json'
    paths=sorted(p for p in ROOT.rglob('*') if p.is_file() and
                 (p.relative_to(ROOT).parts[0] in ('scripts','scenes','assets','tests','tools') or p.name=='project.godot') and
                 not any(x in p.parts for x in ('__pycache__',)))
    manifest=dict(commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
                  dirty_status=subprocess.check_output(['git','status','--porcelain'],cwd=ROOT,text=True),
                  files={str(p.relative_to(ROOT)):digest(p) for p in paths},
                  fixture_sha256=digest(args.fixture),active_engine='scripts/sim/physics_stepper.gd; GameController default; acquisition subclass calls super',
                  artifact='Godot source run, not release export',input='scripted controller request; no OS input capture')
    (output/'manifest.json').write_text(json.dumps(manifest,indent=2,allow_nan=False)+'\n')
    command=['bash','tools/godot.sh']+([] if args.native else ['--headless'])+['--path',str(ROOT),'--script','tests/measurement/run_acquisition.gd','--',f'--output={raw_path}',f'--fixture={args.fixture.resolve()}']+(['--native'] if args.native else [])
    try:
        result=subprocess.run(command,cwd=ROOT,capture_output=True,text=True,timeout=90)
        (output/'engine.log').write_text(result.stdout+result.stderr)
        if result.returncode or 'SCRIPT ERROR' in result.stdout+result.stderr or not raw_path.exists():
            raise ValueError(f'engine acquisition failed: exit={result.returncode}; see engine.log')
        raw=json.loads(raw_path.read_text())
        summary=summarize(raw)
        if args.native and (not raw.get('native') or not pathlib.Path(str(raw_path)+'.png').is_file()):
            raise ValueError('missing native image/run')
        manifest.update(raw_sha256=digest(raw_path),engine=raw['engine'],os=raw['os'],device=raw['device'])
        (output/'manifest.json').write_text(json.dumps(manifest,indent=2,allow_nan=False)+'\n')
        summary['raw_sha256']=manifest['raw_sha256']
        (output/'summary.json').write_text(json.dumps(summary,indent=2,allow_nan=False)+'\n')
        print(json.dumps(summary,indent=2,allow_nan=False))
    except (ValueError,OSError,subprocess.TimeoutExpired) as error:
        (output/'summary.json').write_text(json.dumps(dict(status='FAIL',error=str(error)),indent=2,allow_nan=False)+'\n')
        print(error,file=sys.stderr)
        return 1
    return 0

if __name__=='__main__':
    sys.exit(main())
