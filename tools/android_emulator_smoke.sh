#!/usr/bin/env bash
set -euo pipefail

APK=${1:?Usage: android_emulator_smoke.sh APK [EVIDENCE_DIR]}
EVIDENCE_DIR=${2:-build/emulator-evidence}
mkdir -p "$EVIDENCE_DIR"
rm -f "$EVIDENCE_DIR/result.json" "$EVIDENCE_DIR/first-frame.png"

collect_evidence() {
  adb logcat -d > "$EVIDENCE_DIR/full-logcat.txt" 2>&1 || true
  adb shell dumpsys activity activities > "$EVIDENCE_DIR/activity.txt" 2>&1 || true
  adb shell dumpsys activity top > "$EVIDENCE_DIR/activity-top.txt" 2>&1 || true
  adb shell dumpsys window windows > "$EVIDENCE_DIR/windows.txt" 2>&1 || true
  # Do not replace the frame that passed validation with a later exit snapshot.
  adb exec-out screencap -p > "$EVIDENCE_DIR/exit-frame.png" 2>/dev/null || true
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
# Control the notification permission fixture on this isolated test device.
# Android's permission activity otherwise races with the first-frame check.
# Do not grant unrelated runtime permissions or change app permission logic.
NOTIFICATION_PERMISSION=not_required
if (( $(cat "$EVIDENCE_DIR/android-api.txt") >= 33 )); then
  adb shell pm grant "$PACKAGE" android.permission.POST_NOTIFICATIONS
  NOTIFICATION_PERMISSION=pregranted_on_test_device
fi
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

valid_frame() {
python3 - "$1" <<'PY'
from pathlib import Path
import sys

image = Path(sys.argv[1])
payload = image.read_bytes()
if not payload.startswith(b"\x89PNG\r\n\x1a\n") or len(payload) < 10_000:
    raise SystemExit(1)
print(f"[PASS] Captured first Android frame: {len(payload)} bytes")
PY
}

# A resumed Android activity can precede Flutter's first rendered screen.
# Keep the existing screenshot gate, but allow bounded time for rendering.
FRAME_READY=false
for FRAME_ATTEMPT in $(seq 1 30); do
  CURRENT_PID=$(adb shell pidof -s "$PACKAGE" 2>/dev/null | tr -d '\r' || true)
  if [[ "$CURRENT_PID" != "$PID" ]]; then
    echo "[FAIL] App exited or restarted while waiting for its first frame." >&2
    exit 1
  fi
  if adb exec-out screencap -p > "$EVIDENCE_DIR/frame-candidate.png" 2>/dev/null && \
      valid_frame "$EVIDENCE_DIR/frame-candidate.png"; then
    mv "$EVIDENCE_DIR/frame-candidate.png" "$EVIDENCE_DIR/first-frame.png"
    FRAME_READY=true
    break
  fi
  sleep 1
done
if [[ "$FRAME_READY" != true ]]; then
  echo "[FAIL] Emulator screenshot is missing or invalid after 30 capture attempts." >&2
  exit 1
fi

# Refresh crash evidence after the rendering wait, not just after launch.
adb logcat --pid="$PID" -d > "$EVIDENCE_DIR/app-logcat.txt"
adb shell dumpsys meminfo "$PACKAGE" > "$EVIDENCE_DIR/meminfo.txt"
collect_evidence
CURRENT_PID=$(adb shell pidof -s "$PACKAGE" 2>/dev/null | tr -d '\r' || true)
if [[ "$CURRENT_PID" != "$PID" ]]; then
  echo "[FAIL] App exited or restarted after its first frame." >&2
  exit 1
fi
if ! grep -hE 'mResumedActivity|topResumedActivity|ResumedActivity|mCurrentFocus|mFocusedApp|^[[:space:]]*ACTIVITY ' \
    "$EVIDENCE_DIR/activity.txt" "$EVIDENCE_DIR/activity-top.txt" "$EVIDENCE_DIR/windows.txt" | grep -F "$PACKAGE" > /dev/null; then
  echo "[FAIL] App lost its foreground activity while rendering." >&2
  exit 1
fi
if grep -E 'FATAL EXCEPTION|Fatal signal [0-9]+|ANR in ' "$EVIDENCE_DIR/app-logcat.txt"; then
  echo "[FAIL] Android reported a fatal exception, native crash or ANR." >&2
  exit 1
fi
if grep -F "ANR in $PACKAGE" "$EVIDENCE_DIR/full-logcat.txt"; then
  echo "[FAIL] Android reported an ANR for $PACKAGE." >&2
  exit 1
fi

APK_SHA256=$(sha256sum "$APK" | cut -d ' ' -f 1)
cat > "$EVIDENCE_DIR/result.json" <<EOF
{
  "status": "PASSED",
  "package": "$PACKAGE",
  "pid": $PID,
  "frame_capture_attempts": $FRAME_ATTEMPT,
  "notification_permission": "$NOTIFICATION_PERMISSION",
  "android_api": "$(cat "$EVIDENCE_DIR/android-api.txt")",
  "apk_sha256": "$APK_SHA256",
  "checks": ["installed", "launcher_started", "process_alive", "activity_resumed", "no_app_crash_or_anr", "first_frame_captured"]
}
EOF

echo "[PASS] APK installed and remained foregrounded on Android API $(cat "$EVIDENCE_DIR/android-api.txt")."
