from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def require(text: str, needle: str, context: str) -> None:
    assert needle in text, f"Missing {context}: {needle}"


def main() -> None:
    design = read("flutter_app/lib/r9_design_system.dart")
    visual = read("flutter_app/lib/b307_visual_revolution.dart")
    main_dart = read("flutter_app/lib/main.dart")

    # Shared production palette: bright sky/azure is the visible foundation,
    # while gold is reserved for premium hierarchy and conversion emphasis.
    for needle, label in (
        ("Color(0xFF24C8FF)", "sky blue token"),
        ("Color(0xFF0B8CFF)", "azure token"),
        ("Color(0xFF22D3EE)", "cyan token"),
        ("Color(0xFFFFC84A)", "premium gold token"),
        ("Color(0xFF07598F)", "blue glass surface"),
    ):
        require(design, needle, label)

    require(design, "class R9Section", "shared glass section")
    require(design, "R9Design.sky.withValues", "cyan focus/border treatment")
    require(design, "NavigationBarThemeData", "shared responsive navigation styling")

    # R27 visual layer must remain original Warqnaa blue/cyan/gold and use the
    # shipped game-art pipeline rather than falling back to emoji-only cards.
    require(visual, "class B307SkyLuxury", "Sky Luxury visual system")
    require(visual, "0xff24c8ff", "Sky Luxury sky token")
    require(visual, "0xff0b8cff", "Sky Luxury azure token")
    require(visual, "0xffffc84a", "Sky Luxury gold token")
    require(visual, "r101GameArtAsset(game.id)", "real game art on dashboard cards")
    require(visual, "B307SkyLuxury.heroGradient", "premium hero gradient")
    require(visual, "B307SkyLuxury.panelGradient", "blue glass panel gradient")
    require(visual, "B307CashShopPage", "premium store surface")

    # The visual modules are compiled into the real Flutter application.
    require(main_dart, "import 'r9_design_system.dart';", "shared design-system import")
    require(main_dart, "part 'b307_visual_revolution.dart';", "R27 visual part inclusion")

    # Accessibility and responsive safety remain part of the visual contract.
    require(design, "minimumSize: const Size(44, 48)", "44px minimum touch target")
    require(visual, "MediaQuery.sizeOf(context).width > 700", "responsive store grid")
    require(visual, "maxLines: 1", "narrow-layout text guard")
    require(visual, "overflow: TextOverflow.ellipsis", "narrow-layout overflow guard")

    print("R27 sky-blue luxury visual contract: PASS")


if __name__ == "__main__":
    main()
