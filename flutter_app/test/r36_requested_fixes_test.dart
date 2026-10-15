import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';
import 'package:warqna_mobile/services/api_client.dart';
import 'r8_play_experience_test.dart' show host;

class ClubDestinationApi extends WarqnaApiClient {
  int reads=0;
  int? joined;
  Map<String,dynamic> get club=>{'id':42,'name':'Actual server club','visibility':'public',
    'members_count':2,'capacity':50,'weekly_points':12,'league':{'en':'Gold','ar':'ذهبي'}};
  @override Future<Map<String,dynamic>> clubsWorldR11() async {
    reads++;return {'clubs':[club],'my_club':joined==null?null:club};
  }
  @override Future<Map<String,dynamic>> joinClubWorldR11(int clubId) async {
    joined=clubId;return {'ok':true,'status':'joined'};
  }
}

void main() {
  setUp(() { SharedPreferences.setMockInitialValues({}); AppSounds.enabled = false; });

  test('unequipped owned items remain visible; consumed or expired items do not', () {
    final controller = AppController();
    controller.syncPackInventoryV176([
      {'store_item':{'key':'owned_back'},'quantity':100,'active':false,'expires_at':null},
      {'store_item':{'key':'consumed_booster'},'quantity':0,'active':true},
      {'store_item':{'key':'expired_back'},'quantity':1,'active':false,'expires_at':'2020-01-01'},
    ]);
    expect(controller.owned, contains('owned_back'));
    expect(controller.owned, isNot(contains('consumed_booster')));
    expect(controller.owned, isNot(contains('expired_back')));
    controller.dispose();
  });

  test('device administrator receives exact virtual balance and the whole local catalogue', () async {
    final controller = AppController();
    await controller.loginAsLocalAdmin();
    expect(controller.coins.toString(),'9999999999999999999');
    expect(controller.owned, containsAll(products.map((item)=>item.id).toSet()));
    expect(controller.competitionTickets.values.every((count)=>count>=100),isTrue);
    expect(controller.serverConnected,isFalse);
    expect(controller.isPrimaryAdmin,isFalse);
    controller.dispose();
  });

  for (final id in ['tarneeb','syrian_tarneeb','tarneeb_400','trix','trix_partner','trix_complex','hand','hand_partner','saudi_hand','banakil','baloot','basra']) {
    testWidgets('visible play-now opens a live local $id table without a global navigator key', (tester) async {
      final controller = AppController()..isAuthenticated=true;
      final game = gamesCatalog.firstWhere((game)=>game.id==id);
      await tester.pumpWidget(AnimatedBuilder(animation:controller,builder:(_,__)=>host(Scaffold(body: Builder(builder:(context)=>TextButton(
        onPressed:()=>showGameLobby(context,controller,game), child:const Text('open'),
      ))),'ar')));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(ValueKey('r36-play-now-$id')));
      await tester.tap(find.byKey(ValueKey('r36-play-now-$id')));
      await tester.pump();
      await tester.pump(const Duration(seconds:1));
      expect(controller.activeGame,id);
      expect(find.byType(GameRoomPage),findsOneWidget);
      expect(controller.activeGame,id);
      expect(tester.takeException(),isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds:6));
      controller.dispose();
    });
  }

  for (final width in [320.0,390.0,800.0]) {
  testWidgets('administrator opens a usable command center at width $width', (tester) async {
    tester.view.physicalSize=Size(width,844);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    final controller = AppController()..isAuthenticated=true..isAdmin=true..adminRole='primary_admin';
    await tester.pumpWidget(host(HomeShell(controller:controller),'ar'));
    await tester.pump();
    expect(find.byKey(const ValueKey('r36-open-admin-center')),findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('r36-open-admin-center')));
    await tester.pump();
    await tester.pump(const Duration(seconds:1));
    expect(find.byType(AdminDashboardPage),findsOneWidget);
    expect(tester.takeException(),isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
  }

  testWidgets('meld workspace selects two identical physical runs independently',(tester) async {
    List<List<String>>? submitted;
    await tester.pumpWidget(host(Scaffold(body:Builder(builder:(context)=>TextButton(
      onPressed:()async{submitted=await showDialog<List<List<String>>>(context:context,
        builder:(_)=>const R36MeldWorkspace(cards:['3_spades','3_spades','4_spades','4_spades','5_spades','5_spades'],ar:true));},
      child:const Text('compose'),
    ))),'ar'));
    await tester.tap(find.text('compose'));await tester.pumpAndSettle();
    for(final indices in [[0,2,4],[1,3,5]]) {
      for(final index in indices) {await tester.tap(find.byKey(ValueKey('r36-meld-card-$index')));await tester.pump();}
      await tester.tap(find.byKey(const ValueKey('r36-add-meld-group')));await tester.pump();
    }
    await tester.ensureVisible(find.byKey(const ValueKey('r36-submit-meld-groups')));
    await tester.tap(find.byKey(const ValueKey('r36-submit-meld-groups')));await tester.pumpAndSettle();
    expect(submitted,[['3_spades','4_spades','5_spades'],['3_spades','4_spades','5_spades']]);
    expect(tester.takeException(),isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('home club destination lists and joins real server clubs',(tester) async {
    final api=ClubDestinationApi();
    final controller=AppController(api:api)..serverConnected=true;
    await tester.pumpWidget(host(ClubsPage(controller:controller),'ar'));
    await tester.pumpAndSettle();
    expect(find.byType(R11ClubsWorldPage),findsOneWidget);
    expect(find.text('Actual server club'),findsOneWidget);
    final join=find.byKey(const ValueKey('r21-club-join-42'));
    await tester.ensureVisible(join);await tester.pumpAndSettle();
    await tester.tap(join);await tester.pumpAndSettle();
    expect(api.joined,42);expect(api.reads,2);
    expect(find.text('Actual server club'),findsNWidgets(2));
    expect(tester.takeException(),isNull);
    await tester.pumpWidget(const SizedBox.shrink());controller.dispose();
  });
}
