import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

import 'r7_runtime_review_test.dart' as review;

void main() {
  setUpAll(() async {
    if (review.reviewDirectory.isEmpty) return;
    final bytes = await File(const String.fromEnvironment('R7_REVIEW_FONT')).readAsBytes();
    for (final family in ['R7Review', 'Roboto']) {
      await (FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }
    await (FontLoader('MaterialIcons')
      ..addFont(File(const String.fromEnvironment('R7_MATERIAL_FONT'))
        .readAsBytes().then(ByteData.sublistView))).load();
  });
  for (final locale in ['ar', 'en']) {
    for (final width in [320.0, 390.0]) {
      for (final brightness in Brightness.values) {
        testWidgets('R254 voice privacy $locale $width $brightness', (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final handle = tester.ensureSemantics();
          try {
            final scheme = ColorScheme.fromSeed(
              seedColor: const Color(0xFF1565C0), brightness: brightness);
            final direction = locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
            var enabled = false;
            final captureKey = GlobalKey();
            await tester.pumpWidget(RepaintBoundary(key: captureKey, child: MaterialApp(
              locale: Locale(locale),
              supportedLocales: const [Locale('ar'), Locale('en')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              theme: ThemeData(colorScheme: scheme,
                fontFamily: review.reviewDirectory.isEmpty ? null : 'R7Review'),
              home: Directionality(textDirection: direction, child: Scaffold(
                body: StatefulBuilder(builder: (context, setState) => Column(
                  children: [
                    Switch(value: enabled, onChanged: (value) => setState(() => enabled = value)),
                    if (enabled) R254RoomVoicePrivacyNotice(locale: locale),
                  ],
                )),
              )),
            )));
            await tester.pumpAndSettle();
            final notice = find.byKey(const ValueKey('r77-voice-privacy-notice'));
            final announcement = find.byKey(const ValueKey('r254-room-voice-privacy-announcement'));
            expect(notice, findsNothing);
            await tester.tap(find.byType(Switch));
            await tester.pumpAndSettle();
            expect(notice, findsOneWidget);
            final semantics = tester.widget<Semantics>(announcement);
            final hint = L.t(locale, 'voicePrivacyHint');
            expect(semantics.properties.label, hint);
            expect(semantics.properties.liveRegion, isTrue);
            expect(semantics.excludeSemantics, isTrue);
            final label = find.descendant(of: notice, matching: find.text(hint));
            expect(label, findsOneWidget);
            expect(Directionality.of(tester.element(label)), direction);
            expect(tester.widget<Text>(label).style?.color,
                R69PlaySurfaceColors.of(tester.element(label)).onSurface);
            expect(tester.getSize(notice).width, lessThanOrEqualTo(width));
            expect(tester.takeException(), isNull);
            if (review.reviewDirectory.isNotEmpty) {
              await review.capture(tester, captureKey,
                'r254-voice-privacy-$locale-${brightness.name}-${width.toInt()}x844');
            }
            await tester.tap(find.byType(Switch));
            await tester.pumpAndSettle();
            expect(announcement, findsNothing);
          } finally {
            handle.dispose();
          }
        });
      }
    }
  }
}
