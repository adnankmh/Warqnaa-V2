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
python3 tools/test_v261_r14_1_contract.py
python3 tools/global_release_preflight.py
python3 tools/validate_release.py
if command -v php >/dev/null 2>&1; then
  WARQNA_GOLD_MATCHES_PER_ENGINE=25 WARQNA_GOLD_MAX_TRANSITIONS=160 php backend-laravel/tools/test-v250-r13-engine-gold.php
  if [[ -f backend-laravel/vendor/autoload.php ]]; then
    (cd backend-laravel && php artisan test --filter V260GlobalReleaseContractTest && php artisan warqna:global-release-check --json && php artisan test)
  fi
else
  echo "[INFO] PHP is absent; executable suites remain enforced by GitHub Actions."
fi
echo "WARQNAA R14.1 LEGENDARY EXPERIENCE BUILD 261 CHECK: PASS"
