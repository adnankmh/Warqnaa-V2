#!/usr/bin/env python3
"""Warqnaa R14.1 Build 261 Legendary Experience and CI hotfix contract."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def check(value: bool, label: str) -> None:
    if not value:
        raise SystemExit("[FAIL] " + label)
    print("[PASS] " + label)


def text(path: str) -> str:
    target = ROOT / path
    check(target.is_file(), path + " exists")
    return target.read_text(encoding="utf-8")


def main() -> None:
    meta = json.loads(text("RELEASE_VERSION.json"))
    check(
        meta == {
            "version": "1.0.1",
            "build": 261,
            "full": "1.0.1+261",
            "release": "v261",
            "display_release": "V1.0.1",
            "name": "Warqnaa R14.1 Legendary Experience",
        },
        "metadata is exactly R14.1 Build 261",
    )
    check("version: 1.0.1+261" in text("flutter_app/pubspec.yaml"), "Flutter release matches Build 261")

    r10 = text("tools/test_v220_r10_contract.py")
    check(
        all(token in r10 for token in ("source_files", "generated_files", "source_bytes", "generated_bytes", "deployed_bytes", "28*1024*1024", "for e in entries:")),
        "R10 contract separates build budgets, caps deployment and hashes the complete asset manifest",
    )

    layout = text("backend-laravel/resources/views/layouts/app.blade.php")
    check(
        all(token in layout for token in ("r14-1-legendary-experience.css", "warqna-r14-1", "WARQNAA_R14_1", "r141-footer", "R14.1 • B261")),
        "Laravel shell loads the Legendary Experience, release marker and expanded footer",
    )
    check(
        "routeIs('rooms.show')" in layout and "routeIs('room.show')" not in layout,
        "Laravel room route detection uses the real route name",
    )
    home = text("backend-laravel/resources/views/home.blade.php")
    check(
        all(token in home for token in ("r141-hero-stage", "r141-livebar", "r141-game-shelf", "r141-world-grid", "r141-quality", "20 محركًا معتمدًا")),
        "expanded Laravel home includes hero, live platform, games, worlds and quality story",
    )
    check("route('games')" in home and "route('games.index')" not in home, "home play CTA resolves the registered games route")
    lobby = text("backend-laravel/resources/views/games/index.blade.php")
    check(
        all(token in lobby for token in ("r141-lobby-hero", "r141-lobby-stats", "gameSearchR141", "data-family-r141", "r141-game-cover", "r141-game-enter", "r141NoGames")),
        "Laravel Game Hall has responsive discovery, filtering and premium game cards",
    )
    css = text("backend-laravel/public/assets/css/r14-1-legendary-experience.css")
    check(
        len(css) >= 20000
        and all(token in css for token in ("--r141-gold", ".r141-btn-primary", ".r141-game-card", ".r141-playing-card", ":focus-visible", "prefers-reduced-motion")),
        "web design layer is substantial, accessible and motion-safe",
    )

    main_dart = text("flutter_app/lib/main.dart")
    check(
        "part 'r14_1_legendary.dart';" in main_dart
        and "R141LegendaryHomeDashboard(controller: controller, onTab: onTab)" in main_dart
        and "itemBuilder: (_, i) => R141LegendaryGameCard(" in main_dart,
        "Flutter routes home and Game Hall cards through the R14.1 experience",
    )
    flutter = text("flutter_app/lib/r14_1_legendary.dart")
    check(
        all(token in flutter for token in ("warqnaaR141Release", "R141LegendaryHomeDashboard", "R141LegendaryButton", "R141LegendaryGameCard", "R141Palette", "Semantics(")),
        "Flutter premium dashboard, controls, cards and accessibility semantics are complete",
    )
    theme = text("flutter_app/lib/r10_1_release.dart")
    check(
        "minimumSize: const Size(48, 50)" in theme
        and "disabledBackgroundColor" in theme
        and "backgroundColor: scheme.onSurface.withValues(alpha: .035)" in theme,
        "Flutter global buttons have premium sizing, disabled state and glass outline",
    )

    required = (
        "docs/ar/releases/current/START_HERE_V261_AR.md",
        "docs/ar/releases/current/R14_1_LEGENDARY_EXPERIENCE_CONTRACT_AR.md",
        "docs/en/R14_1_LEGENDARY_EXPERIENCE_CONTRACT.md",
        "docs/ar/releases/current/RELEASE_NOTES_V261_AR.md",
        "docs/ar/releases/current/R14_1_UPGRADE_FROM_B260_AR.md",
        "docs/ar/deployment/GITHUB_UPLOAD_V261_AR.md",
        "docs/ar/reports/current/QUALITY_REPORT_V261_AR.md",
        "docs/ar/validation/current/VALIDATION_RESULTS_V261.txt",
        "releases/manifests/current/RELEASE_MANIFEST_V261.json",
        "scripts/windows/current/CHECK_V261_WINDOWS.bat",
        "scripts/windows/current/START_WARQNA_V261_WINDOWS.bat",
        "scripts/unix/current/check-v261.sh",
    )
    check(all((ROOT / path).is_file() for path in required), "R14.1 release, upgrade, validation and launcher files are complete")

    for workflow_name in (
        "backend-ci.yml",
        "production-release-check.yml",
        "flutter-android.yml",
        "flutter-ios.yml",
        "flutter-web-pages.yml",
        "global-release.yml",
    ):
        check(
            "test_v261_r14_1_contract.py" in text(".github/workflows/" + workflow_name),
            "R14.1 contract reaches " + workflow_name,
        )
    print("V261 R14.1 LEGENDARY EXPERIENCE CONTRACT: PASS")


if __name__ == "__main__":
    main()
