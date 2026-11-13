import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in <String>['ar', 'en']) {
    for (final brightness in <Brightness>[
      Brightness.light,
      Brightness.dark,
    ]) {
      for (final width in <double>[320, 390]) {
        testWidgets('R230 World Hub portrait $locale $brightness $width',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final direction = locale == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr;
          final title = locale == 'ar' ? 'إنشاء مجموعة' : 'Create party';
          final subtitle = locale == 'ar'
              ? 'اجمع أصدقاءك وادخلوا المباراة معًا'
              : 'Group with friends and enter matches together';
          final scheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF0B8CFF),
            brightness: brightness,
          );
          var taps = 0;
          final handle = tester.ensureSemantics();
          await tester.pumpWidget(MaterialApp(
            theme: ThemeData(useMaterial3: true, colorScheme: scheme),
            home: Directionality(
              textDirection: direction,
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: (width - 42) / 2,
                    height: width == 320 ? 169 : 184,
                    child: R230WorldHubActionCard(
                      key: const ValueKey('r230-world-card'),
                      icon: Icons.groups_2_rounded,
                      title: title,
                      subtitle: subtitle,
                      onTap: () => taps++,
                    ),
                  ),
                ),
              ),
            ),
          ));

          final card = find.byKey(const ValueKey('r230-world-card'));
          expect(card, findsOneWidget);
          expect(Directionality.of(tester.element(card)), direction);
          expect(find.bySemanticsLabel('$title. $subtitle'), findsOneWidget);
          final ink = tester.widget<Ink>(
            find.descendant(of: card, matching: find.byType(Ink)).first,
          );
          final decoration = ink.decoration! as BoxDecoration;
          final gradient = decoration.gradient! as LinearGradient;
          expect(gradient.colors.first, scheme.primary.withValues(alpha: .14));
          expect((decoration.border! as Border).top.color,
              scheme.primary.withValues(alpha: .30));

          await tester.tap(card);
          await tester.pump();
          expect(taps, 1);
          expect(tester.takeException(), isNull);
          handle.dispose();
        });
      }
    }
  }

  testWidgets('R230 disabled reconnect action is announced as unavailable',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 180,
            height: 180,
            child: R230WorldHubActionCard(
              key: ValueKey('r230-disabled-card'),
              icon: Icons.wifi_protected_setup_rounded,
              title: 'Reconnect',
              subtitle: 'Return to the same seat',
            ),
          ),
        ),
      ),
    ));
    final card = find.byKey(const ValueKey('r230-disabled-card'));
    final semantics = tester.widget<Semantics>(
      find.descendant(of: card, matching: find.byType(Semantics)).first,
    );
    expect(semantics.properties.button, isTrue);
    expect(semantics.properties.enabled, isFalse);
    expect(semantics.properties.onTap, isNull);
    expect(find.bySemanticsLabel('Reconnect. Return to the same seat'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  testWidgets('R230 wide landscape card keeps blue surface and no overflow',
      (tester) async {
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 180,
            height: 150,
            child: R230WorldHubActionCard(
              icon: Icons.visibility_rounded,
              title: 'Spectate',
              subtitle: 'Watch public matches without exposing private hands',
            ),
          ),
        ),
      ),
    ));
    expect(find.text('Spectate'), findsOneWidget);
    expect(find.byType(Ink), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
