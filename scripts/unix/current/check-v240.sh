#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../.."
python3 tools/verify_release_versions.py
python3 tools/test_v208_r8_contract.py
python3 tools/test_v209_r9_contract.py
python3 tools/test_v210_r9_1_contract.py
python3 tools/test_v220_r10_contract.py
python3 tools/test_v221_r101_contract.py
python3 tools/test_v230_r11_contract.py
python3 tools/test_v240_competitive_engines.py
python3 tools/test_v240_r12_contract.py
python3 tools/test_v240_php_structure.py
python3 tools/test_ci_release_compat_contract.py
python3 tools/validate_release.py
if command -v php >/dev/null 2>&1; then
  php backend-laravel/tools/test-v208-r8-rules.php
  php backend-laravel/tools/test-v184-official-rules-audit.php
  WARQNA_STRESS_ITERATIONS=40 php backend-laravel/tools/test-v184-engine-stress.php
  WARQNA_PLAYTHROUGH_RUNS=4 WARQNA_PLAYTHROUGH_STEPS=80 php backend-laravel/tools/test-v208-r8-playthrough-stress.php
  if [[ -f backend-laravel/vendor/autoload.php ]]; then
    (cd backend-laravel && php artisan test --filter V230SocialWorldTest && php artisan test --filter V240CompetitiveArenaTest && php artisan warqna:competitive-tick --dry-run && php artisan test)
  else
    echo "[INFO] Composer vendor is absent; Laravel PHPUnit remains enforced by GitHub Actions."
  fi
else
  echo "[INFO] PHP is absent; executable engine and Laravel suites remain enforced by GitHub Actions."
fi
echo "WARQNAA R12 BUILD 240 CHECK: PASS"
