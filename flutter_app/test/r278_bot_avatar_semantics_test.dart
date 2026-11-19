import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/premium_v149.dart';

void main() {
  for (final language in <String>['ar', 'en']) {
    for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
      for (final width in <double>[320, 390]) {
        testWidgets('R278 bot avatar semantic identity $language $brightness $width',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final semantics = tester.ensureSemantics();
          final direction = language == 'ar'
              ? TextDirection.rtl : TextDirection.ltr;
          final profile = botProfiles.first;
          await tester.pumpWidget(MaterialApp(
            theme: ThemeData(colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff0878cf),
              brightness: brightness,
            )),
            home: Directionality(
              textDirection: direction,
              child: Scaffold(body: Center(
                child: Bot3DAvatar(profile: profile, locale: language),
              )),
            ),
          ));
          await tester.pump();
          expect(find.byType(Bot3DAvatar), findsOneWidget);
          expect(
            find.byWidgetPredicate((widget) =>
              widget is Semantics && widget.properties.image == true &&
              widget.properties.label == (language == 'ar'
                ? 'الصورة الرمزية للاعب الآلي ${profile.nameAr}'
                : '${profile.nameEn} computer-player avatar')),
            findsOneWidget,
          );
          expect(Directionality.of(tester.element(find.byType(Bot3DAvatar))),
              direction);
          expect(tester.takeException(), isNull);
    semantics.dispose();
          semantics.dispose();
        });
      }
    }
  }

  testWidgets('R278 avatar label uses explicit locale over ambient locale',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      home: Scaffold(body: Bot3DAvatar(
        profile: botProfiles[0], locale: 'ar',
      )),
    ));
    expect(find.byWidgetPredicate((widget) =>
          widget is Semantics && widget.properties.image == true &&
          widget.properties.label ==
              'الصورة الرمزية للاعب الآلي ${botProfiles[0].nameAr}'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
