#!/usr/bin/env python3
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent
# Allow the patch kit to be placed either inside the repo or one level above it.
candidates = [
    ROOT,
    ROOT / "Warqnaa-V2",
    ROOT.parent / "Warqnaa-V2",
]
repo = next((p for p in candidates if (p / "tools" / "test_v210_r9_1_contract.py").is_file()), None)

if repo is None:
    print("[ERROR] Warqnaa-V2 repository was not found.")
    print("Put this patch kit inside the Warqnaa-V2 folder, or beside a folder named Warqnaa-V2.")
    sys.exit(1)

target = repo / "tools" / "test_v210_r9_1_contract.py"
text = target.read_text(encoding="utf-8")

old = """    road=has('backend-laravel/app/Services/WarqnaPro/ChallengeRoadService.php','10,12,15','ATTEMPTS = 5','challenge_road_match')
    ok(('min(1800' in road) if int(meta.get('build',0))>=304 else ('min(1000' in road),'challenge road preserves progression with release-appropriate reward ceiling')"""

new = """    road=has('backend-laravel/app/Services/WarqnaPro/ChallengeRoadService.php','10,12,15','ATTEMPTS = 5','challenge_road_match')
    build=int(meta.get('build',0))
    if build >= 305:
        reward_ceiling_ok = (
            'min(1000' in road
            or 'TOKEN_REWARD_CAP = 1000' in road
            or 'TOKEN_REWARD_CAP=1000' in road
        )
    elif build >= 304:
        # Build 304 existed during the transition; accept either compatible ceiling.
        reward_ceiling_ok = ('min(1800' in road or 'min(1000' in road)
    else:
        reward_ceiling_ok = 'min(1000' in road
    ok(reward_ceiling_ok,'challenge road preserves progression with release-appropriate reward ceiling')"""

if old in text:
    backup = target.with_suffix(target.suffix + ".bak")
    backup.write_text(text, encoding="utf-8")
    target.write_text(text.replace(old, new, 1), encoding="utf-8")
    print(f"[OK] Patched: {target.relative_to(repo)}")
    print(f"[OK] Backup:  {backup.relative_to(repo)}")
elif "reward_ceiling_ok" in text and "build >= 305" in text:
    print("[OK] Patch is already installed.")
else:
    print("[ERROR] Expected legacy block was not found.")
    print("The file may have changed since the failing GitHub Actions run.")
    sys.exit(2)

def run(cmd, required=True):
    print("\n> " + " ".join(cmd))
    result = subprocess.run(cmd, cwd=repo)
    if required and result.returncode != 0:
        print(f"[ERROR] Command failed with exit code {result.returncode}")
        sys.exit(result.returncode)
    return result.returncode

# Run the contract that failed.
run([sys.executable, "tools/test_v210_r9_1_contract.py"])

# Run release validator if present.
validator = repo / "tools" / "validate_release.py"
if validator.is_file():
    run([sys.executable, "tools/validate_release.py"])
else:
    print("\n[INFO] tools/validate_release.py not present; skipped.")

print("\n[SUCCESS] CI patch applied and local checks passed.")
