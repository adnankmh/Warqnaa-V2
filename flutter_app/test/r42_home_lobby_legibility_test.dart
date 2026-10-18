import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('R42 home lobby copy keeps an 11px type floor', () {
    final source = File('lib/r8_play_experience.dart').readAsStringSync();
    expect(
      RegExp(r'fontSize:\\s*(?:[0-9](?:\\.[0-9]+)?|10(?:\\.[0-9]+)?)(?![0-9])')
          .hasMatch(source),
      isFalse,
      reason: 'The live R8 home lobby must not reintroduce sub-11px copy',
    );
  });

  for (final locale in <String>['ar', 'en']) {
    testWidgets('R42 game tile remains readable on a 320px $locale phone',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(
        theme: r101Theme('emerald', '#ffcf67'),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 148,
              height: 190,
              child: R8GameTile(
                game: gamesCatalog.first,
                locale: locale,
                onTap: () {},
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      final prompt = tester.widget<Text>(
        find.text(locale == 'ar' ? 'ابدأ اللعب الآن' : 'Play now'),
      );
      expect(prompt.style?.fontSize, 11);
      expect(prompt.style?.fontWeight, FontWeight.w700);
      expect(tester.takeException(), isNull);
    });
  }
}
