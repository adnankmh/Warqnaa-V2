import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/engines/local_game_engine.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/models/room_launch_options.dart';
import 'package:warqna_mobile/services/api_client.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

import 'r7_runtime_review_test.dart' as review;

/// A controllable transport exercises the real room widget and API methods.
/// Only invitation responses pause: creating and reading the room still work.
class R49DeliveryApi extends WarqnaApiClient {
  R49DeliveryApi(String game, String locale, {this.failedIds = const {2}}) {
    room = Map<String, dynamic>.from(LocalGameSession(
      gameId: game, humanName: 'Adnan', difficulty: 'pro',
      playerCount: 4, localeCode: locale,
    ).room())..['code'] = 'R49ROOM';
  }

  late final Map<String, dynamic> room;
  final Set<int> failedIds;
  final gate = Completer<void>();
  final invitations = <int>[];
  final invitationBodies = <Map<String, dynamic>>[];
  int createCalls = 0;
  int joinCalls = 0;

  @override
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body,
      {bool authenticated = true}) async {
    if (path == '/games/session') {
      createCalls += 1;
      return {'room': room};
    }
    if (path == '/games/session/R49ROOM/join') {
      joinCalls += 1;
      return {'room': room};
    }
    if (path.startsWith('/social/users/') && path.endsWith('/room-invite')) {
      final id = int.parse(path.split('/')[3]);
      invitations.add(id);
      invitationBodies.add(Map<String, dynamic>.from(body));
      await gate.future;
      if (failedIds.contains(id)) {
        throw const ApiException('Synthetic invitation rejection', statusCode: 403);
      }
      return {'message': 'Invitation sent'};
    }
    throw StateError('Unexpected fixture POST: $path');
  }

  @override
  Future<Map<String, dynamic>> get(String path, {bool authenticated = true}) async {
    if (path == '/games/session/R49ROOM/chat') return {'messages': []};
    if (path == '/games/session/R49ROOM') return {'room': room};
    throw StateError('Unexpected fixture GET: $path');
  }
}

String failureNotice(String locale, int failures) => locale == 'ar'
    ? 'الغرفة جاهزة، لكن تعذّر إرسال $failures من الدعوات. يمكنك إعادة الدعوة من زر الأصدقاء.'
    : 'Your room is ready, but $failures invitation(s) could not be sent. Use Invite friends to try again.';

Future<(AppController, R49DeliveryApi, GlobalKey)> openRoom(
    WidgetTester tester, String locale, String game, Size size,
    {Set<int> failedIds = const {2}, bool joining = false}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final api = R49DeliveryApi(game, locale, failedIds: failedIds);
  final controller = AppController(api: api)
    ..localeCode = locale
    ..serverConnected = true
    ..isAuthenticated = true;
  addTearDown(() {
    controller.connectivityTimerV173?.cancel();
    controller.dispose();
  });
  final key = GlobalKey();
  await tester.pumpWidget(review.reviewApp(ServerEngineRoomPage(
    controller: controller,
    game: gamesCatalog.firstWhere((entry) => entry.id == game),
    options: RoomLaunchOptions(
      playerCount: 4, botCount: 1, inviteeIds: const [2, 3],
      roomCode: joining ? 'R49ROOM' : null,
    ),
  ), controller, key));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  return (controller, api, key);
}

void expectReady(AppController controller, String locale) {
  expect(controller.activeRoomCode, 'R49ROOM');
  expect(find.text(locale == 'ar' ? 'غرفة R49ROOM' : 'Room R49ROOM'), findsOneWidget);
  expect(find.text(locale == 'ar' ? 'تدريب مع الكمبيوتر' : 'Practice with computer'), findsNothing);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppSounds.enabled = false;
  });
  setUpAll(() async {
    if (review.reviewDirectory.isEmpty) return;
    final bytes = await File(const String.fromEnvironment('R7_REVIEW_FONT')).readAsBytes();
    for (final family in ['R7Review', 'Roboto']) {
      await (FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }
    await (FontLoader('MaterialIcons')..addFont(
      File(const String.fromEnvironment('R7_MATERIAL_FONT')).readAsBytes()
          .then((bytes) => ByteData.sublistView(bytes)),
    )).load();
    const emoji = String.fromEnvironment('R7_EMOJI_FONT');
    if (emoji.isNotEmpty) {
      await (FontLoader('R7Emoji')..addFont(
        File(emoji).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
      )).load();
    }
  });

  for (final locale in ['ar', 'en']) {
    for (final game in ['hand', 'banakil']) {
      for (final size in [const Size(390, 844), const Size(844, 390)]) {
        testWidgets('R49 $game opens while invites wait and reports partial failure $locale $size',
            (tester) async {
          final (controller, api, key) = await openRoom(tester, locale, game, size);
          // The invitation is still unresolved. The real room must already be usable.
          expect(api.gate.isCompleted, isFalse);
          expect(api.invitations, [2]);
          expectReady(controller, locale);
          expect(api.createCalls, 1);

          api.gate.complete();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
          // A rejection neither falls back offline nor prevents the remaining invite.
          expect(api.invitations, [2, 3]);
          expect(api.invitationBodies, [
            {'room_code': 'R49ROOM'}, {'room_code': 'R49ROOM'},
          ]);
          expectReady(controller, locale);
          expect(api.createCalls, 1);
          expect(find.text(failureNotice(locale, 1)), findsOneWidget);
          expect(tester.takeException(), isNull);

          if (game == 'hand' && review.reviewDirectory.isNotEmpty) {
            final name = locale + '-r49-invite-failure-' +
                size.width.toInt().toString() + 'x' + size.height.toInt().toString();
            await review.capture(tester, key, name);
            if (const bool.fromEnvironment('R49_LOG_REVIEW')) {
              // Synthetic-account PNG evidence can be reviewed through CI logs
              // when the local execution environment is unavailable.
              final encoded = base64Encode(await File(review.reviewDirectory + '/' + name + '.png').readAsBytes());
              stdout.writeln('R49_IMAGE_BEGIN:' + name);
              for (var offset = 0; offset < encoded.length; offset += 4096) {
                final end = offset + 4096 < encoded.length ? offset + 4096 : encoded.length;
                stdout.writeln('R49_PNG:' + encoded.substring(offset, end));
              }
              stdout.writeln('R49_IMAGE_END:' + name);
            }
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        });
      }
    }

    testWidgets('R49 successful invitations do not show a failure $locale', (tester) async {
      final (controller, api, _) = await openRoom(tester, locale, 'hand',
        const Size(390, 844), failedIds: const <int>{});
      expectReady(controller, locale);
      api.gate.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(api.invitations, [2, 3]);
      expect(find.byType(SnackBar), findsNothing);
      expectReady(controller, locale);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('R49 leaving during an invite causes no stale UI or extra sends $locale', (tester) async {
      final (_, api, _) = await openRoom(tester, locale, 'banakil', const Size(390, 844));
      expect(api.invitations, [2]);
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Another screen'))));
      api.gate.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(api.invitations, [2]);
      expect(find.text('Another screen'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('R49 joining a room does not resend its creation invitations $locale', (tester) async {
      final (controller, api, _) = await openRoom(tester, locale, 'hand',
        const Size(390, 844), joining: true);
      expectReady(controller, locale);
      expect(api.createCalls, 0);
      expect(api.joinCalls, 1);
      expect(api.invitations, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }
}
