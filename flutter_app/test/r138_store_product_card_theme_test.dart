import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R138 store product card follows active theme and preview stays interactive',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController()..localeCode = 'en';
    addTearDown(controller.dispose);
    const product = StoreProduct(
      id: 'r138_theme_probe',
      category: 'tables',
      icon: '🎴',
      nameAr: 'طاولة اختبار',
      nameEn: 'Preview table',
      descriptionAr: 'وصف اختبار',
      descriptionEn: 'Theme-aware product description',
      price: 1000,
      value: 'table-r138-probe',
      previewColor1: Color(0xff0f766e),
      previewColor2: Color(0xff14b8a6),
    );
    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff0a8f62),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff0a8f62),
        brightness: Brightness.dark,
      ),
    );

    Future<List<Color>> pumpCard(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r138-store-card-${theme.brightness}'),
        theme: theme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              height: 520,
              child: ProductCardV170(
                controller: controller,
                product: product,
              ),
            ),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 250));
      final tier = tester.widget<Container>(
        find.byKey(const ValueKey('r138-store-tier-surface')),
      );
      final preview = tester.widget<Container>(
        find.byKey(const ValueKey('r138-store-preview-surface')),
      );
      final description = tester.widget<Text>(
        find.byKey(const ValueKey('r138-store-description')),
      );
      final tierDecoration = tier.decoration! as BoxDecoration;
      final previewDecoration = preview.decoration! as BoxDecoration;
      expect(tierDecoration.color, theme.colorScheme.surfaceContainerHighest);
      expect(tierDecoration.border!.top.color, theme.colorScheme.outlineVariant);
      expect(previewDecoration.color, theme.colorScheme.surfaceContainerLow);
      expect(description.style!.color, theme.colorScheme.onSurfaceVariant);
      return <Color>[tierDecoration.color!, previewDecoration.color!, description.style!.color!];
    }

    final lightColors = await pumpCard(light);
    final darkColors = await pumpCard(dark);
    expect(darkColors, isNot(equals(lightColors)));

    final previewAction = tester.widget<InkWell>(
      find.byKey(const ValueKey('r138-store-preview-action')),
    );
    expect(previewAction.onTap, isNotNull);
    await tester.tap(find.byKey(const ValueKey('r138-store-preview-action')));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Preview table'), findsAtLeastNWidgets(2));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
