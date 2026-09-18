#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../.."
python3 tools/verify_release_versions.py
python3 tools/test_r61_world_class_contract.py
python3 tools/test_v305_single_table_contract.py
python3 tools/check_git_privacy_v304.py
python3 tools/validate_v030_static.py
python3 tools/validate_release.py
echo "WARQNAA R6.1 BUILD 610 CHECK: PASS"
