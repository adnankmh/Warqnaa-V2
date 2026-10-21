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
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 420,
        maxHeight: math.min(470, MediaQuery.sizeOf(context).height * .64)),
      child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(text('اضغط على الورقة المطلوبة من النار. ستأخذها مع جميع الأوراق التي فوقها.',
                    'Tap a discard. You will take it and every newer card above it.'),
            style: const TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w800)),
          const SizedBox(height: 9),
          if (all.isNotEmpty) SizedBox(
            height: 87,
            child: ListView.separated(
              key: const ValueKey('r44-discard-tap-strip'),
              scrollDirection: Axis.horizontal,
              itemCount: all.length - beginning,
              separatorBuilder: (_, __) => const SizedBox(width: 5),
              itemBuilder: (context, i) {
                final index = beginning + i;
                final needed = all.length - index;
                final included = needed <= count;
                return Semantics(
                  button: true,
                  selected: included,
                  label: '${label(all[index])} - ${text('اسحب', 'Take')} $needed',
                  child: InkWell(
                    key: ValueKey('r44-discard-select-$needed'),
                    onTap: () => setState(() =>
                      count = math.max(2, math.min(widget.maxCount, needed))),
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: included ? B307SkyLuxury.sky.withValues(alpha: .18) : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: included ? B307SkyLuxury.goldSoft : Colors.white24,
                          width: included ? 2 : 1,
                        ),
                      ),
                      child: PlayingCard(label: label(all[index]), width: 42, height: 65),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            key: const ValueKey('r40-discard-count'),
            initialValue: count,
            decoration: InputDecoration(labelText: text('عدد أوراق النار', 'Discard count')),
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
  String text(String ar, String en) => widget.ar ? ar : en;
  String label(String card) => r52CardLabel(card);

  @override
  Widget build(BuildContext context) {
    final used = groups.expand((group)=>group).toSet();
    return AlertDialog(
      title: Text(text('ترتيب وتجميع الأوراق', 'Arrange & group cards')),
      content: SizedBox(width: 560, child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(text('حدد أوراق كل مجموعة ثم أضفها. اعتمد جميع المجموعات معًا لافتتاح اليد.', 'Select each meld, add it, then submit all groups together to open your hand.')),
          const SizedBox(height: 12),
          Wrap(spacing: 6, runSpacing: 8, children: [
            for (var i=0;i<widget.cards.length;i++) if (!used.contains(i))
              Semantics(selected:selected.contains(i),button:true,label:label(widget.cards[i]),child:InkWell(
                key: ValueKey('r36-meld-card-$i'),
                onTap: ()=>setState(()=>selected.contains(i) ? selected.remove(i) : selected.add(i)),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(borderRadius:BorderRadius.circular(9),border:Border.all(
                    color:selected.contains(i)?B307SkyLuxury.goldSoft:Colors.transparent,width:2)),
                  child: PlayingCard(label:label(widget.cards[i]),width:42,height:60),
                ),
              )),
          ]),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            key: const ValueKey('r36-add-meld-group'),
            onPressed: selected.length<3 || groups.length>=8 ? null : ()=>setState((){
              groups.add(selected.toList()..sort()); selected.clear();
            }),
            icon: const Icon(Icons.add_rounded),label:Text(text('أضف مجموعة (${selected.length})', 'Add group (${selected.length})')),
          ),
          for (var i=0;i<groups.length;i++) ListTile(
            contentPadding: EdgeInsets.zero,
            title:Text(groups[i].map((index)=>label(widget.cards[index])).join('  '),textDirection:TextDirection.ltr),
            trailing:IconButton(tooltip:text('إرجاع الأوراق لليد', 'Return cards to hand'),
              onPressed:()=>setState(()=>groups.removeAt(i)),icon:const Icon(Icons.undo_rounded)),
          ),
        ],
      ))),
      actions: [
        TextButton(onPressed:()=>Navigator.pop(context),child:Text(text('إلغاء','Cancel'))),
        FilledButton(
          key:const ValueKey('r36-submit-meld-groups'),
          onPressed:groups.isEmpty?null:()=>Navigator.pop(context,[
            for(final group in groups) [for(final index in group) widget.cards[index]],
          ]),
          child:Text(text('نزّل ${groups.length} مجموعات','Meld ${groups.length} groups')),
        ),
      ],
    );
  }
}
