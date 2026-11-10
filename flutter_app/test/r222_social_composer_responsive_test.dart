import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/r9_design_system.dart';

void main() {
  for (final locale in const ['ar', 'en']) {
    for (final light in const [true, false]) {
      for (final width in const [320.0, 390.0]) {
        testWidgets('R222 social composer portrait $locale light=$light width=$width',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final isArabic = locale == 'ar';
          final theme = R9Design.theme(
            light: light,
            accent: R9Design.azure,
            arabic: isArabic,
          );
          var type = 'status';
          var audience = 'friends';

          await tester.pumpWidget(MaterialApp(
            locale: Locale(locale),
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: theme,
            home: Directionality(
              textDirection:
                  isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 520,
                      child: StatefulBuilder(
                        builder: (context, setState) =>
                            R222SocialComposerOptions(
                          isArabic: isArabic,
                          type: type,
                          audience: audience,
                          onTypeChanged: (value) =>
                              setState(() => type = value),
                          onAudienceChanged: (value) =>
                              setState(() => audience = value),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ));
          await tester.pump(const Duration(milliseconds: 300));

          final typeFinder =
              find.byKey(const ValueKey('r222-composer-type'));
          final audienceFinder =
              find.byKey(const ValueKey('r222-composer-audience'));
          expect(typeFinder, findsOneWidget);
          expect(audienceFinder, findsOneWidget);
          expect(find.text(isArabic ? 'نوع المنشور' : 'Post type'),
              findsOneWidget);
          expect(find.text(isArabic ? 'الجمهور' : 'Audience'),
              findsOneWidget);
          expect(
            Directionality.of(tester.element(typeFinder)),
            isArabic ? TextDirection.rtl : TextDirection.ltr,
          );
          expect(tester.getTopLeft(audienceFinder).dy,
              greaterThan(tester.getTopLeft(typeFinder).dy));
          expect(tester.getSize(typeFinder).width, greaterThan(200));
          final icons =
              tester.widgetList<Icon>(find.byIcon(Icons.expand_more_rounded));
          expect(icons.length, 2);
          expect(
            icons.every((icon) => icon.color == theme.colorScheme.primary),
            isTrue,
          );

          await tester.tap(audienceFinder);
          await tester.pumpAndSettle();
          await tester.tap(find.text(isArabic ? 'خاص' : 'Private').last);
          await tester.pumpAndSettle();
          expect(audience, 'private');
          expect(type, 'status');
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('R222 social composer uses side-by-side fields on wide layouts',
      (tester) async {
    tester.view.physicalSize = const Size(700, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: R9Design.theme(light: true, accent: R9Design.azure),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 520,
            child: R222SocialComposerOptions(
              isArabic: false,
              type: 'status',
              audience: 'friends',
              onTypeChanged: (_) {},
              onAudienceChanged: (_) {},
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    final type = find.byKey(const ValueKey('r222-composer-type'));
    final audience = find.byKey(const ValueKey('r222-composer-audience'));
    expect(tester.getTopLeft(type).dy, tester.getTopLeft(audience).dy);
    expect(tester.takeException(), isNull);
  });
}
