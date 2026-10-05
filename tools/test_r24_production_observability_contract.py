#!/usr/bin/env python3
"""R24 exact-head production observability and operational readiness contract."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    target = ROOT / path
    assert target.exists(), f"missing required file: {path}"
    return target.read_text()


contract = read('docs/R24_PRODUCTION_OBSERVABILITY.md')
for token in [
    'server-authoritative',
    'primary_admin',
    'privacy-safe',
    'matchmaking',
    'heartbeat',
    'reconnect',
    'WebRTC',
    'store verification',
    'anti-cheat',
    'economy audit',
    'health/readiness',
    'Arabic RTL',
    'English LTR',
    'R20–R23',
]:
    assert token in contract, f'R24 contract missing: {token}'

# R24 is cumulative: all earlier release contracts and privacy checks remain mandatory.
for path in [
    'tools/test_r23_security_economy_contract.py',
    'tools/test_r22_multiplayer_resilience_contract.py',
    'tools/test_r21_community_contract.py',
    'tools/test_r20_premium_experience_contract.py',
    'tools/check_git_privacy_v304.py',
]:
    assert (ROOT / path).exists(), f'cumulative gate missing: {path}'

# Every release-critical workflow, including R24, must test the exact PR head.
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
]:
    text = read(f'.github/workflows/{name}.yml')
    assert 'ref: ${{ github.event.pull_request.head.sha || github.sha }}' in text, f'{name}: exact-head checkout required'

workflow = read('.github/workflows/r24-production-observability.yml')
assert 'python3 tools/test_r24_production_observability_contract.py' in workflow
assert 'python3 tools/test_r23_security_economy_contract.py' in workflow
assert 'python3 tools/check_git_privacy_v304.py' in workflow
print('R24 production observability/readiness contract: PASS')
