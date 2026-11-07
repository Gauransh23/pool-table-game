#!/usr/bin/env python3
"""Frozen active-model atlas. Exit 0 = valid measurement, 1 = harness invalid, 2 = strict product FAIL.

Unique output directories and incomplete manifests preserve interrupted runs. Each family is a
resumable bounded chunk; --resume verifies fixture/source hashes before using completed chunks.
"""
import argparse
import collections
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
SCHEMA = 'long-rail-power-atlas/1'
PROFILE = dict(fixed_step=1/480, gravity=9.81, ball_mass=.168, ball_restitution=.94,
    ball_friction=.055, cushion_restitution=.84, cushion_friction=.12,
    sliding_friction=.19, rolling_resistance=.012, spinning_friction=.0127,
    sleep_speed_threshold=.012, sleep_spin_threshold=.08, max_speed=14.,
    max_substep_travel_fraction=.45, max_collision_iterations=6, cue_mass=.52,
    cue_collision_efficiency=.87, cue_end_mass=.008, pocket_liner_restitution=.2)
REQUIREMENTS = ['PWR-001','PWR-002','PWR-003','PWR-004','PWR-005','PWR-006',
                'CUE-001','CUE-002','CUE-003','CUE-004','CUE-005','CUE-006','CUE-007',
                'CLT-001','CLT-002','CLT-003','CLT-004','CLT-005','CLT-006','CLT-007']
TIPS = dict(center=[0,0], follow=[0,.45], draw=[0,-.45], right=[.45,0], left=[-.45,0])
ANCHORS = [1,10,20,40,80,120,160,200]


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',',':'), allow_nan=False)


def sha(value):
    return hashlib.sha256(value).hexdigest()


def digest(path):
    return sha(path.read_bytes())


def write(path, value):
    with path.open('w') as file:
        file.write(json.dumps(value, indent=2, allow_nan=False)+'\n')
        file.flush()
        os.fsync(file.fileno())


def state(identity=0, x=0, z=0):
    return [identity,identity,x,z,.028575,0,0,0,0,0,0,0,0,0,1,0,-1]


def fixture(identity, family, power, tip, **overrides):
    f=dict(schema='long-rail-power-atlas-fixture/1', id=identity, family=family,
        domain=('direct cue-speed matrix; power placeholder unused' if family=='launch' else ('ideal pure rolling initial ball speed' if family=='rolling' else 'level resting-ball active default model')), profile=PROFILE,
        mapping='floor-quadratic-v1', power=power, power_tick=round(power*200),
        cue_speed=0 if power==0 else .075+7.925*power*power,
        tip=tip, direction=[1,0], elevation=0, half_size=[10000,10000],
        balls=[state()], ticks=40000, termination='rest', modality='direct',
        event_policy=dict(required=[], observed='report any; no contact is a valid scout outcome'),
        oracle=dict(kind='model measurement; analytic comparison separate', bounds=None),
        requirements=REQUIREMENTS, trace=False)
    f.update(overrides)
    return f


def fixtures():
    result=[]
    for name, tip in TIPS.items():
        for tick in range(201):
            result.append(fixture(f'free-{name}-{tick:03}', 'free',tick/200,tip,
                modality='controller' if name=='center' else 'direct',
                controller_probe=name!='center' and tick in ANCHORS,
                trace=(name=='center' and tick in [1,20,27,28,38,47,200]) or
                      (name in ['draw','right','left'] and tick==20)))
    tips=[[0,0]]+[[r*math.cos(a*math.tau/8),r*math.sin(a*math.tau/8)]
                   for r in [.1,.25,.45,.49,.50] for a in range(8)]
    for si,speed in enumerate([0,.05,.1,.2,.5,1,2,4,6,8]):
        for ti,tip in enumerate(tips):
            result.append(fixture(f'launch-{si:02}-{ti:02}','launch',0,tip,
                                  cue_speed=speed,ticks=0,termination='launch'))
    for a in range(8):
        result.append(fixture(f'outside-{a}','launch',.5,
            [.50001*math.cos(a*math.tau/8),.50001*math.sin(a*math.tau/8)],
            ticks=0,termination='launch', expected_rejection=True))
    for heading in [30,60,90]:
        # Validate nominal ray against the actual top straight-rail extent. At
        # 90 degrees this requested fixture targets the side-pocket opening.
        cue_x=-.30 if heading==90 else 0
        x=cue_x+(.635-.028575-.30)/math.tan(math.radians(heading))
        straight=.129/2 < abs(x) < 1.27-.116/math.sqrt(2)
        for p in [.1,.25,1.]:
            for name in ['center','right','left','draw']:
                result.append(fixture(f'rail-{heading}-{p}-{name}','rail',p,TIPS[name],
                    direction=[math.cos(math.radians(heading)),math.sin(math.radians(heading))],
                    half_size=[1.27,.635],balls=[state(x=cue_x,z=.30)],ticks=960,termination='horizon',
                    fixture_revision='90deg cue x=-.30 to hit straight rail; lead ruling 2026-11-07',
                    nominal_top_intersection_x_m=x, nominal_geometry='straight' if straight else 'side-pocket-axis',
                    trace=p==1 and heading==60 and name=='right'))
    for distance in [.1,.5,1.]:
        for p in [.1,.25,1.]:
            for name,tip in TIPS.items():
                result.append(fixture(f'object-{distance}-{p}-{name}','object',p,tip,
                    half_size=[1.27,.635],balls=[state(x=.25-distance,z=.20),state(1,x=.25,z=.20)],
                    ticks=960,termination='horizon',object_center_distance_m=distance,
                    trace=distance==.5 and p==1 and name in ['center','follow','draw']))
    for speed in [.01,.05,.2,1.,3.,8.,14.]:
        s=state(); s[5]=speed; s[10]=-speed/.028575
        result.append(fixture(f'rolling-{speed}','rolling',0,[0,0],balls=[s],ticks=0 if speed==0 else 60000,
                              trace=speed in [.01,1.], oracle=dict(kind='independent constant rolling resistance',
                              speed_m_s=speed,relative_bound=.001,absolute_distance_m=1e-6,absolute_time_s=1e-6)))
    return result


def finite(value):
    if isinstance(value,float): return math.isfinite(value)
    if isinstance(value,list): return all(finite(v) for v in value)
    if isinstance(value,dict): return all(finite(v) for v in value.values())
    return True


def validate(fixtures_):
    if not isinstance(fixtures_,list) or not fixtures_: raise ValueError('empty fixture set')
    ids=set()
    for f in fixtures_:
        if not isinstance(f,dict) or not finite(f): raise ValueError('malformed/nonfinite fixture')
        if f.get('schema')!='long-rail-power-atlas-fixture/1' or f.get('profile')!=PROFILE:
            raise ValueError('fixture schema/profile mismatch')
        if not f.get('id') or f['id'] in ids: raise ValueError('empty/duplicate fixture identity')
        ids.add(f['id'])
    return ids


def numeric_equal(a,b):
    # Godot JSON parsing/printing may round a double by a few ulps. This
    # tolerance is serialization-only; exact same-build physical replay below
    # still compares every recorded number without tolerance.
    if isinstance(a,(float,int)) and isinstance(b,(float,int)):
        return math.isclose(a,b,rel_tol=2e-15,abs_tol=1e-15)
    if isinstance(a,list) and isinstance(b,list):
        return len(a)==len(b) and all(numeric_equal(x,y) for x,y in zip(a,b))
    return a==b


def read_chunk(path, expected):
    lines=[json.loads(line) for line in (path/'raw.jsonl').read_text().splitlines()]
    if not lines or lines[0].get('kind')!='runtime' or lines[-1].get('kind')!='completion':
        raise ValueError('missing runtime/completion marker')
    if lines[-1].get('errors')!=[] or lines[-1].get('fixtures')!=len(expected):
        raise ValueError('incomplete/failed engine run')
    if lines[0].get('profile')!=PROFILE: raise ValueError('wrong runtime profile')
    rows=[r for r in lines if r.get('kind')=='result']
    if [r['id'] for r in rows]!=[f['id'] for f in expected]: raise ValueError('missing/duplicate/order fixture rows')
    for f,r in zip(expected,rows):
        if not finite(r) or not r['finite'] or r['observer_overflow']: raise ValueError('nonfinite/overflow result')
        if r.get('status')!='MEASURED' or not numeric_equal(r['cue_speed_m_s'],f['cue_speed']) or not numeric_equal(r['direction'],f['direction']) or not numeric_equal(r['tip_requested'],f['tip']):
            raise ValueError('input/result mismatch')
        if f.get('expected_rejection') and r['accepted']: raise ValueError('outside-tip accepted')
        if not numeric_equal(r['initial'],f['balls']) or len(r['launch'])!=len(f['balls']) or len(r['terminal'])!=len(f['balls']):
            raise ValueError('initial/inventory disagreement')
        for states in (r['launch'],r['terminal']):
            for index,s in enumerate(states):
                if len(s)!=17 or s[0]!=f['balls'][index][0] or s[1]!=s[0]: raise ValueError('invalid canonical state')
                if not math.isclose(sum(q*q for q in s[11:15]),1,abs_tol=2e-5): raise ValueError('invalid orientation')
        if r['ticks']>f['ticks'] or not math.isclose(r['simulation_s'],r['ticks']*PROFILE['fixed_step'],abs_tol=1e-8):
            raise ValueError('clock/cap disagreement')
        if r['termination']=='cap': raise ValueError('free/rolling run did not settle')
        if f['modality']=='controller' and not math.isclose(r['hud_readback'],f['power'],abs_tol=1e-12):
            raise ValueError('HUD quantization mismatch')
        for e in r['events']:
            if not 1<=e['event']['tick']<=r['ticks'] or e['event']['kind'] not in ['ball_contact','rail','pocket','off_table']:
                raise ValueError('invalid event')
            if not isinstance(e['event'].get('position'),list) or len(e['event']['position'])!=2:
                raise ValueError('event position must be a numeric planar vector')
    # Full traces must be present for precisely the named fixtures, with no gaps.
    trace_counts=collections.Counter()
    with (path/'traces.jsonl').open() as trace_file:
        for line in trace_file:
            item=json.loads(line); identity=item['id']
            if item['tick']!=trace_counts[identity]: raise ValueError('trace gap/duplicate')
            if not finite(item): raise ValueError('nonfinite trace')
            trace_counts[identity]+=1
            row=next((r for r in rows if r['id']==identity),None)
            if row is None: raise ValueError('trace identity absent')
            if item['tick']==0 and item['states']!=row['launch']: raise ValueError('trace launch mismatch')
            if item['tick']==row['ticks'] and item['states']!=row['terminal']: raise ValueError('trace terminal mismatch')
    expected_traces={r['id']:r['ticks']+1 for r in rows if r['trace']}
    if dict(trace_counts)!=expected_traces: raise ValueError('missing/truncated trace')
    return rows,lines[0],lines


def analytic(row):
    """Independent uniform-sphere vector slip impulse + constant rolling resistance.

    u=v+omega cross contact radius. Coulomb impulse changes translation by
    -(2/7)u and spin by the complementary torque, so du/dt=-(7/2)mu*g*u_hat.
    This assumes exact transition splitting and ignores the active sleep threshold.
    """
    s=row['launch'][0]; v=(s[5],s[6]); u=(v[0]+.028575*s[10],v[1]-.028575*s[8])
    um=math.hypot(*u); ts=2*um/(7*.19*9.81)
    vr=tuple(v[i]-2*u[i]/7 for i in range(2))
    xs=tuple(v[i]*ts-(.5*.19*9.81*u[i]/um*ts*ts if um else 0) for i in range(2))
    speed=math.hypot(*vr); tr=speed/(.012*9.81)
    end=tuple(xs[i]+(vr[i]*speed/(2*.012*9.81) if speed else 0) for i in range(2))
    error=math.dist(row['net_displacement_m'],end)
    interval=row['first_roll_interval']
    sampled_t=None if interval is None else interval['time_interval_s'][1]
    transition_error=None if sampled_t is None or not ts else abs(sampled_t-ts)
    # Do not widen the original 0.1% requirement to hide tick quantization.
    return dict(id=row['id'],assumptions='level homogeneous sphere; fixed Coulomb slide; exact split; constant rolling resistance; no sleep',
        initial_slip_m_s=list(u),slide_time_s=ts,slide_displacement_m=list(xs),roll_velocity_m_s=list(vr),
        roll_time_s=tr,endpoint_m=list(end),endpoint_error_m=error,
        endpoint_bound_m=max(1e-6,.001*math.hypot(*end)),
        endpoint_status='PASS' if error<=max(1e-6,.001*math.hypot(*end)) else 'FAIL',
        stopping_time_s=ts+tr,readiness_time_error_s=abs(row['simulation_s']-(ts+tr)),
        stopping_time_bound_s=max(1e-6,.001*(ts+tr)),
        stopping_time_status='PASS' if abs(row['simulation_s']-(ts+tr))<=max(1e-6,.001*(ts+tr)) else 'FAIL',
        sampled_transition_time_s=sampled_t,transition_time_error_s=transition_error,
        transition_bound_s=max(1e-6,.001*ts),
        transition_status='NOT_APPLICABLE' if not ts else ('NOT_RUN' if sampled_t is None else
            ('PASS' if transition_error<=max(1e-6,.001*ts) else 'FAIL')))


def summarize(rows, fs):
    byid={r['id']:r for r in rows}
    center=sorted((r for r in rows if r['id'].startswith('free-center')),key=lambda r:r['power_tick'])
    distances=[math.hypot(*r['net_displacement_m']) for r in center]
    nearest=[]; gaps=[]
    for target in [.05,.1,.2,.5,1.]:
        i=min(range(len(center)),key=lambda j:abs(distances[j]-target)); error=distances[i]-target; bound=max(.002,.01*target)
        nearest.append(dict(target_m=target,id=center[i]['id'],power=center[i]['requested_power'],actual_m=distances[i],
                            signed_error_m=error,bound_m=bound,status='PASS' if abs(error)<=bound else 'FAIL'))
    for a,b,da,db in zip(center,center[1:],distances,distances[1:]):
        in_band=.02<=da<=.2 and .02<=db<=.2
        gaps.append(dict(a=a['id'],b=b['id'],gap_m=db-da,slope_m_per_unit_power=(db-da)/.005,
                         soft_band=in_band,status=('FAIL' if db-da>.002 else 'PASS') if in_band else 'OUT_OF_SCOPE'))
    failures=[g for g in gaps if g['status']=='FAIL']
    energies=[dict(id=r['id'],ball_energy_J=r['launch_energy_J'],cue_input_J=r['cue_input_energy_J'],
        bound_J=r['energy_bound_J'],status='PASS' if r['launch_energy_J']<=r['energy_bound_J'] else 'FAIL')
        for r in rows if r['family']=='launch' and not r['id'].startswith('outside')]
    oracles=[analytic(r) for r in rows if r['family']=='rolling' or r['id'] in
             ['free-center-001','free-center-020','free-center-040','free-center-200','free-follow-020','free-draw-020']]
    contact_map=[]
    for r in rows:
        if r['family'] in ['rail','object']:
            kinds=[e['event']['kind'] for e in r['events']]
            contact_map.append(dict(id=r['id'],first_event=kinds[0] if kinds else 'none',
                event_counts=dict(collections.Counter(kinds)),first_ball_contact=r['first_ball_contact'],first_rail_event=r['first_rail_event'],rail_classification=r['rail_classification'],
                cue_signed_travel_after_contact_m=r['cue_signed_travel_after_contact_m'],cue_object_classification=r['cue_object_classification'],
                termination=r['termination'],terminal_phases=[s[15] for s in r['terminal']],
                geometry=next(f.get('nominal_geometry','object line') for f in fs if f['id']==r['id'])))
    signed=[]
    for tick in ANCHORS:
        right=byid[f'free-right-{tick:03}']; left=byid[f'free-left-{tick:03}']
        signed.append(dict(power_tick=tick,endpoint_right_m=right['net_displacement_m'],endpoint_left_m=left['net_displacement_m'],
            mirror_position_error_m=math.hypot(right['net_displacement_m'][0]-left['net_displacement_m'][0],
                                             right['net_displacement_m'][1]+left['net_displacement_m'][1]),
            axial_spin_transform='reflect world z: (-wx,-wy,wz)'))
    ledger={r:dict(status='NOT_RUN',scope='physical calibration/native delivery/human acceptance not established by C0') for r in REQUIREMENTS}
    ledger['PWR-001']=dict(status='PASS',scope='units and frozen mapping identity in level source atlas; cue speed, impulse, launch energy separately stored')
    ledger['PWR-002']=dict(status='INCONCLUSIVE' if .01<=distances[1]<=.03 and all(d>0 for d in distances[1:]) else 'FAIL',
        scope='all 201 HUD/controller callbacks; committed launch replayed on no-contact diagnostic table; manual tween clock, zero sound not independently captured')
    ledger['PWR-003']=dict(status='FAIL' if failures or any(r['status']=='FAIL' for r in nearest) else 'PASS',scope='all 201 reachable machine inputs; no human inference')
    ledger['PWR-004']=dict(status='PASS' if all(a<b for a,b in zip(distances,distances[1:])) else 'FAIL',scope='center free response; 8m/s maximum preserved; contact maps categorical')
    ledger['CUE-001']=dict(status='FAIL' if any(e['status']=='FAIL' for e in energies) else 'INCONCLUSIVE',scope='410 level resting-ball launches only; outgoing cue unobserved; moving-ball probe unsupported')
    ledger['CLT-001']=dict(status='FAIL' if any(o['endpoint_status']=='FAIL' or o['stopping_time_status']=='FAIL' for o in oracles if o['id'].startswith('rolling')) else 'INCONCLUSIVE',scope='7 ideal pure-rolling speed endpoints; original 0.1% bound with 1um absolute floor; time/kinematics obligations remain open')
    ledger['CLT-002']=dict(status='FAIL' if any(o['transition_status']=='FAIL' for o in oracles) else 'INCONCLUSIVE',scope='sampled transition-time comparisons only; first/last stable crossings retained; exact transition roots unavailable')
    return dict(schema=SCHEMA,status='COMPLETE',measurement_kind='active-model machine evidence; not calibrated physical/human evidence',
        fixture_counts=dict(collections.Counter(r['family'] for r in rows)),nearest_targets=nearest,adjacent_gaps=gaps,
        soft_band_states=sum(.02<=d<=.2 for d in distances),soft_band_pairs=sum(g['soft_band'] for g in gaps),
        center_zero_to_first_jump_m=distances[1]-distances[0],
        minimum_center_distance_m=distances[1],maximum_center_distance_m=distances[-1],
        center_launch_strictly_increasing=all(math.hypot(a['launch'][0][5],a['launch'][0][6])<math.hypot(b['launch'][0][5],b['launch'][0][6]) for a,b in zip(center,center[1:])),
        gap_violations=len(failures),nearest_target_failures=sum(r['status']=='FAIL' for r in nearest),
        product_resolution_failures=len(failures)+sum(r['status']=='FAIL' for r in nearest),
        energy_ledger=energies,analytic_comparisons=oracles,signed_spin=signed,contact_map=contact_map,
        no_contact_count=sum(c['first_event']=='none' for c in contact_map),
        horizon_limited_count=sum(not r['endpoint_to_rest'] for r in rows if r['family'] in ['rail','object']),
        total_ticks=sum(r['ticks'] for r in rows),simulation_s=sum(r['simulation_s'] for r in rows),
        fixture_wall_s=sum(r['wall_usec'] for r in rows)/1e6,scope_ledger=ledger)


def plots(output, rows):
    """Dependency-free SVGs; plot vertices are derived only after raw JSONL persists."""
    def plot(name, series, xlabel, ylabel):
        points=[p for _,values in series for p in values]
        xmax=max(p[0] for p in points) or 1; ymax=max(p[1] for p in points) or 1
        colors=['#174a7e','#c24b35','#2d8051','#8e56a0','#b87a09']
        pieces=['<svg xmlns="http://www.w3.org/2000/svg" width="920" height="480" viewBox="0 0 920 480">',
            '<rect width="920" height="480" fill="white"/>',
            f'<text x="55" y="25">{name}: active model measurement</text>',
            '<path d="M60 45V420H780" fill="none" stroke="black"/>',
            f'<text x="360" y="465">{xlabel} (0 to {xmax:.4g})</text>',
            f'<text x="65" y="445">{ylabel}: 0 to {ymax:.5g}</text>']
        for i,(label,values) in enumerate(series):
            coords=' '.join(f'{60+720*x/xmax:.3f},{420-360*y/ymax:.3f}' for x,y in values)
            pieces.append(f'<polyline points="{coords}" fill="none" stroke="{colors[i%5]}" stroke-width="1.5"/>')
            pieces.append(f'<text x="790" y="{65+22*i}" fill="{colors[i%5]}">{label}</text>')
        pieces.append('</svg>'); (output/(name+'.svg')).write_text('\n'.join(pieces))
    families=[]
    for name in TIPS:
        rs=sorted((r for r in rows if r['id'].startswith('free-'+name+'-')),key=lambda r:r['power_tick'])
        families.append((name,rs))
    plot('launch-speed',[(n,[(r['requested_power'],math.hypot(r['launch'][0][5],r['launch'][0][6])) for r in rs]) for n,rs in families], 'power fraction','ball speed m/s')
    plot('cue-speed',[('cue',[(r['requested_power'],r['cue_speed_m_s']) for r in families[0][1]])],'power fraction','cue speed m/s')
    plot('launch-spin',[(n,[(r['requested_power'],math.sqrt(sum(w*w for w in r['launch'][0][8:11]))) for r in rs]) for n,rs in families],'power fraction','angular speed rad/s')
    plot('free-distance',[(n,[(r['requested_power'],math.hypot(*r['net_displacement_m'])) for r in rs]) for n,rs in families],'power fraction','endpoint distance m')
    plot('soft-distance',[(n,[(r['requested_power'],1000*math.hypot(*r['net_displacement_m'])) for r in rs if math.hypot(*r['net_displacement_m'])<=.2]) for n,rs in families],'power fraction','endpoint distance mm')
    plot('settling-time',[(n,[(r['requested_power'],r['simulation_s']) for r in rs]) for n,rs in families],'power fraction','time to readiness s')
    plot('slide-roll-time',[(phase,[(r['requested_power'], (r['first_roll_interval']['time_interval_s'][1] if r['first_roll_interval'] else 0) if phase=='slide' else max(0,r['simulation_s']-(r['first_roll_interval']['time_interval_s'][1] if r['first_roll_interval'] else 0))) for r in families[0][1]]) for phase in ['slide','roll']],'power fraction','sampled center regime duration s')


def source_identity():
    paths=[p for top in ['scripts','scenes','assets'] for p in (ROOT/top).rglob('*') if p.is_file()]
    paths += [ROOT/'project.godot',ROOT/'tools/power_response_atlas.py',ROOT/'tests/power_response_atlas.gd',
              ROOT/'tests/measurement/power_atlas_fixture.gd',ROOT/'tests/measurement/shot_fixture.gd']
    return {str(p.relative_to(ROOT)):digest(p) for p in sorted(paths)}


def run_chunk(directory, selected, resume=False):
    validate(selected)
    directory.mkdir(exist_ok=True)
    fp=directory/'fixtures.json'
    if resume and (directory/'complete.json').exists():
        if json.loads(fp.read_text())!=selected: raise ValueError('resume fixture mismatch')
        rows,runtime,_=read_chunk(directory,selected)
        stored=json.loads((directory/'complete.json').read_text())
        if any(digest(directory/p)!=v for p,v in stored.items()): raise ValueError('resume artifact mismatch')
        return rows,runtime
    if (directory/'raw.jsonl').exists():
        raise ValueError('interrupted chunk retained; use a new output directory (completed chunks resumable)')
    write(fp,selected)
    command=['bash','tools/godot.sh','--headless','--path',str(ROOT),'--script','tests/power_response_atlas.gd','--',
             '--fixtures='+str(fp),'--output='+str(directory)]
    try:
        result=subprocess.run(command,cwd=ROOT,capture_output=True,text=True,timeout=120)
    except subprocess.TimeoutExpired as exc:
        (directory/'engine.log').write_text((exc.stdout or b'').decode()+(exc.stderr or b'').decode())
        raise ValueError('120s watchdog; incomplete artifacts retained') from exc
    (directory/'engine.log').write_text(result.stdout+result.stderr)
    if result.returncode or 'SCRIPT ERROR' in result.stdout+result.stderr:
        raise ValueError('engine error: '+str(directory/'engine.log'))
    rows,runtime,_=read_chunk(directory,selected)
    write(directory/'complete.json',{p:digest(directory/p) for p in ['fixtures.json','raw.jsonl','traces.jsonl']})
    return rows,runtime


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--smoke',action='store_true',help='small integrity/controller subset; no complete atlas claim')
    parser.add_argument('--resume',action='store_true')
    parser.add_argument('--strict',action='store_true')
    args=parser.parse_args()
    output=args.output.resolve(); started=time.time()
    try:
        fs=fixtures(); validate(fs)
        if args.smoke:
            ids={'free-center-000','free-center-001','free-center-020','free-center-040','free-center-200',
                 'free-right-020','free-left-020','object-0.5-1.0-draw','rail-60-1.0-right','rolling-1.0','outside-0'}
            fs=[f for f in fs if f['id'] in ids]
        if args.resume:
            manifest=json.loads((output/'manifest.json').read_text())
            if manifest['source_sha256']!=source_identity() or manifest['fixtures_sha256']!=sha(canonical(fs).encode()):
                raise ValueError('resume source/fixture identity mismatch')
        else:
            output.mkdir(parents=True,exist_ok=False)
            manifest=dict(schema=SCHEMA,run_id=output.name,status='INCOMPLETE',started_utc=time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),
                baseline_head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
                dirty_summary=subprocess.check_output(['git','status','--short'],cwd=ROOT,text=True),
                source_sha256=source_identity(),fixtures_sha256=sha(canonical(fs).encode()),
                fixture_schema='long-rail-power-atlas-fixture/1',mapping_identity='floor-quadratic-v1',
                profile=PROFILE,profile_sha256=sha(canonical(PROFILE).encode()),requirements=REQUIREMENTS,
                units=dict(distance='m',time='s',mass='kg',spin='rad/s',angles='rad',energy='J',impulse='N s',planar_axes='x,z'),
                rng='active physics seedless; cosmetic stream excluded',host=dict(os=platform.platform(),architecture=platform.machine()),
                oracle_identity='uniform solid sphere vector Coulomb slide; exact transition split; constant rolling resistance',
                artifact='headless source run; controller tween manually advanced; no native/human evidence',
                cli=sys.argv,per_process_watchdog_s=120,worst_free_ticks=1005*40000,smoke=args.smoke)
            write(output/'manifest.json',manifest)
        rows=[]; runtime=[]
        for group in ['center','follow','draw','right','left','launch','rail','object','rolling']:
            selected=[f for f in fs if f['id'].startswith('free-'+group+'-') or (f['family']==group and group not in TIPS)]
            if not selected: continue
            print('chunk',group,len(selected),flush=True)
            rs,rt=run_chunk(output/group,selected,args.resume); rows.extend(rs); runtime.append(rt)
        # A small named replay proves snapshots/events/regime metrics, excluding clocks.
        repeat_ids={'free-center-001','free-center-020','free-center-040','free-center-200','free-right-020','free-left-020','object-0.5-1.0-draw','rail-60-1.0-right'}
        repeated=[dict(f,trace=False) for f in fs if f['id'] in repeat_ids]
        rr,_=run_chunk(output/'repeat',repeated,args.resume)
        hashes=[]
        for r in rr:
            base=next(b for b in rows if b['id']==r['id'])
            fields=['launch','terminal','events','regime_changes','ticks','path_length_m','translation_rest_s','spin_rest_s','readiness_s']
            a={k:base[k] for k in fields}; b={k:r[k] for k in fields}
            if a!=b: raise ValueError('same-build repeat mismatch: '+r['id'])
            hashes.append(dict(id=r['id'],sha256=sha(canonical(a).encode())))
        # Matched trace-on/off runs, not extrapolated to native-frame performance.
        timing_fixture=next(f for f in fs if f['id']=='free-center-020')
        pairs=[]
        for i in range(3):
            pair=[]
            for enabled in [False,True]:
                rs,_=run_chunk(output/f'overhead-{i}-{int(enabled)}',[dict(timing_fixture,trace=enabled)],args.resume)
                pair.append(rs[0]['wall_usec'])
            pairs.append(dict(plain_usec=pair[0],traced_usec=pair[1],ratio=pair[1]/max(1,pair[0])))
        if len(rows)!=len(fs): raise ValueError('empty/incomplete full run')
        summary=dict(status='SMOKE_COMPLETE',fixture_counts=dict(collections.Counter(r['family'] for r in rows))) if args.smoke else summarize(rows,fs)
        summary.update(repeat_hashes=hashes,paired_trace_overhead=pairs,wall_s=time.time()-started)
        if not args.smoke: plots(output,rows)
        write(output/'summary.json',summary)
        # Validate source identity again, preventing mixed-source chunk qualification.
        if manifest['source_sha256']!=source_identity(): raise ValueError('source changed during atlas')
        manifest.update(status='SMOKE_COMPLETE' if args.smoke else 'COMPLETE',completed_utc=time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),
                        runtime=runtime,artifact_sha256={str(p.relative_to(output)):digest(p) for p in output.rglob('*') if p.is_file() and p.name!='manifest.json'})
        write(output/'manifest.json',manifest)
        print(json.dumps({k:summary[k] for k in ['status','fixture_counts','gap_violations','nearest_target_failures','total_ticks','wall_s'] if k in summary},indent=2))
        return 2 if args.strict and not args.smoke and any(v['status']=='FAIL' for v in summary['scope_ledger'].values()) else 0
    except (OSError,ValueError,KeyError,TypeError,subprocess.SubprocessError) as exc:
        if output.exists():
            write(output/'failure.json',dict(status='INVALID',reason=str(exc),wall_s=time.time()-started))
        print(str(exc),file=sys.stderr); return 1


if __name__=='__main__': sys.exit(main())
