#!/usr/bin/env python3
"""Cumulative R21 wiring and authority checks; behavioral coverage lives in CI."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
required = {
    'flutter_app/lib/r11_social_world.dart': ['R21ClubDirectory', 'join_request_pending', 'serverVerified', 'joiningId', 'clubsWorldR11', 'respondClubJoinRequestR11'],
    'flutter_app/lib/r12_competitive.dart': ['R21TournamentDirectory', 'R21TournamentCard', 'expectedEntryFee: fee', 'cupBusy', 'serverVerified', 'leaveCompetitiveTournamentR12', 'r21CompetitiveLabel'],
    'flutter_app/lib/services/api_client.dart': ["'expected_entry_fee': expectedEntryFee"],
    'backend-laravel/app/Http/Controllers/MobileClubWorldController.php': ['join_request_pending', "where('user_id', $request->user()->id)", "where('visibility', '!=', 'private')"],
    'backend-laravel/app/Services/WarqnaPro/CompetitionService.php': ['$expectedFee !== (int)$locked->entry_fee', 'lockForUpdate', 'creditPrimaryAdminRevenue', 'CompetitionTicket'],
    'backend-laravel/tests/Feature/V240CompetitiveArenaTest.php': ['test_r21_stale_fee_consent_never_consumes_a_ticket_or_wallet', "assertJsonPath('competitive.tournaments.0.registered',true)"],
    'flutter_app/test/r21_community_test.dart': ['failed detail refresh never exposes registration', 'guards repeated taps', 'offline clubs and arena', 'Size(320, 640)', "['ar', 'en']"],
    'tools/r7_runtime_smoke.py': ['clubs_request_privacy_acceptance_and_restoration', 'tournament_consent_registration_withdrawal_and_restoration'],
    'flutter_app/test/r7_runtime_review_test.dart': ['r21-clubs', 'r21-cups', 'reviewCups, hasLength(3)'],
    'flutter_app/lib/r10_1_release.dart': ['R20StoreCollections'],
}
for path, tokens in required.items():
    source = (ROOT / path).read_text()
    for token in tokens:
        assert token in source, f'{path}: missing {token}'
    print('[PASS]', path)
service = (ROOT / 'backend-laravel/app/Services/WarqnaPro/CompetitionService.php').read_text()
assert service.index('$expectedFee !== (int)$locked->entry_fee') < service.index('$ticket->decrement'), 'Fee consent must precede ticket consumption'
assert service.index('$expectedFee !== (int)$locked->entry_fee') < service.index('$this->wallet->debit'), 'Fee consent must precede wallet debit'
for name in ['r21-community', 'r20-premium-experience', 'r7-runtime-verification', 'backend-ci', 'production-release-check', 'flutter-web-pages', 'flutter-android']:
    text = (ROOT / f'.github/workflows/{name}.yml').read_text()
    assert 'ref: ${{ github.event.pull_request.head.sha || github.sha }}' in text, f'{name}: exact-head checkout required'
print('R21 cumulative community contract: PASS')
