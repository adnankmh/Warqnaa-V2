from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding='utf-8')


def require(text: str, needle: str, context: str) -> None:
    assert needle in text, f'Missing {context}: {needle}'


def main() -> None:
    main_dart = read('flutter_app/lib/main.dart')

    require(main_dart, "r32-premium-notifications", 'premium notifications center')
    require(main_dart, "r32-premium-wallet", 'premium wallet center')
    require(main_dart, "r32-wallet-balance-card", 'wallet balance card')
    require(main_dart, "r32-premium-rewards", 'premium rewards center')
    require(main_dart, "r32-premium-settings", 'premium settings center')
    require(main_dart, "r32-settings-save", 'settings save action')
    require(main_dart, "Gameplay experience", 'settings gameplay section')
    require(main_dart, "Identity & player", 'settings identity section')
    require(main_dart, "Display & accessibility", 'settings accessibility section')
    require(main_dart, "Language & system", 'settings system section')
    require(main_dart, "B307SkyLuxury.heroGradient", 'premium wallet hero gradient')
    require(main_dart, "controller.serverConnected ? 'LIVE API' : 'PWA LOCAL'", 'settings connection state')
    require(main_dart, "controller.markAllRead()", 'notifications read-all behavior')
    require(main_dart, "controller.claimDaily()", 'daily reward behavior')
    require(main_dart, "controller.reconnectV173()", 'wallet server refresh behavior')

    print('R32 premium account and rewards center contract: PASS')


if __name__ == '__main__':
    main()
