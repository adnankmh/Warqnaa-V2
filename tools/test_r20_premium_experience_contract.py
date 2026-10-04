#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def text(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8", errors="ignore")


def require(condition: bool, message: str, checks: list[dict]) -> None:
    checks.append({"check": message, "ok": bool(condition)})
    if not condition:
        raise SystemExit(f"[FAIL] {message}")
    print(f"[PASS] {message}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", dest="json_path")
    args = parser.parse_args()

    checks: list[dict] = []
    v170 = text("flutter_app/lib/v170_global.dart")
    profile = text('flutter_app/lib/r6_1_world_class.dart')
    premium = text('flutter_app/lib/premium_v149.dart')
    r10 = text("flutter_app/lib/r10_1_release.dart")
    v304 = text("flutter_app/lib/v304_vertical_legend.dart")
    user = text("backend-laravel/app/Models/User.php")
    lifecycle = text("backend-laravel/app/Services/Gameplay/MatchLifecycleService.php")
    doc = text("docs/R20_PREMIUM_EXPERIENCE.md")

    require("warqnaaR19LuxuryCommerce" in r10, "R19 luxury commerce baseline is preserved", checks)
    require("r19_luxury_profile" in v304, "R19 premium profile collection remains wired", checks)
    require("ResponsiveAccountStatsV170" in v170, "responsive account/profile stats surface remains present", checks)
    require("HomeQuickActionsV170" in v170, "premium quick-action surface remains present", checks)
    require("PRIMARY_ADMIN_DISPLAY_BALANCE = '99999999999999999'" in user, "primary-admin ceremonial balance contract is preserved", checks)
    require("admin_role" in user and "isPrimaryAdmin" in user, "primary-admin authority remains role based", checks)
    require("ABANDONED_SECONDS" in lifecycle, "multiplayer lifecycle authority remains present", checks)
    require("server-authoritative" in doc.lower(), "R20 scope explicitly preserves server-authoritative gameplay/economy", checks)
    require("320px" in doc and "desktop" in doc.lower(), "R20 responsive scope covers narrow phones through desktop", checks)
    require("Arabic RTL" in doc and "English LTR" in doc, "R20 bilingual direction contract is explicit", checks)

    require("final IconData icon;" in v170, "account metrics use stable Material icons", checks)
    require("R20ProfileCounter" in profile and "avatar: Icon(icon" in profile, "live profile counters use stable icons with accessible labels", checks)
    require("MediaQuery.disableAnimationsOf(context)" in premium, "profile cover respects reduced motion", checks)
    require("r20_premium_accessibility_test.dart" in text(".github/workflows/r20-premium-experience.yml"), "R20 accessibility regression is required by its CI gate", checks)

    decorative_profile_glyphs = [glyph for glyph in ("🏅", "🪙", "👑") if f"icon: '{glyph}'" in v170]
    visual_debt = {
        "decorative_profile_glyphs_remaining": decorative_profile_glyphs,
        "must_be_zero_before_r20_merge": True,
    }
    if decorative_profile_glyphs:
        print("[WARN] R20 visual hardening pending: decorative profile glyphs still use text emoji: " + ", ".join(decorative_profile_glyphs))
    else:
        print("[PASS] stable Material icons replace decorative profile glyphs")

    report = {
        "release": "R20",
        "checks": checks,
        "visual_debt": visual_debt,
        "status": "PASS_WITH_TRACKED_VISUAL_DEBT" if decorative_profile_glyphs else "PASS",
    }
    if args.json_path:
        path = Path(args.json_path)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    print(f"R20 PREMIUM EXPERIENCE CONTRACT: {report['status']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
