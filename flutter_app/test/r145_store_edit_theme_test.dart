import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets(
      'R145 store edit metadata follows theme and cancel preserves catalogue',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController()..localeCode = 'ar';
    addTearDown(() {
      controller.connectivityTimerV173?.cancel();
      controller.dispose();
    });
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

    Future<Color> inspect(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r145-store-edit-${theme.brightness}'),
        theme: theme,
        home: Scaffold(
          body: AdminStoreStudioV151(
            key: ValueKey('r145-store-body-${theme.brightness}'),
            controller: controller,
          ),
        ),
      ));
      await tester.pump();

      final editButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'تعديل').first,
      );
      editButton.onPressed!();
      await tester.pumpAndSettle();

      final metadataFinder =
          find.byKey(const ValueKey('r145-store-product-metadata'));
      final metadata = tester.widget<Text>(metadataFinder);
      expect(metadata.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(metadata.style!.fontSize, 11);
      expect(metadata.data, contains('المعرّف:'));
      expect(metadata.data, contains('الفئة:'));
      expect(tester.takeException(), isNull);

      final cancelButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'إلغاء'),
      );
      cancelButton.onPressed!();
      await tester.pumpAndSettle();

      expect(metadataFinder, findsNothing);
      expect(find.widgetWithText(OutlinedButton, 'تعديل'), findsWidgets);
      expect(tester.takeException(), isNull);
      return metadata.style!.color!;
    }

    final lightColor = await inspect(light);
    final darkColor = await inspect(dark);
    expect(darkColor, isNot(lightColor));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
