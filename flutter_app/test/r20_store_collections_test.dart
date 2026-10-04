import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  for (final locale in ['ar', 'en']) {
    testWidgets('R20 collections browse real inventory without a purchase $locale', (tester) async {
      SharedPreferences.setMockInitialValues({});
      AppSounds.enabled = false;
      final controller = AppController()..localeCode = locale;
      addTearDown(controller.dispose);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1;
      final coins = controller.coins;
      final inventory = Set<String>.from(controller.owned);
      for (final size in [const Size(320, 640), const Size(844, 390), const Size(1280, 800)]) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(MaterialApp(
          locale: Locale(locale), supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: r101Theme('midnight_cyan', '#25e4df', localeCode: locale),
          home: Scaffold(body: SingleChildScrollView(child: Padding(
            padding: const EdgeInsets.all(12), child: R20StoreCollections(controller: controller),
          ))),
        ));
        await tester.pump();
        for (final category in ['pasha', 'themes', 'cards', 'profile_colors', 'emoji', 'covers']) {
          expect(find.byKey(ValueKey('r20-collection-$category')), findsOneWidget);
        }
        await tester.ensureVisible(find.byKey(const ValueKey('r20-collection-emoji')));
        await tester.tap(find.byKey(const ValueKey('r20-collection-emoji')));
        await tester.pumpAndSettle();
        expect(find.text(locale == 'ar' ? 'اختر عنصرًا للمعاينة. الشراء أو التفعيل يتم بعد التأكيد.' : 'Choose an item to preview. Purchase or activation requires confirmation.'), findsOneWidget);
        expect(find.byKey(const ValueKey('r20-collection-item-emoji_fun')), findsOneWidget);
        expect(controller.coins, coins);
        expect(controller.owned, inventory);
        expect(tester.takeException(), isNull);
        tester.state<NavigatorState>(find.byType(Navigator)).pop();
        await tester.pumpAndSettle();
      }
    });
  }
  test('R20 collection filtering respects hidden products', () {
    final controller = AppController();
    final shelf = R20StoreCollections(controller: controller);
    final original = shelf.items('emoji');
    expect(original, isNotEmpty);
    controller.hiddenStoreProducts.add(original.first.id);
    expect(shelf.items('emoji').any((p) => p.id == original.first.id), isFalse);
    controller.dispose();
  });
}
