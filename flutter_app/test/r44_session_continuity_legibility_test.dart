import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('R44 continuity surfaces keep an 11px type floor', () {
    for (final path in <String>[
      'lib/v166_polish.dart',
      'lib/r9_local_studio.dart',
    ]) {
      final source = File(path).readAsStringSync();
      expect(
        RegExp(
          r'fontSize:\s*(?:[0-9](?:\.[0-9]+)?|10(?:\.[0-9]+)?)(?![0-9])',
        ).hasMatch(source),
        isFalse,
        reason: '$path must not reintroduce sub-11px session copy',
      );
    }
  });

  for (final locale in <String>['ar', 'en']) {
    testWidgets(
      'R44 active-game controls are readable and localized at 320px in $locale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final controller = AppController()
          ..localeCode = locale
          ..activeGame = 'tarneeb'
          ..activeRoomCode = 'R44-7K2';
        addTearDown(() {
          controller.connectivityTimerV173?.cancel();
          controller.dispose();
        });
        var resumed = false;

        await tester.pumpWidget(MaterialApp(
          theme: r101Theme('emerald', '#ffcf67'),
          locale: Locale(locale),
          home: Directionality(
            textDirection:
                locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              body: Column(children: [
                R9SessionBanner(controller: controller),
                ActiveGameBanner(
                  controller: controller,
                  onResume: () => resumed = true,
                ),
              ]),
            ),
          ),
        ));
        await tester.pump();

        final resume = tester.widget<Text>(
          find.text(locale == 'ar' ? 'العودة إلى اللعبة' : 'Return to game'),
        );
        expect(resume.style?.fontSize, 11);
        final sessionDetail = tester.widget<Text>(find.text(
          locale == 'ar'
              ? 'تدريب مع الكمبيوتر على هذا الجهاز'
              : 'Practice with the computer on this device',
        ));
        expect(sessionDetail.style?.fontSize, 11);
        expect(find.byTooltip(locale == 'ar' ? 'الخروج من اللعبة' : 'Exit game'), findsOneWidget);

        await tester.tap(find.text(
          locale == 'ar' ? 'العودة إلى اللعبة' : 'Return to game',
        ));
        expect(resumed, isTrue);

        await tester.tap(find.byTooltip(
          locale == 'ar' ? 'الخروج من اللعبة' : 'Exit game',
        ));
        await tester.pump();
        expect(
          find.text(locale == 'ar' ? 'مغادرة اللعبة' : 'Leave game'),
          findsOneWidget,
        );
        expect(find.text(locale == 'ar' ? 'إلغاء' : 'Cancel'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
