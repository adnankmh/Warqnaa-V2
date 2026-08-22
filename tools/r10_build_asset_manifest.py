#!/usr/bin/env python3
"""Build the R10 versioned asset-delivery manifest and compact CDN thumbnails."""
from __future__ import annotations
import hashlib, json, shutil
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
FLUTTER=ROOT/'flutter_app'
MANIFEST_DIR=ROOT/'assets/manifest'
BACKEND_COPY=ROOT/'backend-laravel/resources/data/r10_asset_manifest.json'
THUMBS=ROOT/'assets/cdn/r10/thumbs'


def sha256(path:Path)->str:
    h=hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda:f.read(1024*1024),b''): h.update(chunk)
    return h.hexdigest()


def classify(rel:str)->tuple[str,str]:
    s=rel.lower()
    if '/games/' in f'/{s}': return 'game_art','core'
    if '/tables/' in f'/{s}': return 'table','ondemand'
    if '/cardbacks/' in f'/{s}': return 'card_back','ondemand'
    if '/tickets/' in f'/{s}': return 'ticket','ondemand'
    if '/prize_boxes/' in f'/{s}': return 'prize_box','ondemand'
    if '/rewards/' in f'/{s}': return 'reward','ondemand'
    if '/pasha/' in f'/{s}': return 'pasha_style','ondemand'
    if '/sounds/' in f'/{s}': return 'sound','core'
    return 'visual','ondemand'


def thumb_for(src:Path, relative_under_r10:Path)->str|None:
    if src.suffix.lower()!='.webp': return None
    dst=THUMBS/relative_under_r10
    dst.parent.mkdir(parents=True,exist_ok=True)
    with Image.open(src) as im:
        im.load(); im.thumbnail((320,320),Image.Resampling.LANCZOS)
        im.save(dst,'WEBP',quality=76,method=4)
    return (Path('warqnaa/r10/thumbs')/relative_under_r10).as_posix()


def main():
    entries=[]
    files=[]
    opt=FLUTTER/'assets/optimized/r10'
    if opt.is_dir(): files.extend(p for p in opt.rglob('*') if p.is_file())
    audio=FLUTTER/'assets/sounds/r10'
    if audio.is_dir(): files.extend(p for p in audio.rglob('*') if p.is_file())
    shutil.rmtree(THUMBS,ignore_errors=True)
    for path in sorted(files):
        local=path.relative_to(FLUTTER).as_posix()
        if local.startswith('assets/optimized/r10/'):
            relative=Path(local.removeprefix('assets/optimized/r10/'))
            remote=(Path('warqnaa/r10/full')/relative).as_posix()
            thumb=thumb_for(path,relative)
        else:
            relative=Path(local.removeprefix('assets/sounds/r10/'))
            remote=(Path('warqnaa/r10/audio')/relative).as_posix()
            thumb=None
        kind,delivery=classify(local)
        entries.append({
            'id': relative.with_suffix('').as_posix().replace('/','.'),
            'version':1,
            'kind':kind,
            'delivery':delivery,
            'bundled':True,
            'local_asset':local,
            'remote_path':remote,
            'thumbnail_remote_path':thumb,
            'bytes':path.stat().st_size,
            'sha256':sha256(path),
            'mime':'audio/ogg' if path.suffix.lower()=='.ogg' else 'image/webp',
        })
    payload={
        'schema':1,
        'release':'R10',
        'build':220,
        'mode':'hybrid',
        'entries':entries,
        'summary':{
            'entries':len(entries),
            'bundled_bytes':sum(e['bytes'] for e in entries),
            'ondemand_entries':sum(e['delivery']=='ondemand' for e in entries),
            'core_entries':sum(e['delivery']=='core' for e in entries),
        }
    }
    MANIFEST_DIR.mkdir(parents=True,exist_ok=True)
    out=MANIFEST_DIR/'r10_asset_manifest.json'
    text=json.dumps(payload,ensure_ascii=False,indent=2)
    out.write_text(text,encoding='utf-8')
    BACKEND_COPY.parent.mkdir(parents=True,exist_ok=True)
    BACKEND_COPY.write_text(text,encoding='utf-8')
    print(json.dumps(payload['summary'],indent=2))

if __name__=='__main__': main()
