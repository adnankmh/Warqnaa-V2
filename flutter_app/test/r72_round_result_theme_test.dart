import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'r7_runtime_review_test.dart' as review;

BoxDecoration r72Decoration(WidgetTester tester, Key key, {int index = 0}) =>
    (tester.widgetList<Container>(find.byKey(key)).elementAt(index).decoration!
        as BoxDecoration);

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
      testWidgets('R72 round and result surfaces inherit $themeCode in $locale',
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
        final theme = review.reviewTheme(controller);
        final scheme = theme.colorScheme;
        final surface = Color.lerp(
          scheme.surface,
          theme.scaffoldBackgroundColor,
          theme.brightness == Brightness.dark ? .34 : .16,
        )!;
        final key = GlobalKey();

        await tester.pumpWidget(review.reviewApp(
          Scaffold(
            body: Directionality(
              textDirection:
                  locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 90),
                child: Column(
                  children: <Widget>[
                    R52RoundScoreCard(
                      state: const <String, dynamic>{
                        'round_results': <dynamic>[
                          <String, dynamic>{
                            'delta': <String, int>{'you': 24, 'peer': -12},
                          },
                        ],
                      },
                      players: <dynamic>[
                        <String, String>{
                          'key': 'you',
                          'name': locale == 'ar' ? 'أنت' : 'You',
                        },
                        <String, String>{
                          'key': 'peer',
                          'name': locale == 'ar' ? 'المنافس' : 'Opponent',
                        },
                      ],
                      ar: locale == 'ar',
                    ),
                    const SizedBox(height: 18),
                    R52MatchResult(
                      ar: locale == 'ar',
                      won: true,
                      points: '+24',
                      onExit: () {},
                      onReplay: () {},
                    ),
                    const SizedBox(height: 18),
                    R52MatchResult(
                      ar: locale == 'ar',
                      won: false,
                      points: '-12',
                      onExit: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          controller,
          key,
        ));
        await tester.pump();

        final score = r72Decoration(
          tester, const ValueKey<String>('r52-round-points'));
        final victory = r72Decoration(
          tester, const ValueKey<String>('r52-match-result'));
        final complete = r72Decoration(
          tester, const ValueKey<String>('r52-match-result'), index: 1);
        expect(score.color, surface);
        expect(score.border!.top.color,
            scheme.primary.withValues(alpha: .72));
        expect(victory.color, surface);
        expect(victory.border!.top.color, B307SkyLuxury.goldSoft);
        expect(complete.color, surface);
        expect(complete.border!.top.color, scheme.primary);
        expect(tester.takeException(), isNull);

        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
            tester, key, '$locale-r72-round-result-$themeCode-390x844');
        }
      });
    }
  }
}
