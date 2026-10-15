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



def verify_consolidated_quality_workflows() -> None:
    """Keep exactly five general PR parents, preserving all fourteen child gates."""
    workflow_dir = ROOT / ".github/workflows"
    parents = {
        "backend-ci.yml",
        "flutter-android.yml",
        "flutter-web-pages.yml",
        "production-release-check.yml",
        "r7-runtime-verification.yml",
    }
    # These two workflows run only when their platform-specific paths change.
    conditional = {"flutter-ios.yml", "windows-installer.yml"}
    triggered = {
        p.name
        for p in workflow_dir.glob("*.yml")
        if "\n  pull_request:" in read(p)
    }
    assert triggered == parents | conditional, (
        f"Unexpected direct PR workflows: {sorted(triggered ^ (parents | conditional))}"
    )

    groups = {
        "r7-runtime-verification.yml": (
            "r20-premium-experience.yml",
            "r21-community.yml",
            "r28-sky-luxury-cross-device.yml",
            "r29-premium-world-polish.yml",
            "r30-premium-table-avatars-reactions.yml",
            "r31-premium-lobby-room-flow.yml",
            "r32-premium-account-rewards.yml",
            "r35-reference-world.yml",
        ),
        "production-release-check.yml": (
            "r22-multiplayer-resilience.yml",
            "r23-security-economy.yml",
            "r24-production-observability.yml",
            "r25-resilience-release.yml",
            "r26-game-matrix-final-qa.yml",
            "r27-admin-economy-store-localization.yml",
        ),
    }
    for parent, children in groups.items():
        parent_source = read(workflow_dir / parent)
        verify_always_runs_on_release_pr(parent_source, parent)
        for child in children:
            content = read(workflow_dir / child)
            require(content, "\n  workflow_call:", f"{child} reusable trigger")
            assert "\n  pull_request:" not in content, (
                f"{child} would duplicate the umbrella PR run"
            )
            require(
                parent_source,
                f"uses: ./.github/workflows/{child}",
                f"{child} still runs inside {parent}",
            )
            require(content, "\njobs:", f"{child} original quality jobs")
    print("Five parent release workflows retain all fourteen reusable quality gates: PASS")

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

    verify_consolidated_quality_workflows()
    print("Android + Flutter Web every-stage workflow contract: PASS")


if __name__ == "__main__":
    main()
