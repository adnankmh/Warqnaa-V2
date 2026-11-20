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
# Evidence must be uploaded when APK build succeeded, even if emulator smoke fails.
# A failed APK build has no emulator frames, so requiring an unconditional upload
# creates a misleading second failure instead of preserving useful diagnostics.
evidence_step = workflow.split("- name: Upload Android emulator evidence", 1)[1].split("\n      - name:", 1)[0]
require("if: always() && steps.safe_apk.outcome == 'success'" in evidence_step and "android-emulator-evidence" in evidence_step, "emulator evidence is retained after emulator failure when APK exists")
require("if-no-files-found: error" in workflow, "missing emulator evidence remains a hard failure after APK success")
require("if: failure() && steps.safe_apk.outcome == 'failure'" in workflow and "android-gradle-diagnostics" in workflow, "failed APK builds preserve separate Gradle diagnostics")
for token in ("adb install --no-streaming -r", "mResumedActivity", "topResumedActivity", "mCurrentFocus", "FATAL EXCEPTION", "screencap -p", '"status": "PASSED"'):
    require(token in smoke, f"emulator smoke includes {token}")
require("WARQNAA_ADNAN_ADMIN" not in smoke, "emulator smoke uses no private account credentials")
print("R7 ANDROID EMULATOR CONTRACT: PASS")
