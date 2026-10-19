import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';
import 'r8_play_experience_test.dart' show host;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppSounds.enabled = false;
  });

  for (final locale in ['ar', 'en']) {
    for (final gameId in ['hand', 'banakil']) {
      testWidgets('R49 $gameId friendly room invites replace bots ($locale)', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final controller = AppController()
          ..localeCode = locale
          ..isAuthenticated = true;
        final game = gamesCatalog.firstWhere((entry) => entry.id == gameId);
        final players = v170AllowedPlayerCounts(gameId).first;
        expect(players, greaterThan(1));

        await tester.pumpWidget(host(Scaffold(body: Builder(builder: (context) =>
          TextButton(onPressed: () => showGameLobby(context, controller, game),
            child: const Text('open')))), locale));
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        final friendly = find.text(L.t(locale, 'friendly'));
        await tester.ensureVisible(friendly);
        await tester.tap(friendly);
        await tester.pumpAndSettle();

        final friend = find.widgetWithText(FilterChip, 'سامر');
        await tester.ensureVisible(friend);
        await tester.pumpAndSettle();
        // All spare seats start as bots. A real friend must still be selectable.
        expect(tester.widget<FilterChip>(friend).onSelected, isNotNull);
        await tester.tap(friend);
        await tester.pumpAndSettle();
        expect(tester.widget<FilterChip>(friend).selected, isTrue);

        // Changing the seat mix must remount the dropdown with the new count.
        expect(find.byKey(ValueKey('r49-room-bots-$players-1-${players - 2}')),
          findsOneWidget);

        FocusManager.instance.primaryFocus?.unfocus();
        final submit = find.byKey(const ValueKey('r48-create-room-submit'));
        await tester.ensureVisible(submit);
        await tester.pumpAndSettle();
        await tester.tap(submit);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        final room = tester.widget<GameRoomPage>(find.byType(GameRoomPage));
        expect(room.options.playerCount, players);
        expect(room.options.inviteeIds, [2]);
        expect(room.options.botCount, players - 2);
        expect(room.options.inviteeIds.length + room.options.botCount,
          players - 1);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 6));
        controller.connectivityTimerV173?.cancel();
        controller.dispose();
      });
    }
  }
}
