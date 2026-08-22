#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
from collections import defaultdict, Counter
import hashlib, json
ROOT=Path(__file__).resolve().parents[1]
TARGETS=[ROOT/'flutter_app/assets',ROOT/'backend-laravel/public/assets']
report={'version':'R9','targets':{},'duplicate_groups':[],'largest_files':[]}
all_files=[]
for root in TARGETS:
    files=[p for p in root.rglob('*') if p.is_file()]
    total=sum(p.stat().st_size for p in files)
    ext=Counter(p.suffix.lower() or '<none>' for p in files)
    report['targets'][str(root.relative_to(ROOT))]={'files':len(files),'bytes':total,'extensions':dict(ext)}
    all_files.extend(files)
by_hash=defaultdict(list)
for p in all_files:
    try: h=hashlib.sha256(p.read_bytes()).hexdigest()
    except OSError: continue
    by_hash[h].append(p)
for h,group in by_hash.items():
    if len(group)<2: continue
    saved=sum(p.stat().st_size for p in group[1:])
    report['duplicate_groups'].append({'sha256':h,'bytes_per_file':group[0].stat().st_size,'potential_saved_bytes':saved,'files':[str(p.relative_to(ROOT)) for p in group]})
report['duplicate_groups'].sort(key=lambda x:x['potential_saved_bytes'],reverse=True)
for p in sorted(all_files,key=lambda p:p.stat().st_size,reverse=True)[:60]:
    report['largest_files'].append({'file':str(p.relative_to(ROOT)),'bytes':p.stat().st_size})
report['potential_duplicate_savings_bytes']=sum(x['potential_saved_bytes'] for x in report['duplicate_groups'])
out=ROOT/'docs/ar/reports/current/R9_ASSET_AUDIT.json'; out.parent.mkdir(parents=True,exist_ok=True); out.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
md=ROOT/'docs/ar/reports/current/R9_ASSET_AUDIT_AR.md'
lines=['# تدقيق أصول Warqnaa R9','']
for name,data in report['targets'].items(): lines += [f'## {name}',f'- الملفات: **{data["files"]}**',f'- الحجم: **{data["bytes"]/1024/1024:.2f} MB**','']
lines += [f'## التكرار المطابق بالـSHA-256','',f'- مجموع الوفر النظري من التكرارات المطابقة: **{report["potential_duplicate_savings_bytes"]/1024/1024:.2f} MB**','', 'أكبر مجموعات التكرار:','']
for g in report['duplicate_groups'][:15]:
    lines.append(f'- {g["bytes_per_file"]/1024:.1f} KB × {len(g["files"])} — يمكن توفير {g["potential_saved_bytes"]/1024:.1f} KB')
    for f in g['files'][:4]: lines.append(f'  - `{f}`')
lines += ['','## أكبر الملفات','']
for x in report['largest_files'][:25]: lines.append(f'- {x["bytes"]/1024:.1f} KB — `{x["file"]}`')
lines += ['','## سياسة R9','', '- لا نحذف أي أصل لمجرد أنه كبير. الحذف يتطلب إثبات أنه غير مستخدم أو نسخة مطابقة.','- الصور المرجعية والاختبارية لا تدخل خطة CDN لاحقًا إلا بعد فصلها عن Runtime.','- R10 سيحوّل المقتنيات المدفوعة والموسمية إلى Remote Assets مع thumbnails وSHA-256 وcache versioning.']
md.write_text('\n'.join(lines)+'\n',encoding='utf-8')
print(f'R9 asset audit: {len(all_files)} files, duplicates save {report["potential_duplicate_savings_bytes"]/1024/1024:.2f} MB')
