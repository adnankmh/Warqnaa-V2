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
python3 tools/test_v240_r12_contract.py
python3 tools/test_v240_competitive_engines.py
python3 tools/test_v240_php_structure.py
python3 tools/test_v250_r13_contract.py
python3 tools/test_v260_r14_contract.py
python3 tools/test_v263_r14_3_contract.py
python3 tools/test_v300_world_experience_contract.py
python3 tools/test_v301_ci_i18n_contract.py
python3 tools/test_v302_flutter_hand_final_contract.py
python3 tools/global_release_preflight.py
python3 tools/test_v030_contract.py
python3 tools/validate_v030_static.py
python3 tools/validate_release.py
if command -v php >/dev/null 2>&1; then
  php backend-laravel/tools/test-v208-r8-rules.php
  php backend-laravel/tools/test-v184-official-rules-audit.php
  php backend-laravel/tools/test-v184-engine-stress.php
  if [[ -f backend-laravel/vendor/autoload.php ]]; then
    (cd backend-laravel && php artisan migrate --force && php artisan test && php artisan warqna:global-release-check --json)
  fi
fi
if command -v flutter >/dev/null 2>&1; then
  (cd flutter_app && flutter pub get && flutter analyze && flutter test)
fi
echo "WARQNAA BUILD 302 CHECK: PASS"
