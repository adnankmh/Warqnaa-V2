import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';
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
  test('R52 landscape source backs rotate to portrait while approved portraits stay upright',() {
    expect(r52CardBackQuarterTurns('assets/optimized/r10/tables/v173/royal/table_v173_royal_03.webp'),1);
    expect(r52CardBackQuarterTurns('assets/optimized/r48/ocean_portrait.webp'),0);
    expect(r52CardBackQuarterTurns('assets/optimized/r10/cardbacks/v021/cardback_v021_whale.webp'),0);
  });
  testWidgets('R52 previous round points remain visible after automatic next-round transition',(tester) async {
    await tester.pumpWidget(MaterialApp(home:Scaffold(body:R52RoundScoreCard(
      state:const {'round':2,'round_results':[{'round':1,'delta':{'user:0':-30,'bot:1':126}}]},
      players:const [{'key':'user:0','name':'Player'},{'key':'bot:1','name':'Bot'}],ar:false))));
    expect(find.text('Player: -30'),findsOneWidget);
    expect(find.text('Bot: +126'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });
}
