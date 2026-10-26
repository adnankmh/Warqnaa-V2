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
      testWidgets('R83 room members inherit $themeCode in $locale',
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
        var opened = 0;
        var kicked = 0;
        final players = <Map<String, dynamic>>[
          <String, dynamic>{
            'key': 'user:1', 'user_id': 1, 'name': 'Adnan',
            'level': 31, 'country_code': 'PS', 'connected': true,
          },
          <String, dynamic>{
            'key': 'user:2', 'user_id': 2, 'name': 'Lina',
            'level': 18, 'country_code': 'JO', 'connected': false,
          },
          <String, dynamic>{
            'key': 'bot:1', 'name': locale == 'ar' ? 'النسر' : 'Eagle',
            'bot': true, 'connected': true,
          },
        ];

        await tester.pumpWidget(review.reviewApp(
          Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(children: <Widget>[
                R83RoomMembersPanel(
                  players: players,
                  ar: locale == 'ar',
                  currentPlayerKey: 'user:1',
                  canKick: true,
                  onOpenProfile: (_) => opened++,
                  onKick: (_) => kicked++,
                ),
                FilledButton(
                  key: const ValueKey('r83-open-kick-dialog'),
                  onPressed: () => showR83KickPlayerDialog(
                    tester.element(find.byKey(
                        const ValueKey('r83-open-kick-dialog'))),
                    name: 'Lina',
                    ar: locale == 'ar',
                  ),
                  child: const Text('Open dialog'),
                ),
              ]),
            ),
          ),
          controller,
          key,
        ));
        await tester.pump();

        final panel = find.byKey(const ValueKey('r83-room-members-panel'));
        expect(panel, findsOneWidget);
        expect(find.text(locale == 'ar' ? 'إدارة لاعبي الغرفة' : 'Room players'),
            findsOneWidget);
        expect(find.text('PS'), findsOneWidget);
        expect(find.text('JO'), findsOneWidget);
        expect(find.byIcon(Icons.smart_toy_rounded), findsOneWidget);
        expect(find.byKey(const ValueKey('r83-kick-1')), findsNothing);
        expect(find.byKey(const ValueKey('r83-kick-2')), findsOneWidget);
        expect(find.byIcon(Icons.person_remove_alt_1_rounded), findsOneWidget);
        await tester.tap(find.text('Lina'));
        expect(opened, 1);
        await tester.tap(find.byKey(const ValueKey('r83-kick-2')));
        expect(kicked, 1);
        expect(tester.takeException(), isNull);
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
              tester, key, '$locale-r83-room-members-$themeCode-390x844');
        }

        await tester.tap(find.byKey(const ValueKey('r83-open-kick-dialog')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        final dialog = tester.widget<AlertDialog>(
            find.byKey(const ValueKey('r83-kick-player-dialog')));
        final expected = R69PlaySurfaceColors.of(tester.element(
            find.byKey(const ValueKey('r83-kick-player-dialog'))));
        expect(dialog.backgroundColor!.toARGB32(), expected.surface.toARGB32());
        expect(find.text(locale == 'ar'
            ? 'إخراج اللاعب من الغرفة'
            : 'Remove player from room'), findsOneWidget);
        expect(find.text(locale == 'ar' ? 'إلغاء' : 'Cancel'), findsOneWidget);
        expect(find.text(locale == 'ar' ? 'إخراج' : 'Remove'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
              tester, key, '$locale-r83-kick-dialog-$themeCode-390x844');
        }
        await tester.tap(find.text(locale == 'ar' ? 'إلغاء' : 'Cancel'));
        await tester.pump(const Duration(milliseconds: 400));
      });
    }
  }
}
