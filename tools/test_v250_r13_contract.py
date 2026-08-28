#!/usr/bin/env python3
"""Warqnaa R13 Build 250 Engine Gold release contract."""
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
    body = source(relative)
    missing = [needle for needle in needles if needle not in body]
    check(not missing, label + (" (missing: " + ", ".join(missing) + ")" if missing else ""))
    return body


def main() -> None:
    metadata = json.loads(source("RELEASE_VERSION.json"))
    build = int(metadata.get("build", 0))
    check(int(metadata.get("build", 0)) >= 250 and metadata.get("full") == f'{metadata.get("version")}+{metadata.get("build")}', "R13 or a compatible successor has internally consistent metadata")
    check(f"version: {metadata['full']}" in source("flutter_app/pubspec.yaml"), "Flutter package matches the current R13-compatible successor")

    registry = contains(
        "backend-laravel/app/Services/GameEngine/EngineRegistry.php",
        ("'tarneeb'", "'tarneeb_41'", "'tarneeb_61'", "'syrian_tarneeb'", "'tarneeb_400'",
         "'trix'", "'trix_partner'", "'trix_complex'", "'hand'", "'hand_partner'",
         "'saudi_hand'", "'banakil'", "'pinochle'", "'solitaire_multiplayer'", "'baloot'",
         "'basra'", "'domino'", "'backgammon'", "'jackaroo'", "'chess'",
         "'engine_certification'=>'r13_engine_gold_v1'", "'server_authoritative'=>true"),
        "all 20 customer engines are registered and server-authoritative",
    )
    check(registry.count("self::entry(") == 20, "registry contains exactly 20 certified engine entries")

    config = contains(
        "backend-laravel/config/warqna_engine_gold.php",
        ("'release' => '0.8.0+250'", "'matches_per_engine' => 25", "'matches_per_engine' => 2000",
         "'matches_per_engine' => 5000", "'max_transitions' => 400", "'advertised_action_validates'",
         "'no_active_deadlock'", "'replayable_seed_for_seeded_engines'"),
        "smoke, release and nightly certification profiles plus invariants exist",
    )
    check(config.count("'matches_per_engine'") == 3, "Engine Gold has exactly three bounded certification profiles")

    harness = contains(
        "backend-laravel/tools/test-v250-r13-engine-gold.php",
        ("WARQNA_GOLD_MATCHES_PER_ENGINE", "WARQNA_GOLD_MAX_TRANSITIONS", "WARQNA_GOLD_REPORT",
         "EngineRegistry::all()", "GameFactory::make", "goldAssertState", "availableActions",
         "->validate(", "->apply(", "onTurnTimeout", "active engine deadlock", "state is not JSON serializable",
         "supplied replay seed was not preserved", "r13_engine_gold_v1", "total_matches", "status' => 'gold'"),
        "standalone runner certifies legal bounded matches and emits a machine report",
    )
    check("['wait', 'resign', 'offer_draw', 'organize']" in harness, "certifier avoids artificial chess resignation and no-op choices")

    adapter = contains(
        "backend-laravel/app/Services/GameEngine/GlobalCardEngineRules.php",
        ("$options['seed'] ?? random_int", "'engine_certification'=>'r13_engine_gold_v1'", "availableActions", "applyAction"),
        "global adapter preserves replay seeds and exposes certification",
    )
    bot = contains(
        "backend-laravel/app/Services/GameEngine/GlobalEngines/GlobalCardEngineCore.php",
        ("botActionsOfType", "botActionCardCount", "botChooseCardAction", "handPower", "arsort($strength",
         "replace_wild", "move_to_foundation", "crc32", "selected from availableActions"),
        "global bot policy is deterministic, strength-aware and legal-action bounded",
    )
    check("return $actions[0];" in bot, "bot policy has a safe advertised-action fallback")
    contains(
        "backend-laravel/app/Services/GameEngine/TarneebRules.php",
        ("$options['seed'] ?? random_int", "'engine_certification'=>'r13_engine_gold_v1'"),
        "Tarneeb preserves replay seed and certification identity",
    )

    unit = contains(
        "backend-laravel/tests/Unit/V250EngineGoldContractTest.php",
        ("test_every_customer_engine_is_registered_for_gold_certification",
         "test_global_adapter_preserves_a_replayable_seed_and_advertises_only_valid_moves",
         "test_release_profile_certifies_thousands_of_matches_per_engine", "assertCount(20"),
        "Laravel unit contract covers registry, deterministic seed, valid actions and scale",
    )
    check("assertGreaterThanOrEqual(2000" in unit and "assertGreaterThanOrEqual(5000" in unit, "Laravel locks release and nightly certification scale")

    release_files = (
        "docs/ar/releases/current/START_HERE_V250_AR.md",
        "docs/ar/releases/current/R13_ENGINE_GOLD_CONTRACT_AR.md",
        "docs/en/R13_ENGINE_GOLD_CONTRACT.md",
        "docs/ar/releases/current/RELEASE_NOTES_V250_AR.md",
        "docs/ar/releases/current/R13_UPGRADE_FROM_B240_AR.md",
        "docs/ar/deployment/GITHUB_UPLOAD_V250_AR.md",
        "docs/ar/reports/current/QUALITY_REPORT_V250_AR.md",
        "docs/ar/validation/current/VALIDATION_RESULTS_V250.txt",
        "releases/manifests/current/RELEASE_MANIFEST_V250.json",
        "scripts/windows/current/CHECK_V250_WINDOWS.bat",
        "scripts/windows/current/START_WARQNA_V250_WINDOWS.bat",
        "scripts/unix/current/check-v250.sh",
        ".github/workflows/engine-gold-nightly.yml",
    )
    check(all((ROOT / path).is_file() for path in release_files), "R13 docs, manifest, operations scripts and scheduled certification are complete")

    gates = ("test_v208_r8_contract.py", "test_v209_r9_contract.py", "test_v210_r9_1_contract.py",
             "test_v220_r10_contract.py", "test_v221_r101_contract.py", "test_v230_r11_contract.py",
             "test_v240_r12_contract.py", "test_v250_r13_contract.py", "test-v250-r13-engine-gold.php")
    for script in ("scripts/unix/current/check-v250.sh", "scripts/windows/current/CHECK_V250_WINDOWS.bat"):
        body = source(script)
        check(all(gate in body for gate in gates), f"{script} runs the R8–R13 compatibility chain")

    for workflow in ("backend-ci.yml", "production-release-check.yml", "flutter-android.yml", "flutter-ios.yml", "flutter-web-pages.yml"):
        body = source(".github/workflows/" + workflow)
        check("test_v250_r13_contract.py" in body, f"R13 contract reaches {workflow}")
    release_ci = source(".github/workflows/production-release-check.yml")
    if build >= 304:
        check("WARQNA_GOLD_MATCHES_PER_ENGINE: 50" in release_ci and "WARQNA_GOLD_MAX_TRANSITIONS: 120" in release_ci and "test-v250-r13-engine-gold.php" in release_ci, "B304 release CI runs a bounded 50-match-per-engine Gold profile")
        nightly = source(".github/workflows/engine-gold-nightly.yml")
        check("WARQNA_GOLD_MATCHES_PER_ENGINE: 100" in nightly and "WARQNA_GOLD_MAX_TRANSITIONS: 160" in nightly and "WARQNA_GOLD_REPORT" in nightly and "upload-artifact" in nightly, "B304 nightly CI runs the extended bounded Gold profile and retains its report")
    else:
        check("WARQNA_GOLD_MATCHES_PER_ENGINE: 2000" in release_ci and "test-v250-r13-engine-gold.php" in release_ci, "release CI certifies 2,000 matches per engine")
        nightly = source(".github/workflows/engine-gold-nightly.yml")
        check("WARQNA_GOLD_MATCHES_PER_ENGINE: 5000" in nightly and "WARQNA_GOLD_REPORT" in nightly and "upload-artifact" in nightly, "scheduled CI certifies 5,000 matches per engine and retains its report")

    print("V250 R13 ENGINE GOLD CONTRACT: PASS")


if __name__ == "__main__":
    main()
