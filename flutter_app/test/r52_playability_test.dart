import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';
import 'package:warqna_mobile/engines/local_game_engine.dart';
import 'package:warqna_mobile/models/room_launch_options.dart';
import 'r7_runtime_review_test.dart' as review;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppSounds.enabled=false;
  });
  setUpAll(() async {
    if(review.reviewDirectory.isEmpty)return;
    final bytes=await File(const String.fromEnvironment('R7_REVIEW_FONT')).readAsBytes();
    for(final family in ['R7Review','Roboto']) {
      await (FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }
    await (FontLoader('MaterialIcons')..addFont(File(const String.fromEnvironment('R7_MATERIAL_FONT')).readAsBytes().then((b)=>ByteData.sublistView(b)))).load();
    const emoji=String.fromEnvironment('R7_EMOJI_FONT');
    if(emoji.isNotEmpty)await (FontLoader('R7Emoji')..addFont(File(emoji).readAsBytes().then((b)=>ByteData.sublistView(b)))).load();
  });
  for(final locale in ['ar','en']) {
    testWidgets('R52 rewards are reachable through real wheel and box routes $locale',(tester) async {
      tester.view.physicalSize=const Size(390,844);
      tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller=AppController()..localeCode=locale;
      controller.awardLocalPrizeBoxV02('hand');
      addTearDown(controller.dispose);
      final key=GlobalKey();
      await tester.pumpWidget(review.reviewApp(Scaffold(body:SingleChildScrollView(
        child:R52RewardsHomePanel(controller:controller))),controller,key));
      if(review.reviewDirectory.isNotEmpty)await review.capture(tester,key,'$locale-r52-rewards-home-390x844');
      await tester.tap(find.byKey(const ValueKey('r52-open-wheel')));
      await tester.pump();
      await tester.pump(const Duration(seconds:1));
      expect(find.byType(LuckyWheelPageV182),findsOneWidget);
      if(review.reviewDirectory.isNotEmpty)await review.capture(tester,key,'$locale-r52-wheel-390x844');
      final context=tester.element(find.byType(LuckyWheelPageV182));
      Navigator.of(context).pop();
      await tester.pump();
      await tester.pump(const Duration(seconds:1));
      await tester.tap(find.byKey(const ValueKey('r52-open-boxes')));
      await tester.pump();
      await tester.pump(const Duration(seconds:1));
      expect(find.byType(PrizeBoxesPageV02),findsOneWidget);
      if(review.reviewDirectory.isNotEmpty)await review.capture(tester,key,'$locale-r52-boxes-390x844');
      final open=find.byKey(ValueKey('r52-open-prize-box-${controller.prizeBoxesTodayV02.first['id']}'));
      await tester.ensureVisible(open);await tester.pump();await tester.tap(open);
      for(var frame=0;frame<15 && find.byType(PrizeBoxOpeningDialogV02).evaluate().isEmpty;frame++) {await tester.pump(const Duration(milliseconds:100));}
      expect(find.byType(PrizeBoxOpeningDialogV02),findsOneWidget);
      if(review.reviewDirectory.isNotEmpty)await review.capture(tester,key,'$locale-r52-box-opening-390x844');
      await tester.pump(const Duration(seconds:6));
      if(review.reviewDirectory.isNotEmpty)await review.capture(tester,key,'$locale-r52-box-reward-390x844');
      expect(controller.prizeBoxesTodayV02.first['opened_at'],isNotNull);
      expect(tester.takeException(),isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
    testWidgets('R52 finished match offers a working exit $locale',(tester) async {
      var exited=false;
      await tester.pumpWidget(MaterialApp(home:Scaffold(body:R52MatchResult(
        ar:locale=='ar',won:true,points:'+20',onExit:()=>exited=true))));
      expect(find.byIcon(Icons.emoji_events_rounded),findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('r52-exit-finished-game')));
      expect(exited,isTrue);
      expect(tester.takeException(),isNull);
    });
  }
  test('R52 every server suit is rendered with a visible symbol',() {
    expect(r52CardLabel('A_spades'),'A♠');
    expect(r52CardLabel('10_hearts'),'10♥');
    expect(r52CardLabel('Q_diamonds'),'Q♦');
    expect(r52CardLabel('K_clubs'),'K♣');
  });
  test('R52 result follows the real server identity and partnership instead of user zero',() {
    const players=[{'key':'user:41','seat':0},{'key':'user:72','seat':1},{'key':'user:93','seat':2},{'key':'bot:4','seat':3}];
    expect(r52PlayerWon({'winner':'user:41'},you:'user:41',players:players),isTrue);
    expect(r52PlayerWon({'winner':'user:93'},you:'user:41',players:players),isFalse);
    expect(r52PlayerWon({'winner':0,'winner_team':'teamA'},you:'user:93',players:players),isTrue);
    expect(r52PlayerWon({'winner':0,'winner_team':'teamA'},you:'user:72',players:players),isFalse);
    expect(r52PlayerWon({'winner':'bot:1'},you:'user:0',players:const []),isFalse);
  });
  test('R52 landscape source backs rotate to portrait while approved portraits stay upright',() {
    expect(r52CardBackQuarterTurns('assets/optimized/r10/tables/v173/royal/table_v173_royal_03.webp'),1);
    expect(r52CardBackQuarterTurns('assets/optimized/r48/ocean_portrait.webp'),0);
    expect(r52CardBackQuarterTurns('assets/optimized/r10/cardbacks/v021/cardback_v021_whale.webp'),0);
  });
  testWidgets('R52 all six chests include their actual body, lid, front and full artwork',(tester) async {
    for(final key in prizeBoxKeysV02) {
      for(final suffix in ['','body','lid','front_panel']) {
        final bytes=await rootBundle.load(prizeBoxAssetV02(key,suffix));
        expect(bytes.lengthInBytes,greaterThan(1000),reason:'A restored chest must ship all of its actual opening sprites.');
      }
    }
  });
  testWidgets('R52 previous round points remain visible after automatic next-round transition',(tester) async {
    await tester.pumpWidget(MaterialApp(home:Scaffold(body:R52RoundScoreCard(
      state:const {'round':2,'round_results':[{'round':1,'delta':{'user:0':-30,'bot:1':126}}]},
      players:const [{'key':'user:0','name':'Player'},{'key':'bot:1','name':'Bot'}],ar:false))));
    expect(find.text('Player: -30'),findsOneWidget);
    expect(find.text('Bot: +126'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });
  for(final locale in ['ar','en']) {
    for(final size in [const Size(390,844),const Size(1440,900)]) {
      testWidgets('R52 actual completed Hand route exits to Games $locale $size',(tester) async {
        tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
        addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
        final controller=AppController()..localeCode=locale;
        addTearDown(controller.dispose);
        final key=GlobalKey();
        final game=gamesCatalog.firstWhere((g)=>g.id=='hand');
        await tester.pumpWidget(review.reviewApp(Scaffold(body:Builder(builder:(context)=>TextButton(
          key:const ValueKey('r52-launch-hand'),onPressed:()=>Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>
            GameRoomPage(controller:controller,game:game,options:const RoomLaunchOptions(playerCount:2,singleRound:true,turnSeconds:120)))),
          child:const Text('Games')))),controller,key));
        await tester.tap(find.byKey(const ValueKey('r52-launch-hand')));
        await tester.pump();await tester.pump(const Duration(seconds:1));
        final dynamic table=tester.state(find.byType(ServerEngineRoomPage));
        final session=LocalGameSession(gameId:'hand',humanName:'Player',localeCode:locale,playerCount:2,seed:52);
        for(var step=0;step<1000 && !session.gameOver;step++) {session.timeout();}
        expect(session.gameOver,isTrue);
        table.localSession=session;table.room=session.room();table.loading=false;table.seconds=120;
        table.setState(() {});await tester.pump();
        final exit=find.byKey(const ValueKey('r52-exit-finished-game'));
        await tester.ensureVisible(exit);await tester.pump(const Duration(seconds:1));
        expect(exit.hitTestable(),findsOneWidget);
        expect(find.byKey(const ValueKey('r52-round-points')),findsOneWidget);
        if(review.reviewDirectory.isNotEmpty)await review.capture(tester,key,'$locale-r52-finished-hand-${size.width.toInt()}x${size.height.toInt()}');
        await tester.tap(exit);await tester.pump();await tester.pump(const Duration(seconds:1));
        expect(find.byType(ServerEngineRoomPage),findsNothing);
        expect(find.byKey(const ValueKey('r52-launch-hand')),findsOneWidget);
        expect(controller.activeGame,isNull);
        expect(tester.takeException(),isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
  testWidgets('R52 catalogue cutouts preserve a transparent exterior and an interior playing area',(tester) async {
    for(final size in [const Size(360,560),const Size(800,480)]) {
      for(final showcase in [true,false]) {
        final path=R52TableOutline(showcase:showcase).getClip(size);
        expect(path.contains(Offset(size.width/2,size.height/2)),isTrue);
        expect(path.contains(Offset.zero),isFalse);
        expect(path.contains(Offset(size.width-1,1)),isFalse);
      }
    }
  });
  final tables=products.where((p)=>isR61CuratedTable(p) && p.imageAsset!=null).toList();
  for(var page=0;page<(tables.length/12).ceil();page++) {
    testWidgets('R52 actual catalogue table gallery page $page',(tester) async {
      tester.view.physicalSize=const Size(1440,900);tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
      final controller=AppController()..localeCode='ar'..tableAmbientEffects=false;
      addTearDown(controller.dispose);final key=GlobalKey();
      final group=tables.skip(page*12).take(12).toList();
      await tester.pumpWidget(review.reviewApp(Scaffold(body:GridView.count(
        padding:const EdgeInsets.all(16),crossAxisCount:4,childAspectRatio:1.42,crossAxisSpacing:14,mainAxisSpacing:14,
        children:[for(final product in group)Column(children:[
          Expanded(child:WarqnaaTableSurface(trump:null,phase:'playing',skinId:product.id,controller:controller)),
          Text(product.nameAr,style:const TextStyle(fontSize:14,color:Colors.white)),
        ])])),controller,key));
      await tester.pump();
      expect(find.byType(WarqnaaTableSurface),findsNWidgets(group.length));
      if(review.reviewDirectory.isNotEmpty)await review.capture(tester,key,'ar-r52-catalogue-tables-$page');
      expect(tester.takeException(),isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
