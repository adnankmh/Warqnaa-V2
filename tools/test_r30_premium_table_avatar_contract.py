from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding='utf-8')


def require(text: str, needle: str, context: str) -> None:
    assert needle in text, f'Missing {context}: {needle}'


def main() -> None:
    main_dart = read('flutter_app/lib/main.dart')
    play = read('flutter_app/lib/r8_play_experience.dart')
    premium = read('flutter_app/lib/premium_v149.dart')

    require(main_dart, "r30-premium-card-back", 'premium card-back marker')
    require(main_dart, "r30-premium-table-surface", 'premium table marker')
    require(main_dart, "r30-table-brand-badge", 'table identity badge')
    require(main_dart, "r30-room-tool-", 'premium room controls')
    require(main_dart, "B307SkyLuxury.cyan", 'sky/cyan card selection')
    require(main_dart, "r30-avatar-preview-ring", 'premium avatar preview')
    require(main_dart, "Avatar studio", 'localized avatar studio')
    require(main_dart, "Premium symbols", 'premium avatar symbols')

    require(play, "r30-seat-$name", 'premium player seat marker')
    require(play, "B307SkyLuxury.azure", 'active seat sky palette')
    require(play, "B307SkyLuxury.goldSoft", 'active turn gold highlight')
    require(premium, "r30-sky-reaction-dock", 'premium reaction dock')
    require(premium, "r30-sky-floating-reaction", 'premium floating reaction')
    require(premium, "r30-bot-identity-", 'premium bot identity surface')
    require(premium, "B307SkyLuxury.heroGradient", 'shared sky hero gradient for reactions')
    require(premium, "Gameplay decisions come from the authoritative engine, not this presentation layer.", 'authoritative bot-engine boundary')

    print('R30 premium tables, avatars and interactions contract: PASS')


if __name__ == '__main__':
    main()
