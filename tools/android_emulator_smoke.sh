#!/usr/bin/env bash
set -euo pipefail

APK=${1:?Usage: android_emulator_smoke.sh APK [EVIDENCE_DIR]}
EVIDENCE_DIR=${2:-build/emulator-evidence}
mkdir -p "$EVIDENCE_DIR"
rm -f "$EVIDENCE_DIR/result.json" "$EVIDENCE_DIR/first-frame.png" \
  "$EVIDENCE_DIR/frame-candidate.png" "$EVIDENCE_DIR/frame-attempts.txt" \
  "$EVIDENCE_DIR/exit-frame.png" "$EVIDENCE_DIR/process-queries.txt" \
  "$EVIDENCE_DIR/process-query.txt" "$EVIDENCE_DIR/process-query-error.txt" \
  "$EVIDENCE_DIR/first-foreground-failure.txt" "$EVIDENCE_DIR/first-display-failure.txt" \
  "$EVIDENCE_DIR/final-frame-timeout-state.txt"

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

# Match the main process exactly; pidof may include auxiliary processes or
# return an empty result during a transient adb failure. Keep raw evidence.
read_app_pid() {
  local attempt query_pid query_status
  for attempt in 1 2 3; do
    query_status=0
    adb shell ps -A -o PID,NAME > "$EVIDENCE_DIR/process-query.txt" 2> "$EVIDENCE_DIR/process-query-error.txt" || query_status=$?
    {
      printf 'query_status=%s attempt=%s\n' "$query_status" "$attempt"
      cat "$EVIDENCE_DIR/process-query.txt" "$EVIDENCE_DIR/process-query-error.txt"
    } >> "$EVIDENCE_DIR/process-queries.txt"
    if [[ "$query_status" == 0 ]]; then
      query_pid=$(awk -v package="$PACKAGE" '$1 ~ /^[0-9]+$/ && $2 == package {print $1}' "$EVIDENCE_DIR/process-query.txt" | tr -d '\r')
      if [[ "$query_pid" =~ ^[0-9]+$ ]]; then
        printf '%s\n' "$query_pid"
        return 0
      fi
    fi
    sleep 1
  done
  return 1
}

app_has_foreground() {
  local activities windows
  activities=$(adb shell dumpsys activity activities 2>/dev/null) || return 1
  if ! grep -E '^[[:space:]]*(mResumedActivity|topResumedActivity|ResumedActivity)[:=]' <<< "$activities" \
      | grep -F " $PACKAGE/" > /dev/null; then
    return 1
  fi
  windows=$(adb shell dumpsys window windows 2>/dev/null) || return 1
  # The real activity window is named package/component.
  printf '%s\n' "$activities" "$windows" | awk -v component="$PACKAGE/" '
    $1 ~ /^mCurrentFocus=Window\{/ && $2 ~ /^u[0-9]+$/ && index($3, component) == 1 { focused = 1 }
    END { exit !focused }
  '
}

app_window_was_drawn() {
  # Window focus can already point to the activity while Android is still
  # showing its launch splash. The Displayed event may be in the main
  # logcat buffer (confirmed by emulator evidence 14377277006), not system.
  adb logcat -d -b all -s ActivityTaskManager:I \
    | grep -F "Displayed $PACKAGE/" > /dev/null
}

PID=''
for _ in $(seq 1 30); do
  PID=$(read_app_pid || true)
  if [[ -n "$PID" ]]; then
    break
  fi
  sleep 1
done

if [[ -z "$PID" ]]; then
  echo "[FAIL] $PACKAGE did not remain running after launch." >&2
  exit 1
fi
valid_frame() {
python3 - "$1" <<'PY'
from pathlib import Path
import struct
import sys
import zlib

image = Path(sys.argv[1])
payload = image.read_bytes()
signature = b"\x89PNG\r\n\x1a\n"
if not payload.startswith(signature) or len(payload) < 10_000:
    raise SystemExit(1)
# PNG IHDR is the first chunk, with exactly 13 bytes of metadata.
if len(payload) < 33 or payload[12:16] != b"IHDR" or struct.unpack(">I", payload[8:12])[0] != 13:
    raise SystemExit(1)
width, height = struct.unpack(">II", payload[16:24])
bit_depth, color_type, compression, filter_method, interlace = payload[24:29]
valid_depths = {0: (1, 2, 4, 8, 16), 2: (8, 16), 3: (1, 2, 4, 8), 4: (8, 16), 6: (8, 16)}
# The Android smoke evidence must be a portrait frame, not a rotated or cropped landscape capture.
if not (1 <= width < height <= 16384):
    raise SystemExit(1)
if bit_depth not in valid_depths.get(color_type, ()) or compression != 0 or filter_method != 0 or interlace not in (0, 1):
    raise SystemExit(1)
if zlib.crc32(payload[12:29]) & 0xffffffff != struct.unpack(">I", payload[29:33])[0]:
    raise SystemExit(1)
# Validate every chunk boundary and CRC, not only IHDR. A corrupted IDAT
# can otherwise masquerade as a successfully captured emulator frame.
offset = 8
saw_idat = False
idat_bytes = 0
compressed_idat = bytearray()
saw_iend = False
idat_closed = False
saw_plte = False
chunk_index = 0
while offset < len(payload):
    if offset + 12 > len(payload):
        raise SystemExit(1)
    size = struct.unpack(">I", payload[offset:offset + 4])[0]
    end = offset + 12 + size
    if end > len(payload):
        raise SystemExit(1)
    kind = payload[offset + 4:offset + 8]
    body = payload[offset + 4:offset + 8 + size]
    expected = struct.unpack(">I", payload[offset + 8 + size:end])[0]
    if zlib.crc32(body) & 0xffffffff != expected:
        raise SystemExit(1)
    # PNG chunk types are ASCII letters; the third (reserved) letter must be uppercase.
    if len(kind) != 4 or any(not (65 <= c <= 90 or 97 <= c <= 122) for c in kind) or kind[2] & 0x20:
        raise SystemExit(1)
    # IHDR must occur exactly once and first; IDAT must precede IEND.
    if kind == b"IHDR" and chunk_index != 0:
        raise SystemExit(1)
    # Palette metadata is optional for RGB captures, but must be unique and
    # precede pixel data. Reject impossible palette ordering.
    if kind == b"PLTE":
        if saw_plte or saw_idat or size == 0 or size % 3 or size > 768 or (color_type == 3 and size // 3 > (1 << bit_depth)):
            raise SystemExit(1)
        saw_plte = True
    # Grayscale PNG forbids palettes, even when the palette CRC is valid.
    if kind == b"PLTE" and color_type in (0, 4):
        raise SystemExit(1)
    # PNG requires consecutive IDAT chunks; a later IDAT is invalid.
    if kind == b"IDAT":
        if idat_closed:
            raise SystemExit(1)
        saw_idat = True
        idat_bytes += size
        compressed_idat.extend(payload[offset + 8:offset + 8 + size])
    elif saw_idat:
        idat_closed = True
    # Unknown critical chunks cannot be interpreted safely.
    if kind[0] & 0x20 == 0 and kind not in (b"IHDR", b"PLTE", b"IDAT", b"IEND"):
        raise SystemExit(1)
    if kind == b"IEND":
        if not saw_idat:
            raise SystemExit(1)
        if size != 0 or end != len(payload):
            raise SystemExit(1)
        saw_iend = True
    offset = end
    chunk_index += 1
if not (saw_idat and saw_iend and idat_bytes):
    raise SystemExit(1)
# Indexed PNGs require a palette. Their bit depth also limits the number
# of palette entries; accepting an impossible palette yields false evidence.
if color_type == 3 and not saw_plte:
    raise SystemExit(1)
# Chunk CRCs do not prove that IDAT contains a decodable zlib stream.
# Bound decompression to avoid trusting attacker-controlled image dimensions.
try:
    decoder = zlib.decompressobj()
    limit = min(128 * 1024 * 1024, width * height * 8 + height * 2)
    decoded = decoder.decompress(bytes(compressed_idat), limit + 1)
    if len(decoded) > limit or not decoder.eof or decoder.unused_data or decoder.unconsumed_tail:
        raise SystemExit(1)
    # RGB/RGBA8 non-interlaced Android frames require one filter byte per scanline.
    # A CRC-correct zlib stream can still omit rows or contain invalid filters.
    if color_type in (2, 6) and bit_depth == 8 and interlace == 0:
        stride = width * (3 if color_type == 2 else 4) + 1
        if len(decoded) != stride * height or any(decoded[row * stride] > 4 for row in range(height)):
            raise SystemExit(1)
except zlib.error:
    raise SystemExit(1)
print(f"[PASS] Captured first Android frame: {width}x{height}, {len(payload)} bytes")
PY
}

# A resumed Android activity can precede Flutter's first rendered screen.
# Keep the existing screenshot gate, but allow bounded time for rendering.
FRAME_READY=false
for FRAME_ATTEMPT in $(seq 1 30); do
  CURRENT_PID=$(read_app_pid || true)
  if [[ "$CURRENT_PID" != "$PID" ]]; then
    echo "[FAIL] App exited or restarted while waiting for its first frame." >&2
    exit 1
  fi
  # Persist which gate is blocking a real emulator, rather than returning
  # an ambiguous timeout after a successful APK install.
  if ! app_has_foreground; then
    printf 'attempt=%s stage=foreground_missing\n' "$FRAME_ATTEMPT" >> "$EVIDENCE_DIR/frame-attempts.txt"
    if [[ ! -f "$EVIDENCE_DIR/first-foreground-failure.txt" ]]; then
      { printf 'attempt=%s package=%s pid=%s\n' "$FRAME_ATTEMPT" "$PACKAGE" "$PID";
        adb shell dumpsys activity activities; adb shell dumpsys window windows;
      } > "$EVIDENCE_DIR/first-foreground-failure.txt" 2>&1 || true
    fi
  elif ! app_window_was_drawn; then
    printf 'attempt=%s stage=display_event_missing\n' "$FRAME_ATTEMPT" >> "$EVIDENCE_DIR/frame-attempts.txt"
    if [[ ! -f "$EVIDENCE_DIR/first-display-failure.txt" ]]; then
      { printf 'attempt=%s package=%s pid=%s\n' "$FRAME_ATTEMPT" "$PACKAGE" "$PID";
        adb logcat -d -b all -s ActivityTaskManager:I;
      } > "$EVIDENCE_DIR/first-display-failure.txt" 2>&1 || true
    fi
  elif ! adb exec-out screencap -p > "$EVIDENCE_DIR/frame-candidate.png" 2>/dev/null; then
    printf 'attempt=%s stage=screencap_failed\n' "$FRAME_ATTEMPT" >> "$EVIDENCE_DIR/frame-attempts.txt"
  elif ! valid_frame "$EVIDENCE_DIR/frame-candidate.png"; then
    printf 'attempt=%s stage=invalid_png\n' "$FRAME_ATTEMPT" >> "$EVIDENCE_DIR/frame-attempts.txt"
  else
    printf 'attempt=%s stage=accepted\n' "$FRAME_ATTEMPT" >> "$EVIDENCE_DIR/frame-attempts.txt"
    mv "$EVIDENCE_DIR/frame-candidate.png" "$EVIDENCE_DIR/first-frame.png"
    FRAME_READY=true
    break
  fi
  sleep 1
done
if [[ "$FRAME_READY" != true ]]; then
  echo "[FAIL] No valid screenshot of the foreground app after 30 capture attempts." >&2
  echo "[FAIL] Frame gate summary:" >&2
  sed -E 's/^attempt=[0-9]+ stage=//' "$EVIDENCE_DIR/frame-attempts.txt" | sort | uniq -c >&2 || true
  # Preserve final focus/resume and ActivityTaskManager state for timeouts,
  # even if the initial failing stage changed during the retry window.
  { printf 'package=%s pid=%s attempts=%s\n' "$PACKAGE" "$PID" "$FRAME_ATTEMPT";
    adb shell dumpsys activity activities;
    adb shell dumpsys window windows;
    adb logcat -d -b all -s ActivityTaskManager:I;
  } > "$EVIDENCE_DIR/final-frame-timeout-state.txt" 2>&1 || true
  echo "[FAIL] See frame-attempts.txt, final-frame-timeout-state.txt and frame-candidate.png in emulator evidence." >&2
  exit 1
fi

# A focus query can run during an Android window transition. Require the same
# process to regain a real, resumed foreground window before passing.
FOREGROUND_READY=false
for _ in $(seq 1 10); do
  CURRENT_PID=$(read_app_pid || true)
  if [[ "$CURRENT_PID" != "$PID" ]]; then
    echo "[FAIL] App exited or restarted after its first frame." >&2
    exit 1
  fi
  if app_has_foreground; then
    FOREGROUND_READY=true
    break
  fi
  sleep 1
done
if [[ "$FOREGROUND_READY" != true ]]; then
  echo "[FAIL] App lost its foreground activity while rendering." >&2
  exit 1
fi

# Refresh crash evidence after the final focus check.
adb logcat --pid="$PID" -d > "$EVIDENCE_DIR/app-logcat.txt"
adb logcat -d > "$EVIDENCE_DIR/full-logcat.txt"
adb shell dumpsys meminfo "$PACKAGE" > "$EVIDENCE_DIR/meminfo.txt"
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
