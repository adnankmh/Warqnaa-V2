"""Source wiring checks shared by historical home-screen compatibility gates.

These checks establish reachability, not runtime or visual correctness.
"""
import re


def r61_home_is_wired(main: str, home: str, lobby: str = '') -> bool:
    base = all((
        "part 'r6_1_world_class.dart';" in main,
        bool(re.search(r'=>\s*R61HomeDashboard\(controller:\s*controller,\s*onTab:\s*onTab\)', main)),
        'class R61HomeDashboard extends StatelessWidget' in home,
    ))
    if "part 'r8_play_experience.dart';" in main:
        return base and all((
            '=> R8HomeLobby(controller: controller, onTab: onTab)' in home,
            'class R8HomeLobby extends StatelessWidget' in lobby,
            "controller.localeCode == 'ar'" in lobby,
            'constraints.maxWidth' in lobby,
            'onTab(1)' in lobby,
            'showGameLobby(context, controller, game)' in lobby,
            'R64RoomBrowserPage(controller: controller)' in lobby,
            'R65PartyPage(controller: controller)' in lobby,
        ))
    return base and all((
        'LayoutBuilder' in home,
        'constraints.maxWidth' in home,
        '_R61Hero(controller: controller, onPlay: () => onTab(1))' in home,
        'showGameLobby(context, controller, game)' in home,
    ))


def r64_hub_is_wired(main: str, hub: str) -> bool:
    return all((
        "part 'r6_4_world_championship.dart';" in main,
        'R64PlayHubPage(controller: widget.controller)' in main,
        'class R64PlayHubPage extends StatefulWidget' in hub,
        'showGameLobby(context, widget.controller, game)' in hub,
        'R64RoomBrowserPage(controller: widget.controller)' in hub,
        'R65PartyPage(controller: widget.controller)' in hub,
        'onQuickMatch: _quickMatch' in hub,
        'onParty: _createParty' in hub,
        'onWatch: () => _open(R11SocialWorldPage(controller: widget.controller))' in hub,
        'onRanked: () => _open(R12CompetitiveArenaPage(controller: widget.controller))' in hub,
    ))


def premium_web_home_is_wired(home: str, layout: str, css: str) -> bool:
    # Preserve the bilingual responsive game hub, not a release-specific slogan.
    return all((
        "$ar=app()->getLocale()==='ar'" in home,
        "$ar?'" in home,
        'class="b304-head"' in home,
        'class="b304-grid"' in home,
        'GameCatalog::customerKeys()' in home,
        "route('rooms.index',$game->key)" in home,
        "route('competitive')" in home,
        'r6-1-world-class.css' in layout,
        'warqna-r61' in layout,
        '.warqna-r61 .b304-home' in css,
        '@media' in css,
    ))
