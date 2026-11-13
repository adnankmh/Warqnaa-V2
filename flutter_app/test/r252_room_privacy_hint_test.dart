import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in ['ar', 'en']) {
    for (final width in [320.0, 390.0]) {
      for (final brightness in Brightness.values) {
        testWidgets('R252 privacy $locale $width $brightness', (tester) async {
          await tester.binding.setSurfaceSize(Size(width, 700));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final scheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0), brightness: brightness);
          final direction = locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
          var privateRoom = false;
          await tester.pumpWidget(MaterialApp(
            theme: ThemeData(colorScheme: scheme),
            home: Directionality(textDirection: direction, child: Scaffold(
              body: StatefulBuilder(builder: (context, setState) => Column(
                children: [
                  R252RoomPrivacyHint(locale: locale, isPrivate: privateRoom),
                  TextButton(onPressed: () => setState(() => privateRoom = !privateRoom),
                    child: const Text('Toggle')),
                ],
              )),
            )),
          ));
          final hint = find.byKey(const ValueKey('r252-room-privacy-hint'));
          expect(tester.widget<Text>(hint).data, locale == 'ar'
              ? 'لا تحتاج الغرفة العامة إلى كلمة مرور.'
              : 'A public room does not require a password.');
          await tester.tap(find.text('Toggle'));
          await tester.pumpAndSettle();
          final text = tester.widget<Text>(hint);
          expect(text.data, locale == 'ar'
              ? 'يمكنك تعيين كلمة مرور للغرفة الخاصة.'
              : 'You can set a password for the private room.');
          expect(text.style?.color, scheme.onSurfaceVariant);
          expect(text.softWrap, isTrue);
          expect(Directionality.of(tester.element(hint)), direction);
          expect(tester.getSize(hint).width, lessThanOrEqualTo(width));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
