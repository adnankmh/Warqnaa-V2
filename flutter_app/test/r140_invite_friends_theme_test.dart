import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R140 invite friends sheet follows theme and selection still works',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController()..localeCode = 'ar';
    addTearDown(() {
      controller.connectivityTimerV173?.cancel();
      controller.dispose();
    });
    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff0a8f62),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff0a8f62),
        brightness: Brightness.dark,
      ),
    );

    Future<List<Color>> openAndInspect(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r140-invite-friends-${theme.brightness}'),
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              key: const ValueKey('r140-open-invite-friends'),
              onPressed: () => inviteFriendsToRoomV151(
                context,
                controller,
                'tarneeb',
              ),
              child: const Text('Open invite sheet'),
            ),
          ),
        ),
      ));
      await tester.tap(find.byKey(const ValueKey('r140-open-invite-friends')));
      await tester.pumpAndSettle();

      final introFinder =
          find.byKey(const ValueKey('r140-invite-friends-intro'));
      final intro = tester.widget<Text>(introFinder);
      final offline = tester.widget<Container>(
        find.byKey(const ValueKey('r140-friend-status-4')),
      );
      final online = tester.widget<Container>(
        find.byKey(const ValueKey('r140-friend-status-2')),
      );
      final offlineDecoration = offline.decoration! as BoxDecoration;
      final onlineDecoration = online.decoration! as BoxDecoration;

      expect(intro.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(offlineDecoration.color, theme.colorScheme.outline);
      expect(offlineDecoration.border!.top.color, theme.colorScheme.surface);
      expect(onlineDecoration.color, Colors.greenAccent);
      expect(onlineDecoration.border!.top.color, theme.colorScheme.surface);

      await tester.tap(find.text('جميل'));
      await tester.pump();
      expect(find.text('إرسال 1 دعوة'), findsOneWidget);
      expect(tester.takeException(), isNull);

      Navigator.of(tester.element(introFinder)).pop();
      await tester.pumpAndSettle();
      return <Color>[
        intro.style!.color!,
        offlineDecoration.color!,
        offlineDecoration.border!.top.color,
      ];
    }

    final lightColors = await openAndInspect(light);
    final darkColors = await openAndInspect(dark);
    expect(darkColors, isNot(equals(lightColors)));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
