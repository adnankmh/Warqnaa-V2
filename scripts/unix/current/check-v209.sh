#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$ROOT"
python3 tools/verify_release_versions.py
python3 tools/test_v209_r8_contract.py
python3 tools/validate_release.py
php backend-laravel/tools/test-v209-r8-rules.php
WARQNA_STRESS_ITERATIONS=40 php backend-laravel/tools/test-v184-engine-stress.php
WARQNA_PLAYTHROUGH_RUNS=4 WARQNA_PLAYTHROUGH_STEPS=80 php backend-laravel/tools/test-v209-r8-playthrough-stress.php
php backend-laravel/tools/test-v184-official-rules-audit.php
printf '\n[PASS] Warqnaa V209 R9 checks completed.\n'
