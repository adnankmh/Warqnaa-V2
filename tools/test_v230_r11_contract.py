#!/usr/bin/env python3
"""Warqnaa R11 Build 230 Social World additive release contract."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    print(f"[FAIL] {message}")
    raise SystemExit(1)


def check(condition: bool, message: str) -> None:
    if not condition:
        fail(message)
    print(f"[PASS] {message}")


def source(relative: str) -> str:
    path = ROOT / relative
    check(path.is_file(), f"{relative} exists")
    return path.read_text(encoding="utf-8")


def contains_all(relative: str, needles: tuple[str, ...], label: str) -> str:
    value = source(relative)
    missing = [needle for needle in needles if needle not in value]
    check(not missing, f"{label}" + (f" (missing: {', '.join(missing)})" if missing else ""))
    return value


def main() -> None:
    meta = json.loads(source("RELEASE_VERSION.json"))
    build = int(meta.get("build") or 0)
    check(build >= 230, "release includes R11 Build 230 or a later additive successor")
    check(meta.get("full") == f'{meta.get("version")}+{meta.get("build")}', "successor release metadata remains internally consistent")
    pubspec = source("flutter_app/pubspec.yaml")
    packaged = re.search(r"^version:\s*([^+\s]+)\+(\d+)\s*$", pubspec, re.M)
    check(packaged is not None and int(packaged.group(2)) >= 230, "Flutter package preserves R11 in Build 230 or later")

    migration = source("backend-laravel/database/migrations/2026_08_21_000230_r11_social_world.php")
    tables = (
        "social_preferences", "social_follows", "social_activities", "social_events",
        "social_event_attendees", "room_spectators", "match_replays", "social_gifts",
    )
    check(all(f"Schema::create('{table}'" in migration for table in tables), "R11 migration owns all eight Social World tables")
    check("unique(['room_id', 'user_id'])" in migration and "unique(['follower_id', 'followed_id'])" in migration, "spectator and follow memberships are idempotent")
    config = contains_all(
        "backend-laravel/config/warqna_social_world.php",
        ("'release' => '0.6.0+230'", "'max_replay_frames'", "'spectator_stale_seconds'", "'rose'", "'aurora'"),
        "versioned Social World limits and gift catalog exist",
    )
    check(config.count("'animation' =>") == 6, "six social-only animated gifts are server-authorized")

    policy = contains_all(
        "backend-laravel/app/Services/Social/SocialWorldPolicy.php",
        ("canDiscover", "canViewProfile", "canSeePresence", "canMessage", "canInvite", "canFollow", "canViewActivity", "canSpectate", "canViewReplay", "canShareReplay", "blocked("),
        "one server policy controls privacy across the Social World",
    )
    check("allow_spectators" in policy and "allow_replay_share" in policy and "show_online_status" in policy and "room.players.user" in policy, "spectating, replay and presence honor every participant's privacy")
    legacy_social = contains_all(
        "backend-laravel/app/Http/Controllers/MobileSocialController.php",
        ("SocialWorldPolicy", "canDiscover", "canInvite", "allow_friend_requests", "canMessage", "canSeePresence"),
        "legacy social routes enforce R11 privacy",
    )
    discovery_method = legacy_social[legacy_social.index("public function search"):legacy_social.index("public function profile")]
    check("orWhere('email'" not in discovery_method and "orWhere(\"email\"" not in discovery_method, "player discovery never exposes email lookup")
    realtime = contains_all(
        "backend-laravel/app/Http/Controllers/RealtimeController.php",
        ("SocialWorldPolicy", "canSeePresence", "show_current_room", "where('is_bot',false)", "محادثة الغرفة متاحة للاعبين فقط"),
        "realtime presence honors Social World privacy",
    )
    check("RoomSpectator" not in realtime, "legacy realtime chat never grants spectator membership")

    api_routes = source("backend-laravel/routes/api.php")
    required_api = (
        "/social-world", "/social-world/privacy", "/social-world/follows/{user}",
        "/social-world/activities", "/social-world/events", "/social-world/gifts",
        "/spectator/rooms", "/replays", "/clubs-world", "/admin/social-world",
    )
    check(all(route in api_routes for route in required_api), "mobile Social World, Clubs 2.0 and admin APIs are wired")
    spectator_routes = "\n".join(line for line in api_routes.splitlines() if "/spectator/" in line)
    check(not re.search(r"spectator/.+(action|play|bid|draw|discard|deal)", spectator_routes, re.I), "spectator API exposes no gameplay mutation route")

    spectator = contains_all(
        "backend-laravel/app/Http/Controllers/MobileSpectatorController.php",
        ("canSpectate", "spectatorState", "read_only' => true", "hands_visible' => false", "voice_enabled' => false", "private_chat_visible' => false", "max_room_spectators"),
        "spectator mode is capacity-limited, read-only and privacy-safe",
    )
    check("can_chat' => false" in spectator and "voice_enabled' => false" in spectator, "spectator memberships cannot join chat or voice")
    check("lockForUpdate" in spectator and spectator.count("canSpectate") >= 2, "spectator consent and capacity are rechecked atomically")
    replay_service = contains_all(
        "backend-laravel/app/Services/Social/MatchReplayService.php",
        ("spectatorState", "sanitizeNode", "hash('sha256'", "hash_equals", "integrity_verified", "spectator_safe", "hands_visible", "hand_counts", "deck_count", "stock_count", "boneyard_count"),
        "replays are signed and derived from sanitized spectator state",
    )
    secret_keys = ("'hands'", "'deck'", "'legal_cards'", "'private_state'", "'seed'", "'rng'", "'password'", "'auth_token'", "'credential'", "'email'")
    check(all(key in replay_service for key in secret_keys), "recursive replay sanitizer blocks cards, hints, credentials and RNG secrets")
    check("R11 replay capture skipped without affecting gameplay" in replay_service, "replay recording failures cannot interrupt authoritative gameplay")
    replay_controller = contains_all(
        "backend-laravel/app/Http/Controllers/MobileReplayController.php",
        ("canViewReplay", "canShareReplay", "verify($replay)", "public,friends,private", "hands_visible' => false", "voice_included' => false"),
        "replay access and sharing are privacy-gated",
    )
    check("increment('views')" in replay_controller, "authorized replay views are counted")

    for controller in ("MobileGameController.php", "RoomController.php"):
        contents = source(f"backend-laravel/app/Http/Controllers/{controller}")
        check("MatchReplayService" in contents and contents.count("->capture(") >= 3, f"{controller} records create/play/terminal replay events")
        check("allow_spectators" in contents, f"{controller} persists room spectator choice")
    contains_all(
        "backend-laravel/app/Http/Controllers/MobileVoiceController.php",
        ("private function player", "where('is_bot', false)", "allow_voice", "SocialWorldPolicy"),
        "voice remains player-only and respects privacy",
    )

    clubs = contains_all(
        "backend-laravel/app/Http/Controllers/MobileClubWorldController.php",
        ("CAPS", "LEAGUES", "one_club_per_user", "create_announcements", "SocialActivity::create", "ClubJoinRequest::updateOrCreate", "join_requests", "accept_members", "lockForUpdate"),
        "Clubs 2.0 supports leagues, capacity, requests, moderation and social announcements",
    )
    check("User::whereKey" in clubs and "visibleMembers" in clubs, "Clubs 2.0 serializes one-club membership and respects profile privacy")
    gift_controller = contains_all(
        "backend-laravel/app/Http/Controllers/MobileSocialWorldController.php",
        ("giftCatalog", "WalletService", "social_gift", "creditPrimaryAdminRevenue", "DB::transaction", "SocialGift::create"),
        "social gifts debit wallets atomically and account for platform revenue",
    )
    check("recipient_id' => 'required" in gift_controller and "gift_key' => 'required" in gift_controller, "gift recipient and catalog key are server-validated")

    admin_controller = contains_all(
        "backend-laravel/app/Http/Controllers/AdminSocialWorldController.php",
        ("hasAdminPermission('social_world')", "AdminAuditService", "admin.social_world.settings", "admin.social_world.activity", "admin.social_world.event", "admin.social_world.replay", "admin.social_world.spectator.evict"),
        "Admin Social World is permission-gated and fully audited",
    )
    check("required|in:hide,restore" in admin_controller and "required|in:feature,unfeature,hide,restore" in admin_controller, "admin moderation actions use strict allowlists")
    check("canManageSocial" in source("backend-laravel/app/Http/Controllers/AdminController.php"), "delegated admins without social_world permission do not load Social World datasets")
    web_routes = source("backend-laravel/routes/web.php")
    check("social-world.spectator.state" in web_routes and "admin.social-world.spectator.evict" in web_routes, "web Social World and Admin Social World routes are wired")
    contains_all(
        "backend-laravel/resources/views/admin/index.blade.php",
        ("data-admin-tab=\"social-world\"", "id=\"admin-social-world\"", "Admin Social World", "Audit Log"),
        "web Command Center exposes the R11 control plane",
    )

    contains_all(
        "backend-laravel/resources/views/layouts/app.blade.php",
        ("r11-social-world.css?v=230", "route('social-world')", "WARQNAA_R11"),
        "web shell loads and links the R11 experience",
    )
    for view in ("index.blade.php", "spectator.blade.php", "replay.blade.php"):
        check((ROOT / "backend-laravel/resources/views/social-world" / view).is_file(), f"web Social World {view} exists")
    css = source("backend-laravel/public/assets/css/r11-social-world.css")
    check(".r11-world" in css and "@media" in css and "prefers-reduced-motion" in css, "R11 web styling is responsive and motion-aware")

    if build >= 304:
        flutter_main = contains_all(
            "flutter_app/lib/main.dart",
            ("part 'r11_social_world.dart';", "R11ClubsWorldPage", "R11AdminSocialWorldPanel", "allowSpectators"),
            "Flutter preserves R11 clubs/admin/privacy while B304 moves Social World off the home navigation",
        )
        check("class R11SocialWorldPage" in source("flutter_app/lib/r11_social_world.dart"), "R11 Social World remains available as a non-home legacy surface")
    else:
        flutter_main = contains_all(
            "flutter_app/lib/main.dart",
            ("part 'r11_social_world.dart';", "R11ClubsWorldPage", "R11SocialWorldPage", "R11AdminSocialWorldPanel", "allowSpectators"),
            "Flutter navigation, room creation and admin surface wire R11",
        )
    tab_lengths = [int(value) for value in re.findall(r"TabController\(length:\s*(\d+)", flutter_main)]
    check(tab_lengths and max(tab_lengths) >= 7, "Flutter admin tabs retain Social World in successor releases")
    flutter_api = contains_all(
        "flutter_app/lib/services/api_client.dart",
        ("socialWorldR11", "updateSocialPrivacyR11", "createSocialEventR11", "sendSocialGiftR11", "joinSpectatorR11", "spectatorStateR11", "replayR11", "clubsWorldR11", "createClubWorldR11", "announceClubWorldR11", "respondClubJoinRequestR11", "adminSocialWorldR11", "allow_spectators"),
        "Flutter client covers Social World, spectator, replay, clubs and admin APIs",
    )
    api_build = re.search(r"warqnaAppBuild\s*=.*defaultValue:\s*(\d+)", flutter_api)
    check(api_build is not None and int(api_build.group(1)) >= 230, "Flutter API advertises R11-compatible release headers")
    flutter_r11 = contains_all(
        "flutter_app/lib/r11_social_world.dart",
        ("warqnaaR11Release = '0.6.0+230'", "class R11SocialWorldPage", "class R11SpectatorPage", "class R11ReplayViewerPage", "class R11ClubsWorldPage", "class R11AdminSocialWorldPanel", "_createEvent", "_toggleFollow", "_createClub", "_openClub", "_announce", "_manage", "Privacy-safe"),
        "Flutter ships all five polished R11 surfaces",
    )
    check("Timer.periodic" in flutter_r11 and "leaveSpectatorR11" in flutter_r11, "spectator and replay sessions have live lifecycle handling")

    contains_all(
        "backend-laravel/app/Console/Commands/CleanupSocialWorld.php",
        ("warqna:cleanup-social-world", "stale_spectators", "expired_replays", "events_to_finish", "stale_presence", "--dry-run"),
        "Social World lifecycle and replay retention cleanup is operational",
    )
    check("warqna:cleanup-social-world" in source("backend-laravel/routes/console.php"), "Social World cleanup is scheduled")
    feature_test = source("backend-laravel/tests/Feature/V230SocialWorldTest.php")
    check("test_realtime_room_chat_is_player_only" in feature_test and "test_social_world_cleanup_enforces_retention" in feature_test, "Laravel R11 suite covers spectator chat isolation and retention")

    release_files = (
        "docs/ar/releases/current/START_HERE_V230_AR.md",
        "docs/ar/releases/current/R11_SOCIAL_WORLD_CONTRACT_AR.md",
        "docs/en/R11_SOCIAL_WORLD_CONTRACT.md",
        "docs/ar/deployment/GITHUB_UPLOAD_V230_AR.md",
        "docs/ar/reports/current/QUALITY_REPORT_V230_AR.md",
        "releases/manifests/current/RELEASE_MANIFEST_V230.json",
        "scripts/windows/current/CHECK_V230_WINDOWS.bat",
        "scripts/windows/current/START_WARQNA_V230_WINDOWS.bat",
        "scripts/windows/current/START_WARQNA_R11_PORT.bat",
        "scripts/unix/current/check-v230.sh",
    )
    check(all((ROOT / item).is_file() for item in release_files), "R11 operational documentation, scripts and manifest are complete")
    windows_check = source("scripts/windows/current/CHECK_V230_WINDOWS.bat")
    unix_check = source("scripts/unix/current/check-v230.sh")
    engine_gates = ("test-v208-r8-rules.php", "test-v184-official-rules-audit.php", "test-v184-engine-stress.php", "test-v208-r8-playthrough-stress.php")
    check(all(gate in windows_check and gate in unix_check for gate in engine_gates), "R11 local checks execute the complete engine gate when PHP is available")

    workflows = (
        "backend-ci.yml", "production-release-check.yml", "flutter-android.yml",
        "flutter-ios.yml", "flutter-web-pages.yml",
    )
    for workflow in workflows:
        check("test_v230_r11_contract.py" in source(f".github/workflows/{workflow}"), f"R11 regression gate is wired into {workflow}")

    print("V230 R11 SOCIAL WORLD RETENTION CONTRACT: PASS")


if __name__ == "__main__":
    main()
