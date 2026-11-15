import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final locale in <String>['ar', 'en']) {
    for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
      for (final width in <double>[320, 390]) {
        testWidgets('R236 room code $locale $brightness portrait $width',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final semantics = tester.ensureSemantics();
          addTearDown(semantics.dispose);

          final direction =
              locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
          final theme = ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff1767c5),
              brightness: brightness,
            ),
          );
          await tester.pumpWidget(MaterialApp(
            theme: theme,
            home: Directionality(
              textDirection: direction,
              child: Scaffold(
                body: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: width - 24,
                    child: ActiveGameRoomLabelR236(
                      gameName: locale == 'ar' ? 'ترنيب' : 'Tarneeb',
                      roomCode: 'AB12-C9',
                      localeCode: locale,
                    ),
                  ),
                ),
              ),
            ),
          ));
          await tester.pumpAndSettle();

          final code = find.byKey(const ValueKey('r236-active-room-code'));
          expect(code, findsOneWidget);
          expect(Directionality.of(tester.element(code)), TextDirection.ltr);
          expect(
            Directionality.of(
              tester.element(find.byType(ActiveGameRoomLabelR236)),
            ),
            direction,
          );
          expect(
            find.bySemanticsLabel(
              locale == 'ar' ? 'رمز الغرفة AB12-C9' : 'Room code AB12-C9',
            ),
            findsOneWidget,
          );
          final decoration =
              tester.widget<Container>(code).decoration! as BoxDecoration;
          expect(
            decoration.color,
            theme.colorScheme.primary.withValues(alpha: .12),
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('R236 empty room code does not show a fake badge',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ActiveGameRoomLabelR236(
          gameName: 'Tarneeb',
          roomCode: '  ',
          localeCode: 'en',
        ),
      ),
    ));
    expect(find.byKey(const ValueKey('r236-active-room-code')), findsNothing);
    expect(find.text('Tarneeb'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('R236 long identity stays inside a narrow portrait viewport',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(12),
            child: ActiveGameRoomLabelR236(
              gameName: 'اسم لعبة طويل جدا للاختبار على الهاتف العمودي',
              roomCode: 'LONG-ROOM-CODE-ABCD-123456789',
              localeCode: 'ar',
            ),
          ),
        ),
      ),
    ));
    expect(find.byKey(const ValueKey('r236-active-room-code')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
