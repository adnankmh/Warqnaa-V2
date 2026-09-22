#!/usr/bin/env python3
"""Prevent regression of the R7 Android install-and-launch release gate."""
from pathlib import Path


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(f"[FAIL] {message}")
    print(f"[PASS] {message}")


root = Path(__file__).resolve().parents[1]
workflow = (root / ".github/workflows/flutter-android.yml").read_text(encoding="utf-8")
smoke = (root / "tools/android_emulator_smoke.sh").read_text(encoding="utf-8")

require("reactivecircus/android-emulator-runner@a421e43855164a8197daf9d8d40fe71c6996bb0d" in workflow, "emulator action is immutable and pinned")
require("Install and launch APK on an isolated Android emulator" in workflow, "Android workflow installs the built APK")
require(workflow.index("Build launch-safe test APK") < workflow.index("Install and launch APK on an isolated Android emulator"), "the tested APK is built before emulator launch")
require("if: always()" in workflow and "android-emulator-evidence" in workflow, "emulator evidence is retained even on failure")
for token in ("adb install --no-streaming -r", "mResumedActivity", "topResumedActivity", "mCurrentFocus", "FATAL EXCEPTION", "screencap -p", '"status": "PASSED"'):
    require(token in smoke, f"emulator smoke includes {token}")
require("WARQNAA_ADNAN_ADMIN" not in smoke, "emulator smoke uses no private account credentials")
print("R7 ANDROID EMULATOR CONTRACT: PASS")
