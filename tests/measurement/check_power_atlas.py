#!/usr/bin/env python3
"""Atlas integrity: real GDScript fixture rejection and retained-output negative tests."""
import copy
import importlib.util
import io
from unittest.mock import patch
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('atlas',ROOT/'tools/power_response_atlas.py')
atlas=importlib.util.module_from_spec(spec); spec.loader.exec_module(atlas)

class AtlasIntegrity(unittest.TestCase):
    def test_fixed_counts_and_geometry(self):
        fs=atlas.fixtures(); self.assertEqual(len(fs),1511)
        self.assertEqual(sum(f['family']=='free' for f in fs),1005)
        self.assertEqual(sum(f['family']=='launch' and not f['id'].startswith('outside') for f in fs),410)
        self.assertEqual(sum(f['family']=='rail' for f in fs),36)
        self.assertEqual(sum(f['family']=='object' for f in fs),45)
        for f in fs:
            if f['family']=='rail':
                self.assertEqual(f['nominal_geometry'],'straight')
                self.assertGreater(abs(f['nominal_top_intersection_x_m']),.129/2)
                self.assertLess(abs(f['nominal_top_intersection_x_m']),1.27-.116/2**.5)

    def test_python_fixture_identity_rejection(self):
        f=atlas.fixtures()[0]
        for bad in [[],[f,f],[dict(f,profile={})],[dict(f,power=float('nan'))]]:
            with self.assertRaises(ValueError): atlas.validate(bad)

    def test_engine_fixture_rejection(self):
        f=atlas.fixtures()[0]
        bads=[[],[f,f],[dict(f,profile={})],[dict(f,ticks=40001)],
              [dict(f,direction=[0,0])],[dict(f,balls=[])]]
        moving=copy.deepcopy(f); moving['balls'][0][5]=.1; bads.append([moving])
        overlap=copy.deepcopy(f); overlap['balls']=[atlas.state(),atlas.state(1)]; bads.append([overlap])
        for i,bad in enumerate(bads):
            with self.subTest(i=i),tempfile.TemporaryDirectory() as temp:
                fp=Path(temp)/'fixtures.json'; atlas.write(fp,bad)
                result=subprocess.run(['bash','tools/godot.sh','--headless','--path',str(ROOT),
                    '--script','tests/power_response_atlas.gd','--','--fixtures='+str(fp),'--output='+temp],
                    cwd=ROOT,text=True,capture_output=True,timeout=15)
                self.assertEqual(result.returncode,1,result.stdout+result.stderr)
                self.assertIn('INVALID:',result.stderr)

    def test_write_failure_is_nonzero(self):
        with tempfile.TemporaryDirectory() as temp:
            fp=Path(temp)/'fixtures.json'; atlas.write(fp,[atlas.fixtures()[0]])
            result=subprocess.run(['bash','tools/godot.sh','--headless','--path',str(ROOT),
                '--script','tests/power_response_atlas.gd','--','--fixtures='+str(fp),
                '--output='+str(Path(temp)/'missing'/'child')],cwd=ROOT,text=True,capture_output=True,timeout=15)
            self.assertEqual(result.returncode,1)
            self.assertIn('cannot open atlas output',result.stderr)

    def test_preserved_product_counterexamples(self):
        directory=ROOT/'test-results/power-atlas-c0-20261107-final-v2'
        if not (directory/'summary.json').exists(): self.skipTest('complete documented full atlas first')
        report=json.loads((directory/'summary.json').read_text())
        self.assertEqual(report['gap_violations'],21)
        self.assertEqual(report['soft_band_pairs'],27)
        self.assertEqual(report['nearest_target_failures'],3)
        self.assertEqual([r['target_m'] for r in report['nearest_targets'] if r['status']=='FAIL'],[.2,.5,1.])
        self.assertEqual(report['scope_ledger']['PWR-003']['status'],'FAIL')
        self.assertEqual(report['fixture_counts'],dict(free=1005,launch=418,rail=36,object=45,rolling=7))
        self.assertEqual(len(report['repeat_hashes']),8)
        for row in report['contact_map']:
            if row['first_event']=='rail':
                self.assertIsNotNone(row['first_rail_event'])
                self.assertEqual(row['first_rail_event']['event']['kind'],'rail')
                self.assertIn(row['rail_classification'],['straight','jaw'])
                self.assertEqual(len(row['first_rail_event']['event']['position']),2)
            if row['first_event']=='ball_contact':
                self.assertIsNotNone(row['first_ball_contact'])
        manifest=json.loads((directory/'manifest.json').read_text())
        self.assertEqual(manifest['status'],'COMPLETE')
        current=atlas.source_identity()
        for path,old in manifest['source_sha256'].items():
            if path!='tools/power_response_atlas.py': self.assertEqual(old,current[path])
        original=subprocess.check_output(['git','show','92f09ba:tools/power_response_atlas.py'],cwd=ROOT)
        self.assertEqual(atlas.sha(original),manifest['source_sha256']['tools/power_response_atlas.py'])

    def test_review_missing_rows_fields_and_consistency(self):
        base=ROOT/'test-results/power-atlas-c0-20261107-final-v2'
        mutations=[]
        def add(group,name,action): mutations.append((group,name,action))
        def results(data): return [r for r in data if r['kind']=='result']
        def first(data,kind): return next(r for r in data if r['kind']==kind)
        add('center','all boundary and unsupported rows missing',lambda d:d.__setitem__(slice(None),[r for r in d if r['kind'] not in ['unsupported_probe','controller_boundary']]))
        add('center','all four reviewed controller fields missing',lambda d:[r.pop(k) for r in results(d) for k in ['accepted','committed_power','hud_tip_readback','provenance']])
        for key in ['accepted','committed_power','hud_tip_readback','hud_readback','provenance','input_domain','requested_power','power_tick','controller_equivalent','tip_actual']:
            add('center','missing controller '+key,lambda d,k=key:[r.pop(k) for r in results(d)])
        for key in ['engine','architecture','clock','os','processor','scalar_precision','vector_precision','table','half_size']:
            add('center','missing runtime '+key,lambda d,k=key:d[0].pop(k))
        add('center','missing engine hash',lambda d:d[0]['engine'].pop('hash'))
        add('center','unknown precision',lambda d:d[0].__setitem__('vector_precision','unknown'))
        for kind in ['runtime','completion','unsupported_probe','controller_boundary']:
            add('center','duplicate '+kind,lambda d,k=kind:d.insert(1,copy.deepcopy(first(d,k))))
        for kind in ['unsupported_probe','controller_boundary']:
            add('center','missing '+kind,lambda d,k=kind:d.remove(first(d,k)))
            add('center','duplicate identity '+kind,lambda d,k=kind:[r for r in d if r['kind']==k][1].__setitem__('id' if k=='unsupported_probe' else 'input',first(d,k)['id' if k=='unsupported_probe' else 'input']))
        for key in ['accepted','finite_outcome','states','missing_reason','domain','qualification']:
            add('center','missing unsupported '+key,lambda d,k=key:first(d,'unsupported_probe').pop(k))
        for key in ['committed','committed_power','states']:
            add('center','missing boundary '+key,lambda d,k=key:first(d,'controller_boundary').pop(k))
        add('center','outside pending missing',lambda d:next(r for r in d if r.get('input')=='outside_tip_0').pop('pending'))
        add('center','wrong clamp',lambda d:next(r for r in d if r.get('input')=='1.1').__setitem__('committed_power',1.1))
        add('center','unknown kind',lambda d:d.insert(1,dict(kind='unknown')))
        add('center','zero committed',lambda d:results(d)[0].__setitem__('committed_power',0.0))
        add('center','nonzero rejected',lambda d:results(d)[1].__setitem__('accepted',False))
        add('right','equivalence missing',lambda d:next(r for r in results(d) if r['controller_equivalent'] is True).pop('controller_equivalent'))
        add('right','equivalence false',lambda d:next(r for r in results(d) if r['controller_equivalent'] is True).__setitem__('controller_equivalent',False))
        add('launch','wrong domain',lambda d:results(d)[0].__setitem__('input_domain','HUD power'))
        def rail_event(d): return next(e for r in results(d) for e in r['events'] if e['event']['kind']=='rail')['event']
        add('rail','jaw missing',lambda d:rail_event(d).pop('jaw'))
        add('rail','jaw wrong type',lambda d:rail_event(d).__setitem__('jaw',0))
        add('rail','rail class inconsistent',lambda d:next(r for r in results(d) if r['first_rail_event']).__setitem__('rail_classification','no_rail_event'))
        add('rail','first rail missing',lambda d:next(r for r in results(d) if r['first_rail_event']).pop('first_rail_event'))
        cache={}
        for group,name,action in mutations:
            if group not in cache:
                path=base/group
                cache[group]=(path,json.loads((path/'fixtures.json').read_text()),[json.loads(l) for l in (path/'raw.jsonl').read_text().splitlines()],(path/'traces.jsonl').read_text())
            path,expected,original,trace=cache[group]
            with self.subTest(mutation=name):
                data=copy.deepcopy(original); action(data)
                raw='\n'.join(json.dumps(r) for r in data)+'\n'
                with patch.object(Path,'read_text',return_value=raw),patch.object(Path,'open',return_value=io.StringIO(trace)):
                    with self.assertRaises(ValueError): atlas.read_chunk(path,expected)

    def test_independent_torque_audit_and_adversarial_spin(self):
        import sys
        sys.path.insert(0,str(ROOT/'tools'))
        import power_atlas_torque_audit as torque
        self.assertEqual(torque.RELATIVE_BOUND,2e-6)
        self.assertEqual(torque.ABSOLUTE_BOUND,1e-11)
        base=ROOT/'test-results/power-atlas-c0-20261107-final-v2'
        result=torque.audit(base)
        self.assertEqual(result['checks'],410)
        self.assertEqual(result['failures'],0)
        rows=[json.loads(l) for l in (base/'launch/raw.jsonl').read_text().splitlines()]
        row=next(r for r in rows if r.get('kind')=='result' and not r['id'].startswith('outside') and abs(r['launch'][0][10])>1)
        flipped=copy.deepcopy(row); flipped['launch'][0][10]*=-1
        self.assertEqual(torque.check(flipped)['status'],'FAIL')
        wrong_axis=copy.deepcopy(row); wrong_axis['launch'][0][8],wrong_axis['launch'][0][10]=wrong_axis['launch'][0][10],wrong_axis['launch'][0][8]
        self.assertEqual(torque.check(wrong_axis)['status'],'FAIL')
        moving=copy.deepcopy(row); moving['initial'][0][5]=.1
        with self.assertRaises(ValueError): torque.check(moving)
        wrong_impulse=copy.deepcopy(row); wrong_impulse['cue_impulse_Ns'][0]+=.01
        with self.assertRaises(ValueError): torque.check(wrong_impulse)

    def test_revalidate_retained_chunks(self):
        base=ROOT/'test-results/power-atlas-c0-20261107-final-v2'
        for path in sorted(base.iterdir()):
            if path.is_dir() and (path/'complete.json').exists():
                with self.subTest(chunk=path.name):
                    expected=json.loads((path/'fixtures.json').read_text())
                    atlas.read_chunk(path,expected)

    def test_actual_raw_negative_mutations(self):
        # Reuse the preserved smoke acquisition, never rerun the physics for parser tests.
        source=ROOT/'test-results/power-atlas-c0-20261107-final-v2/center'
        if not source.exists(): self.skipTest('run documented smoke command first')
        expected=json.loads((source/'fixtures.json').read_text())
        atlas.read_chunk(source,expected)
        lines=[json.loads(s) for s in (source/'raw.jsonl').read_text().splitlines()]
        for mutation in ['empty','missing_completion','duplicate','wrong_clock','wrong_terminal','nonfinite','wrong_profile','truncated_trace']:
            with self.subTest(mutation=mutation),tempfile.TemporaryDirectory() as temp:
                directory=Path(temp); data=copy.deepcopy(lines)
                trace=(source/'traces.jsonl').read_text()
                if mutation=='empty': data=[]
                if mutation=='missing_completion': data=data[:-1]
                if mutation=='duplicate': data.insert(1,data[1])
                if mutation=='wrong_clock': data[2]['simulation_s']+=1
                if mutation=='wrong_terminal': data[2]['terminal'][0][2]+=.1
                if mutation=='nonfinite': data[2]['terminal'][0][2]=float('nan')
                if mutation=='wrong_profile': data[0]['profile']['gravity']=9.8
                if mutation=='truncated_trace': trace='\n'.join(trace.splitlines()[:-1])+'\n'
                (directory/'raw.jsonl').write_text('\n'.join(json.dumps(r) for r in data)+'\n')
                (directory/'traces.jsonl').write_text(trace)
                with self.assertRaises(ValueError): atlas.read_chunk(directory,expected)

if __name__=='__main__': unittest.main()
