part of 'main.dart';

/// R44: native, seat-owned rummy groups and two central physical piles.
/// Both piles use existing server-authorized draw callbacks; no state is
/// mutated by this widget and opponents' hands are never rendered.
class R44RummyTableOverlay extends StatelessWidget {
  const R44RummyTableOverlay({
    super.key, required this.state, required this.players,
    required this.ar, required this.cardLabel, required this.partnership,
    this.onDrawDeck, this.onDrawDiscard, this.onDrawStack,
  });
  final Map<String, dynamic> state;
  final List players;
  final bool ar;
  final bool partnership;
  final String Function(String) cardLabel;
  final VoidCallback? onDrawDeck;
  final VoidCallback? onDrawDiscard;
  final VoidCallback? onDrawStack;

  String tr(String arText, String enText) => ar ? arText : enText;

  @override
  Widget build(BuildContext context) {
    final colors = R69PlaySurfaceColors.of(context);
    // Room players use key/user_key; direct engine fixtures can use id.
    // Normalize only public table data, never an opponent's hidden hand.
    String playerKey(Map player) =>
        (player['key'] ?? player['user_key'] ?? player['id'] ??
            player['player_id'] ?? '').toString();
    final playerInfo = <String, Map<String, dynamic>>{};
    for (final player in players) {
      if (player is! Map) continue;
      final item = Map<String, dynamic>.from(player);
      final id = playerKey(item);
      if (id.isNotEmpty) playerInfo[id] = item;
    }

    final raw = state['melds'] ?? state['table_groups'];
    final ownerGroups = <String, List<List<String>>>{};
    void addGroup(String owner, dynamic group) {
      final cards = group is Map ? group['cards'] : group;
      if (owner.isEmpty || cards is! List || cards.isEmpty) return;
      ownerGroups.putIfAbsent(owner, () => <List<String>>[])
          .add(cards.map((value) => value.toString()).toList());
    }
    if (raw is Map) {
      // Authoritative rooms group melds by player key.
      for (final entry in raw.entries) {
        if (entry.value is List) {
          for (final group in entry.value as List) {
            addGroup(entry.key.toString(), group);
          }
        }
      }
    } else if (raw is List) {
      // Offline sessions keep parallel meld and owner-seat lists.
      final owners = state['meld_owners'];
      if (owners is List) {
        for (var i = 0; i < raw.length && i < owners.length; i++) {
          final seat = int.tryParse(owners[i].toString());
          if (seat == null || seat < 0 || seat >= players.length ||
              players[seat] is! Map) {
            continue;
          }
          addGroup(playerKey(players[seat] as Map), raw[i]);
        }
      }
    }
    final teams = state['teams'] is Map ? state['teams'] as Map : const {};
    String teamOfOwner(String owner, int index) {
      if (teams['teamA'] is List && (teams['teamA'] as List).contains(owner)) return '0';
      if (teams['teamB'] is List && (teams['teamB'] as List).contains(owner)) return '1';
      final seat = players.indexWhere((player) => player is Map && playerKey(player) == owner);
      return playerInfo[owner]?['team']?.toString() ?? '${(seat >= 0 ? seat : index) % 2}';
    }
    final ordered = ownerGroups.entries.toList(growable: false);
    final teamGroups = <String, List<MapEntry<String, List<List<String>>>>>{};
    if (partnership) {
      for (var i = 0; i < ordered.length; i++) {
        final entry = ordered[i];
        teamGroups.putIfAbsent(teamOfOwner(entry.key, i), () => []).add(entry);
      }
    }
    final count = int.tryParse('${state['deck_count'] ?? ''}')
        ?? (state['deck'] is List ? (state['deck'] as List).length : 0);
    final rawDiscard = state['discard'] ?? state['discard_pile'];
    final publicDiscard = rawDiscard is List ? rawDiscard : const [];
    final lastDiscard = publicDiscard.isEmpty ? null : publicDiscard.last;
    // Server discards can retain their public player/card metadata.
    final topDiscard = (lastDiscard is Map
        ? lastDiscard['card'] : lastDiscard)?.toString();

    return LayoutBuilder(builder: (context, area) {
      final compact = area.maxWidth < 250;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (ordered.isNotEmpty) Flexible(
            child: SingleChildScrollView(
              key: const ValueKey('r44-meld-owner-scroll'),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 5, runSpacing: 5,
                children: <Widget>[
                  if (partnership)
                    for (final team in teamGroups.entries)
                      _teamTile(
                        key: ValueKey('r84-meld-team-${team.key}'),
                        team: team.key,
                        owners: team.value,
                        playerInfo: playerInfo,
                        compact: compact,
                        colors: colors,
                      )
                  else
                    for (var i = 0; i < ordered.length; i++)
                      _ownerTile(
                        key: ValueKey('r44-meld-owner-${ordered[i].key}'),
                        id: ordered[i].key,
                        groups: ordered[i].value,
                        player: playerInfo[ordered[i].key],
                        team: '$i',
                        compact: compact,
                        colors: colors,
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            key: const ValueKey('r44-central-rummy-piles'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _pile(
                key: const ValueKey('r44-stock-pile'),
                icon: Icons.style_rounded,
                label: tr('الرزمة', 'Stock'),
                number: count,
                card: null,
                onTap: onDrawDeck,
                compact: compact,
                colors: colors,
                surfaceKey: const ValueKey('r69-stock-pile-surface'),
              ),
              SizedBox(width: compact ? 7 : 11),
              _pile(
                key: const ValueKey('r44-fire-pile'),
                icon: Icons.local_fire_department_rounded,
                label: tr('الرمي', 'Discard'),
                number: publicDiscard.length,
                card: topDiscard,
                onTap: onDrawDiscard,
                compact: compact,
                colors: colors,
                surfaceKey: const ValueKey('r69-discard-pile-surface'),
              ),
              if (onDrawStack != null) ...<Widget>[
                const SizedBox(width: 5),
                IconButton(
                  key: const ValueKey('r44-stack-pick'),
                  onPressed: onDrawStack,
                  tooltip: tr('اختر ورقة من النار واسحبها مع التي فوقها',
                    'Take a selected discard with all newer cards'),
                  icon: Icon(Icons.layers_rounded,
                    color: colors.accent, size: 23),
                  constraints: const BoxConstraints(minWidth: 42, minHeight: 44),
                ),
              ],
            ],
          ),
        ],
      );
    });
  }

  Widget _ownerTile({
    required Key key, required String id, required List<List<String>> groups,
    required Map<String, dynamic>? player, required String team,
    required bool compact, required R69PlaySurfaceColors colors,
  }) {
    final teamIndex = int.tryParse(team) ?? team.hashCode.abs();
    const legacyTeamColors = <Color>[
      Color(0xFF51D8FF), Color(0xFFFFD16A),
      Color(0xFF92EBB0), Color(0xFFCEACFF),
    ];
    final tint = Color.lerp(
      legacyTeamColors[teamIndex % legacyTeamColors.length],
      teamIndex.isEven ? colors.accent : colors.secondary,
      .38,
    )!;
    final name = (player?['name'] ?? player?['username'] ??
      player?['display_name'] ?? player?['id'] ?? id).toString();
    final ownerLabel = partnershipLabel(team, name);
    return Semantics(
      label: tr('مجموعات $ownerLabel', '$ownerLabel melds'),
      child: Container(
        key: key,
        constraints: BoxConstraints(maxWidth: compact ? 150 : 195),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: .90),
          border: Border.all(color: tint, width: 1.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text(ownerLabel, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(color: tint, fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          for (final group in groups.take(4))
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: SizedBox(
                height: 26,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: <Widget>[
                    for (final card in group)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 2),
                        child: PlayingCard(
                          label: cardLabel(card),
                          width: 19, height: 25,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (groups.length > 4) Text('+${groups.length - 4}',
            style: TextStyle(color: tint, fontSize: 10)),
        ]),
      ),
    );
  }

  Widget _teamTile({
    required Key key, required String team,
    required List<MapEntry<String, List<List<String>>>> owners,
    required Map<String, Map<String, dynamic>> playerInfo,
    required bool compact, required R69PlaySurfaceColors colors,
  }) {
    final teamIndex = int.tryParse(team) ?? team.hashCode.abs();
    final tint = Color.lerp(
      const <Color>[Color(0xFF51D8FF), Color(0xFFFFD16A)]
          [teamIndex % 2],
      teamIndex.isEven ? colors.accent : colors.secondary,
      .38,
    )!;
    String ownerName(String id) =>
      (playerInfo[id]?['name'] ?? playerInfo[id]?['username'] ??
        playerInfo[id]?['display_name'] ?? playerInfo[id]?['id'] ?? id)
      .toString();
    final names = owners.map((entry) => ownerName(entry.key)).join(' + ');
    final letter = teamIndex == 0 ? tr('أ', 'A') : tr('ب', 'B');
    final teamLabel = '${tr('فريق', 'Team')} $letter';
    return Semantics(
      label: tr('مجموعات $teamLabel المشتركة: $names',
        '$teamLabel shared melds: $names'),
      child: Container(
        key: key,
        constraints: BoxConstraints(maxWidth: compact ? 190 : 290),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: .90),
          border: Border.all(color: tint, width: 1.8),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text('$teamLabel • $names', maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: tint, fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          for (var ownerIndex = 0; ownerIndex < owners.length; ownerIndex++) ...[
            if (ownerIndex > 0) Divider(height: 7, thickness: .7,
              color: tint.withValues(alpha: .35)),
            KeyedSubtree(
              key: ValueKey('r44-meld-owner-${owners[ownerIndex].key}'),
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(ownerName(owners[ownerIndex].key),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textMuted,
                      fontSize: compact ? 9 : 10,
                      fontWeight: FontWeight.w700)),
                ),
                for (final group in owners[ownerIndex].value.take(4))
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: SizedBox(
                      height: 26,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        children: <Widget>[
                          for (final card in group)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 2),
                              child: PlayingCard(label: cardLabel(card),
                                width: 19, height: 25),
                            ),
                        ],
                      ),
                    ),
                  ),
                if (owners[ownerIndex].value.length > 4)
                  Text('+${owners[ownerIndex].value.length - 4}',
                    style: TextStyle(color: tint, fontSize: 10)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  String partnershipLabel(String team, String name) {
    if (!partnership) return name;
    return '${tr('فريق', 'Team')} $team • $name';
  }

  Widget _pile({
    required Key key, required IconData icon, required String label,
    required int number, required String? card,
    required VoidCallback? onTap, required bool compact,
    required R69PlaySurfaceColors colors, required Key surfaceKey,
  }) {
    return Semantics(
      button: onTap != null,
      label: '$label $number',
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          key: surfaceKey,
          width: compact ? 72 : 82,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: colors.surface.withValues(alpha: .94),
            border: Border.all(color: onTap != null
              ? colors.accent : colors.secondary.withValues(alpha: .45)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            SizedBox(
              height: compact ? 32 : 37,
              child: card == null
                ? Icon(icon, color: colors.accent, size: 29)
                : PlayingCard(label: cardLabel(card),
                    width: compact ? 24 : 28, height: compact ? 32 : 37),
            ),
            Text('$label · $number',
              textAlign: TextAlign.center,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.onSurface, fontSize: 10.5,
                fontWeight: FontWeight.w900)),
          ]),
        ),
      ),
    );
  }
}
