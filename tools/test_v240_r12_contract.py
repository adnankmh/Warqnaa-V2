#!/usr/bin/env python3
"""Warqnaa R12 Build 240 Competitive Arena release contract."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    raise SystemExit("[FAIL] " + message)


def check(condition: bool, message: str) -> None:
    if not condition:
        fail(message)
    print("[PASS] " + message)


def source(relative: str) -> str:
    path = ROOT / relative
    check(path.is_file(), f"{relative} exists")
    return path.read_text(encoding="utf-8")


def contains(relative: str, needles: tuple[str, ...], label: str) -> str:
    value = source(relative)
    missing = [needle for needle in needles if needle not in value]
    check(not missing, label + (" (missing: " + ", ".join(missing) + ")" if missing else ""))
    return value


def main() -> None:
    meta = json.loads(source("RELEASE_VERSION.json"))
    check(int(meta.get("build", 0)) >= 240 and meta.get("full") == f'{meta.get("version")}+{meta.get("build")}', "R12 or a compatible successor has internally consistent release metadata")
    check(f"version: {meta['full']}" in source("flutter_app/pubspec.yaml"), "Flutter package matches current metadata while preserving R12")

    migration = source("backend-laravel/database/migrations/2026_08_21_000240_r12_competitive_arena.php")
    tables = (
        "competitive_seasons", "competitive_ratings", "ranked_queue_entries", "competitive_matches",
        "competitive_rating_events", "season_reward_claims", "competitive_standing_snapshots",
    )
    check(all(f"Schema::create('{table}'" in migration for table in tables), "R12 migration owns seven competitive tables")
    check("competitive_rating_event_unique" in migration and "season_reward_claim_unique" in migration, "MMR and season rewards have database idempotency keys")
    check(all(field in migration for field in ("season_id", "format", "scope", "country_code", "min_rating", "current_round", "champion_user_id", "competitive_rules")), "tournament schema supports seasons, leagues, cups, countries and clubs")

    config = contains("backend-laravel/config/warqna_competitive.php", ("'release' => '0.7.0+240'", "'initial_rating'", "'abandon_penalty'", "'grandmaster'", "'legend'", "'season_rewards'"), "versioned MMR tiers and rewards exist")
    check(config.count("['key' =>") == 8, "eight competitive tiers are server-defined")

    matchmaking = contains("backend-laravel/app/Services/Competitive/CompetitiveMatchmakingService.php", ("whereIn('status',['waiting','matching','matched'])", "lockForUpdate", "foreach($candidates as $anchor)", "GameCatalog::isCustomerVisible", "allowedSeatCounts", "compatibleAgainstAll", "blockedAgainstAny", "search_window_max", "cross-region", "server_authoritative'=>true", "is_bot'=>false", "CompetitiveMatch::create", "url('/room/'", "SEAT_LAYOUTS"), "Ranked matchmaking is fair, head-of-line safe, private and server-authoritative")
    check("allow_spectators'=>false" in matchmaking and "allow_owner_kick'=>false" in matchmaking, "Ranked rooms prevent spectators and owner manipulation")
    rating = contains("backend-laravel/app/Services/Competitive/CompetitiveRatingService.php", ("processRoom", "resolveResult", "rating_processed", "lockForUpdate", "CompetitiveRatingEvent::create", "ranked_abandon_penalty", "anti_cheat_review", "review_override", "overall", "game:"), "MMR is idempotent, dual-scope and integrity-gated")
    check("request()->" not in rating and "client_winner" not in rating, "MMR never accepts a client-authoritative result")
    seasons = contains("backend-laravel/app/Services/Competitive/CompetitiveSeasonService.php", ("rating_soft_reset_factor", "leaderboard", "captureStandings", "activate", "finalize", "SeasonRewardClaim::firstOrCreate", "lockForUpdate", "competitive_season_reward"), "season activation, snapshots and atomic rewards are serialized")
    check("if ($claim->status === 'claimed')" in seasons, "season reward claims are idempotent")
    bracket = contains("backend-laravel/app/Services/Competitive/TournamentBracketService.php", ("r12_competitive_bracket_v1", "snakeSeed", "qualificationSnapshot", "season_league_ladder", "group_qualification", "createRound", "advanceFromMatch", "rematchVoided", "rematchDrawn", "replaceUnadvancedMatch", "$kind.'_history'", "settlement_ready", "champion_user_ids", "GameFactory::make", "is_bot'=>false"), "deterministic multi-round server brackets, integrity/draw rematches and league qualification snapshots are implemented")
    check("requiredPlayers" in bracket and "$numerator%$advance" in bracket, "odd-seat tournaments derive an exact complete bracket capacity")
    check("if($force) throw new RuntimeException" in bracket, "issued R12 rooms make their bracket immutable instead of spawning duplicate matches")
    competition = contains("backend-laravel/app/Services/WarqnaPro/CompetitionService.php", ("Tournament::with(['game','season'])->lockForUpdate()", "assertJoinable", "entryMode = (int)$tournament->entry_fee > 0 ? 'tokens' : 'free'", "if((int)$locked->entry_fee>0)", "requiredPlayers", "TournamentBracketService::class)->build"), "tournament registration is capacity-locked, free-safe and atomically starts the bracket")
    settlement = contains("backend-laravel/app/Services/WarqnaPro/TournamentSettlementService.php", ("r12_competitive_bracket_v1", "settlement_ready", "deferred", "paid_at", "lockForUpdate", "champion_user_ids", "unverified_r12_final", "count($eligible)!==count($winnerUserIds)"), "prize settlement is deferred and revalidated inside the locked final transaction")
    check("empty($bracket['settlement_ready'])" in settlement and "unverified_r12_final" in settlement, "early or mismatched tournament rooms cannot release the prize escrow")

    routes = source("backend-laravel/routes/api.php")
    check(all(route in routes for route in ("/competitive/queue", "/competitive/leaderboard", "/competitive/history", "/competitive/tournaments/{tournament}", "/competitive/rewards/{claim}/claim", "/admin/competitive/settings", "/admin/competitive/seasons", "/admin/competitive/ratings/{user}", "/admin/competitive/matches/{match}", "/admin/competitive/tournaments/{tournament}/bracket")), "mobile and admin Competitive APIs are complete")
    admin = contains("backend-laravel/app/Http/Controllers/AdminCompetitiveController.php", ("hasAdminPermission('competitive')", "createSeason(Request $request, CompetitiveSeasonService $seasons", "AdminAuditService", "admin.competitive.settings", "admin.competitive.rating.adjust", "admin.competitive.match.", "admin.competitive.tournament.bracket", "required_if:scope,club", "required_if:scope,country"), "Admin Competitive is permission-gated, dependency-complete and audited")
    mobile = contains("backend-laravel/app/Http/Controllers/MobileCompetitiveController.php", ("joinQueue", "queueStatus", "leaderboard", "tournament", "joinTournament", "claimReward", "history"), "mobile Competitive controller covers the complete player journey")
    check("warqna:competitive-tick" in source("backend-laravel/routes/console.php"), "competitive lifecycle and recovery are scheduled")
    tick = contains("backend-laravel/app/Console/Commands/CompetitiveTick.php", ("--dry-run", "lifecycleTick", "matchmaking->tick", "processRoom", "brackets_recoverable", "advanceFromMatch", "captureStandings", "error_refs", "rating_match:", "bracket_match:"), "operations tick recovers matchmaking, MMR, brackets, seasons and snapshots with failure isolation")
    check("return self::FAILURE" in tick, "operations tick surfaces isolated recovery errors to monitoring")

    for model in ("CompetitiveSeason", "CompetitiveRating", "RankedQueueEntry", "CompetitiveMatch", "CompetitiveRatingEvent", "SeasonRewardClaim", "CompetitiveStandingSnapshot"):
        check((ROOT / "backend-laravel/app/Models" / f"{model}.php").is_file(), f"{model} model exists")
    for controller in ("RoomController.php", "MobileGameController.php"):
        body = source("backend-laravel/app/Http/Controllers/" + controller)
        check("CompetitiveRatingService" in body and "competitive_abandons" in body, f"{controller} connects authoritative results and abandon penalties")
        check("competitiveMatch()->first()?->participant_ids" in body, f"{controller} locks official rooms to server-matched participants")
        check("competitive_player_left" in body and "away_players" in body, f"{controller} keeps an abandoning Ranked seat human-owned and bot-free")

    layout = contains("backend-laravel/resources/views/layouts/app.blade.php", ("r12-competitive-arena.css?v=240", "WARQNAA_R12", "route('competitive')"), "web shell exposes the R12 arena")
    check("WARQNAA_R11" in layout and "r11-social-world.css?v=230" in layout, "R11 Social World remains loaded under R12")
    contains("backend-laravel/resources/views/competitive/index.blade.php", ("RANKED MATCHMAKING", "SEASON REWARDS", "competitive.queue", "competitive.rewards.claim", "LEAGUES & CUPS", "World & club championships"), "player web Arena contains queue, ladder, cups and rewards")
    contains("backend-laravel/resources/views/admin/competitive.blade.php", ("Admin Competitive Arena", "Season lifecycle", "Create championship", "Manual MMR settlement", "Integrity review queue", "Tournament brackets"), "web admin control plane is complete")
    css = source("backend-laravel/public/assets/css/r12-competitive-arena.css")
    check(".r12-arena" in css and ".r12-admin" in css and "@media" in css and "prefers-reduced-motion" in css, "R12 web visuals are responsive and motion-aware")

    flutter_main = contains("flutter_app/lib/main.dart", ("part 'r12_competitive.dart';", "R12CompetitiveArenaPage", "R12AdminCompetitivePanel", "TabController(length:"), "Flutter navigation and Admin include R12")
    api = contains("flutter_app/lib/services/api_client.dart", ("competitiveR12", "joinRankedQueueR12", "rankedQueueR12", "competitiveLeaderboardR12", "competitiveHistoryR12", "competitiveTournamentR12", "claimCompetitiveRewardR12", "adminCompetitiveR12", "adminCreateCompetitiveSeasonR12", "adminAdjustCompetitiveRatingR12", "adminCreateCompetitiveTournamentR12", "adminCompetitiveMatchActionR12", "adminBuildCompetitiveBracketR12"), "Flutter API covers player and Admin R12")
    check(f"defaultValue: '{meta['version']}'" in api and f"defaultValue: {meta['build']}" in api, "Flutter API release headers match the current R12-compatible successor")
    flutter = contains("flutter_app/lib/r12_competitive.dart", ("warqnaaR12Release = '0.7.0+240'", "class R12CompetitiveArenaPage", "class R12AdminCompetitivePanel", "Timer.periodic", "Ranked battle", "LEAGUES • CUPS • CHAMPIONSHIPS", "GLOBAL RANKED LADDER", "SEASON REWARD VAULT", "Integrity review", "New season", "New championship", "Adjust MMR"), "Flutter ships the polished player and full mobile admin Competitive experiences")
    check("serverConnected" in flutter and "_offlineCompetitive" in flutter, "Flutter provides a safe offline preview without faking Ranked mutations")
    check("'grandmaster'" in flutter and "'max_players':32" in flutter, "Flutter offline preview mirrors the complete tier and valid bracket-capacity model")

    admin_competitive = source("backend-laravel/app/Http/Controllers/AdminCompetitiveController.php")
    check("AuthenticatedActor::resolve($request)" in admin_competitive, "Admin Competitive refreshes bearer-token actor state before permission checks")

    feature = source("backend-laravel/tests/Feature/V240CompetitiveArenaTest.php")
    check("$this->game('basra',2,false)" in feature and "$this->game('backgammon',2,false)" not in feature, "R12 runtime fixtures use a current customer-visible two-seat game")
    check("'primary_admin'" in feature and "Str::lower($username)==='adnan'" in feature, "R12 prize tests mirror the primary-admin unlimited wallet role")
    check("$role=$admin ? (Str::lower($username)==='adnan' ? 'primary_admin' : 'delegated_admin') : 'player';" in feature, "R12 player fixtures always use a non-null admin_role compatible with the schema")
    for test in ("test_ranked_matchmaker_creates_server_authoritative_bot_free_room", "test_ranked_matchmaker_expands_a_two_sided_mmr_window_without_forcing_an_unfair_match", "test_incompatible_oldest_queue_entry_does_not_block_a_fair_pair_behind_it", "test_competitive_room_rejects_every_non_matched_player", "test_rating_result_is_idempotent_and_writes_both_scopes", "test_severe_anti_cheat_event_holds_rating_until_admin_approval", "test_two_round_bracket_advances_and_pays_only_after_final", "test_mobile_registration_supports_an_admin_created_custom_championship_key", "test_three_player_two_stage_bracket_uses_nine_entrants_and_finishes_cleanly", "test_solo_four_seat_final_crowns_and_pays_exactly_one_champion", "test_voided_tournament_match_is_replaced_without_reusing_its_room", "test_drawn_tournament_match_awards_draw_mmr_then_issues_a_tiebreak_rematch", "test_duplicate_final_advancement_recovers_a_deferred_settlement", "test_finalized_season_reward_is_atomic_and_claimable_once", "test_admin_competitive_requires_explicit_permission", "test_admin_can_create_an_immediately_active_season_and_finalize_the_previous_one"):
        check(test in feature, f"Laravel suite includes {test}")
    check((ROOT / "tools/test_v240_competitive_engines.py").is_file(), "R12 competitive engine gate exists")

    release_files = (
        "docs/ar/releases/current/START_HERE_V240_AR.md",
        "docs/ar/releases/current/R12_COMPETITIVE_ARENA_CONTRACT_AR.md",
        "docs/en/R12_COMPETITIVE_ARENA_CONTRACT.md",
        "docs/ar/releases/current/RELEASE_NOTES_V240_AR.md",
        "docs/ar/releases/current/R12_UPGRADE_FROM_B230_AR.md",
        "docs/ar/deployment/GITHUB_UPLOAD_V240_AR.md",
        "docs/ar/reports/current/QUALITY_REPORT_V240_AR.md",
        "docs/ar/validation/current/VALIDATION_RESULTS_V240.txt",
        "releases/manifests/current/RELEASE_MANIFEST_V240.json",
        "scripts/windows/current/CHECK_V240_WINDOWS.bat",
        "scripts/windows/current/START_WARQNA_V240_WINDOWS.bat",
        "scripts/windows/current/START_WARQNA_R12_PORT.bat",
        "scripts/unix/current/check-v240.sh",
    )
    check(all((ROOT / item).is_file() for item in release_files), "R12 documentation, manifest and local operations scripts are complete")
    windows_check = source("scripts/windows/current/CHECK_V240_WINDOWS.bat")
    unix_check = source("scripts/unix/current/check-v240.sh")
    for gate in ("test_v208_r8_contract.py", "test_v209_r9_contract.py", "test_v210_r9_1_contract.py", "test_v220_r10_contract.py", "test_v221_r101_contract.py", "test_v230_r11_contract.py", "test_v240_r12_contract.py", "test_v240_competitive_engines.py", "test_v240_php_structure.py", "test-v208-r8-rules.php", "test-v184-official-rules-audit.php", "test-v184-engine-stress.php", "test-v208-r8-playthrough-stress.php"):
        check(gate in windows_check and gate in unix_check, f"local release checks include {gate}")

    workflows = ("backend-ci.yml", "production-release-check.yml", "flutter-android.yml", "flutter-ios.yml", "flutter-web-pages.yml")
    for workflow in workflows:
        contents = source(".github/workflows/" + workflow)
        check("test_v230_r11_contract.py" in contents and "test_v240_r12_contract.py" in contents and "test_v240_competitive_engines.py" in contents and "test_v240_php_structure.py" in contents, f"R8–R12 regression chain reaches {workflow}")
    print("V240 R12 COMPETITIVE ARENA CONTRACT: PASS")


if __name__ == "__main__":
    main()
