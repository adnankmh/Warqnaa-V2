import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'r7_runtime_review_test.dart' as review;

const r74Reward = <String, dynamic>{
  'type': 'ticket',
  'value': '500',
  'label_ar': 'تذكرة مسابقة 500',
  'label_en': 'Competition ticket 500',
};

void main() {
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
      testWidgets('R74 prize opening inherits $themeCode in $locale',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()
          ..localeCode = locale
          ..themeCode = themeCode
          ..uiAccentHex = '#25e4df';
        addTearDown(controller.dispose);
        final key = GlobalKey();
        var continued = 0;

        await tester.pumpWidget(review.reviewApp(
          Scaffold(
            body: R53PrizeOpeningScene(
              locale: locale,
              boxKey: 'emerald_eagle',
              reward: r74Reward,
              progress: 1,
              completed: true,
              onSkip: () {},
              onContinue: () => continued++,
            ),
          ),
          controller,
          key,
        ));
        await tester.pump();

        final context = tester.element(
          find.byKey(const ValueKey('r53-prize-summary')));
        final theme = Theme.of(context);
        final colors = R69PlaySurfaceColors.of(context);
        final scene = tester.widget<ColoredBox>(
          find.byKey(const ValueKey('r74-prize-scene')));
        final summary = tester.widget<Container>(
          find.byKey(const ValueKey('r53-prize-summary')));
        final decoration = summary.decoration! as BoxDecoration;
        expect(scene.color, theme.scaffoldBackgroundColor);
        expect(decoration.color, colors.surface);
        expect(decoration.border!.top.color, colors.accent);
        expect(
          tester.widget<Text>(
            find.byKey(const ValueKey('r53-prize-description'))).style!.color,
          colors.onSurface,
        );
        final close = find.byKey(const ValueKey('r53-prize-continue'));
        final closeStyle = tester.widget<FilledButton>(close).style!;
        expect(closeStyle.backgroundColor!.resolve(<WidgetState>{}),
            colors.accent);
        expect(closeStyle.foregroundColor!.resolve(<WidgetState>{}),
            theme.colorScheme.onPrimary);
        await tester.tap(close);
        expect(continued, 1);
        expect(tester.takeException(), isNull);

        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
            tester, key, '$locale-r74-prize-opening-$themeCode-390x844');
        }
      });
    }
  }
}
