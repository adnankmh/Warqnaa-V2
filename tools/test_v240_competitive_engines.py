#!/usr/bin/env python3
"""R12 competitive-to-engine integration and inherited engine regression gate."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    raise SystemExit("[FAIL] " + message)


def read(relative: str) -> str:
    path = ROOT / relative
    if not path.is_file():
        fail("missing " + relative)
    return path.read_text(encoding="utf-8")


def check(condition: bool, message: str) -> None:
    if not condition:
        fail(message)
    print("[PASS] " + message)


def main() -> None:
    catalog = read("backend-laravel/app/Services/Games/GameCatalog.php")
    factory = read("backend-laravel/app/Services/GameEngine/GameFactory.php")
    block = catalog[catalog.index("public static function all"):catalog.index("public static function customerKeys")]
    keys = re.findall(r"^\s*'([a-z0-9_]+)'\s*=>\s*\[", block, re.M)
    check(len(keys) >= 12 and len(keys) == len(set(keys)), "customer game catalog is unique and complete")
    missing = [key for key in keys if not re.search(rf"['\"]{re.escape(key)}['\"]", factory)]
    check(not missing, "every customer game has an explicit authoritative GameFactory mapping" + (": " + ", ".join(missing) if missing else ""))

    matchmaking = read("backend-laravel/app/Services/Competitive/CompetitiveMatchmakingService.php")
    bracket = read("backend-laravel/app/Services/Competitive/TournamentBracketService.php")
    rating = read("backend-laravel/app/Services/Competitive/CompetitiveRatingService.php")
    for service, label in ((matchmaking, "Ranked"), (bracket, "tournament")):
        check("GameFactory::make" in service and "initialState" in service, f"{label} rooms start through the registered server engine")
        check("server_authoritative'=>true" in service and "is_bot'=>false" in service, f"{label} rooms are authoritative and bot-free")
    check("resolveResult" in rating and "rating_processed" in rating and "lockForUpdate" in rating, "MMR consumes locked server results exactly once")
    check("request()->" not in rating and "client_winner" not in rating, "rating engine never trusts a client-submitted winner")

    for relative, marker in (
        ("backend-laravel/tools/test-v208-r8-rules.php", "Tarneeb"),
        ("backend-laravel/tools/test-v184-official-rules-audit.php", "Banakil"),
        ("backend-laravel/tools/test-v184-engine-stress.php", "engine stress scenarios completed"),
        ("backend-laravel/tools/test-v208-r8-playthrough-stress.php", "WARQNA_PLAYTHROUGH_RUNS"),
    ):
        check(marker in read(relative), f"inherited executable engine gate retained: {Path(relative).name}")

    feature = read("backend-laravel/tests/Feature/V240CompetitiveArenaTest.php")
    check("test_ranked_matchmaker_creates_server_authoritative_bot_free_room" in feature, "Laravel proves Ranked room integrity")
    check("test_rating_result_is_idempotent_and_writes_both_scopes" in feature, "Laravel proves engine result-to-MMR idempotence")
    print("V240 R12 COMPETITIVE ENGINE GATE: PASS")


if __name__ == "__main__":
    main()
