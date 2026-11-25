import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in <String>['ar', 'en']) {
    for (final entry in <({String category, String arabic, String english})>[
      (category: 'cards', arabic: 'خلفيات أوراق اللعب', english: 'Card-back collection'),
      (category: 'boost', arabic: 'معزز النقاط', english: 'XP Boosters'),
      (category: 'emoji', arabic: 'الإيموجي وردود الفعل', english: 'Emojis and reactions'),
    ]) {
      testWidgets('R43 uses native interactive catalogue for ${entry.category} in $locale',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final controller = AppController()..localeCode = locale;
          addTearDown(controller.dispose);
          await tester.pumpWidget(MaterialApp(
            locale: Locale(locale),
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: R43ReferenceCatalogPage(controller: controller, category: entry.category),
          ));
          await tester.pump();

          final expected = locale == 'ar' ? entry.arabic : entry.english;
          expect(find.text(expected), findsWidgets);
          expect(find.byKey(const ValueKey('r286-collection-scroll')), findsOneWidget);
          expect(find.byKey(const ValueKey('r286-collection-count')), findsOneWidget);
          expect(find.text(locale == 'ar' ? 'المتجر الكامل' : 'Full store'), findsOneWidget);
          final search = find.byKey(const ValueKey('r286-collection-search'));
          await tester.scrollUntilVisible(search, 120,
            scrollable: find.descendant(
              of: find.byKey(const ValueKey('r286-collection-scroll')),
              matching: find.byType(Scrollable),
            ).first);
          expect(search, findsOneWidget);
          await tester.enterText(search, 'r43-no-matching-product-xyz');
          await tester.pump();
          await tester.testTextInput.receiveAction(TextInputAction.search);
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pump();
          final empty = find.byKey(const ValueKey('r286-collection-empty'));
          await tester.scrollUntilVisible(empty, 120,
            scrollable: find.descendant(
              of: find.byKey(const ValueKey('r286-collection-scroll')),
              matching: find.byType(Scrollable),
            ).first);
          expect(empty, findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
