import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

Widget _host(Widget child, String locale) => MaterialApp(
      locale: Locale(locale),
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: r101Theme('emerald', '#ffcf67'),
      home: child,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppSounds.enabled = false;
  });

  test('R41 board labels retain the 11px floor and semantic state', () {
    final source = File('lib/main.dart').readAsStringSync();
    for (final contract in <String>[
      "Semantics(label: 'Point \$number'",
      "Semantics(label: '\$count checkers'",
      "_roomText('حجر في البيت', 'Piece at home')",
      "_roomText('حجر في الأمان', 'Piece safe')",
      "_roomText('حجر عند \$progress', 'Piece at \$progress')",
    ]) {
      expect(source, contains(contract));
    }
    final boardSource = source.substring(
      source.indexOf('Widget _backgammonBoard'),
      source.indexOf('Future<void> _reorderServerHand'),
    );
    expect(
      RegExp(r'fontSize:\s*(?:[0-9](?:\.[0-9]+)?|10(?:\.[0-9]+)?)(?![0-9])')
          .hasMatch(boardSource),
      isFalse,
      reason: 'Backgammon and Jackaroo labels must remain at least 11px',
    );
  });

  for (final locale in <String>['ar', 'en']) {
    for (final gameId in <String>['backgammon', 'jackaroo']) {
      testWidgets('R41 $gameId board renders on a 320px $locale phone',
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
        final game = <GameInfo>[
          ...gamesCatalog,
          ...customerGamesR101,
        ].firstWhere((item) => item.id == gameId);

        await tester.pumpWidget(
          _host(
            ServerEngineRoomPage(controller: controller, game: game),
            locale,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));

        expect(find.byType(ServerEngineRoomPage), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (gameId == 'backgammon') {
          final point = tester.widget<Text>(find.text('24').first);
          expect(point.style?.fontSize, 11);
          expect(point.style?.fontWeight, FontWeight.w700);
        }
      });
    }
  }
}
