import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R238 pack inventory is localized, accessible and portrait-safe '
      'in both Warqnaa blue themes', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppSounds.enabled = false;
    final semantics = tester.ensureSemantics();
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    final controller = AppController()
      ..dailyPackHistoryV176.addAll(<Map<String, dynamic>>[
        <String, dynamic>{
          'label_ar': 'جائزة دائمة',
          'label_en': 'Permanent gift',
          'icon': '🎨',
        },
        <String, dynamic>{
          'label_ar': 'جائزة منتهية',
          'label_en': 'Expired gift',
          'icon': '🎁',
          'expires_at': '2020-01-01T00:00:00Z',
        },
      ]);
    addTearDown(() {
      controller.connectivityTimerV173?.cancel();
      controller.dispose();
    });

    var opened = 0;
    for (final width in <double>[320, 390]) {
      for (final ar in <bool>[true, false]) {
        for (final brightness in Brightness.values) {
          tester.view.physicalSize = Size(width, 844);
          controller.localeCode = ar ? 'ar' : 'en';
          final direction = ar ? TextDirection.rtl : TextDirection.ltr;
          final theme = ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff0b8cff),
              brightness: brightness,
            ),
          );
          await tester.pumpWidget(MaterialApp(
            key: ValueKey('r238-$width-$ar-$brightness'),
            theme: theme,
            builder: (context, child) => Directionality(
              textDirection: direction,
              child: child!,
            ),
            home: Scaffold(body: PackInventoryStripV176(
              controller: controller,
              onOpenInventory: () => opened++,
            )),
          ));
          await tester.pumpAndSettle();

          expect(find.text(ar ? 'مقتنيات الحزم' : 'Pack inventory'), findsOneWidget);
          expect(find.text(ar ? 'عرض الكل' : 'View all'), findsOneWidget);
          expect(find.text(ar ? 'جائزة دائمة' : 'Permanent gift'), findsOneWidget);
          expect(find.text(ar ? 'انتهت الصلاحية' : 'Expired'), findsOneWidget);
          expect(
            find.bySemanticsLabel(ar
                ? 'جائزة دائمة, أضيفت مباشرة إلى الرصيد'
                : 'Permanent gift, Added to balance'),
            findsOneWidget,
          );
          final reward = find.byKey(const ValueKey('r130-pack-reward-0'));
          expect(reward, findsOneWidget);
          expect(Directionality.of(tester.element(reward)), direction);
          final decoration = tester.widget<Container>(reward).decoration!
              as BoxDecoration;
          expect(decoration.color,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: .58));
          expect((decoration.border! as Border).top.color,
              theme.colorScheme.tertiary.withValues(alpha: .45));
          expect(tester.takeException(), isNull);

          await tester.tap(find.byKey(const ValueKey('r238-pack-open-all')));
          expect(opened, greaterThan(0));
          expect(tester.takeException(), isNull);
        }
      }
    }
    expect(opened, 8);
    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
