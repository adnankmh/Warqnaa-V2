#!/usr/bin/env python3
"""Warqnaa R10 deterministic image/audio optimization pipeline.

The historical source artwork stays in the repository for design/audit history, while
Flutter ships only R10 WebP derivatives. Laravel public store artwork is converted to
WebP in-place-by-new-path and the catalog is repointed to those compact files.
"""
from __future__ import annotations

import json
import re
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FLUTTER = ROOT / "flutter_app"
SRC_IMAGES = FLUTTER / "assets/images"
OPT = FLUTTER / "assets/optimized/r10"
WEB_R10 = ROOT / "backend-laravel/public/assets/r10"

try:
    from PIL import Image
except Exception as exc:  # pragma: no cover
    raise SystemExit("Pillow is required to regenerate R10 image derivatives: pip install Pillow") from exc

SKIP_BUNDLED = {
    "assets/images/brand/warqna_logo.png",
    "assets/images/pasha.png",
}


def webp_quality(rel: Path) -> int:
    s = rel.as_posix()
    if "/tables/" in f"/{s}": return 88
    if "/games/" in f"/{s}": return 88
    if "/cardbacks/" in f"/{s}": return 90
    if "/tickets/" in f"/{s}": return 88
    if "/prize_boxes/" in f"/{s}": return 90
    return 90


def convert_image(src: Path, dst: Path, *, max_side: int | None = None) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(src) as image:
        image.load()
        if max_side and max(image.size) > max_side:
            image.thumbnail((max_side, max_side), Image.Resampling.LANCZOS)
        try:
            quality_rel = src.relative_to(SRC_IMAGES)
        except ValueError:
            quality_rel = src
        image.save(dst, "WEBP", quality=webp_quality(quality_rel), method=4)


def referenced_flutter_images() -> set[str]:
    refs: set[str] = set()
    pattern = re.compile(r"assets/images/[A-Za-z0-9_/$.-]+\.(?:png|jpe?g)", re.I)
    for path in (FLUTTER / "lib").rglob("*.dart"):
        refs.update(pattern.findall(path.read_text(encoding="utf-8")))
    # Dynamic paths need their whole source family.
    refs.update(f"assets/images/games/{p.name}" for p in (SRC_IMAGES / "games").glob("*.png"))
    refs.update(f"assets/images/v02/tickets/{p.name}" for p in (SRC_IMAGES / "v02/tickets").glob("*.png"))
    return refs


def optimized_path(asset: str) -> str:
    rel = Path(asset).relative_to("assets/images")
    return (Path("assets/optimized/r10") / rel).with_suffix(".webp").as_posix()


def optimize_flutter() -> dict[str, str]:
    mapping: dict[str, str] = {}
    for asset in sorted(referenced_flutter_images()):
        if "$" in asset or asset in SKIP_BUNDLED or asset.startswith("assets/images/boosters/"):
            continue
        src = FLUTTER / asset
        if not src.is_file():
            continue
        dst_asset = optimized_path(asset)
        dst = FLUTTER / dst_asset
        convert_image(src, dst)
        mapping[asset] = dst_asset

    # Replace exact/static references, then dynamic family helpers.
    for dart in (FLUTTER / "lib").rglob("*.dart"):
        text = dart.read_text(encoding="utf-8")
        before = text
        for old, new in mapping.items():
            text = text.replace(old, new)
        text = text.replace("assets/images/games/$gameId.png", "assets/optimized/r10/games/$gameId.webp")
        text = text.replace("assets/images/v02/tickets/ticket_$value.png", "assets/optimized/r10/v02/tickets/ticket_$value.webp")
        if text != before:
            dart.write_text(text, encoding="utf-8")
    return mapping


def optimize_web_store() -> int:
    public = ROOT / "backend-laravel/public/assets/store"
    catalog = ROOT / "backend-laravel/resources/data/v173_store_catalog.json"
    converted = 0
    if public.is_dir():
        for src in list(public.rglob("*.png")) + list(public.rglob("*.jpg")) + list(public.rglob("*.jpeg")):
            rel = src.relative_to(public)
            dst = WEB_R10 / "store" / rel.with_suffix(".webp")
            convert_image(src, dst)
            converted += 1
    if catalog.is_file():
        text = catalog.read_text(encoding="utf-8")
        text = re.sub(r'(/assets/store/[^"\\]+?)\.(?:png|jpe?g)', lambda m: '/assets/r10/store/' + m.group(1).removeprefix('/assets/store/') + '.webp', text, flags=re.I)
        catalog.write_text(text, encoding="utf-8")
    return converted


def optimize_audio() -> int:
    sounds = FLUTTER / "assets/sounds"
    out = sounds / "r10"
    out.mkdir(parents=True, exist_ok=True)
    count = 0
    ffmpeg = shutil.which("ffmpeg")
    if not ffmpeg:
        return 0
    for wav in sounds.glob("*.wav"):
        ogg = out / f"{wav.stem}.ogg"
        subprocess.run([ffmpeg, "-hide_banner", "-loglevel", "error", "-y", "-i", str(wav), "-c:a", "libvorbis", "-q:a", "5", str(ogg)], check=True)
        count += 1
    sound_bus = FLUTTER / "lib/services/app_sounds.dart"
    text = sound_bus.read_text(encoding="utf-8").replace("sounds/$cue.wav", "sounds/r10/$cue.ogg")
    sound_bus.write_text(text, encoding="utf-8")
    return count


def write_report(mapping: dict[str, str], web_count: int, audio_count: int) -> None:
    old = sum((FLUTTER / old).stat().st_size for old in mapping if (FLUTTER / old).is_file())
    new = sum((FLUTTER / new).stat().st_size for new in mapping.values() if (FLUTTER / new).is_file())
    report = {
        "release": "R10",
        "converted_flutter_images": len(mapping),
        "flutter_source_bytes": old,
        "flutter_optimized_bytes": new,
        "flutter_saved_bytes_if_only_optimized_is_bundled": max(0, old-new),
        "converted_web_store_images": web_count,
        "converted_audio_files": audio_count,
        "strategy": "historical sources remain in repository; release bundle points at R10 derivatives",
    }
    out = ROOT / "docs/ar/reports/current/R10_ASSET_OPTIMIZATION.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))


def main() -> None:
    OPT.mkdir(parents=True, exist_ok=True)
    mapping = optimize_flutter()
    web_count = optimize_web_store()
    audio_count = optimize_audio()
    write_report(mapping, web_count, audio_count)


if __name__ == "__main__":
    main()
