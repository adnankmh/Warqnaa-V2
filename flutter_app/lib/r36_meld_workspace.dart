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
  String label(String card) {
    if (card.startsWith('JOKER')) return '🃏';
    final parts = card.split('_');
    return '${parts.first}${const {'clubs':'♣','diamonds':'♦','spades':'♠','hearts':'♥','C':'♣','D':'♦','S':'♠','H':'♥'}[parts.length > 1 ? parts[1] : ''] ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.cards.skip(math.max(0, widget.cards.length - count)).toList();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360, maxHeight: 360),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(text('عاين الأوراق قبل السحب؛ الورقة الأخيرة هي المكشوفة.',
          'Preview before drawing; the last card is the top discard.')),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          key: const ValueKey('r40-discard-count'),
          initialValue: count,
          decoration: InputDecoration(labelText: text('عدد أوراق النار', 'Discard count')),
          items: [for (var value=2; value<=widget.maxCount; value++)
            DropdownMenuItem(value:value,child:Text('$value'))],
          onChanged:(value){if(value!=null)setState(()=>count=value);},
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty) Text(text('معاينة النار غير متاحة في هذه الحالة.', 'The discard preview is unavailable in this snapshot.')),
        Directionality(textDirection:TextDirection.ltr,child:Wrap(spacing:6,runSpacing:8,children:[
          for(var i=0;i<visible.length;i++) Semantics(
            key:ValueKey('r40-discard-preview-$i'),label:label(visible[i]),
            child:PlayingCard(label:label(visible[i]),width:42,height:60)),
        ])),
        const SizedBox(height: 12),
        FilledButton.icon(
          key:const ValueKey('r40-confirm-discard-stack'),
          onPressed:()=>Navigator.pop(context,count),
          icon:const Icon(Icons.layers_rounded),
          label:Text(text('اسحب $count أوراق', 'Take $count cards')),
        ),
      ])),
    );
  }
}

class _R36MeldWorkspaceState extends State<R36MeldWorkspace> {
  final selected = <int>{};
  final groups = <List<int>>[];
  String text(String ar, String en) => widget.ar ? ar : en;
  String label(String card) {
    if (card.startsWith('JOKER')) return '🃏';
    final parts = card.split('_');
    final suit = parts.length > 1 ? parts[1] : '';
    return '${parts.first}${const {'clubs':'♣','diamonds':'♦','spades':'♠','hearts':'♥','C':'♣','D':'♦','S':'♠','H':'♥'}[suit] ?? suit}';
  }

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
