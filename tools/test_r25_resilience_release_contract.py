#!/usr/bin/env python3
"""R25 exact-head resilience and release hardening contract."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    target = ROOT / path
    assert target.exists(), f"missing required file: {path}"
    return target.read_text()


contract = read('docs/R25_RESILIENCE_RELEASE_HARDENING.md')
for token in [
    '12-game',
    'server-authoritative',
    'primary_admin',
    'matchmaking',
    'heartbeat',
    'reconnect',
    'WebRTC',
    'anti-cheat',
    'store',
    'privacy/no-secrets',
    'Arabic RTL',
    'English LTR',
    'idempotent',
    'timeouts/backoff',
    'health/readiness',
    'R20–R24',
]:
    assert token in contract, f'R25 contract missing: {token}'

# R25 is cumulative: every earlier stage contract and privacy guard remains mandatory.
for path in [
    'tools/test_r24_production_observability_contract.py',
    'tools/test_r23_security_economy_contract.py',
    'tools/test_r22_multiplayer_resilience_contract.py',
    'tools/test_r21_community_contract.py',
    'tools/test_r20_premium_experience_contract.py',
    'tools/check_git_privacy_v304.py',
]:
    assert (ROOT / path).exists(), f'cumulative gate missing: {path}'

# Every release-critical workflow, including R25, must checkout the exact PR head.
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
    'r24-production-observability',
    'r25-resilience-release',
]:
    text = read(f'.github/workflows/{name}.yml')
    assert 'ref: ${{ github.event.pull_request.head.sha || github.sha }}' in text, f'{name}: exact-head checkout required'

workflow = read('.github/workflows/r25-resilience-release.yml')
assert 'python3 tools/test_r25_resilience_release_contract.py' in workflow
assert 'python3 tools/test_r24_production_observability_contract.py' in workflow
assert 'python3 tools/check_git_privacy_v304.py' in workflow
print('R25 resilience/release hardening contract: PASS')
