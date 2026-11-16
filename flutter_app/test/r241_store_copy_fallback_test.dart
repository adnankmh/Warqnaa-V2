import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  test('R241 ignores blank server translations and preserves server quote', () {
    final product = products.firstWhere((item) => item.category == 'pasha');
    final controller = AppController()..serverConnected = true;
    controller.syncServerStoreR36([
      {
        'key': product.id,
        'price': 125,
        'name': {'ar': '  ', 'en': 'Warqnaa Blue membership'},
        'payload': {
          'description': {'ar': '', 'en': 'Original blue membership'},
        },
      },
    ]);
    expect(controller.nameFor(product, 'ar'), 'Warqnaa Blue membership');
    expect(controller.descriptionFor(product, 'ar'), 'Original blue membership');
    expect(controller.priceFor(product), 125);
    controller.dispose();
  });

  test('R241 flat server copy falls back to a nonblank language', () {
    final product = products.firstWhere((item) => item.category == 'pasha');
    final controller = AppController()..serverConnected = true;
    controller.syncServerStoreR36([
      {
        'key': product.id,
        'price': 125,
        'name': {'ar': 'عضوية ورقنا الزرقاء', 'en': '  '},
        'payload': {
          'description_ar': '  ',
          'description_en': 'Blue membership details',
        },
      },
    ]);
    expect(controller.nameFor(product, 'en'), 'عضوية ورقنا الزرقاء');
    expect(controller.descriptionFor(product, 'ar'), 'Blue membership details');
    expect(controller.descriptionFor(product, 'en'), 'Blue membership details');
    expect(controller.storeTextR36(product, 'unsupported', 'en'), isNull);
    expect(controller.priceFor(product), 125);
    controller.dispose();
  });

  for (final locale in <String>['ar', 'en']) {
    for (final brightness in <Brightness>[
      Brightness.light,
      Brightness.dark,
    ]) {
      for (final width in <double>[320, 390]) {
        testWidgets(
          'R241 live store copy on blue portrait $locale $brightness ${width.toInt()}',
          (tester) async {
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(() {
              tester.view.resetPhysicalSize();
              tester.view.resetDevicePixelRatio();
            });

            final product =
                products.firstWhere((item) => item.category == 'pasha');
            final controller = AppController()
              ..localeCode = locale
              ..serverConnected = true;
            controller.syncServerStoreR36([
              {
                'key': product.id,
                'price': 125,
                'name': {
                  'ar': 'عضوية ورقنا الزرقاء',
                  'en': 'Warqnaa Blue membership',
                },
                'payload': {
                  'description_ar': 'تفاصيل العضوية الزرقاء',
                  'description_en': 'Blue membership details',
                },
              },
            ]);
            final direction =
                locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
            final theme = ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xff0878cf),
                brightness: brightness,
              ),
            );
            await tester.pumpWidget(MaterialApp(
              locale: Locale(locale),
              theme: theme,
              home: Directionality(
                textDirection: direction,
                child: Scaffold(
                  body: Center(
                    child: SizedBox(
                      width: width - 24,
                      height: 520,
                      child: ProductCardV170(
                        controller: controller,
                        product: product,
                      ),
                    ),
                  ),
                ),
              ),
            ));
            await tester.pump();

            final description =
                find.byKey(const ValueKey('r138-store-description'));
            expect(description, findsOneWidget);
            expect(
              tester.widget<Text>(description).data,
              locale == 'ar'
                  ? 'تفاصيل العضوية الزرقاء'
                  : 'Blue membership details',
            );
            expect(
              find.text(locale == 'ar'
                  ? 'عضوية ورقنا الزرقاء'
                  : 'Warqnaa Blue membership'),
              findsOneWidget,
            );
            expect(Directionality.of(tester.element(description)), direction);
            final scheme = Theme.of(tester.element(description)).colorScheme;
            expect(
              tester.widget<Text>(description).style?.color,
              scheme.onSurfaceVariant,
            );
            expect(
              HSLColor.fromColor(scheme.primary).hue,
              inInclusiveRange(185, 265),
            );
            expect(controller.priceFor(product), 125);
            expect(tester.takeException(), isNull);

            await tester.pumpWidget(const SizedBox.shrink());
            controller.connectivityTimerV173?.cancel();
            controller.dispose();
          },
        );
      }
    }
  }
}
