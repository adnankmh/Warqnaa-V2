import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  Future<void> inspectNavigation(
    WidgetTester tester, {
    required String locale,
    required Brightness brightness,
    required double width,
    required double height,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController()..localeCode = locale;
    addTearDown(() {
      controller.connectivityTimerV173?.cancel();
      controller.dispose();
    });
    final direction = locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: B307SkyLuxury.azure,
        brightness: brightness,
      ),
    );
    var lastSelected = -1;

    await tester.pumpWidget(MaterialApp(
      theme: theme,
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          bottomNavigationBar: B307BottomNavigation(
            controller: controller,
            selectedIndex: 2,
            onSelected: (index) => lastSelected = index,
          ),
        ),
      ),
    ));
    await tester.pump();

    final labels = locale == 'ar'
        ? <String>['المتجر', 'الألعاب', 'الرئيسية', 'الأصدقاء', 'البطولات']
        : <String>['Store', 'Games', 'Home', 'Social', 'Events'];
    for (var i = 0; i < 5; i++) {
      final finder = find.byKey(ValueKey('r228-bottom-destination-$i'));
      expect(finder, findsOneWidget);
      final semantics = tester.widget<Semantics>(finder);
      expect(semantics.properties.label, labels[i]);
      expect(semantics.properties.button, isTrue);
      expect(semantics.properties.selected, i == 2);
      expect(semantics.properties.onTap, isNotNull);
      expect(Directionality.of(tester.element(finder)), direction);
      expect(tester.getSize(finder).height, greaterThanOrEqualTo(48));
    }

    final selectedFinder = find.byKey(
      const ValueKey('r228-bottom-destination-2'),
    );
    final selectedContainer = tester.widget<AnimatedContainer>(
      find.descendant(
        of: selectedFinder,
        matching: find.byType(AnimatedContainer),
      ),
    );
    final decoration = selectedContainer.decoration! as BoxDecoration;
    final gradient = decoration.gradient! as LinearGradient;
    expect(gradient.colors, <Color>[
      const Color(0xff23c7ff),
      B307SkyLuxury.azure,
    ]);
    final selectedBorder = decoration.border! as Border;
    expect(
      selectedBorder.top.color,
      B307SkyLuxury.goldSoft.withValues(alpha: .72),
    );

    await tester.tap(find.byKey(const ValueKey('r228-bottom-destination-4')));
    await tester.pump();
    expect(lastSelected, 4);
    expect(tester.takeException(), isNull);
  }

  for (final locale in <String>['ar', 'en']) {
    for (final brightness in <Brightness>[
      Brightness.light,
      Brightness.dark,
    ]) {
      for (final width in <double>[320, 390]) {
        testWidgets(
          'R228 bottom navigation ' +
              locale +
              ' ' +
              brightness.name +
              ' portrait ' +
              width.toString(),
          (tester) => inspectNavigation(
            tester,
            locale: locale,
            brightness: brightness,
            width: width,
            height: 844,
          ),
        );
      }
    }
  }

  testWidgets('R228 Arabic short landscape keeps five accessible destinations',
      (tester) => inspectNavigation(
        tester,
        locale: 'ar',
        brightness: Brightness.dark,
        width: 640,
        height: 320,
      ));
}
