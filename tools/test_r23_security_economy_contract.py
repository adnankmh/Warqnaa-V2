#!/usr/bin/env python3
"""R23 exact-head anti-cheat, economy and security release contract."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    target = ROOT / path
    assert target.exists(), f"missing required file: {path}"
    return target.read_text()


contract = read('docs/R23_ANTI_CHEAT_ECONOMY_SECURITY.md')
for token in [
    'server-authoritative',
    'primary_admin',
    'Anti-cheat',
    'Economy',
    'Security',
    'Multiplayer integrity',
    'Admin',
    'Arabic RTL',
    'English LTR',
    'all 12 games',
    'full production matrix',
]:
    assert token in contract, f'R23 contract missing: {token}'

# R23 is cumulative: do not weaken earlier release gates.
for path in [
    'tools/test_r22_multiplayer_resilience_contract.py',
    'tools/test_r21_community_contract.py',
    'tools/test_r20_premium_experience_contract.py',
    'tools/check_git_privacy_v304.py',
]:
    assert (ROOT / path).exists(), f'cumulative gate missing: {path}'

# Release-critical workflows must test the exact PR head.
for name in [
    'backend-ci',
    'production-release-check',
    'flutter-web-pages',
    'flutter-android',
    'r7-runtime-verification',
    'r20-premium-experience',
    'r21-community',
    'r22-multiplayer-resilience',
    'r23-security-economy',
]:
    text = read(f'.github/workflows/{name}.yml')
    assert 'ref: ${{ github.event.pull_request.head.sha || github.sha }}' in text, f'{name}: exact-head checkout required'

workflow = read('.github/workflows/r23-security-economy.yml')
assert 'python3 tools/test_r23_security_economy_contract.py' in workflow
assert 'python3 tools/test_r22_multiplayer_resilience_contract.py' in workflow
assert 'python3 tools/check_git_privacy_v304.py' in workflow
print('R23 anti-cheat/economy/security contract: PASS')
