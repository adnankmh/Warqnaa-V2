import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R152 operations status hero follows theme and direction',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff286c88),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff286c88),
        brightness: Brightness.dark,
      ),
    );
    final report = <String, dynamic>{
      'release': '1.7.0',
      'environment': 'production',
      'generated_at': '2026-10-30T19:00:00Z',
    };

    Future<List<Color>> inspect(
      ThemeData theme,
      bool ar,
      TextDirection direction,
    ) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r152-operations-status-${theme.brightness}-$ar'),
        theme: theme,
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: child!,
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: R65OperationsStatusHero(report: report, ar: ar),
          ),
        ),
      ));
      await tester.pump();

      final heroFinder =
          find.byKey(const ValueKey('r152-operations-status-hero'));
      final hero = tester.widget<Container>(heroFinder);
      final decoration = hero.decoration! as BoxDecoration;
      final gradient = decoration.gradient! as LinearGradient;
      final border = decoration.border! as Border;
      final title = tester.widget<Text>(
        find.byKey(const ValueKey('r152-operations-status-title')),
      );
      final release = tester.widget<Text>(
        find.byKey(const ValueKey('r152-operations-status-release')),
      );
      final generatedAt = tester.widget<Text>(
        find.byKey(const ValueKey('r152-operations-status-generated-at')),
      );

      expect(
        gradient.colors,
        <Color>[
          Color.lerp(
            theme.colorScheme.surfaceContainerHighest,
            theme.colorScheme.primary,
            0.14,
          )!,
          Color.lerp(
            theme.colorScheme.surface,
            theme.colorScheme.secondary,
            0.08,
          )!,
        ],
      );
      expect(border.top.color, theme.colorScheme.outlineVariant);
      expect(title.data, ar ? 'حالة منصتك الآن' : 'Your platform now');
      expect(title.style!.color, theme.colorScheme.onSurface);
      expect(release.data, '1.7.0 • production');
      expect(release.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(generatedAt.data, '2026-10-30T19:00:00Z');
      expect(generatedAt.style!.color, theme.colorScheme.outline);
      expect(generatedAt.style!.fontSize, 11);
      expect(Directionality.of(tester.element(heroFinder)), direction);
      expect(tester.takeException(), isNull);
      return gradient.colors;
    }

    final lightGradient =
        await inspect(light, true, TextDirection.rtl);
    final darkGradient =
        await inspect(dark, false, TextDirection.ltr);
    expect(darkGradient, isNot(lightGradient));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
