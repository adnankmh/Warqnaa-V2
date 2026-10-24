import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  test('R64 room tools use compact tiles with readable text', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(source, contains("final tileHeight = constraints.maxWidth < 350 ? 68.0 : 56.0;"));
    expect(source, contains("style: const TextStyle(color: B307SkyLuxury.text, fontSize: 17,"));
    expect(source, contains("key: const ValueKey('r31-lobby-tools-grid')"));
  });

  for (final locale in <String>['ar','en']) {
    testWidgets('R64 meld workspace reversible sorting and colored group for $locale',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        List<List<String>>? result;
        final cards = <String>['7_C','5_C','6_C','K_S'];
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: Builder(builder: (context) =>
            Center(child: FilledButton(
              onPressed: () async {
                result = await showDialog<List<List<String>>>(
                  context: context,
                  builder: (_) => R36MeldWorkspace(cards: cards, ar: locale == 'ar'),
                );
              },
              child: const Text('Open workspace'),
            )),
          )),
        ));
        await tester.tap(find.text('Open workspace'));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('r64-sort-meld-cards')), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('r64-sort-meld-cards')));
        await tester.pump();
        expect(find.byKey(const ValueKey('r36-meld-card-0')), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('r64-sort-meld-cards')));
        await tester.pump();
        for (final i in <int>[0,1,2]) {
          await tester.tap(find.byKey(ValueKey('r36-meld-card-$i')));
        }
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('r36-add-meld-group')));
        await tester.pump();
        expect(find.byKey(const ValueKey('r44-meld-group-0')), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('r36-submit-meld-groups')));
        await tester.pumpAndSettle();
        expect(result, <List<String>>[['7_C','5_C','6_C']]);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
