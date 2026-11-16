import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/r9_design_system.dart';

const _reward = <String, dynamic>{
  'type': 'ticket',
  'value': '500',
  'label_ar': 'تذكرة مسابقة 500',
  'label_en': 'Competition ticket 500',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in <String>['ar', 'en']) {
    for (final light in <bool>[true, false]) {
      for (final width in <double>[320, 390]) {
        testWidgets('R220 blue prize chest semantics $locale light=$light width=$width',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final semantics = tester.ensureSemantics();
          try {
          final ar = locale == 'ar';
          final direction = ar ? TextDirection.rtl : TextDirection.ltr;
          var continued = 0;
          var skipped = 0;

          Future<void> render(double progress, bool completed) async {
            await tester.pumpWidget(MaterialApp(
              locale: Locale(locale),
              supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              theme: R9Design.theme(
                light: light, accent: R9Design.azure, arabic: ar),
              home: Directionality(
                textDirection: direction,
                child: Scaffold(body: R53PrizeOpeningScene(
                  locale: locale,
                  boxKey: 'emerald_eagle',
                  reward: _reward,
                  progress: progress,
                  completed: completed,
                  onSkip: () => skipped++,
                  onContinue: () => continued++,
                )),
              ),
            ));
            await tester.pump();
          }

          const statusKey = ValueKey('r220-prize-chest-status');
          final status = find.byKey(statusKey);
          final summary = find.byKey(
            const ValueKey('r53-prize-summary-viewport'));

          await render(0, false);
          expect(status, findsOneWidget);
          expect(tester.widget<Semantics>(status).excludeSemantics, isTrue);
          expect(tester.widget<Semantics>(status).properties.liveRegion, isFalse);
          expect(tester.getSemantics(status).label,
              ar ? 'جارٍ فتح صندوق المكافأة' : 'Opening reward chest');
          expect(Directionality.of(tester.element(status)), direction);
          expect(tester.getRect(status).overlaps(tester.getRect(summary)), isFalse);
          expect(tester.widget<FilledButton>(find.byKey(
            const ValueKey('r53-prize-continue'))).onPressed, isNull);

          final summaryBox = tester.widget<Container>(
              find.byKey(const ValueKey('r53-prize-summary')));
          final decoration = summaryBox.decoration! as BoxDecoration;
          final surface = light ? const Color(0xFFE8F5FF) : const Color(0xFF123B60);
          final onSurface = light ? const Color(0xFF123B60) : const Color(0xFFF1F8FF);
          final accent = light ? const Color(0xFF075A9C) : const Color(0xFF70C5FF);
          expect(decoration.color, surface);
          expect(decoration.border!.top.color, accent);
          final shell = tester.widget<ColoredBox>(find.byKey(const ValueKey('r74-prize-scene')));
          expect(shell.color, light ? const Color(0xFFD8EDFC) : const Color(0xFF0D2945));

          final heading = tester.widget<Text>(find.text(
            ar ? 'لحظة حظ ملكية' : 'A royal moment'));
          expect(heading.style!.color, onSurface);
          final stage = tester.widget<DecoratedBox>(find.byKey(
            const ValueKey('r266-prize-blue-stage')));
          final gradient = (stage.decoration as BoxDecoration).gradient!
              as RadialGradient;
          expect(gradient.colors.last,
              light ? const Color(0xFFE8F5FF) : const Color(0xFF123B60));

          final skip = find.byKey(const ValueKey('r53-prize-skip'));
          await tester.ensureVisible(skip);
          await tester.tap(skip);
          expect(skipped, 1);
          await render(1, true);
          expect(skip, findsNothing);
          expect(tester.getSemantics(status).label,
              ar ? 'صندوق المكافأة مفتوح' : 'Reward chest open');
          expect(find.text(prizeRewardLabelV02(locale, _reward)),
              findsOneWidget);
          expect(tester.getRect(status).overlaps(tester.getRect(summary)), isFalse);
          final continueButton = find.byKey(
              const ValueKey('r53-prize-continue'));
          expect(tester.widget<FilledButton>(continueButton).onPressed,
              isNotNull);
          final style = tester.widget<FilledButton>(continueButton).style!;
          expect(style.backgroundColor!.resolve(<WidgetState>{}), accent);
          expect(style.foregroundColor!.resolve(<WidgetState>{}),
              light ? Colors.white : const Color(0xFF102E49));
          await tester.ensureVisible(continueButton);
          await tester.pump();
          await tester.tap(continueButton);
          expect(continued, 1);
          expect(tester.takeException(), isNull);
          } finally {
            semantics.dispose();
          }
        });
      }
    }
  }
}
