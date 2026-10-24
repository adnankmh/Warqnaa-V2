import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

BoxDecoration r70Decoration(WidgetTester tester, Finder finder) =>
    tester.widget<Container>(finder).decoration! as BoxDecoration;

void main() {
  for (final locale in <String>['ar', 'en']) {
    for (final themeCode in <String>['royal_crimson', 'emerald_light']) {
      testWidgets('R70 play center and room tools inherit $themeCode in $locale',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()
          ..localeCode = locale
          ..serverConnected = false;
        addTearDown(controller.dispose);
        final theme = r101Theme(themeCode, '#25e4df', localeCode: locale);
        final expectedAccent = theme.colorScheme.primary;

        await tester.pumpWidget(MaterialApp(
          locale: Locale(locale),
          theme: theme,
          home: R64PlayHubPage(controller: controller),
        ));
        await tester.pump();
        final command = r70Decoration(
          tester, find.byKey(const ValueKey('r70-play-command-panel')));
        expect((command.border! as Border).top.color,
            expectedAccent.withValues(alpha: .42));
        expect(command.gradient, isA<LinearGradient>());
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(MaterialApp(
          locale: Locale(locale),
          theme: theme,
          home: Scaffold(body: Builder(builder: (context) => FilledButton(
            onPressed: () => showGameLobby(
              context, controller, customerGamesR101.first),
            child: const Text('Open lobby'),
          ))),
        ));
        await tester.tap(find.text('Open lobby'));
        await tester.pumpAndSettle();
        final toolKey = ValueKey<String>(
          'r70-lobby-tool-${Icons.menu_book_rounded.codePoint}');
        final tool = r70Decoration(tester, find.byKey(toolKey));
        expect((tool.border! as Border).top.color,
            expectedAccent.withValues(alpha: .40));
        expect(tool.gradient, isA<LinearGradient>());
        expect(find.byKey(const ValueKey('r31-lobby-tools-grid')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
