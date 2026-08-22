#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../.."
python3 tools/test_v221_r101_contract.py
python3 tools/test_v220_r10_contract.py
python3 tools/test_v210_r9_1_contract.py
python3 tools/test_v208_r8_contract.py
python3 tools/validate_release.py
echo "WARQNAA R10.1 CHECK: PASS"
