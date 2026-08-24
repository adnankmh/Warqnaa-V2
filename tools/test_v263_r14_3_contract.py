#!/usr/bin/env python3
"""Warqnaa R14.3 Build 263 CI, engine and account-security contract."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def text(path: str) -> str:
    target = ROOT / path
    if not target.is_file():
        raise SystemExit("[FAIL] missing " + path)
    return target.read_text(encoding="utf-8")


def check(value: bool, label: str) -> None:
    if not value:
        raise SystemExit("[FAIL] " + label)
    print("[PASS] " + label)


def main() -> None:
    meta = json.loads(text("RELEASE_VERSION.json"))
    check(meta.get("full") == "1.0.3+263", "release metadata is Build 263")
    main_dart = text("flutter_app/lib/main.dart")
    check("part 'r14_2_account_security.dart';" in main_dart and "R143AccountSecurityPage" in main_dart, "Flutter security center is reachable")
    check("Icons.swords" not in text("flutter_app/lib/r12_competitive.dart"), "unsupported competitive icon removed")
    social_world = text("flutter_app/lib/r11_social_world.dart")
    check("Container(minHeight:" not in social_world and "constraints: BoxConstraints(minHeight:" in social_world, "invalid Container minHeight replaced with constraints")
    check("import 'services/app_sounds.dart';" in text("flutter_app/lib/premium_v149.dart"), "AppSounds import is explicit")
    check("for (final product in products)" in text("flutter_app/lib/v176_release.dart"), "store catalog reference is valid")
    check("String _multiplierLabelV183" in text("flutter_app/lib/v183_overhaul.dart"), "booster multiplier formatter exists")
    security = text("backend-laravel/app/Http/Controllers/AccountSecurityController.php")
    check(all(token in security for token in ("current_password", "Password::min(10)->mixedCase()->numbers()", "email_verified_at = null", "tokens->delete()")), "server account changes require re-authentication and revoke sessions")
    profile = text("backend-laravel/app/Http/Controllers/ProfileController.php")
    check("'email'=>" not in profile and "'password'=>" not in profile, "legacy profile endpoint cannot change credentials")
    seeder = text("backend-laravel/database/seeders/DatabaseSeeder.php")
    check("$admin=User::updateOrCreate" not in seeder and "$abd=User::updateOrCreate" not in seeder, "seed reruns preserve changed admin credentials")
    check("Str::random(48)" in seeder and "Adnan123" not in text("flutter_app/lib/premium_v151.dart"), "administrator passwords are not shipped in app code")
    check("adnanasd63@gmail.com" not in text("backend-laravel/.env.example") and "Adnan123" not in text("backend-laravel/start-windows.bat"), "Windows and env templates do not publish administrator credentials")
    preflight = text("tools/global_release_preflight.py")
    check("git\", \"-C\"" in preflight and 'not tracked("backend-laravel/.env")' in preflight, "runtime CI env does not trigger a false secret-policy failure")
    gold = text("backend-laravel/tools/test-v250-r13-engine-gold.php")
    check("$selectedState = $preview" in gold and "$state = $selectedState" in gold, "Engine Gold bot accepts only legal state-changing actions")
    print("V263 R14.3 CI ENGINE SECURITY CONTRACT: PASS")


if __name__ == "__main__":
    main()
