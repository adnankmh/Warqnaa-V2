from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding='utf-8')


def require(text: str, needle: str, context: str) -> None:
    assert needle in text, f'Missing {context}: {needle}'


def main() -> None:
    visual = read('flutter_app/lib/b307_visual_revolution.dart')
    social = read('flutter_app/lib/r11_social_world.dart')
    competitive = read('flutter_app/lib/r12_competitive.dart')

    require(visual, "1.5.0+309-premium-world", 'R29 visual release marker')
    require(visual, "r29-commerce-trust-strip", 'commerce trust strip')
    require(visual, "B307CommerceTrustStrip", 'commerce trust component')
    require(visual, "B307PageHero(", 'premium offer page hero')
    require(visual, "verified payment provider", 'provider-verification copy')

    require(social, "r29-sky-social-hero", 'social-world sky hero')
    require(social, "const Color _r11Mint = B307SkyLuxury.cyan", 'social cyan palette')
    require(social, "B307PageHero(", 'clubs premium hero')
    require(social, "Warqnaa Clubs", 'clubs English identity')

    require(competitive, "r29-sky-competitive-shell", 'competitive sky shell')
    require(competitive, "r29-sky-season-rank", 'season rank premium surface')
    require(competitive, "const Color _r12Panel = B307SkyLuxury.surface", 'competitive sky panel palette')
    require(competitive, "B307PageHero(", 'tournament premium hero')

    print('R29 premium world polish contract: PASS')


if __name__ == '__main__':
    main()
