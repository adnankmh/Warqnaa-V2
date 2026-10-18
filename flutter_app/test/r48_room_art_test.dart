import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';
import 'package:warqna_mobile/services/api_client.dart';
import 'r8_play_experience_test.dart' show host;

class R48CommerceApi extends WarqnaApiClient {
  @override
  Future<Map<String,dynamic>> commerceCatalogR101() async => {'commerce': {'packages': [
    {'key':'featured-only','tokens':1200,'price_minor':99,'categories':['featured','tokens']},
    {'key':'weekly-only','tokens':6000,'price_minor':399,'categories':['weekly','tokens']},
  ]}};
}

void main() {
  setUp(() { SharedPreferences.setMockInitialValues({}); AppSounds.enabled=false; });
  for (final locale in ['ar','en']) {
    for (final gameId in ['hand','banakil']) {
      for (final size in [const Size(320,640),const Size(844,390)]) {
        testWidgets('friendly creates real $gameId room $locale $size without a global key',(tester) async {
          tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
          addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
          final controller=AppController()..localeCode=locale..isAuthenticated=true;
          final game=gamesCatalog.firstWhere((game)=>game.id==gameId);
          await tester.pumpWidget(host(Scaffold(body:Builder(builder:(context)=>TextButton(
            onPressed:()=>showGameLobby(context,controller,game),child:const Text('open'),
          ))),locale));
          await tester.tap(find.text('open'));await tester.pumpAndSettle();
          await tester.ensureVisible(find.text(L.t(locale,'friendly')));
          await tester.tap(find.text(L.t(locale,'friendly')));await tester.pumpAndSettle();
          expect(find.byKey(const ValueKey('r48-create-room-settings')),findsOneWidget);
          await tester.ensureVisible(find.byKey(const ValueKey('r48-room-name')));
          await tester.enterText(find.byKey(const ValueKey('r48-room-name')),'R48 actual room');
          final single=find.text(locale=='ar'?'مباراة من جولة واحدة فقط':'Single-round match');
          await tester.ensureVisible(single);await tester.tap(single);await tester.pump();
          final submit=find.byKey(const ValueKey('r48-create-room-submit'));
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          await tester.ensureVisible(submit);
          await tester.pumpAndSettle();
          await tester.tap(submit);
          await tester.pump();await tester.pump(const Duration(seconds:1));
          final room=tester.widget<GameRoomPage>(find.byType(GameRoomPage));
          expect(room.game.id,gameId);expect(room.options.roomName,'R48 actual room');
          expect(room.options.singleRound,isTrue);
          expect(room.options.playerCount,v170AllowedPlayerCounts(gameId).first);
          expect(controller.activeGame,gameId);expect(tester.takeException(),isNull);
          await tester.pumpWidget(const SizedBox.shrink());await tester.pump(const Duration(seconds:6));
          controller.connectivityTimerV173?.cancel();controller.dispose();
        });
      }
    }
    testWidgets('cash tabs filter actual server packages $locale',(tester) async {
      tester.view.physicalSize=const Size(390,844);tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
      final controller=AppController(api:R48CommerceApi())..localeCode=locale;
      await tester.pumpWidget(host(B307CashShopPage(controller:controller),locale));
      await tester.pumpAndSettle();
      final weekly=find.widgetWithText(ChoiceChip,locale=='ar'?'الأسبوع':'Weekly');
      await tester.ensureVisible(weekly);await tester.tap(weekly);await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('r48-cash-offer-featured-only')),findsNothing);
      expect(find.byKey(const ValueKey('r48-cash-offer-weekly-only')),findsOneWidget);
      final tile=tester.widget<Container>(find.byKey(const ValueKey('r48-cash-offer-weekly-only')));
      expect((tile.decoration! as BoxDecoration).gradient,isNull);
      expect(tester.takeException(),isNull);
      await tester.pumpWidget(const SizedBox.shrink());controller.dispose();
    });
  }
  test('paired backs resolve to upright artwork without changing catalogue identity',() {
    for(final entry in r48ApprovedTables.entries) {
      expect(r48TableDesign('r61_cardback_${entry.key}'),entry.value);
      expect(r48TableAsset(entry.value,portrait:true),endsWith('_portrait.webp'));
    }
    expect(r48TableDesign(v305PremiumTableId),isNull);
  });
}
