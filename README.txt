WARQNAA V2 — Build 305 CI Fix

Purpose
-------
Fixes the stale R9.1 CI contract that expected the old Build >=304
Challenge Road token ceiling, while Build 305 uses the 1000-token ceiling.

Files changed in your repository
--------------------------------
tools/test_v210_r9_1_contract.py

No gameplay/service file is modified.

How to use
----------
1. Extract this ZIP.
2. Put the extracted folder INSIDE your Warqnaa-V2 repository
   OR beside a folder named Warqnaa-V2.
3. Double-click: FIX_AND_TEST.bat
4. The patch creates:
   tools/test_v210_r9_1_contract.py.bak
5. It runs the failing contract and, if available, validate_release.py.
6. Only after tests pass, it asks whether to Commit + Push.

Expected CI fix
---------------
Build >= 305: accepts the 1000-token reward ceiling.
Build 304: accepts either 1800 or 1000 during the transition.
Older builds: keeps the 1000-token legacy expectation.

Safety
------
If the expected old test block cannot be found, the script stops rather
than making a blind modification.
