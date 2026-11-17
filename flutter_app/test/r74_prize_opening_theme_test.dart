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

double r268Contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  final lighter = a > b ? a : b;
  final darker = a > b ? b : a;
  return (lighter + 0.05) / (darker + 0.05);
}

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
      for (final width in <double>[320, 390]) {
      testWidgets('R74 prize opening uses accessible blue palette with $themeCode in $locale at $width',
          (tester) async {
        tester.view.physicalSize = Size(width, 844);
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
        // Verify that the actual scene inherits the requested reading direction.
        expect(
          Directionality.of(context),
          locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
        final theme = Theme.of(context);
        final dark = theme.brightness == Brightness.dark;
        final surface = dark ? const Color(0xFF123B60) : const Color(0xFFE8F5FF);
        final onSurface = dark ? const Color(0xFFF1F8FF) : const Color(0xFF123B60);
        final accent = dark ? const Color(0xFF70C5FF) : const Color(0xFF075A9C);
        final onAccent = dark ? const Color(0xFF102E49) : Colors.white;
        final scene = tester.widget<ColoredBox>(
          find.byKey(const ValueKey('r74-prize-scene')));
        final summary = tester.widget<Container>(
          find.byKey(const ValueKey('r53-prize-summary')));
        final decoration = summary.decoration! as BoxDecoration;
        expect(scene.color, dark ? const Color(0xFF0D2945) : const Color(0xFFD8EDFC));
        expect(decoration.color, surface);
        expect(decoration.border!.top.color, accent);
        // WCAG AA normal text contrast for the actual foreground/background pairs.
        expect(r268Contrast(onSurface, surface), greaterThanOrEqualTo(4.5));
        expect(r268Contrast(onAccent, accent), greaterThanOrEqualTo(4.5));
        expect(r268Contrast(onSurface, scene.color), greaterThanOrEqualTo(4.5));
        expect(
          tester.widget<Text>(
            find.byKey(const ValueKey('r53-prize-description'))).style!.color,
          onSurface,
        );
        final close = find.byKey(const ValueKey('r53-prize-continue'));
        final closeStyle = tester.widget<FilledButton>(close).style!;
        expect(closeStyle.backgroundColor!.resolve(<WidgetState>{}),
            accent);
        expect(closeStyle.foregroundColor!.resolve(<WidgetState>{}),
            onAccent);
        // Catch layout/paint failures before taking visual evidence.\n        expect(tester.takeException(), isNull);\n        expect(tester.widget<FilledButton>(close).onPressed, isNotNull);\n        final closeRect = tester.getRect(close);
        expect(closeRect.top, greaterThanOrEqualTo(0));
        expect(closeRect.bottom, lessThanOrEqualTo(844));
        expect(closeRect.left, greaterThanOrEqualTo(0));
        expect(closeRect.right, lessThanOrEqualTo(width));
        expect(closeRect.width, greaterThanOrEqualTo(48));
        expect(closeRect.height, greaterThanOrEqualTo(48));
        // Capture the pre-action state so visual review includes the actual CTA.
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
            tester, key, '$locale-r268-prize-opening-$themeCode-${width.toInt()}x844');
        }
        await tester.tap(close);
        await tester.pump();
        await tester.pump(); // Callback must remain single-shot across frames.
        expect(continued, 1);
        expect(tester.takeException(), isNull);
      });
      }
    }
  }
}
