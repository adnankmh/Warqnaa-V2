from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ANDROID = ROOT / ".github/workflows/flutter-android.yml"
WEB = ROOT / ".github/workflows/flutter-web-pages.yml"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def require(text: str, needle: str, context: str) -> None:
    assert needle in text, f"Missing {context}: {needle}"


def verify_always_runs_on_release_pr(text: str, workflow_name: str) -> None:
    trigger = text.split("\npermissions:", 1)[0]
    require(trigger, "pull_request:", f"{workflow_name} pull-request trigger")
    require(trigger, "branches: [main, master]", f"{workflow_name} main/master trigger")
    assert "paths:" not in trigger, (
        f"{workflow_name} must run for every release-stage PR; path filters are not allowed"
    )


def main() -> None:
    android = read(ANDROID)
    web = read(WEB)

    require(android, "name: Build Android APK and AAB", "Android workflow name")
    verify_always_runs_on_release_pr(android, "Android")
    require(android, "ref: ${{ github.event.pull_request.head.sha || github.sha }}", "Android exact-head checkout")
    require(android, "flutter build apk --release", "release APK build")
    require(android, "flutter build appbundle --release", "release AAB build")
    require(android, "android-stage-manifest.txt", "Android stage provenance manifest")
    require(android, "actions/upload-artifact@v6", "Android artifact upload")

    require(web, "name: Build and deploy Flutter Web", "Web workflow name")
    verify_always_runs_on_release_pr(web, "Web")
    require(web, "ref: ${{ github.event.pull_request.head.sha || github.sha }}", "Web exact-head checkout")
    require(web, "flutter build web --release", "Flutter Web release build")
    require(web, "web-stage-manifest.txt", "Web stage provenance manifest")
    require(web, "actions/upload-artifact@v6", "Web artifact upload")

    print("Android + Flutter Web every-stage workflow contract: PASS")


if __name__ == "__main__":
    main()
