import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';
import 'r7_runtime_review_test.dart' as review;

BoxDecoration r75ModeDecoration(WidgetTester tester, Key key) =>
    tester
        .widgetList<Container>(
          find.descendant(of: find.byKey(key), matching: find.byType(Container)),
        )
        .first
        .decoration! as BoxDecoration;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppSounds.enabled = false;
  });
  setUpAll(() async {
    if (review.reviewDirectory.isEmpty) return;
    final bytes = await File(const String.fromEnvironment('R7_REVIEW_FONT'))
        .readAsBytes();
    for (final family in <String>['R7Review', 'Roboto']) {
      await (FontLoader(family)
            ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes))))
          .load();
    }
    await (FontLoader('MaterialIcons')
          ..addFont(File(const String.fromEnvironment('R7_MATERIAL_FONT'))
              .readAsBytes()
              .then(ByteData.sublistView)))
        .load();
  });

  for (final locale in <String>['ar', 'en']) {
    for (final themeCode in <String>['royal_crimson', 'emerald_light']) {
      testWidgets('R75 friendly setup inherits $themeCode in $locale',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()
          ..localeCode = locale
          ..themeCode = themeCode
          ..uiAccentHex = '#25e4df'
          ..isAuthenticated = true;
        addTearDown(controller.dispose);
        final game = gamesCatalog.firstWhere((entry) => entry.id == 'hand');
        final key = GlobalKey();

        await tester.pumpWidget(review.reviewApp(
          Scaffold(body: Builder(builder: (context) => FilledButton(
            onPressed: () => showPlayModePicker(context, controller, game),
            child: const Text('Open friendly setup'),
          ))),
          controller,
          key,
        ));
        await tester.tap(find.text('Open friendly setup'));
        await tester.pumpAndSettle();

        final theme = review.reviewTheme(controller);
        final normal = r75ModeDecoration(
          tester, const ValueKey('r75-normal-mode-card'));
        expect(normal.gradient, isA<LinearGradient>());
        expect(normal.border!.top.color,
            theme.colorScheme.primary.withValues(alpha: .52));

        await tester.tap(find.byKey(const ValueKey('r75-normal-mode-card')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('r48-create-room-settings')),
            findsOneWidget);
        final panelFinder =
            find.byKey(const ValueKey('r75-participant-panel'));
        await tester.ensureVisible(panelFinder);
        await tester.pumpAndSettle();

        final panel = tester.widget<Container>(panelFinder);
        final panelDecoration = panel.decoration! as BoxDecoration;
        final colors = R69PlaySurfaceColors.of(tester.element(panelFinder));
        expect(panelDecoration.gradient, isA<LinearGradient>());
        expect(panelDecoration.border!.top.color,
            colors.accent.withValues(alpha: .34));
        final players = v170AllowedPlayerCounts(game.id).first;
        expect(
          find.byKey(ValueKey('r49-room-bots-$players-0-${players - 1}')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);

        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
            tester, key, '$locale-r75-friendly-setup-$themeCode-390x844');
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
