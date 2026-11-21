#!/usr/bin/env bash
# Regression fixtures for the foreground gate without requiring an emulator.
set -euo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_file="$ROOT/tools/android_emulator_smoke.sh"
# Extract only the pure shell gate; sourcing the full smoke script would launch adb.
gate=$(sed -n '/^app_has_foreground() {/,/^}/p' "$source_file")
[[ "$gate" == *'app_has_foreground()'* ]] || exit 1
eval "$gate"
PACKAGE=com.warqnaa.app
adb() {
  if [[ "$*" == "shell dumpsys activity activities" ]]; then
    printf '%s\n' "$ACTIVITY_FIXTURE"
  elif [[ "$*" == "shell dumpsys window windows" ]]; then
    printf '%s\n' "$WINDOW_FIXTURE"
  else
    return 1
  fi
}
check() {
  local label=$1 expected=$2
  if app_has_foreground; then actual=0; else actual=1; fi
  if [[ "$actual" != "$expected" ]]; then
    echo "FAIL: $label expected=$expected actual=$actual" >&2
    exit 1
  fi
  echo "PASS: $label"
}
ACTIVITY_FIXTURE='mResumedActivity: ActivityRecord{abc u0 com.warqnaa.app/.MainActivity t1}'
WINDOW_FIXTURE='mCurrentFocus=Window{abc u0 com.warqnaa.app/com.warqnaa.app.MainActivity}'
check 'legacy resumed and focused' 0
ACTIVITY_FIXTURE=' topResumedActivity = ActivityRecord{abc u0 com.warqnaa.app/.MainActivity t1}'
WINDOW_FIXTURE='  mCurrentFocus = Window{abc u0 com.warqnaa.app/.MainActivity}'
check 'spaced Android dumpsys fields' 0
ACTIVITY_FIXTURE='mResumedActivity: ActivityRecord{abc u0 com.warqnaa.app.evil/.MainActivity t1}'
check 'reject other resumed package' 1
ACTIVITY_FIXTURE='mResumedActivity: ActivityRecord{abc u0 com.warqnaa.app/.MainActivity t1}'
WINDOW_FIXTURE='mCurrentFocus=Window{abc u0 com.warqnaa.app.evil/.MainActivity}'
check 'reject other focused package' 1
WINDOW_FIXTURE='mCurrentFocus=Window{abc u0 com.android.permissioncontroller/.GrantPermissionsActivity}'
check 'reject permission overlay' 1
