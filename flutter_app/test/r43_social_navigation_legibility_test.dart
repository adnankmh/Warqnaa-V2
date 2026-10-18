import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('R43 social navigation copy keeps an 11px type floor', () {
    final source =
        File('lib/r6_1_world_class.dart').readAsStringSync();
    expect(
      RegExp(
        r'fontSize:\\s*(?:[0-9](?:\\.[0-9]+)?|10(?:\\.[0-9]+)?)(?![0-9])',
      ).hasMatch(source),
      isFalse,
      reason: 'Live R6.1 social and navigation surfaces must remain readable',
    );
  });

  for (final locale in <String>['ar', 'en']) {
    testWidgets(
      'R43 bottom navigation remains readable and interactive at 320px in $locale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final controller = AppController()..localeCode = locale;
        addTearDown(() {
          controller.connectivityTimerV173?.cancel();
          controller.dispose();
        });
        var selected = -1;

        await tester.pumpWidget(MaterialApp(
          theme: r101Theme('emerald', '#ffcf67'),
          home: Directionality(
            textDirection:
                locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              bottomNavigationBar: R61BottomNavigation(
                controller: controller,
                selectedIndex: 2,
                onSelected: (value) => selected = value,
              ),
            ),
          ),
        ));
        await tester.pump();

        final storeLabel = locale == 'ar' ? 'المتجر' : 'Store';
        final label = tester.widget<Text>(find.text(storeLabel));
        expect(label.style?.fontSize, 11);
        await tester.tap(find.text(storeLabel));
        await tester.pump();
        expect(selected, 0);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'R43 social hub remains readable at 320px in $locale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final controller = AppController()..localeCode = locale;
        addTearDown(() {
          controller.connectivityTimerV173?.cancel();
          controller.dispose();
        });

        await tester.pumpWidget(MaterialApp(
          theme: r101Theme('emerald', '#ffcf67'),
          home: Directionality(
            textDirection:
                locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(body: R61SocialHubPage(controller: controller)),
          ),
        ));
        await tester.pump();

        final description = tester.widget<Text>(find.text(
          locale == 'ar'
              ? 'أصدقاء ورسائل وأندية وعالم حي من مركز واحد.'
              : 'Friends, messages, clubs and a live world from one hub.',
        ));
        expect(description.style?.fontSize, 11);
        final friends = tester.widget<Text>(
          find.text(locale == 'ar' ? 'الأصدقاء' : 'Friends'),
        );
        expect(friends.style?.fontSize, 11);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
