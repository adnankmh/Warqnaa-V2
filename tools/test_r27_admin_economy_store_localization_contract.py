#!/usr/bin/env python3
"""R27 exact-head admin/economy/store/content/localization closure contract."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    target = ROOT / path
    assert target.exists(), f"missing required file: {path}"
    return target.read_text()


contract = read('docs/R27_ADMIN_ECONOMY_STORE_LOCALIZATION.md')
for token in [
    'primary_admin', '99,999,999,999,999,999', 'non-depleting',
    'Inventory and ticket entitlements', 'server authoritative', 'idempotent',
    'No client-side grant', 'receipt/provider verification', 'Refunds',
    'webhook replay/idempotency', 'provider failure', 'duplicate delivery',
    'Production provider readiness', 'external release blocker',
    'Arabic RTL', 'English LTR', 'accessibility', 'performance',
    'original', 'licensed', 'Jawaker', 'privacy', 'no-secrets',
]:
    assert token in contract, f'R27 acceptance contract missing: {token}'

# R27 is cumulative: every previously established executable release gate remains present.
for path in [
    'tools/test_r26_game_matrix_contract.py',
    'tools/test_r25_resilience_release_contract.py',
    'tools/test_r24_production_observability_contract.py',
    'tools/test_r23_security_economy_contract.py',
    'tools/test_r22_multiplayer_resilience_contract.py',
    'tools/test_r21_community_contract.py',
    'tools/test_r20_premium_experience_contract.py',
    'tools/check_git_privacy_v304.py',
]:
    assert (ROOT / path).exists(), f'cumulative gate missing: {path}'

for name in [
    'backend-ci', 'production-release-check', 'flutter-web-pages',
    'flutter-android', 'r7-runtime-verification', 'r20-premium-experience',
    'r21-community', 'r22-multiplayer-resilience', 'r23-security-economy',
    'r24-production-observability', 'r25-resilience-release',
    'r26-game-matrix-final-qa', 'r27-admin-economy-store-localization',
]:
    text = read(f'.github/workflows/{name}.yml')
    assert 'ref: ${{ github.event.pull_request.head.sha || github.sha }}' in text, f'{name}: exact-head checkout required'

workflow = read('.github/workflows/r27-admin-economy-store-localization.yml')
assert 'python3 tools/test_r27_admin_economy_store_localization_contract.py' in workflow
assert 'python3 tools/test_r26_game_matrix_contract.py' in workflow
assert 'python3 tools/check_git_privacy_v304.py' in workflow
print('R27 admin/economy/store/content/localization closure contract: PASS')
