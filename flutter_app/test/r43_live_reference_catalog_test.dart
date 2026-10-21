import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
            home: R43ReferenceCatalogPage(controller: controller, category: entry.category),
          ));
          await tester.pump();

          final expected = locale == 'ar' ? entry.arabic : entry.english;
          expect(find.text(expected), findsWidgets);
          expect(find.byType(R35ReferencePanel), findsOneWidget);
          expect(find.text(locale == 'ar' ? 'المتجر الكامل' : 'Full store'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
