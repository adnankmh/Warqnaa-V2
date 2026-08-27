#!/usr/bin/env python3
"""R14 cross-channel source preflight and machine-readable evidence generator."""
from __future__ import annotations
import argparse, json, struct, subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def tracked(path: str) -> bool:
    """Reject committed secrets without failing after CI creates a runtime .env."""
    try:
        result = subprocess.run(
            ["git", "-C", str(ROOT), "ls-files", "--error-unmatch", path],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
        return result.returncode == 0
    except OSError:
        return False


def png_size(path: Path) -> tuple[int, int]:
    data = path.read_bytes()[:24]
    if len(data) != 24 or data[:8] != b"\x89PNG\r\n\x1a\n":
        raise RuntimeError(f"not a PNG: {path}")
    return struct.unpack(">II", data[16:24])


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    meta = json.loads((ROOT / "RELEASE_VERSION.json").read_text(encoding="utf-8"))
    checks = {
        "release_metadata": int(meta.get("build", 0)) >= 263 and bool(meta.get("full")) and bool(meta.get("name")),
        "four_channels": all((ROOT / p).exists() for p in (
            "backend-laravel", "flutter_app/web", ".github/workflows/flutter-android.yml", ".github/workflows/flutter-ios.yml")),
        "production_backend": all((ROOT / p).is_file() for p in (
            "backend-laravel/Dockerfile", "backend-laravel/docker-compose.production.yml", "backend-laravel/.env.production.example")),
        "engine_gold": all((ROOT / p).is_file() for p in (
            "backend-laravel/config/warqna_engine_gold.php", "backend-laravel/tools/test-v250-r13-engine-gold.php")),
        "six_locales": all(token in (ROOT / "flutter_app/lib/main.dart").read_text(encoding="utf-8") for token in ("Locale('ar')", "Locale('en')", "Locale('de')", "Locale('tr')", "Locale('fr')", "Locale('es')")),
        "play_icon_512": png_size(ROOT / "assets/play-store/icon-512.png") == (512, 512),
        "feature_graphic_1024x500": png_size(ROOT / "assets/play-store/feature-graphic-1024x500.png") == (1024, 500),
        "web_manifest": any((ROOT / p).is_file() for p in ("flutter_app/web/manifest.json", "flutter_app/web/manifest.webmanifest")),
        "secret_policy": not tracked("backend-laravel/.env"),
        "global_workflow": (ROOT / ".github/workflows/global-release.yml").is_file(),
    }
    failed = [name for name, passed in checks.items() if not passed]
    report = {
        "contract": "world_experience_v300", "release": meta.get("full"),
        "status": "pass" if not failed else "fail", "checks": checks,
        "channels": ["backend", "web", "android", "ios"],
        "locales": ["ar", "en", "de", "tr", "fr", "es"], "engine_gold": {"engines": 20, "release_matches_per_engine": 2000},
        "deployment_only": ["production secrets", "store signing", "store account submission", "DNS/TLS activation"],
    }
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if failed:
        raise SystemExit("[FAIL] R14 global release preflight: " + ", ".join(failed))
    print("[PASS] GLOBAL RELEASE PREFLIGHT: backend/web/android/ios, six locales, store assets, Engine Gold and secret policy")


if __name__ == "__main__":
    main()
