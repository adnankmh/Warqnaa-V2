import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  Future<void> checkPortal(
    WidgetTester tester, {
    required double width,
    required double height,
    required String locale,
    required Brightness brightness,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final ar = locale == 'ar';
    final direction = ar ? TextDirection.rtl : TextDirection.ltr;
    final label = ar ? 'مع الأصدقاء' : 'With friends';
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0B8CFF),
        brightness: brightness,
      ),
    );
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      theme: theme,
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: width < 500 ? 96 : 140,
              child: R8HomePortal(
                icon: Icons.group_add_outlined,
                label: label,
                accent: theme.colorScheme.primary,
                onTap: () => taps++,
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    final portal = find.byType(R8HomePortal);
    final semantics = tester.widget<Semantics>(
      find.byKey(const ValueKey('r226-home-portal-semantics')));
    final surface = tester.widget<Material>(
      find.byKey(const ValueKey('r226-home-portal-surface')));
    final icon = tester.widget<Icon>(find.byIcon(Icons.group_add_outlined));
    final text = tester.widget<Text>(find.text(label));
    expect(portal, findsOneWidget);
    expect(Directionality.of(tester.element(portal)), direction);
    expect(semantics.properties.button, isTrue);
    expect(semantics.properties.label, label);
    expect(semantics.properties.onTap, isNotNull);
    expect(surface.color, theme.colorScheme.surfaceContainerHigh);
    expect(icon.color, theme.colorScheme.primary);
    expect(text.maxLines, 2);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(tester.getSize(find.byKey(
      const ValueKey('r226-home-portal-surface'))).height, greaterThanOrEqualTo(76));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('r226-home-portal-surface')));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  }

  for (final width in <double>[320, 390]) {
    for (final locale in <String>['ar', 'en']) {
      for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
        testWidgets(
          'R226 blue home portal portrait $width $locale $brightness',
          (tester) => checkPortal(tester,
            width: width, height: 720, locale: locale, brightness: brightness),
        );
      }
    }
  }

  testWidgets('R226 home portal remains accessible in landscape', (tester) =>
    checkPortal(tester, width: 844, height: 390,
      locale: 'en', brightness: Brightness.dark));
}
