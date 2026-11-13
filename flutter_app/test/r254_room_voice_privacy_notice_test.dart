import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in ['ar', 'en']) {
    for (final width in [320.0, 390.0]) {
      for (final brightness in Brightness.values) {
        testWidgets('R254 voice privacy $locale $width $brightness', (tester) async {
          await tester.binding.setSurfaceSize(Size(width, 700));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final handle = tester.ensureSemantics();
          try {
            final scheme = ColorScheme.fromSeed(
              seedColor: const Color(0xFF1565C0), brightness: brightness);
            final direction = locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
            var enabled = false;
            await tester.pumpWidget(MaterialApp(
              theme: ThemeData(colorScheme: scheme),
              home: Directionality(textDirection: direction, child: Scaffold(
                body: StatefulBuilder(builder: (context, setState) => Column(
                  children: [
                    Switch(value: enabled, onChanged: (value) => setState(() => enabled = value)),
                    if (enabled) R254RoomVoicePrivacyNotice(locale: locale),
                  ],
                )),
              )),
            ));
            final notice = find.byKey(const ValueKey('r77-voice-privacy-notice'));
            final announcement = find.byKey(const ValueKey('r254-room-voice-privacy-announcement'));
            expect(notice, findsNothing);
            await tester.tap(find.byType(Switch));
            await tester.pumpAndSettle();
            expect(notice, findsOneWidget);
            final semantics = tester.widget<Semantics>(announcement);
            final hint = L.t(locale, 'voicePrivacyHint');
            expect(semantics.properties.label, hint);
            expect(semantics.properties.liveRegion, isTrue);
            expect(semantics.excludeSemantics, isTrue);
            final label = find.descendant(of: notice, matching: find.text(hint));
            expect(label, findsOneWidget);
            expect(Directionality.of(tester.element(label)), direction);
            expect(tester.widget<Text>(label).style?.color,
                R69PlaySurfaceColors.of(tester.element(label)).onSurface);
            expect(tester.getSize(notice).width, lessThanOrEqualTo(width));
            expect(tester.takeException(), isNull);
            await tester.tap(find.byType(Switch));
            await tester.pumpAndSettle();
            expect(announcement, findsNothing);
          } finally {
            handle.dispose();
          }
        });
      }
    }
  }
}
