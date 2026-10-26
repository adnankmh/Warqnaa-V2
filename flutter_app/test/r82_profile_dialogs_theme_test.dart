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
      testWidgets('R82 profile dialogs inherit $themeCode in $locale',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()
          ..localeCode = locale
          ..themeCode = themeCode
          ..uiAccentHex = '#25e4df'
          ..displayName = locale == 'ar' ? 'لاعب ورقنا' : 'Warqnaa Player'
          ..username = 'player'
          ..avatarEmoji = 'A';
        addTearDown(controller.dispose);
        final key = GlobalKey();

        await tester.pumpWidget(review.reviewApp(
          Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: <Widget>[
                  FilledButton(
                    onPressed: () => showAvatarPreview(context, controller),
                    child: const Text('Open avatar'),
                  ),
                  FilledButton(
                    onPressed: () => showCountryPicker(context, controller),
                    child: const Text('Open country'),
                  ),
                  FilledButton(
                    onPressed: () => showCancelAccountDialog(context, controller),
                    child: const Text('Open cancellation'),
                  ),
                ],
              ),
            ),
          ),
          controller,
          key,
        ));

        await tester.tap(find.text('Open avatar'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        final avatar = tester.widget<Container>(
            find.byKey(const ValueKey('r82-avatar-preview-dialog')));
        final expected = R69PlaySurfaceColors.of(tester.element(
            find.byKey(const ValueKey('r82-avatar-preview-dialog'))));
        final avatarDecoration = avatar.decoration! as BoxDecoration;
        expect(avatarDecoration.gradient, isA<LinearGradient>());
        expect(avatarDecoration.border!.top.color.toARGB32(),
            expected.accent.withValues(alpha: .40).toARGB32());
        final name = tester.widget<Text>(find.text(controller.displayName));
        expect(name.style!.color!.toARGB32(),
            r82ReadableProfileName(tester.element(find.text(controller.displayName)),
                    controller.selectedNameColor)
                .toARGB32());
        expect(find.text(locale == 'ar' ? 'إغلاق' : 'Close'), findsOneWidget);
        expect(find.text(locale == 'ar' ? 'تعديل' : 'Edit'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
              tester, key, '$locale-r82-avatar-$themeCode-390x844');
        }
        await tester.tap(find.text(locale == 'ar' ? 'إغلاق' : 'Close'));
        await tester.pump(const Duration(milliseconds: 400));

        await tester.tap(find.text('Open country'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        final country = tester.widget<AlertDialog>(
            find.byKey(const ValueKey('r82-country-dialog')));
        final countryShape = country.shape! as RoundedRectangleBorder;
        expect(country.backgroundColor!.toARGB32(), expected.surface.toARGB32());
        expect(countryShape.side.color.toARGB32(),
            expected.accent.withValues(alpha: .40).toARGB32());
        expect(find.text(locale == 'ar'
            ? 'اختر الدولة والعلم'
            : 'Choose country and flag'), findsOneWidget);
        expect(find.text(locale == 'ar'
            ? 'ابحث باسم الدولة أو الرمز'
            : 'Search by country name or code'), findsOneWidget);
        expect(find.text('IS'), findsWidgets);
        expect(tester.takeException(), isNull);
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
              tester, key, '$locale-r82-country-$themeCode-390x844');
        }
        await tester.tap(find.text(locale == 'ar' ? 'إلغاء' : 'Cancel'));
        await tester.pump(const Duration(milliseconds: 400));

        await tester.tap(find.text('Open cancellation'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        final cancellation = tester.widget<AlertDialog>(
            find.byKey(const ValueKey('r82-cancel-account-dialog')));
        final cancellationShape =
            cancellation.shape! as RoundedRectangleBorder;
        expect(cancellation.backgroundColor!.toARGB32(),
            expected.surface.toARGB32());
        expect(cancellationShape.side.color.toARGB32(),
            expected.accent.withValues(alpha: .40).toARGB32());
        expect(find.text(locale == 'ar'
            ? 'كلمة المرور للتأكيد'
            : 'Password confirmation'), findsOneWidget);
        expect(find.text(locale == 'ar' ? 'تراجع' : 'Back'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (review.reviewDirectory.isNotEmpty) {
          await review.capture(
              tester, key, '$locale-r82-cancel-$themeCode-390x844');
        }
        await tester.tap(find.text(locale == 'ar' ? 'تراجع' : 'Back'));
        await tester.pump(const Duration(milliseconds: 400));
      });
    }
  }
}
