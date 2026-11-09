#!/usr/bin/env python3
"""Inject corrupted/empty evidence into the actual summarizer after a real run."""
import copy
import importlib.util
import json
import pathlib
import sys

ROOT=pathlib.Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('acquire_shot',ROOT/'tools/acquire_shot.py')
module=importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
raw=json.loads(pathlib.Path(sys.argv[1]).read_text())
module.summarize(raw)
def reviewer_bad_event_clocks(result):
    for event in result['events']:
        event['tick'] = -999
    for record in result['records']:
        record.pop('wall_usec', None)
        record.pop('simulation_seconds', None)


def reviewer_short_native(result):
    cut = next(r for r in result['native_records'] if r['kind'] == 'event')['tick'] + 10
    result['native_records'] = [r for r in result['native_records'] if r['tick'] <= cut]
    result['native_ticks'] = cut
    result['native_terminal'] = [r for r in result['native_records'] if r['kind'] == 'state'][-1]['payload']['balls']


def partial_native_with_termination(result, reason):
    termination=copy.deepcopy(result['native_termination'])
    reviewer_short_native(result)
    termination.update(tick=result['native_ticks'],reason=reason)
    record=copy.deepcopy(result['native_records'][-1])
    record.update(kind='termination',payload=termination)
    result['native_records'].append(record)
    result['native_termination']=copy.deepcopy(termination)


def change_termination(result, **values):
    result['native_termination'].update(values)
    result['native_records'][-1]['payload'].update(values)


cases={
    'empty':lambda r:r.clear(),
    'reviewer invalid event ticks and missing clocks':reviewer_bad_event_clocks,
    'reviewer terminal identity 99':lambda r:r['terminal'][0].__setitem__(0,99),
    'terminal/sample mismatch':lambda r:r['terminal'][0].__setitem__(2,.123),
    'initial/fixture mismatch':lambda r:r['initial'][0].__setitem__(2,.123),
    'missing wall timestamp':lambda r:r['records'][0].pop('wall_usec'),
    'missing simulation timestamp':lambda r:r['records'][0].pop('simulation_seconds'),
    'invalid simulation clock':lambda r:r['records'][0].update(simulation_seconds=999),
    'invalid event tick only':lambda r:r['events'][0].update(tick=-999),
    'invalid event trace tick':lambda r:next(x for x in r['records'] if x['kind']=='event')['payload']['event'].update(tick=-999),
    'invalid event trace time':lambda r:next(x for x in r['records'] if x['kind']=='event')['payload'].update(event_tick_seconds=999),
    'duplicate inventory identity':lambda r:r['terminal'][1].__setitem__(0,0),
    'invalid phase':lambda r:r['terminal'][0].__setitem__(15,99),
    'invalid orientation':lambda r:r['terminal'][0].__setitem__(14,0),
    'malformed terminal':lambda r:r.update(terminal=['bad']*16),
    'nonfinite terminal':lambda r:r['terminal'][0].__setitem__(2,float('nan')),
    'missing sampled inventory':lambda r:r['records'][0]['payload'].pop('balls'),
    'nested missing':lambda r:r['fixture'].pop('ticks'),
    'wrong fixture type':lambda r:r.update(fixture=[]),
    'wrong record type':lambda r:r.update(records=[None]),
    'nonfinite ticks':lambda r:r['fixture'].update(ticks=float('inf')),
    'string ticks':lambda r:r['fixture'].update(ticks='1440'),
    'wrong event type':lambda r:r.update(events=[None]),
    'failed':lambda r:r.update(status='FAIL'),
    'empty states':lambda r:r.update(records=[]),
    'missing initial':lambda r:r.update(initial=[]),
    'missing event':lambda r:r.update(events=[]),
    'incomplete ticks':lambda r:r['records'].pop(0),
    'missing timings':lambda r:r.update(paired_replay_timings=[]),
}
for field in ('plain_usec','traced_usec'):
    for label, value in [('nan',float('nan')),('infinity',float('inf')),('negative',-1),('zero',0),('boolean',True),('string','100')]:
        cases[f'invalid overhead {field} {label}']=lambda r,f=field,v=value:r['paired_replay_timings'][0].update({f:v})
cases['extra timing pair']=lambda r:r['paired_replay_timings'].append(r['paired_replay_timings'][0].copy())
cases['infinite overhead ratio']=lambda r:r['paired_replay_timings'][0].update(plain_usec=1e-300,traced_usec=1e300)
if raw.get('native'):
    cases['reviewer shortened native trajectory']=reviewer_short_native
    cases['partial native horizon with termination']=lambda r:partial_native_with_termination(r,'horizon')
    cases['partial native settled with moving state']=lambda r:partial_native_with_termination(r,'settled')
    cases['missing termination']=lambda r:r.pop('native_termination')
    cases['native timeout']=lambda r:change_termination(r,reason='timeout')
    cases['native elapsed deadline']=lambda r:change_termination(r,elapsed_wall_usec=12000000)
    cases['false early settled']=lambda r:change_termination(r,reason='settled',controller_moving=False,balls_settled=True)
    cases['native final sample mismatch']=lambda r:r['native_terminal'][0].__setitem__(2,.123)
    cases['native missing wall clock']=lambda r:r['native_records'][0].pop('wall_usec')
    cases['empty native']=lambda r:r.update(native_records=[])
    cases['native missing event']=lambda r:r.update(native_records=[x for x in r['native_records'] if x['kind'] != 'event'])
    cases['native missing frames']=lambda r:r.update(native_records=[x for x in r['native_records'] if x['kind'] not in ['frame_process','frame_post_draw']])
for name,mutate in cases.items():
    changed=copy.deepcopy(raw)
    mutate(changed)
    try:
        module.summarize(changed)
    except (ValueError,KeyError,TypeError):
        print('PASS rejected '+name)
    else:
        raise AssertionError('accepted '+name)
print(f'NEGATIVE EVIDENCE: {len(cases)} corrupt acquisitions rejected')

# A backwards wall clock is preserved and reported; simulation ticks remain intact.
changed=copy.deepcopy(raw)
changed['records'][1]['wall_usec']=max(0,changed['records'][0]['wall_usec']-1)
assert module.summarize(changed)['replay_clocks']['backwards_intervals']
print('PASS preserved and reported backwards replay clock')
if raw.get('native'):
    changed=copy.deepcopy(raw)
    frames=[r for r in changed['native_records'] if r['kind']=='frame_process']
    frames[1]['wall_usec']=max(0,frames[0]['wall_usec']-1)
    assert module.summarize(changed)['frame_process']['backwards_intervals']
    print('PASS preserved and reported backwards native frame clock')
