import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  test('R34 all premium action colors maintain WCAG AA contrast', () {
    final surfaces = <Color>[
      const Color(0xFF24C8FF),
      const Color(0xFF0B8CFF),
      const Color(0xFFFFC84A),
      const Color(0xFF329EDB),
      const Color(0xFF0284C7),
      const Color(0xFF211709),
      const Color(0xFF0B0A0C),
    ];
    for (final fill in surfaces) {
      final ink = r101ReadableInk(fill);
      final a = fill.computeLuminance() + .05;
      final b = ink.computeLuminance() + .05;
      final ratio = a > b ? a / b : b / a;
      expect(ratio, greaterThanOrEqualTo(4.5), reason: 'inaccessible action background: $fill');
    }
    final theme = r101Theme('sky', '#24C8FF');
    final button = theme.filledButtonTheme.style!;
    final fill = button.backgroundColor!.resolve(<WidgetState>{})!;
    final ink = button.foregroundColor!.resolve(<WidgetState>{})!;
    expect(fill, const Color(0xFF24C8FF));
    expect(ink, r101ReadableInk(fill));
  });

  testWidgets('premium original game emblems fit compact and large cards', (tester) async {
    for (final id in <String>['tarneeb', 'trix', 'hand', 'banakil', 'baloot',
      'domino', 'backgammon', 'chess', 'tarneeb_400']) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(
        child: SizedBox(width: 60, height: 48, child: R34GameEmblem(gameId: id, compact: true)),
      ))));
      expect(tester.takeException(), isNull, reason: 'compact: $id');
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(
        child: SizedBox(width: 180, height: 152, child: R34GameEmblem(gameId: id)),
      ))));
      expect(tester.takeException(), isNull, reason: 'large: $id');
    }
  });
}
