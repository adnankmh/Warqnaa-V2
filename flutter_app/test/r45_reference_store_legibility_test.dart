import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in <String>['ar', 'en']) {
    testWidgets(
      'R45 reference store keeps full-width readable items at 320px in $locale',
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
          home: Directionality(
            textDirection:
                locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              body: SingleChildScrollView(
                child: R35StoreTreasureStrip(controller: controller),
              ),
            ),
          ),
        ));
        await tester.pump();

        expect(
          find.byKey(const ValueKey('r45-store-treasure-scroll')),
          findsOneWidget,
        );
        final first = products.firstWhere(
          (product) => controller.isStoreProductVisible(product) &&
              <String>{'tables', 'cards', 'boost', 'pasha', 'covers'}
                  .contains(product.category),
        );
        expect(
          tester.getSize(find.byKey(ValueKey('r45-store-item-${first.id}'))).width,
          136,
        );
        final label = tester.widget<Text>(
          find.text(first.name(controller.localeCode)),
        );
        expect(label.style?.fontSize, 12.5);
        expect(label.maxLines, 3);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('R45 category and reward detail copy use a 12px floor',
      (tester) async {
    var activated = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(children: <Widget>[
          R35CategoryAction(
            title: 'Store',
            subtitle: 'Verified catalogue',
            icon: Icons.storefront_rounded,
            color: R35ReferenceColors.gold,
            onTap: () => activated = true,
          ),
        ]),
      ),
    ));
    expect(tester.widget<Text>(find.text('Verified catalogue')).style?.fontSize, 12);
    await tester.tap(find.text('Store'));
    expect(activated, isTrue);
    expect(tester.takeException(), isNull);
  });
}
