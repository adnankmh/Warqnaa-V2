from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding='utf-8')


def require(text: str, needle: str, context: str) -> None:
    assert needle in text, f'Missing {context}: {needle}'


def main() -> None:
    main_dart = read('flutter_app/lib/main.dart')

    require(main_dart, "r31-premium-game-lobby", 'premium game lobby')
    require(main_dart, "r31-lobby-connection-strip", 'lobby connection state')
    require(main_dart, "class _R31LobbyActionTile", 'responsive primary lobby actions')
    require(main_dart, "r31-lobby-tools-grid", 'responsive room tools grid')
    require(main_dart, "class _R31LobbyTool", 'room tool component')
    require(main_dart, "B307PageHero(", 'shared premium page hero')
    require(main_dart, "showPlayModePicker(context, controller, game)", 'friendly play navigation')
    require(main_dart, "showCompetitions(context, controller)", 'competition navigation')
    require(main_dart, "showCreateRoom(context, controller, game)", 'create-room navigation')
    require(main_dart, "showAvailableRooms(context, controller, game)", 'open-room navigation')
    require(main_dart, "showJoinRoomByCode(context, controller, game)", 'join-code navigation')
    require(main_dart, "controller.serverConnected ? Icons.cloud_done_rounded : Icons.phone_android_rounded", 'live/local status')
    require(main_dart, "gradient: B307SkyLuxury.panelGradient", 'shared sky panel styling')

    print('R31 premium lobby and room-flow contract: PASS')


if __name__ == '__main__':
    main()
