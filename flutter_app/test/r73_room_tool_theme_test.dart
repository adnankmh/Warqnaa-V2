import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'r7_runtime_review_test.dart' as review;

Finder r73Tool(IconData icon) => find.byKey(
      ValueKey<String>('r30-room-tool-${icon.codePoint}'),
    );

BoxDecoration r73ToolDecoration(WidgetTester tester, IconData icon) =>
    tester
        .widget<Container>(
          find.descendant(of: r73Tool(icon), matching: find.byType(Container)),
        )
        .decoration! as BoxDecoration;

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
      testWidgets('R73 room tools inherit $themeCode in $locale',
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
        var taps = 0;

        await tester.pumpWidget(review.reviewApp(
          Scaffold(
            body: Directionality(
              textDirection:
                  locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              child: Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    RoomTool(
                      icon: Icons.chat_bubble_outline,
                      onTap: () => taps++,
                    ),
                    RoomTool(icon: Icons.emoji_emotions_outlined, onTap: () {}),
                    RoomTool(icon: Icons.menu_book_outlined, onTap: () {}),
                    RoomTool(icon: Icons.refresh, onTap: () {}),
                    RoomTool(icon: Icons.exit_to_app, onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
          controller,
          key,
        ));
        await tester.pump();

        final decoration =
            r73ToolDecoration(tester, Icons.chat_bubble_outline);
        final gradient = decoration.gradient! as LinearGradient;
        expect(gradient.colors.first,
            Color.lerp(surface, scheme.primary, .18));
        expect(gradient.colors.last,
            Color.lerp(surface, scheme.secondary, .08));
        expect(decoration.border!.top.color,
            scheme.primary.withValues(alpha: .34));
        expect(
          tester.widget<Icon>(find.byIcon(Icons.chat_bubble_outline)).color,
          Color.lerp(B307SkyLuxury.goldSoft, scheme.primary, .30),
        );
        await tester.tap(r73Tool(Icons.chat_bubble_outline));
        expect(taps, 1);
        expect(tester.takeException(), isNull);

        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
            tester, key, '$locale-r73-room-tools-$themeCode-390x844');
        }
      });
    }
  }
}
