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
          addTearDown(semantics.dispose);
          final ar = locale == 'ar';
          final direction = ar ? TextDirection.rtl : TextDirection.ltr;
          var continued = 0;

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
                  onSkip: () {},
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
          final colors = R69PlaySurfaceColors.of(tester.element(status));
          expect((summaryBox.decoration! as BoxDecoration).border!.top.color,
              colors.accent);

          await render(1, true);
          expect(tester.getSemantics(status).label,
              ar ? 'صندوق المكافأة مفتوح' : 'Reward chest open');
          expect(find.text(prizeRewardLabelV02(locale, _reward)),
              findsOneWidget);
          expect(tester.getRect(status).overlaps(tester.getRect(summary)), isFalse);
          final continueButton = find.byKey(
              const ValueKey('r53-prize-continue'));
          expect(tester.widget<FilledButton>(continueButton).onPressed,
              isNotNull);
          await tester.ensureVisible(continueButton);
          await tester.pump();
          await tester.tap(continueButton);
          expect(continued, 1);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
