#!/usr/bin/env python3
from pathlib import Path
import json, re
ROOT=Path(__file__).resolve().parents[1]
checks=[]
for path in [ROOT/'flutter_app/lib/main.dart', ROOT/'backend-laravel/resources/views/layouts/app.blade.php', ROOT/'backend-laravel/config/warqna_languages.php']:
    text=path.read_text(encoding='utf-8', errors='ignore')
    checks.append({'file':str(path.relative_to(ROOT)),'arabic_chars':len(re.findall(r'[\u0600-\u06ff]',text)),'english_chars':len(re.findall(r'[A-Za-z]',text))})
locale_files=[]
for path in (ROOT/'flutter_app/lib').rglob('*.dart'):
    t=path.read_text(encoding='utf-8',errors='ignore')
    if re.search(r"['\"](?:fr|de|tr|es)['\"]\s*:", t): locale_files.append(str(path.relative_to(ROOT)))
report={'product_locales':['ar','en','de','tr','fr','es'],'legacy_locale_map_files':sorted(locale_files),'high_traffic_checks':checks}
out=ROOT/'docs/ar/reports/current/R9_TRANSLATION_AUDIT.json';out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(f"R9 translation audit: product locales=ar/en, legacy-map files={len(locale_files)}")
