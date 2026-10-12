"""R35 screenshot-reference contract for active Flutter Android/Web surfaces.

All required elements must be genuinely navigable and preserve earlier releases.
The uploaded collage is a visual reference, never embedded as a fake UI.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def check(haystack: str, needle: str, name: str) -> None:
    assert needle in haystack, f"R35 missing {name}: {needle}"


def main() -> None:
    main_dart = read("flutter_app/lib/main.dart")
    visual = read("flutter_app/lib/b307_visual_revolution.dart")
    reference = read("flutter_app/lib/r35_reference_world.dart")
    widget_test = read("flutter_app/test/r35_reference_world_test.dart")

    for needle, name in (
        ("part 'r35_reference_world.dart';", "real Flutter part registration"),
        ("R35StoreTreasureStrip(controller: widget.controller)", "store use"),
        ("B307HomeDashboard(controller: controller, onTab: onTab)", "legacy home activation"),
        ("B307DesktopNavigation(controller: widget.controller", "desktop shell"),
        ("B307BottomNavigation(", "phone shell"),
    ):
        check(main_dart, needle, name)

    for needle, name in (
        ("R35ReferenceWorldDashboard(controller: controller, onTab: onTab)", "desktop reference activation"),
        ("R35ChampionBanner(controller: controller)", "phone grand tournament artwork"),
        ("r101GameArtAsset(game.id)", "real packaged game images"),
        ("Expanded(child: SizedBox(", "short phone image height safety"),
        ("AccountAvatar(controller: controller", "genuine round avatar image"),
        ("Icons.leaderboard_rounded", "functional ranking shortcut"),
        ("Icons.card_giftcard_rounded", "functional rewards shortcut"),
    ):
        check(visual, needle, name)

    for needle, name in (
        ("r35-reference-world-dashboard", "reference desktop design"),
        ("r35-sky-grand-tournament-banner", "gold championship hero"),
        ("R35CoastalBannerPainter", "original scenic coastline art"),
        ("R35GoldTrophyPainter", "original gold trophy"),
        ("R35ArtGameCard", "illustrated game cards"),
        ("R35StoreTreasureStrip", "store showcase"),
        ("showProductPreview(context, controller, samples[i])", "real store product preview"),
        ("showRewards(context, controller)", "functional rewards"),
        ("R12CompetitiveArenaPage(controller: controller)", "real tournament route"),
        ("ClubsPage(controller: controller)", "real club route"),
        ("showAvatarPicker(context, controller)", "real photo editor"),
        ("showWallet(context, controller)", "real token wallet"),
        ("controller.isStoreProductVisible", "active catalogue eligibility"),
        ("controller.priceFor(product)", "actual catalogue pricing"),
        ("R35ReferenceColors.gold", "gold controls"),
        ("R35ReferenceColors.cyan", "electric cyan accents"),
    ):
        check(reference, needle, name)

    for needle, name in (
        ("R35 original coastline and trophy render at both orientations", "artwork smoke test"),
        ("R35 gold CTA is accessible and invokes a real callback", "CTA wiring test"),
        ("R35 illustrated real-art game card opens actual game action", "game route wiring test"),
        ("R35 wide world exposes functional panels without layout overflow", "desktop layout test"),
    ):
        check(widget_test, needle, name)

    # R36 expands the photographed design into real server-rendered dashboard
    # panels and interactive native app components, never a screenshot overlay.
    web_home = read("backend-laravel/resources/views/home.blade.php")
    web_style = read("backend-laravel/public/assets/css/b307-cardroom-ui.css")
    web_shell = read("backend-laravel/resources/views/layouts/app.blade.php")
    for needle in (
        "w36-grand-hero", "w36-tournaments", "w36-clubs", "w36-profile",
        "w36-store-preview", "w36-reactions", "w36-bots",
        "withCount('members')", "withCount('entries')", "game_art_url($game->key)",
        "route('tournaments')", "route('clubs')", "route('store')",
    ):
        check(web_home, needle, "live premium web dashboard")
    for needle in (
        "R36 SKY-GOLD REFERENCE IMPLEMENTATION",
        ".w36-world-grid", ".w36-grand-hero", ".w36-profile-avatar",
        ".w36-store-items", ".w36-emoji-preview", "body.warqna-b304",
        "prefers-reduced-motion", "focus-visible",
    ):
        check(web_style, needle, "original responsive visual design")
    check(web_shell, "?v=36-sky-world", "versioned production theme")
    for needle in (
        "R35StoreTreasureStrip(controller: controller)",
        "'ردود الفعل والباقات'", "'ملفي الشخصي ومظهر الباشا'",
        "'التدريب مع الروبوتات'", "showGameLobby(context, controller, featured.first)",
        "showAvatarPicker(context, controller)", "onAction: () => onTab(0)",
    ):
        check(visual, needle, "working native mobile reference panel")
    assert "password" not in web_home.lower(), "Public showcase must not expose demo credentials."
    assert "design-reference.png" not in web_home, "Never render the entire collage as a fake screen."

    assert "password" not in reference.lower(), "Never reproduce demo credentials from the collage."
    print("R35 screenshot-guided Warqnaa world contract: PASS")


if __name__ == "__main__":
    main()
