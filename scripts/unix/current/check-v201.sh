#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../.."
python3 tools/verify_release_versions.py
python3 tools/test_v200_full_fusion_contract.py
python3 tools/test_v201_gameplay_admin_contract.py
python3 tools/test_v201_r4_hotfix_contract.py
python3 tools/test_v201_r5_ci_stability_contract.py
python3 tools/validate_release.py
php backend-laravel/tools/test-v184-engine-stress.php
php backend-laravel/tools/test-v184-official-rules-audit.php
