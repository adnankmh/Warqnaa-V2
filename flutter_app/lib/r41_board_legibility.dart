part of 'main.dart';

class R41BackgammonBoard extends StatelessWidget {
  const R41BackgammonBoard({super.key, required this.points, required this.ar});

  final Map<String, dynamic> points;
  final bool ar;

  String text(String arText, String enText) => ar ? arText : enText;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final range in [
            List.generate(12, (index) => 24 - index),
            List.generate(12, (index) => index + 1),
          ])
            Expanded(
              child: Row(
                children: range.map((number) {
                  final raw = points[number.toString()];
                  final point = raw is Map
                      ? Map<String, dynamic>.from(raw)
                      : <String, dynamic>{};
                  final count =
                      int.tryParse(point['count']?.toString() ?? '') ?? 0;
                  final owner = point['owner']?.toString() ?? '';
                  final even = number.isEven;
                  final pointInk = even
                      ? palette.onPrimaryContainer
                      : palette.onSecondaryContainer;
                  return Expanded(
                    child: Container(
                      key: ValueKey('r217-backgammon-point-$number'),
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: even
                            ? palette.primaryContainer
                            : palette.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: palette.outlineVariant),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Semantics(
                            label: text('النقطة $number', 'Point $number'),
                            child: Text(
                              '$number',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: pointInk,
                              ),
                            ),
                          ),
                          if (count > 0) ...[
                            Semantics(
                              label: owner.startsWith('user:')
                                  ? text('أحجار لاعب', 'Player checkers')
                                  : owner.startsWith('bot:')
                                      ? text('أحجار روبوت', 'Bot checkers')
                                      : text('أحجار', 'Checkers'),
                              child: Text(
                                owner.startsWith('user:') ? '●' : '○',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: pointInk,
                                ),
                              ),
                            ),
                            Semantics(
                              label: text('$count أحجار', '$count checkers'),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: pointInk,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class R41JackarooBoard extends StatelessWidget {
  const R41JackarooBoard({
    super.key,
    required this.pieces,
    required this.ar,
  });

  final Map<String, dynamic> pieces;
  final bool ar;

  String text(String arText, String enText) => ar ? arText : enText;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: PremiumPanel(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: pieces.entries.map((entry) {
              final values =
                  entry.value is List ? entry.value as List : const [];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 86,
                      child: Text(
                        entry.key
                            .toString()
                            .replaceAll('user:', '')
                            .replaceAll('bot:', ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: values.map((value) {
                          final progress =
                              int.tryParse(value.toString()) ?? -1;
                          final semantic = progress < 0
                              ? text('حجر في البيت', 'Piece at home')
                              : progress >= 56
                                  ? text('حجر في الأمان', 'Piece safe')
                                  : text(
                                      'حجر عند $progress',
                                      'Piece at $progress',
                                    );
                          final visible = progress < 0
                              ? text('بيت', 'Home')
                              : progress >= 56
                                  ? '✓'
                                  : '$progress';
                          return Expanded(
                            child: Container(
                              height: 28,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: progress >= 56
                                    ? Colors.green.withValues(alpha: .45)
                                    : progress < 0
                                        ? Colors.white.withValues(alpha: .06)
                                        : Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: .16),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Semantics(
                                label: semantic,
                                child: Text(
                                  visible,
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
