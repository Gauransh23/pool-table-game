#!/usr/bin/env python3
"""Atlas integrity: real GDScript fixture rejection and retained-output negative tests."""
import copy
import importlib.util
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
        self.assertEqual(manifest['source_sha256'],atlas.source_identity())

    def test_actual_raw_negative_mutations(self):
        # Reuse the preserved smoke acquisition, never rerun the physics for parser tests.
        source=ROOT/'test-results/atlas-smoke-3/center'
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
