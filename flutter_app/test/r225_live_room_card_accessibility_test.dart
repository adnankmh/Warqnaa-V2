import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final width in <double>[320, 390]) {
    for (final locale in <String>['ar', 'en']) {
      for (final brightness in <Brightness>[Brightness.light, Brightness.dark]) {
        testWidgets(
          'R225 live room summary and blue Join action: $width $locale $brightness',
          (tester) async {
            tester.view.physicalSize = Size(width, 720);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final semantics = tester.ensureSemantics();
            addTearDown(semantics.dispose);

            final ar = locale == 'ar';
            final direction = ar ? TextDirection.rtl : TextDirection.ltr;
            final theme = ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0B8CFF),
                brightness: brightness,
              ),
            );
            var joins = 0;
            await tester.pumpWidget(MaterialApp(
              theme: theme,
              home: Directionality(
                textDirection: direction,
                child: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: R64RoomCard(
                      ar: ar,
                      room: const <String, dynamic>{
                        'name': 'A long Warqnaa blue table name for portrait testing',
                        'code': 'AB12CD34',
                        'players_count': 2,
                        'max_players': 4,
                        'turn_seconds': 15,
                        'voice_enabled': true,
                      },
                      onJoin: () => joins++,
                    ),
                  ),
                ),
              ),
            ));
            await tester.pump();

            final card = find.byKey(const ValueKey('r225-room-card'));
            final title = tester.widget<Text>(
              find.byKey(const ValueKey('r225-room-title')));
            final subtitle = tester.widget<Text>(
              find.byKey(const ValueKey('r225-room-subtitle')));
            final avatar = tester.widget<CircleAvatar>(
              find.byKey(const ValueKey('r225-room-avatar')));
            final icon = tester.widget<Icon>(
              find.byKey(const ValueKey('r225-room-icon')));

            expect(card, findsOneWidget);
            expect(Directionality.of(tester.element(card)), direction);
            expect(title.maxLines, 2);
            expect(title.overflow, TextOverflow.ellipsis);
            expect(subtitle.textDirection, TextDirection.ltr);
            expect(subtitle.maxLines, 1);
            expect(subtitle.data, '2/4 • 15s • AB12CD34');
            expect(avatar.backgroundColor, theme.colorScheme.primaryContainer);
            expect(icon.color, theme.colorScheme.primary);
            expect(find.bySemanticsLabel(RegExp(
              ar ? r'غرفة .*2 من 4 لاعبين.*AB12CD34'
                 : r'Room .*2 of 4 players.*AB12CD34',
            )), findsOneWidget);
            expect(tester.takeException(), isNull);

            await tester.tap(find.text(ar ? 'دخول' : 'Join'));
            expect(joins, 1);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('R225 empty room names keep the code readable in RTL',
      (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: R64RoomCard(
            ar: true,
            room: const <String, dynamic>{'name': '  ', 'code': 'ROOM42'},
            onJoin: () {},
          ),
        ),
      ),
    ));
    expect(find.text('غرفة ROOM42'), findsOneWidget);
    expect(tester.widget<Text>(
      find.byKey(const ValueKey('r225-room-subtitle'))).textDirection,
      TextDirection.ltr);
    expect(tester.takeException(), isNull);
  });
}
