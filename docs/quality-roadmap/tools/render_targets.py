#!/usr/bin/env python3
"""Validate the specification catalog and render its three human target branches."""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GROUPS = {
    '01-physics': 'Physics and geometry targets',
    '02-controls-and-presentation': 'Controls and presentation targets',
    '03-validation-and-release': 'Validation and release targets',
}

def render():
    catalog = json.loads((ROOT / 'QUALITY_REQUIREMENTS.json').read_text())
    protocol = (ROOT / 'TEST_PROTOCOLS.md').read_text()
    families = set(re.findall(r'^## (F-[A-Z]+)', protocol, re.M))
    categories = {item['code']: item for item in catalog['categories']}
    seen = set()
    grouped = {name: [] for name in GROUPS}
    for row in catalog['requirements']:
        if row['id'] in seen or not re.fullmatch(r'[A-Z]+-\d{3}', row['id']):
            raise ValueError(f'Duplicate/invalid requirement ID: {row["id"]}')
        seen.add(row['id'])
        for key in ['title', 'acceptance', 'verification', 'counterexample', 'basis', 'level', 'gate', 'test_family', 'status']:
            if not row.get(key):
                raise ValueError(f'{row["id"]} missing {key}')
        category = categories[row['category']]
        if row['test_family'] not in families or row['test_family'] != category['family']:
            raise ValueError(f'{row["id"]} has unresolved test family')
        if row['gate'] not in {'G0','G1','G2','G3','G4'}:
            raise ValueError(f'{row["id"]} invalid gate')
        if row['status'] != 'UNVERIFIED':
            raise ValueError('Target catalog is immutable acceptance definition, not the execution ledger')
        if row['level'] not in {'required', 'conditional', 'stretch'}:
            raise ValueError(f'{row["id"]} invalid obligation level')
        grouped[category['group']].append(row)
    outputs = {}
    for group, title in GROUPS.items():
        lines = [f'# {title}', '', f'Generated from `../QUALITY_REQUIREMENTS.json`, revision **{catalog["revision"]}**. '
                 'Edit that catalog and run `python3 docs/quality-roadmap/tools/render_targets.py` from the repository root.', '',
                 'Read [contract and definitions](../QUALITY_TARGETS.md) before interpreting thresholds. '
                 'All rows start **UNVERIFIED**. A separate evidence ledger establishes execution status; this page makes no gameplay acceptance claim.', '']
        for code, category in categories.items():
            rows = [r for r in grouped[group] if r['category'] == code]
            if not rows:
                continue
            lines += [f'## {code} — {category["title"]}', '',
                      f'Owner surface: {category["owner"]}. Test family: [{category["family"]}](../TEST_PROTOCOLS.md#{category["family"].lower()}). '
                      f'Primary gate: **{category["gate"]}**.', '']
            for row in rows:
                lines += [f'### {row["id"]} — {row["title"]}', '',
                          f'**Target ({row["level"]}; {row["basis"]}):** {row["acceptance"]}', '',
                          f'**Test/evidence:** {row["verification"]}', '',
                          f'**Counterexample to catch:** {row["counterexample"]}', '']
        outputs[ROOT / 'targets' / f'{group}.md'] = '\n'.join(lines)
    return catalog, outputs

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--init-ledger', type=Path, help='Create a new all-NOT_RUN execution ledger; never overwrite evidence')
    parser.add_argument('--check', action='store_true', help='Fail if a generated document differs from the catalog')
    args = parser.parse_args()
    catalog, outputs = render()
    if args.init_ledger and args.init_ledger.exists():
        raise SystemExit(f'Refusing to overwrite evidence ledger: {args.init_ledger}')
    for path, text in outputs.items():
        if args.check:
            if not path.exists() or path.read_text() != text:
                raise SystemExit(f'Stale target page: {path}')
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text)
    if args.init_ledger:
        path = args.init_ledger
        if path.exists():
            raise SystemExit(f'Refusing to overwrite evidence ledger: {path}')
        path.parent.mkdir(parents=True, exist_ok=True)
        ledger = {
            'requirements_revision': catalog['revision'],
            'candidate_id': None, 'source_hashes': {}, 'profile_hash': None,
            'artifact_hash': None, 'environment': {},
            'results': [{'id': row['id'], 'status': 'NOT_RUN',
                         'procedure': None, 'oracle': None, 'expected': None,
                         'actual': None, 'uncertainty': None, 'artifacts': [],
                         'reviewer': None, 'limitations': []}
                        for row in catalog['requirements']],
        }
        path.write_text(json.dumps(ledger, indent=2) + '\n')
    print(f'{len(catalog["requirements"])} unique requirements; {len(catalog["categories"])} domains; '
          f'{len(outputs)} generated pages; protocol links and schema valid')
