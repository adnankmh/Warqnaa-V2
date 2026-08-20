#!/usr/bin/env python3
"""CI regression guard for additive historical contracts and optional GitHub Pages deployment."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]

def fail(message: str) -> None:
    print('[FAIL] ' + message)
    raise SystemExit(1)

def text(rel: str) -> str:
    p = ROOT / rel
    if not p.is_file():
        fail('missing ' + rel)
    return p.read_text(encoding='utf-8')

meta = json.loads(text('RELEASE_VERSION.json'))
full = f"{meta['version']}+{meta['build']}"
if meta.get('full') != full:
    fail('release metadata is inconsistent')

for rel in ('tools/test_v183_overhaul_contract.py', 'tools/test_v030_contract.py'):
    data = text(rel)
    if "0.3.3+184" in data or "release must be 0.3.3+184" in data:
        fail(f'stale historical release pin remains in {rel}')
    if "build < 184" not in data:
        fail(f'{rel} must enforce minimum historical build rather than an exact old release')

web = text('.github/workflows/flutter-web-pages.yml')
for required in (
    'actions/configure-pages@v6',
    'actions/upload-pages-artifact@v4',
    'actions/deploy-pages@v5',
    'actions/upload-artifact@v6',
    'pages: read',
    'pages: write',
    'id-token: write',
    "if: steps.pages.outputs.enabled == 'true'",
    "if: needs.build.outputs.pages_enabled == 'true'",
):
    if required not in web:
        fail(f'missing {required!r} in Flutter Web workflow')
if 'enablement: true' in web:
    fail('Flutter Web workflow must not try to create a Pages site with GITHUB_TOKEN')

for wf in (ROOT/'.github/workflows').glob('*.yml'):
    data = wf.read_text(encoding='utf-8')
    if 'actions/checkout@v4' in data or 'actions/checkout@v5' in data:
        fail(f'old checkout action remains in {wf.relative_to(ROOT)}')

print('[PASS] CI release compatibility, Node 24 actions, and optional Pages deployment contract')
