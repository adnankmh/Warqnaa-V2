part of 'main.dart';

/// Drafts use hand positions, so the two identical cards in a double deck can
/// be selected independently. The engine validates the whole opening atomically.
class R36MeldWorkspace extends StatefulWidget {
  const R36MeldWorkspace({super.key, required this.cards, required this.ar});
  final List<String> cards;
  final bool ar;
  @override
  State<R36MeldWorkspace> createState() => _R36MeldWorkspaceState();
}

/// Only the already-public discard pile is previewed. The engine still validates
/// the selected count against the current turn when the dialog is submitted.
class R40DiscardStackPicker extends StatefulWidget {
  const R40DiscardStackPicker({super.key, required this.maxCount, required this.cards, required this.ar});
  final int maxCount;
  final List<String> cards;
  final bool ar;
  @override
  State<R40DiscardStackPicker> createState() => _R40DiscardStackPickerState();
}

class _R40DiscardStackPickerState extends State<R40DiscardStackPicker> {
  int count = 2;
  String text(String ar, String en) => widget.ar ? ar : en;
  String label(String card) => r52CardLabel(card);

  @override
  Widget build(BuildContext context) {
    final all = widget.cards;
    // The newest card is at the end; tapping any exposed older card means
    // taking that card AND every newer discard above it. No hidden cards shown.
    final beginning = math.max(0, all.length - 18);
    final chosen = all.skip(math.max(0, all.length - count)).toList();
    // Lightweight tappable card faces keep the original PlayingCard preview
    // semantically separate, and Row avoids AlertDialog viewport intrinsics.
    Widget discardChoice(int index) {
      final needed = all.length - index;
      final included = needed <= count;
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: 5),
        child: Semantics(
          button: true,
          selected: included,
          label: '${label(all[index])} - ${text('اسحب', 'Take')} $needed',
          child: InkWell(
            key: ValueKey('r44-discard-select-$needed'),
            onTap: () => setState(() =>
              count = math.max(2, math.min(widget.maxCount, needed))),
            borderRadius: BorderRadius.circular(9),
            child: Container(
              width: 47,
              height: 69,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF7FBFF),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: included ? B307SkyLuxury.goldSoft : B307SkyLuxury.cyan,
                  width: included ? 3 : 1,
                ),
              ),
              child: Text(
                label(all[index]),
                maxLines: 1,
                style: const TextStyle(color: Color(0xFF082C60),
                  fontWeight: FontWeight.w900, fontSize: 17),
              ),
            ),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 420,
        maxHeight: math.min(470.0, MediaQuery.sizeOf(context).height * .64)),
      child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(text('اضغط على الورقة المطلوبة من النار. ستأخذها مع جميع الأوراق التي فوقها.',
                    'Tap a discard. You will take it and every newer card above it.'),
            style: const TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w800)),
          const SizedBox(height: 9),
          if (all.isNotEmpty)
            SingleChildScrollView(
              key: const ValueKey('r44-discard-tap-strip'),
              scrollDirection: Axis.horizontal,
              child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                for (var i = beginning; i < all.length; i++)
                  discardChoice(i),
              ]),
            ),
          const SizedBox(height: 8),
          Text(text('عدد أوراق النار', 'Discard count'),
            style: const TextStyle(fontWeight: FontWeight.w800)),
          DropdownButton<int>(
            key: const ValueKey('r40-discard-count'),
            isExpanded: true,
            value: count,
            items: <DropdownMenuItem<int>>[
              for (var value = 2; value <= widget.maxCount; value++)
                DropdownMenuItem(value: value, child: Text('$value')),
            ],
            onChanged: (value) { if (value != null) setState(() => count = value); },
          ),
          const SizedBox(height: 8),
          Text(text('الأوراق التي ستحصل عليها ($count)', 'Cards you will receive ($count)'),
            style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          if (chosen.isEmpty)
            Text(text('لا توجد أوراق مكشوفة.', 'No exposed cards.'))
          else Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(spacing: 4, runSpacing: 6, children: [
              for (var i = 0; i < chosen.length; i++)
                Semantics(
                  key: ValueKey('r40-discard-preview-$i'),
                  label: label(chosen[i]),
                  child: PlayingCard(label: label(chosen[i]), width: 37, height: 53),
                ),
            ]),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            key: const ValueKey('r40-confirm-discard-stack'),
            onPressed: () => Navigator.pop(context, count),
            icon: const Icon(Icons.layers_rounded),
            label: Text(text('اسحب $count أوراق', 'Take $count cards'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          ),
        ],
      )),
    );
  }
}

class _R36MeldWorkspaceState extends State<R36MeldWorkspace> {
  final selected = <int>{};
  final groups = <List<int>>[];
  static const groupColors = <Color>[
    Color(0xFF30C9FF), Color(0xFFFFCD55), Color(0xFF60E9A9),
    Color(0xFFC5A6FF), Color(0xFFFF9AAB), Color(0xFF72DDDE),
    Color(0xFFFFB46E), Color(0xFF94B8FF),
  ];
  String text(String ar, String en) => widget.ar ? ar : en;
  String label(String card) => r52CardLabel(card);

  void moveGroup(int from, int by) {
    final to = from + by;
    if (to < 0 || to >= groups.length) return;
    setState(() => groups.insert(to, groups.removeAt(from)));
  }

  @override
  Widget build(BuildContext context) {
    final used = groups.expand((group) => group).toSet();
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      title: Text(text('مجموعات النزول', 'Meld preparation'),
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      content: SizedBox(
        width: 560,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .66),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(text('اختر 3 أوراق أو أكثر ثم ضعها في مستطيل مجموعة. يمكنك تكوين مجموعات متعددة وإلغاء أي مجموعة قبل النزول.',
                          'Tap 3 or more cards, save them as a colored group, and edit each group before submitting.'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.4)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 7, children: [
                  for (var i=0; i<widget.cards.length; i++) if (!used.contains(i))
                    Semantics(
                      selected: selected.contains(i),
                      button: true,
                      label: label(widget.cards[i]),
                      child: InkWell(
                        key: ValueKey('r36-meld-card-$i'),
                        onTap: () => setState(() =>
                          selected.contains(i) ? selected.remove(i) : selected.add(i)),
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            color: selected.contains(i)
                                ? B307SkyLuxury.goldSoft.withValues(alpha: .22)
                                : B307SkyLuxury.navy.withValues(alpha: .25),
                            border: Border.all(
                              color: selected.contains(i)
                                  ? B307SkyLuxury.goldSoft : B307SkyLuxury.cyan.withValues(alpha: .3),
                              width: selected.contains(i) ? 2 : 1,
                            ),
                          ),
                          child: PlayingCard(
                            label: label(widget.cards[i]), width: 39, height: 56),
                        ),
                      ),
                    ),
                ]),
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  key: const ValueKey('r36-add-meld-group'),
                  onPressed: selected.length < 3 || selected.length > 13 || groups.length >= 8
                      ? null : () => setState(() {
                          groups.add(selected.toList()..sort());
                          selected.clear();
                        }),
                  icon: const Icon(Icons.add_box_rounded),
                  label: Text(text('ضع ${selected.length} أوراق في مجموعة', 'Save ${selected.length} as a group'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 10),
                if (groups.isEmpty) Text(
                  text('ستظهر مجموعاتك هنا بألوان مختلفة.', 'Your prepared groups will appear here with different colors.'),
                  style: const TextStyle(color: Colors.white70)),
                for (var i=0; i<groups.length; i++) Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Container(
                    key: ValueKey('r44-meld-group-$i'),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: groupColors[i % groupColors.length].withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: groupColors[i % groupColors.length], width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(children: <Widget>[
                          Expanded(child: Text(
                            text('المجموعة ${i + 1} • ${groups[i].length} أوراق',
                                 'Group ${i + 1} • ${groups[i].length} cards'),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14))),
                          IconButton(
                            tooltip: text('ارفع المجموعة','Move up'),
                            onPressed: i == 0 ? null : () => moveGroup(i, -1),
                            icon: const Icon(Icons.arrow_upward_rounded, size: 20)),
                          IconButton(
                            tooltip: text('أنزل المجموعة','Move down'),
                            onPressed: i == groups.length - 1 ? null : () => moveGroup(i, 1),
                            icon: const Icon(Icons.arrow_downward_rounded, size: 20)),
                          IconButton(
                            tooltip: text('إرجاع الأوراق لليد','Return cards to hand'),
                            onPressed: () => setState(() => groups.removeAt(i)),
                            icon: const Icon(Icons.undo_rounded, size: 22)),
                        ]),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Wrap(spacing: 5, runSpacing: 5, children: [
                            for (final index in groups[i])
                              PlayingCard(label: label(widget.cards[index]),
                                width: 36, height: 51),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text(text('إلغاء','Cancel'))),
        FilledButton.icon(
          key: const ValueKey('r36-submit-meld-groups'),
          onPressed: groups.isEmpty ? null : () => Navigator.pop(context, <List<String>>[
            for (final group in groups) <String>[
              for (final index in group) widget.cards[index],
            ],
          ]),
          icon: const Icon(Icons.check_circle_rounded),
          label: Text(text('نزّل ${groups.length} مجموعات','Meld ${groups.length} groups')),
        ),
      ],
    );
  }
}
