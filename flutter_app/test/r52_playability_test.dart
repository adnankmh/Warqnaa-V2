import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppSounds.enabled=false;
  });
  for(final locale in ['ar','en']) {
    testWidgets('R52 rewards are reachable through real wheel and box routes $locale',(tester) async {
      tester.view.physicalSize=const Size(390,844);
      tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller=AppController()..localeCode=locale;
      addTearDown(controller.dispose);
      await tester.pumpWidget(MaterialApp(home:Scaffold(body:SingleChildScrollView(
        child:R52RewardsHomePanel(controller:controller)))));
      await tester.tap(find.byKey(const ValueKey('r52-open-wheel')));
      await tester.pump(const Duration(seconds:1));
      expect(find.byType(LuckyWheelPageV182),findsOneWidget);
      final context=tester.element(find.byType(LuckyWheelPageV182));
      Navigator.of(context).pop();
      await tester.pump(const Duration(seconds:1));
      await tester.tap(find.byKey(const ValueKey('r52-open-boxes')));
      await tester.pump(const Duration(seconds:1));
      expect(find.byType(PrizeBoxesPageV02),findsOneWidget);
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
}
