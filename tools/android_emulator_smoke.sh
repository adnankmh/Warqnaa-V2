#!/usr/bin/env bash
set -euo pipefail

APK=${1:?Usage: android_emulator_smoke.sh APK [EVIDENCE_DIR]}
EVIDENCE_DIR=${2:-build/emulator-evidence}
mkdir -p "$EVIDENCE_DIR"

collect_evidence() {
  adb logcat -d > "$EVIDENCE_DIR/full-logcat.txt" 2>&1 || true
  adb shell dumpsys activity activities > "$EVIDENCE_DIR/activity.txt" 2>&1 || true
  adb shell dumpsys activity top > "$EVIDENCE_DIR/activity-top.txt" 2>&1 || true
  adb shell dumpsys window windows > "$EVIDENCE_DIR/windows.txt" 2>&1 || true
  adb exec-out screencap -p > "$EVIDENCE_DIR/first-frame.png" 2>/dev/null || true
}
trap collect_evidence EXIT

if [[ ! -f "$APK" ]]; then
  echo "[FAIL] APK not found: $APK" >&2
  exit 1
fi

adb wait-for-device
adb shell getprop ro.build.version.sdk | tr -d '\r' > "$EVIDENCE_DIR/android-api.txt"
adb logcat -c

if command -v apkanalyzer >/dev/null 2>&1; then
  PACKAGE=$(apkanalyzer manifest application-id "$APK" | tr -d '\r')
else
  AAPT=$(find "$ANDROID_HOME/build-tools" -type f -name aapt -print | sort -V | tail -n 1)
  PACKAGE=$("$AAPT" dump badging "$APK" | sed -n "s/^package: name='\([^']*\)'.*/\1/p" | head -n 1)
fi
if [[ ! "$PACKAGE" =~ ^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$ ]]; then
  echo "[FAIL] Could not derive a safe Android package ID from the APK." >&2
  exit 1
fi

adb install --no-streaming -r "$APK" | tee "$EVIDENCE_DIR/install.txt"
adb shell monkey -p "$PACKAGE" -c android.intent.category.LAUNCHER 1 \
  | tee "$EVIDENCE_DIR/launch.txt"

PID=''
FOREGROUND=''
for _ in $(seq 1 30); do
  PID=$(adb shell pidof -s "$PACKAGE" 2>/dev/null | tr -d '\r' || true)
  FOREGROUND=$({
    adb shell dumpsys activity activities 2>/dev/null
    adb shell dumpsys activity top 2>/dev/null
    adb shell dumpsys window windows 2>/dev/null
  } | grep -E 'mResumedActivity|topResumedActivity|ResumedActivity|mCurrentFocus|mFocusedApp|^[[:space:]]*ACTIVITY ' | grep -F "$PACKAGE" | head -n 1 || true)
  if [[ -n "$PID" && -n "$FOREGROUND" ]]; then
    break
  fi
  sleep 1
done

if [[ -z "$PID" ]]; then
  echo "[FAIL] $PACKAGE did not remain running after launch." >&2
  exit 1
fi
if [[ -z "$FOREGROUND" ]]; then
  echo "[FAIL] $PACKAGE did not reach a resumed foreground activity." >&2
  exit 1
fi

adb logcat --pid="$PID" -d > "$EVIDENCE_DIR/app-logcat.txt"
adb shell dumpsys meminfo "$PACKAGE" > "$EVIDENCE_DIR/meminfo.txt"
collect_evidence
if grep -E 'FATAL EXCEPTION|Fatal signal [0-9]+|ANR in ' "$EVIDENCE_DIR/app-logcat.txt"; then
  echo "[FAIL] Android reported a fatal exception, native crash or ANR." >&2
  exit 1
fi
if grep -F "ANR in $PACKAGE" "$EVIDENCE_DIR/full-logcat.txt"; then
  echo "[FAIL] Android reported an ANR for $PACKAGE." >&2
  exit 1
fi

python3 - "$EVIDENCE_DIR/first-frame.png" <<'PY'
from pathlib import Path
import sys

image = Path(sys.argv[1])
payload = image.read_bytes()
if not payload.startswith(b"\x89PNG\r\n\x1a\n") or len(payload) < 10_000:
    raise SystemExit("[FAIL] Emulator screenshot is missing or invalid")
print(f"[PASS] Captured first Android frame: {len(payload)} bytes")
PY

APK_SHA256=$(sha256sum "$APK" | cut -d ' ' -f 1)
cat > "$EVIDENCE_DIR/result.json" <<EOF
{
  "status": "PASSED",
  "package": "$PACKAGE",
  "pid": $PID,
  "android_api": "$(cat "$EVIDENCE_DIR/android-api.txt")",
  "apk_sha256": "$APK_SHA256",
  "checks": ["installed", "launcher_started", "process_alive", "activity_resumed", "no_app_crash_or_anr", "first_frame_captured"]
}
EOF

echo "[PASS] APK installed and remained foregrounded on Android API $(cat "$EVIDENCE_DIR/android-api.txt")."
