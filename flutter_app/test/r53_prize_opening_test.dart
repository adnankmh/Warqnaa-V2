import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';
import 'r7_runtime_review_test.dart' as review;

const reward = <String,dynamic>{'type':'ticket','value':'500',
  'label_ar':'تذكرة مسابقة 500','label_en':'Competition ticket 500'};

Widget host(AppController controller, GlobalKey key, Widget child,
    {double scale=1, bool reduced=false}) => RepaintBoundary(key:key, child:MaterialApp(
  debugShowCheckedModeBanner:false, locale:Locale(controller.localeCode),
  supportedLocales:const [Locale('ar'),Locale('en')],
  localizationsDelegates:GlobalMaterialLocalizations.delegates,
  theme:review.reviewTheme(controller),
  builder:(context,child)=>MediaQuery(data:MediaQuery.of(context).copyWith(
    textScaler:TextScaler.linear(scale),disableAnimations:reduced),child:child!),
  home:child,
));

Widget launcher(String locale,String box) => Scaffold(body:Builder(builder:(context)=>TextButton(
  onPressed:()=>showDialog<void>(context:context,barrierDismissible:false,
    builder:(_)=>PrizeBoxOpeningDialogV02(locale:locale,boxKey:box,reward:reward)),
  child:const Text('open'),
)));

void expectSeparated(WidgetTester tester) {
  final stage=tester.getRect(find.byKey(const ValueKey('r53-prize-stage')));
  final summary=tester.getRect(find.byKey(const ValueKey('r53-prize-summary-viewport')));
  expect(stage.width,greaterThan(0));expect(stage.height,greaterThan(0));
  expect(stage.overlaps(summary),isFalse,reason:'Artwork must never cover the reward description or controls.');
  final art=tester.getRect(find.byKey(const ValueKey('r53-prize-reward-art')));
  expect(stage.inflate(.5).contains(art.topLeft),isTrue);
  expect(stage.inflate(.5).contains(art.bottomRight),isTrue);
  expect(tester.takeException(),isNull);
}

void main() {
  setUp(() {SharedPreferences.setMockInitialValues({});AppSounds.enabled=false;});
  setUpAll(() async {
    if(review.reviewDirectory.isEmpty)return;
    final bytes=await File(const String.fromEnvironment('R7_REVIEW_FONT')).readAsBytes();
    for(final family in ['R7Review','Roboto']) {
      await (FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }
    final material=await File(const String.fromEnvironment('R7_MATERIAL_FONT')).readAsBytes();
    await (FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(material)))).load();
    const emoji=String.fromEnvironment('R7_EMOJI_FONT');
    if(emoji.isNotEmpty) {
      final data=await File(emoji).readAsBytes();
      await (FontLoader('R7Emoji')..addFont(Future.value(ByteData.sublistView(data)))).load();
    }
  });
  for(final locale in ['ar','en']) {
    for(final size in [const Size(320,568),const Size(390,844),const Size(600,800),
        const Size(844,390),const Size(1440,900)]) {
      for(final box in prizeBoxKeysV02) {
        testWidgets('R53 registered chest $box $locale $size',(tester) async {
          tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
          addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
          final controller=AppController()..localeCode=locale;
          addTearDown(controller.dispose);
          final key=GlobalKey();
          await tester.pumpWidget(host(controller,key,launcher(locale,box)));
          await tester.tap(find.text('open'));await tester.pump();
          await tester.pump(const Duration(milliseconds:250));
          expectSeparated(tester);
          final body=tester.getRect(find.byKey(const ValueKey('r53-prize-sprite-body')));
          expect(tester.getRect(find.byKey(const ValueKey('r53-prize-sprite-front_panel'))),body);
          expect(tester.getRect(find.byKey(const ValueKey('r53-prize-sprite-lid'))),body,
            reason:'Closed sprites use the same original 720x540 registration canvas.');
          expect(tester.widget<FilledButton>(find.byKey(const ValueKey('r53-prize-continue'))).onPressed,isNull);
          await tester.pump(const Duration(seconds:3));expectSeparated(tester);
          final capture=box=='emerald_eagle' && review.reviewDirectory.isNotEmpty;
          final name='$locale-r53-${size.width.toInt()}x${size.height.toInt()}';
          if(capture && (size.width==320 || size.width==844)) await review.capture(tester,key,'$name-opening');
          await tester.pump(const Duration(seconds:3));expectSeparated(tester);
          expect(find.byKey(const ValueKey('r53-prize-skip')),findsNothing);
          expect(tester.widget<Text>(find.byKey(const ValueKey('r53-prize-description'))).data,
            prizeRewardLabelV02(locale,reward));
          if(capture)await review.capture(tester,key,'$name-reward');
          final close=find.byKey(const ValueKey('r53-prize-continue'));
          await tester.ensureVisible(close);await tester.pump();await tester.tap(close);
          await tester.pumpAndSettle();
          expect(find.byType(PrizeBoxOpeningDialogV02),findsNothing);
          expect(tester.takeException(),isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
      for(final reduced in [false,true]) {
        if(size.width!=320 && size.width!=844)continue;
        testWidgets('R53 large text and reduced=$reduced $locale $size',(tester) async {
          tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
          addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
          final controller=AppController()..localeCode=locale;addTearDown(controller.dispose);
          final key=GlobalKey();
          await tester.pumpWidget(host(controller,key,launcher(locale,'diamond_phoenix'),scale:1.6,reduced:reduced));
          await tester.tap(find.text('open'));await tester.pump();await tester.pump(const Duration(milliseconds:250));
          expectSeparated(tester);
          if(reduced) {
            expect(find.byKey(const ValueKey('r53-prize-skip')),findsNothing);
          } else {
            final skip=find.byKey(const ValueKey('r53-prize-skip'));
            await tester.ensureVisible(skip);await tester.pump();await tester.tap(skip);await tester.pump();
          }
          final close=find.byKey(const ValueKey('r53-prize-continue'));
          expect(tester.widget<FilledButton>(close).onPressed,isNotNull);
          await tester.ensureVisible(close);await tester.pump();
          expect(close.hitTestable(),findsOneWidget);
          if(review.reviewDirectory.isNotEmpty && reduced) {
            await review.capture(tester,key,'$locale-r53-large-text-${size.width.toInt()}x${size.height.toInt()}');
          }
          await tester.tap(close);await tester.pumpAndSettle();
          expect(find.byType(PrizeBoxOpeningDialogV02),findsNothing);
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
    testWidgets('R53 skipping a real prize opening never settles the reward twice $locale',(tester) async {
      tester.view.physicalSize=const Size(390,844);tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
      final controller=AppController()..localeCode=locale;
      addTearDown(controller.dispose);controller.awardLocalPrizeBoxV02('hand');
      final key=GlobalKey();
      await tester.pumpWidget(host(controller,key,PrizeBoxesPageV02(controller:controller)));
      await tester.pump();await tester.pump(const Duration(milliseconds:250));
      final box=controller.prizeBoxesTodayV02.first;
      await tester.tap(find.byKey(ValueKey('r52-open-prize-box-${box['id']}')));
      for(var i=0;i<15 && find.byType(PrizeBoxOpeningDialogV02).evaluate().isEmpty;i++) {
        await tester.pump(const Duration(milliseconds:100));
      }
      expect(find.byType(PrizeBoxOpeningDialogV02),findsOneWidget);
      final balance=controller.coins;
      final settled=controller.prizeBoxesTodayV02.first['opened_at'];expect(settled,isNotNull);
      final skip=find.byKey(const ValueKey('r53-prize-skip'));
      await tester.ensureVisible(skip);await tester.pump();await tester.tap(skip);await tester.pump();
      final close=find.byKey(const ValueKey('r53-prize-continue'));
      await tester.ensureVisible(close);await tester.pump();await tester.tap(close);await tester.pumpAndSettle();
      expect(controller.coins,balance);expect(controller.prizeBoxesTodayV02.first['opened_at'],settled);
      expect(tester.widget<FilledButton>(find.byKey(ValueKey('r52-open-prize-box-${box['id']}'))).onPressed,isNull);
      expect(tester.takeException(),isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
