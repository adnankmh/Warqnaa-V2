import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/api_client.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

final clubs = <Map<String, dynamic>>[
  {'id': 1, 'name': 'Majlis', 'description': 'A club for card players', 'league': {'ar': 'ذهبي', 'en': 'Gold'}, 'visibility': 'public', 'members_count': 8, 'capacity': 20, 'weekly_points': 400},
  {'id': 2, 'name': 'Pending', 'visibility': 'request', 'members_count': 2, 'capacity': 20, 'join_request_pending': true},
  {'id': 3, 'name': 'Full', 'visibility': 'public', 'members_count': 20, 'capacity': 20},
];
final cups = <Map<String, dynamic>>[
  {'id': 1, 'name': {'ar': 'كأس ورقنا', 'en': 'Warqnaa Cup'}, 'game': 'basra', 'format': 'single_elimination', 'scope': 'global', 'status': 'open', 'players': 1, 'max_players': 4, 'entry_fee': 500, 'prize_pool': 3000, 'registered': true},
  {'id': 2, 'name': {'ar': 'كأس النادي', 'en': 'Club Cup'}, 'game': 'tarneeb', 'format': 'group_playoffs', 'scope': 'club', 'status': 'running', 'players': 4, 'max_players': 4, 'entry_fee': 0, 'prize_pool': 1000},
];

Widget app(String locale, Widget child) => MaterialApp(locale: Locale(locale),
  supportedLocales: const [Locale('ar'), Locale('en')], localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: r101Theme('midnight_cyan', '#25e4df', localeCode: locale),
  home: child is R12CompetitiveArenaPage ? child : Scaffold(body: child is R11ClubsWorldPage ? child : SingleChildScrollView(padding: const EdgeInsets.all(12), child: child)));

class FakeApi extends WarqnaApiClient {
  bool failDetails = false;
  int joins = 0;
  int detailsCalls = 0;
  int? acceptedFee;
  final pendingJoin = Completer<Map<String, dynamic>>();
  @override Future<Map<String, dynamic>> competitiveR12() async => {'competitive': {'enabled': true, 'tournaments': cups, 'rating': {}, 'season': {}, 'tiers': [], 'rewards': []}};
  @override Future<Map<String, dynamic>> competitiveLeaderboardR12({String? game, String? country, int? clubId, int limit = 100}) async => {'leaderboard': {'rows': []}};
  @override Future<Map<String, dynamic>> competitiveHistoryR12() async => {'matches': []};
  @override Future<Map<String, dynamic>> competitiveTournamentR12(int id) async {
    detailsCalls++;
    if (failDetails) throw const ApiException('Unavailable', statusCode: 503);
    return {'tournament': {...cups.first, 'registered': false}};
  }
  @override Future<Map<String, dynamic>> joinCompetitiveTournamentR12(int id, {int? expectedEntryFee}) {
    joins++; acceptedFee = expectedEntryFee; return pendingJoin.future;
  }
}
class FakeController extends AppController {
  FakeController(this.fake);
  final FakeApi fake;
  @override WarqnaApiClient get api => fake;
}

void main() {
  setUp(() { SharedPreferences.setMockInitialValues({}); AppSounds.enabled = false; });
  for (final locale in ['ar', 'en']) {
    for (final size in [const Size(320, 640), const Size(844, 390), const Size(1280, 800)]) {
      testWidgets('R21 directories $locale $size preserve server states and filters', (tester) async {
        tester.view.devicePixelRatio = 1; tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
        var joined = 0;
        await tester.pumpWidget(app(locale, R21ClubDirectory(clubs: clubs, locale: locale, allowJoin: true,
          onOpen: (_) {}, onJoin: (_) => joined++)));
        expect(tester.widget<FilledButton>(find.byKey(const ValueKey('r21-club-join-2'))).onPressed, isNull);
        expect(tester.widget<FilledButton>(find.byKey(const ValueKey('r21-club-join-3'))).onPressed, isNull);
        await tester.enterText(find.byKey(const ValueKey('r21-club-search')), 'Majlis'); await tester.pump();
        expect(find.byKey(const ValueKey('r21-club-2')), findsNothing);
        await tester.ensureVisible(find.byKey(const ValueKey('r21-club-join-1')));
        await tester.tap(find.byKey(const ValueKey('r21-club-join-1'))); expect(joined, 1);
        await tester.pumpWidget(app(locale, R21TournamentDirectory(cups: cups, locale: locale, onOpen: (_) {})));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('r21-cup-filter-mine'))); await tester.pump();
        expect(find.byKey(const ValueKey('r21-cup-1')), findsOneWidget);
        expect(find.byKey(const ValueKey('r21-cup-2')), findsNothing);
        await tester.enterText(find.byKey(const ValueKey('r21-cup-search')), 'no-match'); await tester.pump();
        expect(find.byType(R21TournamentCard), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('R21 failed detail refresh never exposes registration', (tester) async {
    final api = FakeApi()..failDetails = true;
    final controller = FakeController(api)..serverConnected = true..localeCode = 'en';
    addTearDown(controller.dispose);
    await tester.pumpWidget(app('en', R12CompetitiveArenaPage(controller: controller)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cups')); await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Warqnaa Cup'));
    await tester.tap(find.text('Warqnaa Cup')); await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('r21-cup-register')), findsNothing);
    expect(api.joins, 0); expect(api.detailsCalls, 1);
  });
  testWidgets('R21 confirmation sends accepted fee once and guards repeated taps', (tester) async {
    final api = FakeApi(); final controller = FakeController(api)..serverConnected = true..localeCode = 'en';
    addTearDown(controller.dispose);
    await tester.pumpWidget(app('en', R12CompetitiveArenaPage(controller: controller)));
    await tester.pumpAndSettle(); await tester.tap(find.text('Cups')); await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Warqnaa Cup'));
    await tester.tap(find.text('Warqnaa Cup')); await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('r21-cup-register')));
    await tester.tap(find.byKey(const ValueKey('r21-cup-register'))); await tester.pumpAndSettle();
    expect(api.joins, 0);
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.textContaining('Entry fee: 500 tokens')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('r21-cup-confirm'))); await tester.pumpAndSettle();
    expect(api.joins, 1); expect(api.acceptedFee, 500);
    await tester.tap(find.text('Warqnaa Cup')); await tester.pump();
    expect(find.byKey(const ValueKey('r21-cup-register')), findsNothing); expect(api.joins, 1);
    api.pendingJoin.complete({'ok': true}); await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('R21 offline clubs and arena keep mutation actions disabled', (tester) async {
    final controller = AppController()..localeCode = 'en'; addTearDown(controller.dispose);
    await tester.pumpWidget(app('en', R11ClubsWorldPage(controller: controller))); await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Found your club')).onPressed, isNull);
    await tester.pumpWidget(app('en', R12CompetitiveArenaPage(controller: controller))); await tester.pumpAndSettle();
    expect(find.textContaining('Preview only'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Find opponents')).onPressed, isNull);
  });
}
