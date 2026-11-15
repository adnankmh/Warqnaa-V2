import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/r9_design_system.dart';

void main() {
  for (final locale in const <String>['ar', 'en']) {
    for (final light in const <bool>[true, false]) {
      for (final width in const <double>[320, 390]) {
        testWidgets('R224 party invite code $locale light=$light width=$width',
            (tester) async {
          tester.view.physicalSize = Size(width, 720);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final ar = locale == 'ar';
          final theme = R9Design.theme(
            light: light,
            accent: R9Design.azure,
            arabic: ar,
          );
          final controller = TextEditingController();
          addTearDown(controller.dispose);
          await tester.pumpWidget(MaterialApp(
            theme: theme,
            home: Directionality(
              textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
              child: Scaffold(
                body: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    R65PartyCodeLabel(ar: ar),
                    const R65PartyCodeValue(code: 'AB12C34'),
                    R224PartyInviteCodeField(controller: controller, ar: ar),
                  ],
                ),
              ),
            ),
          ));
          await tester.pump();

          final code = tester.widget<SelectableText>(
            find.byKey(const ValueKey('r156-party-code-value')),
          );
          expect(code.data, 'AB12C34');
          expect(code.textDirection, TextDirection.ltr);
          expect(code.textAlign, TextAlign.center);
          expect(code.style!.color, theme.colorScheme.primary);
          expect(theme.colorScheme.primary.b,
              greaterThan(theme.colorScheme.primary.r));
          expect(find.text(ar ? 'رمز المجموعة' : 'Party code'),
              findsOneWidget);

          final field = tester.widget<TextField>(
            find.byKey(const ValueKey('r224-party-invite-code-input')),
          );
          expect(field.textDirection, TextDirection.ltr);
          expect(field.maxLength, 7);
          expect(field.autocorrect, isFalse);
          expect(field.enableSuggestions, isFalse);
          expect(field.decoration!.labelText,
              ar ? 'رمز مجموعة تمت دعوتك إليها' : 'Code of a party you were invited to');
          await tester.enterText(
            find.byKey(const ValueKey('r224-party-invite-code-input')),
            'ab12c34',
          );
          await tester.pump();
          expect(controller.text, 'ab12c34');
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('R224 party code remains readable in short landscape layout',
      (tester) async {
    tester.view.physicalSize = const Size(640, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      theme: R9Design.theme(light: true, accent: R9Design.azure),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: ListView(children: [
            const R65PartyCodeValue(code: '9B4C2D7'),
            R224PartyInviteCodeField(controller: controller, ar: true),
          ]),
        ),
      ),
    ));
    expect(tester.widget<SelectableText>(
      find.byKey(const ValueKey('r156-party-code-value')),
    ).textDirection, TextDirection.ltr);
    expect(tester.takeException(), isNull);
  });
}
