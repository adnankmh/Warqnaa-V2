import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final width in <double>[320, 390]) {
    for (final locale in <String>['ar', 'en']) {
      for (final brightness in <Brightness>[
        Brightness.light,
        Brightness.dark,
      ]) {
        testWidgets(
          'R239 home hero $width portrait $locale $brightness blue',
          (tester) async {
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            final theme = ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xff1565c0),
                brightness: brightness,
              ),
            );
            final label = locale == 'ar' ? 'الإشعارات' : 'Notifications';
            var notificationsOpened = 0;
            final semantics = tester.ensureSemantics();
            try {
              await tester.pumpWidget(MaterialApp(
                locale: Locale(locale),
                supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                theme: theme,
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: B304HomeHero(
                        isArabic: locale == 'ar',
                        onNotifications: () => notificationsOpened++,
                      ),
                    ),
                  ),
                ),
              ));
              await tester.pump();

              final action =
                  find.byKey(const ValueKey('r239-home-notifications'));
              expect(action, findsOneWidget);
              expect(find.byTooltip(label), findsOneWidget);
              expect(
                Directionality.of(tester.element(action)),
                locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              );
              final button = tester.widget<IconButton>(action);
              expect(
                button.style?.backgroundColor?.resolve(<WidgetState>{}),
                theme.colorScheme.primaryContainer,
              );
              expect(
                button.style?.foregroundColor?.resolve(<WidgetState>{}),
                theme.colorScheme.onPrimaryContainer,
              );
              expect(find.bySemanticsLabel(label), findsOneWidget);
              expect(find.text('Warqnaa • VERTICAL LEGEND'), findsOneWidget);
              expect(tester.takeException(), isNull);

              await tester.tap(action);
              await tester.pump();
              expect(notificationsOpened, 1);
              expect(tester.takeException(), isNull);
              await tester.pumpWidget(const SizedBox.shrink());
            } finally {
              semantics.dispose();
            }
          },
        );
      }
    }
  }
}
