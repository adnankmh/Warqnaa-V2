import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  Future<void> inspectIdentityFields(
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
    final controller = AppController()..localeCode = locale;
    addTearDown(controller.dispose);
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0B8CFF),
        brightness: brightness,
      ),
    );

    await tester.pumpWidget(MaterialApp(
      theme: theme,
      home: Directionality(
        textDirection: direction,
        child: R143AccountSecurityPage(controller: controller),
      ),
    ));
    await tester.pump();

    final usernameFinder =
        find.byKey(const ValueKey('r227-account-username-field'));
    final emailFinder =
        find.byKey(const ValueKey('r227-account-email-field'));
    expect(usernameFinder, findsOneWidget);
    expect(emailFinder, findsOneWidget);

    for (final finder in <Finder>[usernameFinder, emailFinder]) {
      final field = tester.widget<TextField>(finder);
      expect(field.textDirection, TextDirection.ltr);
      expect(field.textAlign, TextAlign.start);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
      expect(field.textCapitalization, TextCapitalization.none);
      // The form remains localized, but the ASCII identity value stays LTR.
      expect(Directionality.of(tester.element(finder)), direction);
      expect(tester.getSize(finder).width, lessThan(width));
      expect(Theme.of(tester.element(finder)).colorScheme.primary,
          theme.colorScheme.primary);
    }
    expect(tester.widget<TextField>(emailFinder).keyboardType,
        TextInputType.emailAddress);
    expect(find.text(ar ? 'مركز أمان الحساب' : 'Account security center'),
        findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(emailFinder, 'user@example.com');
    await tester.pump();
    expect(tester.widget<TextField>(emailFinder).controller!.text,
        'user@example.com');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  }

  for (final width in <double>[320, 390]) {
    for (final locale in <String>['ar', 'en']) {
      for (final brightness in <Brightness>[
        Brightness.light,
        Brightness.dark,
      ]) {
        testWidgets(
          'R227 blue account identity fields portrait $width $locale $brightness',
          (tester) => inspectIdentityFields(
            tester,
            width: width,
            height: 720,
            locale: locale,
            brightness: brightness,
          ),
        );
      }
    }
  }

  testWidgets('R227 identity fields stay readable in landscape', (tester) =>
      inspectIdentityFields(
        tester,
        width: 844,
        height: 390,
        locale: 'ar',
        brightness: Brightness.dark,
      ));
}
