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
    final raw = state['melds'] ?? state['table_groups'];
    final ownerGroups = <String, List<List<String>>>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        final groups = <List<String>>[];
        if (entry.value is List) {
          for (final group in entry.value as List) {
            final cards = group is Map ? group['cards'] : group;
            if (cards is List && cards.isNotEmpty) {
              groups.add(cards.map((value) => value.toString()).toList());
            }
          }
        }
        if (groups.isNotEmpty) ownerGroups[entry.key.toString()] = groups;
      }
    }

    final playerInfo = <String, Map<String, dynamic>>{};
    for (final player in players) {
      if (player is! Map) continue;
      final item = Map<String, dynamic>.from(player);
      final id = (item['id'] ?? item['player_id'] ?? '').toString();
      if (id.isNotEmpty) playerInfo[id] = item;
    }
    final teams = state['teams'] is Map ? state['teams'] as Map : const {};
    String teamOfOwner(String owner, int index) {
      if (teams['teamA'] is List && (teams['teamA'] as List).contains(owner)) return '0';
      if (teams['teamB'] is List && (teams['teamB'] as List).contains(owner)) return '1';
      return playerInfo[owner]?['team']?.toString() ?? '${index % 2}';
    }
    final ordered = ownerGroups.entries.toList(growable: false);
    final count = int.tryParse('${state['deck_count'] ?? ''}')
        ?? (state['deck'] is List ? (state['deck'] as List).length : 0);
    final publicDiscard = state['discard'] is List ? state['discard'] as List : const [];
    final topDiscard = publicDiscard.isEmpty ? null : publicDiscard.last.toString();

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
                  for (var i = 0; i < ordered.length; i++)
                    _ownerTile(
                      key: ValueKey('r44-meld-owner-${ordered[i].key}'),
                      id: ordered[i].key,
                      groups: ordered[i].value,
                      player: playerInfo[ordered[i].key],
                      team: partnership ? teamOfOwner(ordered[i].key, i) : '$i',
                      compact: compact,
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
              ),
              const SizedBox(width: 11),
              _pile(
                key: const ValueKey('r44-fire-pile'),
                icon: Icons.local_fire_department_rounded,
                label: tr('الرمي', 'Discard'),
                number: publicDiscard.length,
                card: topDiscard,
                onTap: onDrawDiscard,
                compact: compact,
              ),
              if (onDrawStack != null) ...<Widget>[
                const SizedBox(width: 5),
                IconButton(
                  key: const ValueKey('r44-stack-pick'),
                  onPressed: onDrawStack,
                  tooltip: tr('اختر ورقة من النار واسحبها مع التي فوقها',
                    'Take a selected discard with all newer cards'),
                  icon: const Icon(Icons.layers_rounded,
                    color: B307SkyLuxury.goldSoft, size: 23),
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
    required bool compact,
  }) {
    final teamIndex = int.tryParse(team) ?? team.hashCode.abs();
    const colors = <Color>[
      Color(0xFF51D8FF), Color(0xFFFFD16A),
      Color(0xFF92EBB0), Color(0xFFCEACFF),
    ];
    final tint = colors[teamIndex % colors.length];
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
          color: B307SkyLuxury.navy.withValues(alpha: .77),
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

  String partnershipLabel(String team, String name) {
    if (!partnership) return name;
    return '${tr('فريق', 'Team')} $team • $name';
  }

  Widget _pile({
    required Key key, required IconData icon, required String label,
    required int number, required String? card,
    required VoidCallback? onTap, required bool compact,
  }) {
    return Semantics(
      button: onTap != null,
      label: '$label $number',
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          width: compact ? 72 : 82,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: B307SkyLuxury.deep.withValues(alpha: .92),
            border: Border.all(color: onTap != null
              ? B307SkyLuxury.goldSoft : B307SkyLuxury.cyan.withValues(alpha: .45)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            SizedBox(
              height: compact ? 32 : 37,
              child: card == null
                ? Icon(icon, color: B307SkyLuxury.goldSoft, size: 29)
                : PlayingCard(label: cardLabel(card),
                    width: compact ? 24 : 28, height: compact ? 32 : 37),
            ),
            Text('$label · $number',
              textAlign: TextAlign.center,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 10.5,
                fontWeight: FontWeight.w900)),
          ]),
        ),
      ),
    );
  }
}
