import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

Widget _host(Widget child, String locale) => MaterialApp(
      locale: Locale(locale),
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: r101Theme('emerald', '#ffcf67'),
      home: Scaffold(
        body: SafeArea(
          child: Center(child: SizedBox(height: 420, child: child)),
        ),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('R41 board labels retain the 11px floor and semantic state', () {
    final source = File('lib/r41_board_legibility.dart').readAsStringSync();
    for (final contract in <String>[
      "text('النقطة \$number', 'Point \$number')",
      "text('\$count أحجار', '\$count checkers')",
      "text('حجر في البيت', 'Piece at home')",
      "text('حجر في الأمان', 'Piece safe')",
      "'حجر عند \$progress'",
      "'Piece at \$progress'",
    ]) {
      expect(source, contains(contract));
    }
    expect(
      RegExp(r'fontSize:\s*(?:[0-9](?:\.[0-9]+)?|10(?:\.[0-9]+)?)(?![0-9])')
          .hasMatch(source),
      isFalse,
      reason: 'Backgammon and Jackaroo labels must remain at least 11px',
    );
  });

  for (final locale in <String>['ar', 'en']) {
    testWidgets('R41 Backgammon board renders readably on a 320px $locale phone',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(
        R41BackgammonBoard(
          ar: locale == 'ar',
          points: const <String, dynamic>{
            '24': <String, dynamic>{'count': 2, 'owner': 'user:1'},
            '13': <String, dynamic>{'count': 5, 'owner': 'bot:1'},
            '8': <String, dynamic>{'count': 3, 'owner': 'user:1'},
            '6': <String, dynamic>{'count': 5, 'owner': 'bot:1'},
          },
        ),
        locale,
      ));
      await tester.pump();

      final point = tester.widget<Text>(find.text('24'));
      expect(point.style?.fontSize, 11);
      expect(point.style?.fontWeight, FontWeight.w700);
      expect(find.bySemanticsLabel(locale == 'ar' ? 'النقطة 24' : 'Point 24'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('R41 Jackaroo board renders readably on a 320px $locale phone',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(
        R41JackarooBoard(
          ar: locale == 'ar',
          pieces: const <String, dynamic>{
            'user:Adnan': <int>[-1, 12, 37, 56],
            'bot:Samer': <int>[-1, 9, 41, 57],
          },
        ),
        locale,
      ));
      await tester.pump();

      final home = tester.widget<Text>(
        find.text(locale == 'ar' ? 'بيت' : 'Home').first,
      );
      expect(home.style?.fontSize, 11);
      expect(find.bySemanticsLabel(
              locale == 'ar' ? 'حجر في البيت' : 'Piece at home'),
          findsWidgets);
      expect(find.bySemanticsLabel(
              locale == 'ar' ? 'حجر في الأمان' : 'Piece safe'),
          findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
