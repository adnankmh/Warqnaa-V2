import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'r7_runtime_review_test.dart' as review;

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
      testWidgets('R84 shared partnership melds inherit $themeCode in $locale',
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
        final players = <Map<String, dynamic>>[
          {'id': 'p0', 'name': locale == 'ar' ? 'عدنان' : 'Adnan', 'team': 0},
          {'id': 'p1', 'name': locale == 'ar' ? 'لينا' : 'Lina', 'team': 1},
          {'id': 'p2', 'name': locale == 'ar' ? 'بيان' : 'Bayan', 'team': 0},
          {'id': 'p3', 'name': locale == 'ar' ? 'عمر' : 'Omar', 'team': 1},
        ];
        final state = <String, dynamic>{
          'deck_count': 73,
          'discard': <String>['5_H', '9_C', 'K_D'],
          'teams': <String, dynamic>{
            'teamA': <String>['p0', 'p2'],
            'teamB': <String>['p1', 'p3'],
          },
          'melds': <String, dynamic>{
            'p0': <dynamic>[<String, dynamic>{'cards': <String>['3_C', '4_C', '5_C']}],
            'p2': <dynamic>[<String, dynamic>{'cards': <String>['A_H', 'A_C', 'A_S']}],
            'p1': <dynamic>[<String, dynamic>{'cards': <String>['7_D', '8_D', '9_D']}],
            'p3': <dynamic>[<String, dynamic>{'cards': <String>['Q_H', 'Q_C', 'Q_S']}],
          },
        };

        await tester.pumpWidget(review.reviewApp(
          Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: R44RummyTableOverlay(
                    state: state,
                    players: players,
                    ar: locale == 'ar',
                    partnership: true,
                    cardLabel: (card) => card,
                    onDrawDeck: () {},
                    onDrawDiscard: () {},
                    onDrawStack: () {},
                  ),
                ),
              ),
            ),
          ),
          controller,
          key,
        ));
        await tester.pump();

        expect(find.byKey(const ValueKey('r84-meld-team-0')), findsOneWidget);
        expect(find.byKey(const ValueKey('r84-meld-team-1')), findsOneWidget);
        for (final owner in <String>['p0', 'p1', 'p2', 'p3']) {
          expect(find.byKey(ValueKey('r44-meld-owner-$owner')), findsOneWidget);
        }
        expect(find.text(locale == 'ar'
            ? 'فريق أ • عدنان + بيان'
            : 'Team A • Adnan + Bayan'), findsOneWidget);
        expect(find.text(locale == 'ar'
            ? 'فريق ب • لينا + عمر'
            : 'Team B • Lina + Omar'), findsOneWidget);
        expect(find.byKey(const ValueKey('r44-stock-pile')), findsOneWidget);
        expect(find.byKey(const ValueKey('r44-fire-pile')), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(tester, key,
              '$locale-r84-shared-partnership-melds-$themeCode-390x844');
        }
      });
    }
  }
}
