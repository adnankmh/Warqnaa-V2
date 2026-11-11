import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/r9_design_system.dart';

void main() {
  for (final locale in const ['ar', 'en']) {
    for (final light in const [true, false]) {
      for (final width in const [320.0, 390.0]) {
        testWidgets('R223 Ranked gateway $locale light=$light width=$width',
            (tester) async {
          tester.view.physicalSize = Size(width, 480);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final arabic = locale == 'ar';
          final theme = R9Design.theme(
            light: light, accent: R9Design.azure, arabic: arabic,
          );
          var submitted = false;
          await tester.pumpWidget(MaterialApp(
            locale: Locale(locale),
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: theme,
            home: Scaffold(body: Builder(builder: (context) => Center(
              child: FilledButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (sheet) => R223RankedQueueSheetViewport(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(arabic ? 'بوابة Ranked' : 'Ranked gateway',
                            style: const TextStyle(fontSize: 23)),
                        const SizedBox(height: 15),
                        for (final label in [
                          arabic ? 'اللعبة' : 'Game',
                          arabic ? 'عدد اللاعبين' : 'Players',
                          arabic ? 'المنطقة' : 'Region',
                        ]) ...[
                          DropdownButtonFormField<String>(
                            initialValue: 'one',
                            decoration: InputDecoration(labelText: label),
                            items: const [
                              DropdownMenuItem(value: 'one', child: Text('One')),
                              DropdownMenuItem(value: 'two', child: Text('Two')),
                            ],
                            onChanged: (_) {},
                          ),
                          const SizedBox(height: 12),
                        ],
                        FilledButton(
                          key: const ValueKey('r223-ranked-submit'),
                          onPressed: () {
                            submitted = true;
                            Navigator.pop(sheet);
                          },
                          child: Text(arabic ? 'ابدأ البحث العادل' : 'Start fair matchmaking'),
                        ),
                      ],
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ))),
          ));
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          final scroll = find.byKey(const ValueKey('r223-ranked-queue-scroll'));
          final submit = find.byKey(const ValueKey('r223-ranked-submit'));
          expect(scroll, findsOneWidget);
          expect(Directionality.of(tester.element(scroll)),
              arabic ? TextDirection.rtl : TextDirection.ltr);
          expect(Theme.of(tester.element(scroll)).brightness, theme.brightness);
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(submit);
          await tester.pumpAndSettle();
          expect(tester.getSize(submit).height, greaterThanOrEqualTo(48));
          await tester.tap(submit);
          await tester.pumpAndSettle();
          expect(submitted, isTrue);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('R223 short landscape gateway remains scrollable', (tester) async {
    tester.view.physicalSize = const Size(568, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: R9Design.theme(light: false, accent: R9Design.azure),
      home: Scaffold(body: R223RankedQueueSheetViewport(
        child: Column(children: [
          const SizedBox(height: 480),
          FilledButton(
            key: const ValueKey('r223-landscape-submit'),
            onPressed: () {},
            child: const Text('Continue'),
          ),
        ]),
      )),
    ));
    await tester.pump();
    final submit = find.byKey(const ValueKey('r223-landscape-submit'));
    await tester.ensureVisible(submit);
    await tester.pump();
    expect(submit.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
