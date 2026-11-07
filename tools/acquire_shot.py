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


def _summarize(raw):
    if raw.get('schema') != 'long-rail-acquisition/1' or raw.get('status') != 'PASS' or raw.get('failures') != []:
        raise ValueError('invalid or failed acquisition')
    records = raw.get('records', [])
    states = [r for r in records if r['kind'] == 'state']
    horizon = raw['fixture']['ticks']
    if isinstance(horizon, bool) or not isinstance(horizon, (int, float)) or not math.isfinite(horizon) or not 1 <= horizon <= 9600 or horizon != int(horizon):
        raise ValueError('invalid replay horizon')
    ticks = int(horizon)
    if len(states) != ticks or [r['tick'] for r in states] != list(range(1, ticks+1)):
        raise ValueError('empty/incomplete replay trace')
    def valid_inventory(states):
        return isinstance(states, list) and len(states) == 16 and all(
            isinstance(s, list) and len(s) == 17 and all(
                not isinstance(v, bool) and isinstance(v, (int, float)) and math.isfinite(v) for v in s)
            for s in states)
    if not valid_inventory(raw.get('initial')) or not valid_inventory(raw.get('terminal')):
        raise ValueError('invalid initial/terminal inventory')
    if any(not valid_inventory(r['payload']['balls']) for r in states):
        raise ValueError('invalid sampled inventory')
    event_counts = {}
    for event in raw.get('events', []):
        event_counts[event['kind']] = event_counts.get(event['kind'], 0)+1
    missing = [k for k in raw['fixture']['expected_events'] if not event_counts.get(k)]
    if missing:
        raise ValueError('missing replay events: '+str(missing))
    def clock_report(items, kind):
        stamps = [r['wall_usec'] for r in items if r['kind'] == kind]
        if any(isinstance(t, bool) or not isinstance(t, (int, float)) or not math.isfinite(t) or t < 0 for t in stamps):
            raise ValueError('invalid frame timestamp')
        diffs = [b-a for a,b in zip(stamps, stamps[1:])]
        if not diffs:
            raise ValueError('empty frame acquisition')
        ordered = sorted(diffs)
        return dict(samples=len(stamps), median_ms=statistics.median(diffs)/1000,
                    p95_ms=ordered[min(len(ordered)-1, int(.95*len(ordered)))]/1000,
                    worst_ms=max(diffs)/1000,
                    nonpositive_intervals=[dict(index=i,delta_usec=d) for i,d in enumerate(diffs) if d <= 0],
                    over_50ms=[dict(index=i,delta_usec=d) for i,d in enumerate(diffs) if d > 50000])
    ratios = [x['traced_usec']/x['plain_usec'] for x in raw['paired_replay_timings'] if x['plain_usec'] > 0]
    if len(ratios) != 5:
        raise ValueError('missing paired overhead trials')
    summary = dict(status='PASS', scope='same-build active-solver replay and acquisition integrity only',
                   fixture=raw['fixture']['id'], replay_ticks=ticks, event_counts=event_counts,
                   missing_expected_events=missing, paired_overhead_ratio_median=statistics.median(ratios),
                   acquisition_loaded_by_gameplay=False, limitations=raw['limitations'])
    if raw.get('native'):
        native = raw.get('native_records', [])
        if not raw.get('native_ticks') or not any(r['kind']=='input_request' for r in native) or not any(r['kind']=='cue_contact_observed' for r in native):
            raise ValueError('empty native shot')
        native_states = [r for r in native if r['kind'] == 'state']
        if not valid_inventory(raw.get('native_terminal')) or any(not valid_inventory(r['payload']['balls']) for r in native_states):
            raise ValueError('invalid native inventory')
        if [r['tick'] for r in native_states] != list(range(1, raw['native_ticks']+1)):
            raise ValueError('incomplete native tick trace')
        native_counts = {}
        for r in native:
            if r['kind'] == 'event':
                k=r['payload']['event']['kind']; native_counts[k]=native_counts.get(k,0)+1
        if any(not native_counts.get(k) for k in raw['fixture']['expected_events']):
            raise ValueError('missing native event')
        summary.update(native_ticks=raw['native_ticks'], native_event_counts=native_counts,
                       frame_process=clock_report(native,'frame_process'), frame_post_draw=clock_report(native,'frame_post_draw'))
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
    (output/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
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
        (output/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
        summary['raw_sha256']=manifest['raw_sha256']
        (output/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
        print(json.dumps(summary,indent=2))
    except (ValueError,OSError,subprocess.TimeoutExpired) as error:
        (output/'summary.json').write_text(json.dumps(dict(status='FAIL',error=str(error)),indent=2)+'\n')
        print(error,file=sys.stderr)
        return 1
    return 0

if __name__=='__main__':
    sys.exit(main())
