#!/usr/bin/env python3
"""R22 exact-head multiplayer resilience release contract."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def read(path: str) -> str:
    target = ROOT / path
    assert target.exists(), f"missing required file: {path}"
    return target.read_text()

contract = read('docs/R22_MULTIPLAYER_RESILIENCE.md')
for token in [
    'Rooms and party lifecycle',
    'Matchmaking and heartbeat',
    'Reconnect',
    'Spectator integrity',
    'WebRTC voice resilience',
    'Arabic RTL / English LTR',
    'primary_admin',
    'complete production matrix',
]:
    assert token in contract, f'R22 contract missing: {token}'

# Preserve the already-verified cumulative release contracts.
for path in [
    'tools/test_r21_community_contract.py',
    'tools/test_r20_premium_experience_contract.py',
    'tools/check_git_privacy_v304.py',
]:
    assert (ROOT / path).exists(), f'cumulative gate missing: {path}'

# Every release-critical workflow must checkout the exact PR head.
for name in [
    'backend-ci',
    'production-release-check',
    'flutter-web-pages',
    'flutter-android',
    'r7-runtime-verification',
    'r20-premium-experience',
    'r21-community',
    'r22-multiplayer-resilience',
]:
    text = read(f'.github/workflows/{name}.yml')
    assert 'ref: ${{ github.event.pull_request.head.sha || github.sha }}' in text, f'{name}: exact-head checkout required'

workflow = read('.github/workflows/r22-multiplayer-resilience.yml')
assert 'python3 tools/test_r22_multiplayer_resilience_contract.py' in workflow
assert 'python3 tools/test_r21_community_contract.py' in workflow
assert 'python3 tools/check_git_privacy_v304.py' in workflow
print('R22 multiplayer resilience contract: PASS')
