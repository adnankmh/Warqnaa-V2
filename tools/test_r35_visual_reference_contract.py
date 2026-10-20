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
        ("R51FeaturedGamesAndTournaments(controller: controller, onTab: onTab)", "real phone reference renderer"),
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
    check(web_shell, "?v=40-rummy-turn-controls", "R40 versioned production theme")
    for needle in (
        "R35StoreTreasureStrip(controller: controller)",
        "'ردود الفعل والباقات'", "'ملفي الشخصي ومظهر الباشا'",
        "'التدريب مع الروبوتات'", "showGameLobby(context, controller, featured.first)",
        "showAvatarPicker(context, controller)", "onAction: () => onTab(0)",
    ):
        check(visual, needle, "working native mobile reference panel")
    # The development dashboard must be real, primary-admin-only and derived
    # from the exact latest GitHub PR head, never a hard-coded success counter.
    for needle in (
        "w36-live-progress",
        "auth()->user()->isPrimaryAdmin()",
        "https://api.github.com/repos/adnankmh/Warqnaa-V2",
        "data-w36-workflow",
        "/pulls/29",
        "/actions/runs?head_sha=",
        "event=pull_request",
        "aria-valuenow",
        "setInterval",
        "response.ok",
        "Live refresh unavailable",
    ):
        check(web_home, needle, "admin-only real GitHub release progress")
    for workflow in (
        "Backend CI and Security Foundation",
        "Build Android APK and AAB",
        "Build and deploy Flutter Web",
        "Production Release Gate",
        "R7 isolated runtime and visual review",
    ):
        check(web_home, workflow, "five quality gates preserve individual status")
    for needle in (
        ".w36-progress-center",
        ".w36-progress-gate[data-status=\"success\"]",
        ".w36-progress-gate[data-status=\"failed\"]",
        ".w36-progress-track",
        "@media(max-width:560px)",
    ):
        check(web_style, needle, "responsive honest progress display")
    check(web_shell, "?v=40-rummy-turn-controls", "refresh shared legibility and rummy CSS")
    for needle in (
        "R37 SKY SURFACE LEGIBILITY",
        "--r37-copy:#f4fcff",
        ".store-section-head-v127 h2",
        ".w36-game-tile-info strong",
        "@media(prefers-contrast:more)",
    ):
        check(web_style, needle, "shared home store and game legibility contract")
    for needle in (
        'id="w36-commit-heading"',
        'id="w36-commit-list"',
        'id="w36-commit-summary"',
        "previousCommitSha",
        "lastCommitUpdate",
        "async function refreshCommits(",
        "'/commits?sha=' + encodeURIComponent(sha) + '&per_page=8'",
        "Number.isSafeInteger(reportedCount)",
        "document.createElement('strong')",
        "document.createElement('small')",
        "commit.sha.slice(0, 8)",
        "title.textContent",
        "link.rel = 'noopener noreferrer'",
        "commitList.replaceChildren(fragment)",
        "void refreshCommits(sha, pr.commits)",
    ):
        check(web_home, needle, "verified real GitHub commit history and safe DOM")
    for needle in (
        ".w36-commit-center",
        ".w36-commit-list",
        ".w36-commit-heading",
        "@media(max-width:620px)",
    ):
        check(web_style, needle, "responsive genuine commit feed")
    assert "innerHTML" not in web_home, "Never render GitHub commit messages as HTML."
    assert "100%" not in web_home, "Do not label commit count as product completion."

    assert "— / 5" in web_home, "First render must never invent successful workflow counts."
    assert "Passing workflows" in web_home, "Do not mistake CI for total game progress."

    assert "password" not in web_home.lower(), "Public showcase must not expose demo credentials."
    assert "design-reference.png" not in web_home, "Never render the entire collage as a fake screen."

    # R36 game-hall replacement: real playable URLs and actual catalog art,
    # not a decorative screenshot. Filters must have observable accessible state.
    hall = read("backend-laravel/resources/views/games/index.blade.php")
    for needle in (
        "w36-premium-games",
        "game_art_url($game->key)",
        "route('rooms.index',$game->key)",
        "route('tournaments')",
        "route('clubs')",
        "data-family-filter-v130",
        "aria-pressed",
        "aria-controls",
        "id=\"gameSearchV130\"",
        "id=\"w36GamesResults\"",
        "id=\"w36GamesEmpty\"",
        "id=\"w36ClearGameFilters\"",
        "card.hidden=!match",
        "empty.hidden=visible!==0",
        "clear.addEventListener",
        "$ar ? 'جميع الألعاب' : 'All games'",
    ):
        check(hall, needle, "functional accessible bilingual game hall")
    for needle in (
        "R36 Premium Games Hall",
        ".w36-games-wall",
        ".w36-game-hall-hero",
        ".w36-game-tile-art img",
        ".w36-game-tile[hidden]",
        ".w36-games-empty[hidden]",
        ".w36-featured-ribbon",
        "@media(max-width:520px)",
    ):
        check(web_style, needle, "reference-aligned responsive game hall")
    assert "object-fit:contain!important" in web_style, "Game illustrations must remain uncropped."
    # Cross-platform game-card fidelity: native Flutter tiles keep their
    # genuine gameplay callbacks and uncut artwork while using premium colors.
    for marker in (
        "class R51FeaturedGamesAndTournaments",
        "R35ArtGameCard(",
        "r101GameArtAsset(game.id)",
        "fit: BoxFit.contain",
        "onTap: () => showGameLobby(context, controller, games[index])",
        "crossAxisCount: gameColumns",
    ):
        check(reference, marker, "shared responsive playable illustrated game tiles")
    assert "MediaQuery.sizeOf(context).width >= 1024" in visual
    assert "R51FeaturedGamesAndTournaments(controller: controller, onTab: onTab)" in visual
    assert "innerHTML" not in hall, "Client search must not inject untrusted text as HTML."
    assert "http://" not in hall, "No unencrypted third-party illustration URLs."

    assert "password" not in reference.lower(), "Never reproduce demo credentials from the collage."
    print("R35 screenshot-guided Warqnaa world contract: PASS")


if __name__ == "__main__":
    main()
