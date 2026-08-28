#!/usr/bin/env python3
"""Warqnaa R14 Build 260 Global Release contract."""
from __future__ import annotations
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def check(value: bool, label: str) -> None:
    if not value: raise SystemExit("[FAIL] " + label)
    print("[PASS] " + label)


def text(path: str) -> str:
    target = ROOT / path
    check(target.is_file(), path + " exists")
    return target.read_text(encoding="utf-8")


def main() -> None:
    meta = json.loads(text("RELEASE_VERSION.json"))
    check(int(meta.get("build", 0)) >= 260 and str(meta.get("name", "")).startswith("Warqnaa"), "metadata preserves the cumulative R14 Global Release line")
    check(int(meta.get("build", 0)) >= 260 and f"version: {meta['full']}" in text("flutter_app/pubspec.yaml"), "Flutter package matches current cumulative R14 metadata")
    config = text("backend-laravel/config/warqna_global_release.php")
    build = int(meta.get("build", 0))
    common = ("'backend', 'web', 'android', 'ios'", "'matches_per_engine' => 2000", "'release_checksums'")
    check(all(item in config for item in common), "four channels and mandatory gates are fixed")
    if build >= 304:
        check("'locales' => ['ar', 'en']" in config and "'future_locales' => ['de', 'tr', 'fr', 'es']" in config, "B304 product locales are Arabic/English with future locale registry preserved")
    else:
        check("'locales' => ['ar', 'en', 'de', 'tr', 'fr', 'es']" in config, "R14 six-locale product contract is preserved")
    service = text("backend-laravel/app/Services/Platform/GlobalReleaseReadinessService.php")
    check(all(item in service for item in ("release_version", "production_definition", "android_store_icon", "web_manifest", "APP_DEBUG", "HTTPS")), "Laravel distinguishes source readiness from production warnings")
    command = text("backend-laravel/app/Console/Commands/GlobalReleaseCheck.php")
    check("warqna:global-release-check" in command and "--strict" in command and "--json" in command, "operations command supports human, strict and JSON modes")
    preflight = text("tools/global_release_preflight.py")
    check(all(item in preflight for item in ("play_icon_512", "feature_graphic_1024x500", "secret_policy", "deployment_only", "engine_gold")), "cross-channel preflight validates launch assets and boundaries")
    unit = text("backend-laravel/tests/Unit/V260GlobalReleaseContractTest.php")
    check("test_global_release_has_four_channels_and_engine_gold" in unit and "test_non_strict_readiness_distinguishes_source_gates_from_deployment_secrets" in unit, "Laravel unit contract covers channels and deployment boundary")
    workflow = text(".github/workflows/global-release.yml")
    check(all(item in workflow for item in ("foundation:", "backend-image:", "android-web:", "ios:", "release-evidence:", "test-v250-r13-engine-gold.php", "build appbundle", "build web", "build ios --release --no-codesign", "docker build", "upload-artifact")), "Global Release workflow gates all four channels and evidence")
    for workflow_name in ("backend-ci.yml", "production-release-check.yml", "flutter-android.yml", "flutter-ios.yml", "flutter-web-pages.yml"):
        check("test_v260_r14_contract.py" in text(".github/workflows/" + workflow_name), "R14 contract reaches " + workflow_name)
    required = (
        "docs/ar/releases/current/START_HERE_V260_AR.md", "docs/ar/releases/current/R14_GLOBAL_RELEASE_CONTRACT_AR.md",
        "docs/en/R14_GLOBAL_RELEASE_CONTRACT.md", "docs/ar/releases/current/RELEASE_NOTES_V260_AR.md",
        "docs/ar/releases/current/R14_UPGRADE_FROM_B250_AR.md", "docs/ar/deployment/GITHUB_UPLOAD_V260_AR.md",
        "docs/ar/deployment/R14_GLOBAL_LAUNCH_CHECKLIST_AR.md", "docs/ar/reports/current/QUALITY_REPORT_V260_AR.md",
        "docs/ar/validation/current/VALIDATION_RESULTS_V260.txt", "releases/manifests/current/RELEASE_MANIFEST_V260.json",
        "scripts/windows/current/CHECK_V260_WINDOWS.bat", "scripts/windows/current/START_WARQNA_V260_WINDOWS.bat",
        "scripts/unix/current/check-v260.sh",
    )
    check(all((ROOT / path).is_file() for path in required), "R14 release, launch, operations and manifest files are complete")
    for script in ("scripts/windows/current/CHECK_V260_WINDOWS.bat", "scripts/unix/current/check-v260.sh"):
        body = text(script)
        check(all(gate in body for gate in ("test_v208_r8_contract.py", "test_v230_r11_contract.py", "test_v240_r12_contract.py", "test_v250_r13_contract.py", "test_v260_r14_contract.py", "global_release_preflight.py")), script + " runs R8–R14 and global preflight")
    print("V260 R14 GLOBAL RELEASE CONTRACT: PASS")


if __name__ == "__main__": main()
