import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

Widget gameArtApp(String locale, Widget child) => MaterialApp(
      locale: Locale(locale),
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        backgroundColor: const Color(0xff050b12),
        body: Center(child: child),
      ),
    );

void main() {
  for (final locale in <String>['ar', 'en']) {
    for (final size in <Size>[const Size(320, 640), const Size(844, 390)]) {
      testWidgets('R19 Warqnaa table $locale ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          gameArtApp(
            locale,
            SizedBox(
              width: size.width - 24,
              height: size.height - 40,
              child: const WarqnaaTableSurface(trump: 'S', phase: 'playing'),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 240));
        expect(find.byKey(const ValueKey('r19-warqnaa-table-surface')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('R19 card ranks and back remain legible $locale', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        gameArtApp(
          locale,
          const Wrap(
            spacing: 10,
            children: <Widget>[
              PlayingCard(label: 'A♠', width: 46, height: 68),
              PlayingCard(label: 'Q♥', width: 46, height: 68),
              PlayingCard(label: '10♦', width: 46, height: 68),
              PlayingCard(label: '7♣', width: 28, height: 42),
              PremiumCardBack(cardBackId: v305CardBackId, width: 28, height: 42),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 180));
      expect(find.byKey(const ValueKey('r19-card-face-A♠')), findsOneWidget);
      expect(find.byKey(const ValueKey('r19-card-face-Q♥')), findsOneWidget);
      expect(find.byKey(const ValueKey('r19-card-face-10♦')), findsOneWidget);
      expect(find.byKey(const ValueKey('r19-card-face-7♣')), findsOneWidget);
      expect(find.byKey(const ValueKey('r19-warqnaa-card-back')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
