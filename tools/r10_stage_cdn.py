#!/usr/bin/env python3
"""Stage Warqnaa R10 CDN assets in the exact paths declared by the manifest.

This script does not upload anything. It creates a deterministic directory that can be
synced to S3/R2/CloudFront/Cloudflare CDN or any static HTTPS origin.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "assets/manifest/r10_asset_manifest.json"


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def copy_verified(src: Path, dest: Path, expected: str | None = None) -> None:
    if not src.is_file():
        raise SystemExit(f"[FAIL] Missing source asset: {src.relative_to(ROOT)}")
    if expected and sha256_file(src) != expected:
        raise SystemExit(f"[FAIL] SHA-256 mismatch before staging: {src.relative_to(ROOT)}")
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dest)


def main() -> None:
    parser = argparse.ArgumentParser(description="Stage Warqnaa R10 CDN assets")
    parser.add_argument("--output", default=str(ROOT / "dist/r10-cdn"), help="Output directory")
    parser.add_argument("--clean", action="store_true", help="Delete output directory before staging")
    args = parser.parse_args()

    out = Path(args.output).resolve()
    if args.clean and out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True, exist_ok=True)

    data = json.loads(MANIFEST.read_text(encoding="utf-8"))
    entries = data.get("entries", [])
    if not entries:
        raise SystemExit("[FAIL] R10 manifest has no entries")

    copied = 0
    copied_bytes = 0
    for entry in entries:
        local = ROOT / "flutter_app" / str(entry["local_asset"])
        remote = out / str(entry["remote_path"])
        copy_verified(local, remote, str(entry.get("sha256") or ""))
        copied += 1
        copied_bytes += local.stat().st_size

        thumb_remote = entry.get("thumbnail_remote_path")
        if thumb_remote:
            rel = str(thumb_remote).replace("warqnaa/r10/thumbs/", "", 1)
            thumb_src = ROOT / "assets/cdn/r10/thumbs" / rel
            if thumb_src.is_file():
                copy_verified(thumb_src, out / str(thumb_remote))

    manifest_dest = out / "warqnaa/r10/manifest.json"
    manifest_dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(MANIFEST, manifest_dest)

    deploy_info = {
        "release": data.get("release"),
        "build": data.get("build"),
        "manifest_path": "warqnaa/r10/manifest.json",
        "entries": copied,
        "full_asset_bytes": copied_bytes,
        "note": "Serve this tree through HTTPS. Set WARQNA_ASSET_CDN_URL to the CDN origin without a trailing slash.",
    }
    (out / "R10_CDN_DEPLOY_INFO.json").write_text(
        json.dumps(deploy_info, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    print(f"[PASS] Staged {copied} manifest assets")
    print(f"[PASS] Full asset bytes: {copied_bytes:,} ({copied_bytes/1024/1024:.2f} MiB)")
    print(f"[PASS] CDN tree: {out}")
    print(f"[PASS] Manifest: {manifest_dest}")


if __name__ == "__main__":
    main()
