#!/usr/bin/env python3
from pathlib import Path
import re, subprocess, sys

ROOT=Path(__file__).resolve().parents[1]
SKIP={'.git','vendor','node_modules','build','.dart_tool','.idea','.gradle'}
# Construct privileged literals so the privacy gate does not publish them itself.
BAD_LITERALS=(
    'Adnan'+'123',
    'Abd'+'Abd'+'123',
    'adnanasd63'+'@gmail.com',
)
BAD_NAMES={'.env','.warqnaa-admin.local.env','auth.json','key.properties','id_rsa','id_ed25519','LOCAL_ADMIN_ACCESS.txt'}
BAD_SUFFIXES={'.sqlite','.sqlite3','.db','.jks','.keystore','.p8','.p12','.pem','.key','.sql','.dump','.bak'}
BAD_PATTERNS=(re.compile(r'^service-account.*\.json$',re.I),re.compile(r'^firebase-admin.*\.json$',re.I),re.compile(r'^credentials.*\.json$',re.I))
ALLOW_NAMES={'.env.example','.env.production.example','.env.testing.example'}

# In a Git working tree, inspect what can actually be committed. This permits the
# ignored local admin file to exist on the developer PC but still rejects it if
# somebody force-adds it. Exported source packages have no .git and are scanned whole.
def candidates():
    if (ROOT/'.git').exists():
        try:
            raw=subprocess.check_output(['git','-C',str(ROOT),'ls-files','-z'])
            for item in raw.decode('utf-8','ignore').split('\0'):
                if item:
                    p=ROOT/item
                    if p.is_file(): yield p
            return
        except Exception:
            pass
    for p in ROOT.rglob('*'):
        if p.is_file() and not any(part in SKIP for part in p.parts):
            yield p

errors=[]
for p in candidates():
    name=p.name; rel=p.relative_to(ROOT)
    if name in ALLOW_NAMES:
        pass
    elif name in BAD_NAMES or p.suffix.lower() in BAD_SUFFIXES or any(rx.match(name) for rx in BAD_PATTERNS):
        errors.append(f'forbidden sensitive file: {rel}')
        continue
    try:
        if p.stat().st_size <= 2_000_000:
            text=p.read_text(encoding='utf-8',errors='ignore')
            for lit in BAD_LITERALS:
                if lit in text:
                    errors.append(f'privileged plaintext credential in {rel}')
    except OSError:
        pass
if errors:
    print('[FAIL] B304 GIT PRIVACY GATE')
    for e in errors[:100]: print(' -',e)
    sys.exit(1)
print('[PASS] B304 Git privacy gate: no tracked/packageable privileged passwords, private admin email, local envs, databases, private keys, signing keys, SQL dumps, or service credentials.')
