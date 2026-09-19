"""Ensure successor compatibility rejects severed routes and missing UI wiring."""
from pathlib import Path
from home_successor_contract import premium_web_home_is_wired, r61_home_is_wired, r64_hub_is_wired

ROOT = Path(__file__).resolve().parents[1]
def read(path):
    return (ROOT / path).read_text(encoding='utf-8')

main = read('flutter_app/lib/main.dart')
home = read('flutter_app/lib/r6_1_world_class.dart')
hub = read('flutter_app/lib/r6_4_world_championship.dart')
web = read('backend-laravel/resources/views/home.blade.php')
layout = read('backend-laravel/resources/views/layouts/app.blade.php')
css = read('backend-laravel/public/assets/css/r6-1-world-class.css')

assert r61_home_is_wired(main, home)
assert not r61_home_is_wired(main.replace('=> R61HomeDashboard(', '=> RemovedHome('), home)
assert not r61_home_is_wired(main, home.replace('onTab(1)', 'onTab(0)'))
assert r64_hub_is_wired(main, hub)
assert not r64_hub_is_wired(main.replace('R64PlayHubPage(controller: widget.controller)', 'GamesPage(controller: widget.controller)'), hub)
assert not r64_hub_is_wired(main, hub.replace('onParty: _createParty', 'onParty: () {}'))
assert not r64_hub_is_wired(main, hub.replace('onWatch: () => _open(R11SocialWorldPage(controller: widget.controller))', 'onWatch: () {}'))
assert premium_web_home_is_wired(web, layout, css)
assert premium_web_home_is_wired(web.replace('WARQNAA WORLD • R6.1', 'Warqnaa'), layout, css)
assert not premium_web_home_is_wired(web.replace("route('rooms.index',$game->key)", "route('home')"), layout, css)
assert not premium_web_home_is_wired(web, layout.replace('r6-1-world-class.css', 'missing.css'), css)
print('[PASS] Successor gates reject disconnected home, game, party, spectator and Web routes while allowing copy changes')
