#!/usr/bin/env python3
"""Independent kinetic-energy accounting, not a copy of the strike-speed equation.

Use the declared solid-sphere mass/radius, complete measured launch v/omega, and
incoming cue kinetic energy. This checks the resting, level matrix only; it does
not observe outgoing cue momentum, contact duration or calibrated equipment.
"""
import json
import math
from pathlib import Path
import sys

run=Path(sys.argv[1])
rows=[json.loads(line) for line in (run/'launch/raw.jsonl').read_text().splitlines()]
rows=[r for r in rows if r.get('kind')=='result' and not r['id'].startswith('outside')]
assert len(rows)==410
mass=.168; radius=.028575; inertia=2/5*mass*radius**2
checks=[]
for row in rows:
    s=row['launch'][0]
    measured=.5*mass*sum(x*x for x in s[5:8])+.5*inertia*sum(x*x for x in s[8:11])
    incoming=.5*.52*row['cue_speed_m_s']**2
    bound=incoming+max(1e-9,1e-6*incoming)
    checks.append(dict(id=row['id'],measured_ball_energy_J=measured,incoming_cue_energy_J=incoming,
                       bound_J=bound,status='PASS' if math.isfinite(measured) and measured<=bound else 'FAIL',
                       instrument_energy_residual_J=measured-row['launch_energy_J']))
report=dict(scope=__doc__,checks=len(checks),failures=sum(c['status']=='FAIL' for c in checks),
            max_instrument_energy_residual_J=max(abs(c['instrument_energy_residual_J']) for c in checks),rows=checks)
print(json.dumps(report,indent=2,allow_nan=False))
sys.exit(1 if report['failures'] else 0)
