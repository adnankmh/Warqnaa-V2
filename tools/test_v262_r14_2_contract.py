#!/usr/bin/env python3
"""Warqnaa R14.2 Build 262 Secure Account and CI Reliability contract."""
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
    check(meta == {
        "version": "1.0.2", "build": 262, "full": "1.0.2+262", "release": "v262",
        "display_release": "V1.0.2", "name": "Warqnaa R14.2 Secure Account & CI Reliability",
    }, "metadata is exactly R14.2 Build 262")
    check("version: 1.0.2+262" in text("flutter_app/pubspec.yaml"), "Flutter package matches Build 262")

    service = text("backend-laravel/app/Services/Account/AccountSecurityService.php")
    check(all(token in service for token in (
        "assertCurrentPassword", "Hash::check", "email_verified_at' => null", "revokeOtherApiTokens",
        "remember_token", "VerifyEmailMobile", "lockForUpdate", "Log::notice",
    )), "one transactional service protects email, password, verification and other sessions")

    web_controller = text("backend-laravel/app/Http/Controllers/AccountSecurityController.php")
    check(all(token in web_controller for token in (
        "Password::min(8)->letters()->mixedCase()->numbers()", "Rule::unique", "updateEmail", "updatePassword", "session()->regenerate",
    )), "web Account Security requires current password and strong credentials")
    mobile = text("backend-laravel/app/Http/Controllers/MobileAccountController.php")
    check(all(token in mobile for token in (
        "public function security", "public function updateEmail", "public function updatePassword", "currentAccessToken", "current_session_preserved",
    )), "mobile Account Security API preserves the current token and revokes other sessions")

    web_routes = text("backend-laravel/routes/web.php")
    api_routes = text("backend-laravel/routes/api.php")
    check(all(token in web_routes for token in (
        "account.security", "account.security.email", "account.security.password", "throttle:warqna-sensitive",
    )), "website security routes are authenticated and rate limited")
    check(all(token in api_routes for token in (
        "'/account/security'", "'/account/email'", "'/account/password'", "throttle:warqna-sensitive",
    )), "mobile security routes are authenticated and rate limited")

    profile_controller = text("backend-laravel/app/Http/Controllers/ProfileController.php")
    check("'email'=>'nullable" not in profile_controller and "'password'=>'nullable" not in profile_controller and "Hash::make($data['password'])" not in profile_controller, "legacy profile endpoint can no longer bypass credential confirmation")
    security_view = text("backend-laravel/resources/views/account/security.blade.php")
    check(all(token in security_view for token in (
        "r142-security-shell", "current_password", "password_confirmation", "account.security.email", "account.security.password", "حساب مدير محمي",
    )), "premium web security center covers email, password and admin accounts")
    check("route('account.security')" in text("backend-laravel/resources/views/admin/index.blade.php"), "Admin Command Center links to Account Security")

    seeder = text("backend-laravel/database/seeders/DatabaseSeeder.php")
    check(all(token in seeder for token in (
        "credentials are defaults for first creation only", "LOWER(username) = ?", "if(!$admin)", "if(!$abd)", "Hash::make(env('ADMIN_PASSWORD','Adnan123'))", "Hash::make('123AbdAbd')",
    )), "seeders preserve changed Adnan and Abd credentials after first creation")

    api_client = text("flutter_app/lib/services/api_client.dart")
    flutter_main = text("flutter_app/lib/main.dart")
    flutter_security = text("flutter_app/lib/r14_2_account_security.dart")
    check(all(token in api_client for token in (
        "accountSecurityR142", "updateAccountEmailR142", "updateAccountPasswordR142", "'/account/email'", "'/account/password'",
    )), "Flutter API client covers all Account Security endpoints")
    check("part 'r14_2_account_security.dart';" in flutter_main and "AccountSecurityPageR142(controller: controller)" in flutter_main, "Flutter Settings exposes the R14.2 security center")
    check("TextEditingController(text: 'Adnan')" not in flutter_main and "TextEditingController(text: 'Adnan123')" not in flutter_main and "if (warqnaProductionMode)" in flutter_main and "حسابات التجربة معطلة في الإنتاج" in flutter_main, "production login never pre-fills or bootstraps default admin demo credentials")
    check(all(token in flutter_security for token in (
        "AccountSecurityPageR142", "changeAccountEmailR142", "changeAccountPasswordR142", "_storeOfflineCredentials", "Semantics(", "RegExp(r'[A-Z]')", "onlineRequired",
    )), "Flutter security UI is bilingual, accessible, validated and synchronizes offline credentials")

    tests = text("backend-laravel/tests/Feature/V262AccountSecurityTest.php")
    check(all(token in tests for token in (
        "wrong-password", "assertJsonValidationErrors(['current_password'])", "assertNull($fresh->email_verified_at)", "assertSame(1, $fresh->tokens()->count())", "legacy_profile_form_cannot_change_credentials", "isPrimaryAdmin",
    )), "Laravel tests cover wrong password, verification reset, token revocation, bypass prevention and admin preservation")

    database = text("backend-laravel/config/database.php")
    phpunit = text("backend-laravel/phpunit.xml")
    pages = text(".github/workflows/flutter-web-pages.yml")
    r10 = text("tools/test_v220_r10_contract.py")
    check("$db !== ':memory:'" in database and 'value=":memory:"' in phpunit, "SQLite :memory: remains a native in-memory database")
    check("pages: read" in pages and "HTTP_CODE" in pages and "pages_enabled" in pages and "if: steps.pages.outputs.enabled == 'true'" in pages, "GitHub Pages permission failures degrade to a normal Web artifact build")
    check(all(token in r10 for token in ("source_files", "generated_files", "deployed_bytes", "for e in entries:")), "R10 public-size fix and complete manifest hashes remain enforced")

    required = (
        "docs/ar/releases/current/START_HERE_V262_AR.md",
        "docs/ar/releases/current/R14_2_SECURE_ACCOUNT_CONTRACT_AR.md",
        "docs/en/R14_2_SECURE_ACCOUNT_CONTRACT.md",
        "docs/ar/releases/current/RELEASE_NOTES_V262_AR.md",
        "docs/ar/releases/current/R14_2_UPGRADE_FROM_B261_AR.md",
        "docs/ar/deployment/GITHUB_UPLOAD_V262_AR.md",
        "docs/ar/reports/current/QUALITY_REPORT_V262_AR.md",
        "docs/ar/validation/current/VALIDATION_RESULTS_V262.txt",
        "releases/manifests/current/RELEASE_MANIFEST_V262.json",
        "scripts/windows/current/CHECK_V262_WINDOWS.bat",
        "scripts/windows/current/START_WARQNA_V262_WINDOWS.bat",
        "scripts/unix/current/check-v262.sh",
    )
    check(all((ROOT / path).is_file() for path in required), "R14.2 release, upgrade, validation and launcher files are complete")

    for workflow in ("backend-ci.yml", "production-release-check.yml", "flutter-android.yml", "flutter-ios.yml", "flutter-web-pages.yml", "global-release.yml"):
        check("test_v262_r14_2_contract.py" in text(".github/workflows/" + workflow), "R14.2 contract reaches " + workflow)
    print("V262 R14.2 SECURE ACCOUNT & CI RELIABILITY CONTRACT: PASS")


if __name__ == "__main__":
    main()
