import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in ['ar', 'en']) {
    for (final width in [320.0, 390.0]) {
      for (final brightness in Brightness.values) {
        testWidgets('R251 hints $locale $width $brightness', (tester) async {
          await tester.binding.setSurfaceSize(Size(width, 700));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final scheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0), brightness: brightness);
          final direction = locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
          await tester.pumpWidget(MaterialApp(
            theme: ThemeData(colorScheme: scheme),
            home: Directionality(textDirection: direction, child: Scaffold(
              body: Column(children: [
                for (final key in ['exportHint', 'sessionsHint', 'reportHint'])
                  ListTile(title: Text(key), subtitle: ProductionActionHintV251(
                    locale: locale, hintKey: key)),
              ]),
            )),
          ));
          await tester.pumpAndSettle();
          final expected = locale == 'ar' ? [
            'تصدير بيانات الحساب والملف الشخصي والمقتنيات والمحفظة والرسائل الأخيرة بصيغة JSON',
            'مراجعة جلسات الاتصال النشطة وإغلاقها',
            'الإبلاغ عن الإساءة أو الغش أو الرسائل المزعجة أو المحتوى غير المناسب',
          ] : [
            'JSON export of account, profile, inventory, wallet and recent messages',
            'Review and close active API sessions',
            'Report abuse, cheating, spam or inappropriate content',
          ];
          final keys = ['exportHint', 'sessionsHint', 'reportHint'];
          for (var i = 0; i < keys.length; i++) {
            final finder = find.byKey(ValueKey('r251-${keys[i]}'));
            expect(finder, findsOneWidget);
            final widget = tester.widget<Text>(finder);
            expect(widget.data, expected[i]);
            expect(widget.softWrap, isTrue);
            expect(widget.style?.color, scheme.onSurfaceVariant);
            expect(Directionality.of(tester.element(finder)), direction);
            expect(tester.getSize(finder).width, lessThanOrEqualTo(width));
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
