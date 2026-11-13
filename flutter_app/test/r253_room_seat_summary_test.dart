import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in ['ar', 'en']) {
    for (final width in [320.0, 390.0]) {
      for (final brightness in Brightness.values) {
        testWidgets('R253 seat summary $locale $width $brightness', (tester) async {
          await tester.binding.setSurfaceSize(Size(width, 700));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final scheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0), brightness: brightness);
          final direction = locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
          var invited = 0;
          await tester.pumpWidget(MaterialApp(
            theme: ThemeData(colorScheme: scheme),
            home: Directionality(textDirection: direction, child: Scaffold(
              body: StatefulBuilder(builder: (context, setState) => Column(
                children: [
                  R253RoomSeatSummary(locale: locale, playerCount: 4, invited: invited, bots: 1),
                  TextButton(onPressed: () => setState(() => invited = 2), child: const Text('Invite')),
                ],
              )),
            )),
          ));
          final summary = find.byKey(const ValueKey('r253-room-seat-summary'));
          final label = find.descendant(of: summary, matching: find.byType(Text));
          expect(tester.widget<Text>(label).data, locale == 'ar'
              ? 'المحدد: 0 لاعب حقيقي • 1 بوت • 2 مقاعد مفتوحة'
              : '0 invited • 1 computer • 2 open seats');
          await tester.tap(find.text('Invite'));
          await tester.pumpAndSettle();
          expect(tester.widget<Text>(label).data, locale == 'ar'
              ? 'المحدد: 2 لاعب حقيقي • 1 بوت • 0 مقاعد مفتوحة'
              : '2 invited • 1 computer • 0 open seats');
          expect(tester.widget<Semantics>(summary).properties.liveRegion, isTrue);
          expect(tester.widget<Text>(label).style?.color, scheme.onSurfaceVariant);
          expect(Directionality.of(tester.element(label)), direction);
          expect(tester.getSize(label).width, lessThanOrEqualTo(width));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
