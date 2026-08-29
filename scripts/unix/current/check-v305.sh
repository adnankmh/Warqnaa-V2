#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../.."
python3 tools/verify_release_versions.py
for t in test_v208_r8_contract.py test_v209_r9_contract.py test_v210_r9_1_contract.py test_v220_r10_contract.py test_v221_r101_contract.py test_v230_r11_contract.py test_v240_r12_contract.py test_v240_competitive_engines.py test_v240_php_structure.py test_v250_r13_contract.py test_v260_r14_contract.py test_v263_r14_3_contract.py test_v300_world_experience_contract.py test_v301_ci_i18n_contract.py test_v302_flutter_hand_final_contract.py test_v303_runtime_premium_contract.py test_v305_vertical_legend_contract.py check_git_privacy_v304.py global_release_preflight.py test_v030_contract.py validate_v030_static.py; do python3 "tools/$t"; done
python3 tools/validate_release.py
if command -v php >/dev/null 2>&1; then
  php backend-laravel/tools/test-v208-r8-rules.php
  php backend-laravel/tools/test-v184-official-rules-audit.php
  php backend-laravel/tools/test-v184-engine-stress.php
  WARQNA_FAIR_DEAL_SCENARIOS=3000 php backend-laravel/tools/test-v304-fair-deal.php
  WARQNA_GOLD_MATCHES_PER_ENGINE=25 WARQNA_GOLD_MAX_TRANSITIONS=160 php backend-laravel/tools/test-v250-r13-engine-gold.php
  if [[ -f backend-laravel/vendor/autoload.php ]]; then (cd backend-laravel && php artisan migrate --force && php artisan test); fi
fi
if command -v flutter >/dev/null 2>&1; then (cd flutter_app && flutter pub get && bash ../tools/flutter_analyze_ci.sh && flutter test && flutter build web --release); fi
echo "WARQNAA BUILD 305 CHECK: PASS"
