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
      testWidgets('R76 lobby status inherits $themeCode in $locale',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()
          ..localeCode = locale
          ..serverConnected = false
          ..themeCode = themeCode
          ..uiAccentHex = '#25e4df';
        addTearDown(controller.dispose);
        final key = GlobalKey();

        await tester.pumpWidget(review.reviewApp(
          Scaffold(body: Builder(builder: (context) => FilledButton(
            onPressed: () => showGameLobby(
              context, controller, customerGamesR101.first),
            child: const Text('Open lobby'),
          ))),
          controller,
          key,
        ));
        await tester.tap(find.text('Open lobby'));
        await tester.pumpAndSettle();

        final stripFinder =
            find.byKey(const ValueKey('r31-lobby-connection-strip'));
        final strip = tester.widget<Container>(stripFinder);
        final decoration = strip.decoration! as BoxDecoration;
        final stripContext = tester.element(stripFinder);
        final accent = r76LobbyConnectionAccent(stripContext, false);
        expect(decoration.gradient, isA<LinearGradient>());
        expect(decoration.border!.top.color.toARGB32(),
            accent.withValues(alpha: .40).toARGB32());

        final art = tester.widget<Container>(
          find.byKey(const ValueKey('r76-lobby-game-art')),
        );
        final artDecoration = art.decoration! as BoxDecoration;
        final colors = R69PlaySurfaceColors.of(stripContext);
        expect(artDecoration.border!.top.color.toARGB32(),
            colors.accent.withValues(alpha: .44).toARGB32());
        expect(find.byKey(const ValueKey('r31-lobby-tools-grid')), findsOneWidget);
        expect(tester.takeException(), isNull);

        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
            tester, key, '$locale-r76-lobby-status-$themeCode-390x844');
        }
      });
    }
  }
}
