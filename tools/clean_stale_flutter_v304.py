#!/usr/bin/env python3
from pathlib import Path
import subprocess, sys
ROOT=Path(__file__).resolve().parents[1]
manifest=ROOT/'releases/manifests/current/FLUTTER_LIB_MANIFEST_V304.txt'
allowed={line.strip() for line in manifest.read_text(encoding='utf-8').splitlines() if line.strip()}
try:
    out=subprocess.check_output(['git','-C',str(ROOT),'ls-files','flutter_app/lib'], text=True)
except Exception as exc:
    print('[INFO] No Git working tree; stale-file cleanup skipped:', exc)
    raise SystemExit(0)
removed=[]
for rel in out.splitlines():
    rel=rel.strip().replace('\\','/')
    if rel.endswith('.dart') and rel not in allowed:
        p=ROOT/rel
        if p.exists():
            p.unlink(); removed.append(rel)
print(f'[PASS] B304 stale Flutter cleanup: {len(removed)} removed')
for rel in removed: print('  -',rel)
