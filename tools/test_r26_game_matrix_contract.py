#!/usr/bin/env python3
"""R26 exact-head 12-game matrix final-QA contract."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    target = ROOT / path
    assert target.exists(), f"missing required file: {path}"
    return target.read_text()


contract = read('docs/R26_GAME_MATRIX_FINAL_QA.md')
for game in [
    'Tarneeb', 'Tarneeb 400', 'Syrian Tarneeb', 'Trix', 'Trix Complex',
    'Trix Partnership', 'Hand', 'Partnership Hand', 'Saudi Hand',
    'Banakil', 'Baloot', 'Basra',
]:
    assert game in contract, f'R26 game matrix missing: {game}'

for token in [
    'legal actions', 'illegal-action guards', 'bidding/pass', 'scoring',
    'restart/rematch', 'Local/bot/server', 'server-authoritative',
    'heartbeat/reconnect', 'Arabic RTL', 'English LTR', '320px',
    'short-landscape', 'desktop', 'Card/table', 'privacy/no-secrets',
    'primary_admin',
]:
    assert token in contract, f'R26 acceptance contract missing: {token}'

# R26 remains cumulative and must never bypass the established release/security gates.
for path in [
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
    'r26-game-matrix-final-qa',
]:
    text = read(f'.github/workflows/{name}.yml')
    assert 'ref: ${{ github.event.pull_request.head.sha || github.sha }}' in text, f'{name}: exact-head checkout required'

workflow = read('.github/workflows/r26-game-matrix-final-qa.yml')
assert 'python3 tools/test_r26_game_matrix_contract.py' in workflow
assert 'python3 tools/test_r25_resilience_release_contract.py' in workflow
assert 'python3 tools/check_git_privacy_v304.py' in workflow
print('R26 12-game matrix final-QA contract: PASS')
