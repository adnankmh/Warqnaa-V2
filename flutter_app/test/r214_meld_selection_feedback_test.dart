import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in <String>['ar', 'en']) {
    for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
      for (final width in <double>[320, 390]) {
        testWidgets('R214 meld feedback $locale $brightness $width portrait',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final ar = locale == 'ar';
          final direction = ar ? TextDirection.rtl : TextDirection.ltr;
          List<List<String>>? submitted;
          const cards = <String>[
            '3_H', '4_H', '5_H', '9_D', '9_C', '9_S', 'K_H',
          ];
          await tester.pumpWidget(MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xff1565c0),
                brightness: brightness,
              ),
            ),
            home: Directionality(
              textDirection: direction,
              child: Scaffold(body: Builder(builder: (context) =>
                Center(child: FilledButton(
                  onPressed: () async {
                    submitted = await showDialog<List<List<String>>>(
                      context: context,
                      builder: (_) => R36MeldWorkspace(ar: ar, cards: cards),
                    );
                  },
                  child: const Text('Open workspace'),
                )),
              )),
            ),
          ));
          await tester.tap(find.text('Open workspace'));
          await tester.pumpAndSettle();

          final status = find.byKey(
            const ValueKey('r214-meld-selection-status'));
          final clear = find.byKey(
            const ValueKey('r214-clear-meld-selection'));
          final add = find.byKey(const ValueKey('r36-add-meld-group'));
          String statusText() => tester.widget<Text>(status).data!;
          expect(statusText(), contains(ar ? 'المحدد: 0' : 'Selected: 0'));
          expect(statusText(), contains(
            ar ? 'اختر 3 أوراق على الأقل' : 'Choose at least 3 cards'));
          expect(Directionality.of(tester.element(status)), direction);
          expect(tester.widget<Text>(status).style!.color,
            R69PlaySurfaceColors.of(tester.element(status)).onSurface);
          expect(tester.widget<TextButton>(clear).onPressed, isNull);

          Future<void> select(int index) async {
            final card = find.byKey(ValueKey('r36-meld-card-$index'));
            await tester.ensureVisible(card);
            await tester.pumpAndSettle();
            await tester.tap(card);
            await tester.pump();
          }
          Future<void> saveGroup() async {
            await tester.ensureVisible(add);
            await tester.pumpAndSettle();
            await tester.tap(add);
            await tester.pump();
          }

          await select(0);
          await select(1);
          expect(statusText(), contains(ar ? 'المحدد: 2' : 'Selected: 2'));
          expect(tester.widget<FilledButton>(add).onPressed, isNull);
          await select(2);
          expect(statusText(), contains(ar ? 'جاهزة للحفظ' : 'Ready to save'));
          await saveGroup();
          expect(find.byKey(const ValueKey('r44-meld-group-0')), findsOneWidget);
          expect(statusText(), contains(ar ? 'المحدد: 0' : 'Selected: 0'));

          await select(3);
          await select(4);
          await tester.ensureVisible(clear);
          await tester.pumpAndSettle();
          await tester.tap(clear);
          await tester.pump();
          expect(statusText(), contains(ar ? 'المحدد: 0' : 'Selected: 0'));
          expect(find.byKey(const ValueKey('r44-meld-group-0')), findsOneWidget);
          expect(tester.widget<TextButton>(clear).onPressed, isNull);

          await select(3);
          await select(4);
          await select(5);
          await saveGroup();
          expect(find.byKey(const ValueKey('r44-meld-group-1')), findsOneWidget);
          final first = tester.widget<Container>(
            find.byKey(const ValueKey('r44-meld-group-0')));
          final second = tester.widget<Container>(
            find.byKey(const ValueKey('r44-meld-group-1')));
          final palette = R69PlaySurfaceColors.of(tester.element(status));
          expect(((first.decoration! as BoxDecoration).border! as Border).top.color,
            palette.group(0));
          expect(((second.decoration! as BoxDecoration).border! as Border).top.color,
            palette.group(1));

          final submit = find.byKey(
            const ValueKey('r36-submit-meld-groups'));
          await tester.ensureVisible(submit);
          await tester.pumpAndSettle();
          await tester.tap(submit);
          await tester.pumpAndSettle();
          expect(submitted, <List<String>>[
            <String>['3_H', '4_H', '5_H'],
            <String>['9_D', '9_C', '9_S'],
          ]);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
