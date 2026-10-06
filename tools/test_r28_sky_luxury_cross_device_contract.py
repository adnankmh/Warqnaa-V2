from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def require(text: str, needle: str, context: str) -> None:
    assert needle in text, f"Missing {context}: {needle}"


def main() -> None:
    main_dart = read("flutter_app/lib/main.dart")
    visual = read("flutter_app/lib/b307_visual_revolution.dart")

    # R28 makes the approved bright sky-luxury layer the real customer shell,
    # not a dormant visual prototype.
    require(main_dart, "B307DesktopNavigation(controller: widget.controller", "desktop sky-luxury navigation activation")
    require(main_dart, "B307BottomNavigation(", "mobile sky-luxury bottom navigation activation")
    require(main_dart, "B307TopBar(controller: controller)", "real shell sky-luxury top bar")
    require(main_dart, "B307HomeDashboard(controller: controller, onTab: onTab)", "real sky-luxury home dashboard")

    # Preserve exact five-tab semantics used by the existing application shell.
    for needle, label in (
        ("Icons.storefront_outlined", "store destination"),
        ("Icons.style_outlined", "games destination"),
        ("Icons.home_rounded", "home destination"),
        ("Icons.groups_2_outlined", "social destination"),
        ("Icons.emoji_events_outlined", "events destination"),
    ):
        require(visual, needle, label)

    require(visual, "class B307DesktopNavigation", "responsive desktop navigation")
    require(visual, "r28-sky-desktop-navigation", "desktop navigation test key")
    require(visual, "مجتمع ألعاب الورق", "Arabic Warqnaa desktop identity")
    require(visual, "Social card games", "English Warqnaa desktop identity")
    require(visual, "B307SkyLuxury.shellGradient", "bright blue shell gradient")
    require(visual, "B307SkyLuxury.goldSoft", "premium gold hierarchy")
    require(visual, "Semantics(", "navigation accessibility semantics")
    require(visual, "overflow: TextOverflow.ellipsis", "narrow-layout overflow guard")

    # The first visual closure increment must not remove R27 game art or store.
    require(visual, "r101GameArtAsset(game.id)", "real shipped game art")
    require(visual, "B307CashShopPage", "real-money store surface")

    print("R28 sky-luxury cross-device shell contract: PASS")


if __name__ == "__main__":
    main()
