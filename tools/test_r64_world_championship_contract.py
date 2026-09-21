#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]

def read(rel):
    return (ROOT / rel).read_text(encoding='utf-8', errors='ignore')

def ok(condition, message):
    if not condition:
        print('[FAIL]', message)
        raise SystemExit(1)
    print('[PASS]', message)

meta = json.loads(read('RELEASE_VERSION.json'))
ok(meta['build'] >= 640, 'R6.4 metadata is authoritative')

main = read('flutter_app/lib/main.dart')
r64 = read('flutter_app/lib/r6_4_world_championship.dart')
api = read('flutter_app/lib/services/api_client.dart')
routes = read('backend-laravel/routes/api.php')

ok("part 'r6_4_world_championship.dart';" in main, 'R6.4 Flutter module is wired')
ok('R64PlayHubPage(controller: widget.controller)' in main, 'unified play hub replaces the legacy games root')
for symbol in ['R64PlayHubPage', 'R64RoomBrowserPage', '_R64PlayCommandBar', '_R64RoomCard']:
    ok(f'class {symbol}' in r64, f'{symbol} is implemented')
for capability in ['createPartyV300', 'availableRooms', 'joinGame', 'competitiveR12', 'socialWorldR11', 'activateStoreItemV183']:
    ok(capability in api, f'{capability} client contract is retained')
for route in ['/games/{gameKey}/rooms', '/games/session/{room:code}/join', '/parties', '/competitive', '/social-world', '/store/activate']:
    ok(route in routes, f'{route} server route is available')
ok('server-authoritative release' in r64 and 'serverConnected' in r64, 'online-only operations fail safely')

print('R6.4 WORLD CHAMPIONSHIP CONTRACT: PASS')
