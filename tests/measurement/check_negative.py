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
cases={
    'empty':lambda r:r.clear(),
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
if raw.get('native'):
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
