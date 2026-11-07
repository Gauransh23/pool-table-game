#!/usr/bin/env python3
"""Postprocess the retained 410 level/resting cue-speed launches; no engine calls.

World axes x/right, y/up, z/planar second axis. A planar heading d defines cue
axis (dx,0,dz), side (-dz,0,dx), and up (0,1,0). Tip (a,b) is a radius ratio.
The sphere contact arm in meters is R*(-axis*sqrt(1-a*a-b*b)+side*a+up*b).
This is a geometric reconstruction, not a copy of the strike-speed equation.

Precision policy declared before evaluation: float-vector unit roundoff is
2^-24. Allow 2e-6 times max(|I*domega|, |r cross J|, R*|J|), about 34 unit
roundoffs, for the short normalized-frame/arm/impulse/cross-product chain and
stored float-vector rounding. A 1e-11 kg m^2/s absolute floor covers near-zero
components without normalizing by cancelling torque. This is a conservative
arithmetic consistency budget, NOT a physical calibration tolerance. No fit to
observed residuals is performed. Recorded impulses must also match m*dv with
the original metadata serialization allowance only.
"""
import argparse
import json
import math
from pathlib import Path
import sys
import power_response_atlas as atlas

MASS=.168
RADIUS=.028575
INERTIA=2/5*MASS*RADIUS**2
RELATIVE_BOUND=2e-6
ABSOLUTE_BOUND=1e-11


def norm(v): return math.sqrt(sum(x*x for x in v))
def cross(a,b): return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]


def check(row):
    atlas.require(row['family']=='launch' and row['elevation_radians']==0,'audit requires level launch matrix')
    before=row['initial'][0]; after=row['launch'][0]
    atlas.require(all(x==0 for x in before[5:11]),'audit requires initially resting ball')
    dx,dz=row['direction']; length=math.hypot(dx,dz)
    atlas.require(length>0,'audit zero direction')
    dx/=length; dz/=length
    a,b=row['tip_actual']; q=1-a*a-b*b
    atlas.require(q>=0,'audit tip outside sphere')
    inward=math.sqrt(q)
    arm=[RADIUS*(-dx*inward-dz*a),RADIUS*b,RADIUS*(-dz*inward+dx*a)]
    impulse=[MASS*(after[i]-before[i]) for i in [5,7,6]]
    atlas.require(atlas.numeric_equal(impulse,row['cue_impulse_Ns']),'recorded cue impulse disagrees with measured m*dv')
    angular_gain=[INERTIA*(after[i]-before[i]) for i in [8,9,10]]
    angular_impulse=cross(arm,impulse)
    residual=[a-b for a,b in zip(angular_gain,angular_impulse)]
    scale=max(norm(angular_gain),norm(angular_impulse),RADIUS*norm(impulse))
    bound=max(ABSOLUTE_BOUND,RELATIVE_BOUND*scale)
    return dict(id=row['id'],contact_arm_m=arm,measured_cue_impulse_Ns=impulse,
        angular_momentum_gain_kg_m2_s=angular_gain,contact_angular_impulse_kg_m2_s=angular_impulse,
        residual_kg_m2_s=residual,residual_norm_kg_m2_s=norm(residual),
        reference_scale_kg_m2_s=scale,bound_kg_m2_s=bound,
        status='PASS' if norm(residual)<=bound else 'FAIL')


def audit(run):
    manifest=json.loads((run/'manifest.json').read_text())
    atlas.require(manifest['status']=='COMPLETE','audit needs complete original acquisition')
    files=['launch/fixtures.json','launch/raw.jsonl','launch/traces.jsonl']
    for name in files:
        atlas.require(atlas.digest(run/name)==manifest['artifact_sha256'][name],'acquisition artifact hash mismatch')
    fixtures=json.loads((run/'launch/fixtures.json').read_text())
    rows,_,_=atlas.read_chunk(run/'launch',fixtures)
    selected=[r for r in rows if not r['id'].startswith('outside')]
    atlas.require(len(selected)==410,'audit requires the entire 410-launch matrix')
    results=[check(row) for row in selected]
    return dict(schema='long-rail-power-atlas-torque-audit/1',status='PASS' if all(r['status']=='PASS' for r in results) else 'FAIL',
        scope='410 level resting-ball direct cue-speed launches, including zero no-ops; arithmetic/geometric invariant only; physical calibration unproven',
        policy=__doc__,mass_kg=MASS,radius_m=RADIUS,inertia_kg_m2=INERTIA,
        relative_bound=RELATIVE_BOUND,absolute_bound_kg_m2_s=ABSOLUTE_BOUND,
        acquisition_manifest_sha256=atlas.digest(run/'manifest.json'),
        acquisition_artifact_sha256={name:atlas.digest(run/name) for name in files},
        acquisition_source_sha256=manifest['source_sha256'],
        postprocess_source_sha256={'tools/power_response_atlas.py':atlas.digest(Path(atlas.__file__)),
                                  'tools/power_atlas_torque_audit.py':atlas.digest(Path(__file__))},
        checks=len(results),failures=sum(r['status']=='FAIL' for r in results),
        max_residual_norm_kg_m2_s=max(r['residual_norm_kg_m2_s'] for r in results),
        max_bound_fraction=max(r['residual_norm_kg_m2_s']/r['bound_kg_m2_s'] for r in results),rows=results)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    if args.output.exists(): parser.error('new audit output path required')
    try:
        result=audit(args.run)
        atlas.write(args.output,result)
        print(json.dumps({k:result[k] for k in ['status','checks','failures','max_residual_norm_kg_m2_s','max_bound_fraction']}))
        return 0 if result['status']=='PASS' else 2
    except (OSError,ValueError,KeyError,TypeError) as exc:
        print(str(exc),file=sys.stderr); return 1


if __name__=='__main__': sys.exit(main())
