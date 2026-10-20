import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/api_client.dart';
import 'package:warqna_mobile/services/app_sounds.dart';
import 'r7_runtime_review_test.dart' as review;
import 'helpers/r54_clubs_fakes.dart';

// Cross-platform synthetic fixtures are shared with the Chrome route tests.

Widget app(AppController controller,GlobalKey key,{double scale=1}) => review.reviewApp(
  Builder(builder:(context)=>MediaQuery(data:MediaQuery.of(context).copyWith(textScaler:TextScaler.linear(scale)),
    child:ClubsPage(controller:controller))),controller,key);

double contrast(Color a,Color b) {
  final x=a.computeLuminance(),y=b.computeLuminance();
  return (x>y?x+.05:y+.05)/(x>y?y+.05:x+.05);
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
  });

  test('R54 unknown discovery states fail closed without inventing membership',() {
    final base=catalogue('en').first;
    expect(r54ClubAvailable(base),isTrue);
    for(final changes in <Map<String,dynamic>>[
      {'visibility':'private'},{'visibility':'unverified'},{'visibility':null},{'capacity':0},
      {'members_count':20},{'members_count':-1},{'id':0},{'membership':{'role':'member'}},
      {'join_request_pending':true},
    ]) {expect(r54ClubAvailable({...base,...changes}),isFalse,reason:changes.toString());}
  });

  for(final locale in ['ar','en']) {
    for(final size in [const Size(320,568),const Size(390,844),const Size(844,390)]) {
      for(final scale in [1.0,1.6]) {
        testWidgets('R54 round XP long names remain bounded $locale $size text $scale',(tester) async {
          tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
          addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
          final controller=AppController()..localeCode=locale;addTearDown(controller.dispose);
          final key=GlobalKey();final name=locale=='ar'?'فارس المجلس وصاحب الاسم الطويل جدًا للاختبار':'A very long player name in the royal card club';
          await tester.pumpWidget(review.reviewApp(Scaffold(body:Builder(builder:(context)=>MediaQuery(
            data:MediaQuery.of(context).copyWith(textScaler:TextScaler.linear(scale)),
            child:Align(alignment:Alignment.topCenter,child:Padding(padding:const EdgeInsets.all(16),
              child:RoundXpBannerV174(notices:[
                RoundXpNoticeV174(name:name,avatar:'A',earnedXp:123456,roundPoints:2000,level:100),
                const RoundXpNoticeV174(name:'Second player',avatar:'B',earnedXp:654321,roundPoints:12345,level:99),
              ]))),
          ))),controller,key));
          await tester.pumpAndSettle();
          final notice=tester.getRect(find.byKey(ValueKey('r54-round-xp-$name')));
          expect(notice.left,greaterThanOrEqualTo(15));expect(notice.right,lessThanOrEqualTo(size.width-15));
          expect(find.text('+123456 XP'),findsOneWidget);
          expect(find.text('+2000 ${locale=='ar'?'نقطة':'points'}'),findsOneWidget);
          expect(tester.takeException(),isNull);
          if(review.reviewDirectory.isNotEmpty && scale==1.6 && size.width!=390) {
            await review.capture(tester,key,'$locale-r54-round-xp-${size.width.toInt()}x${size.height.toInt()}');
          }
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
    for(final size in [const Size(320,568),const Size(390,844),const Size(600,800),
        const Size(844,390),const Size(1440,900)]) {
      for(final scale in [1.0,1.6]) {
        testWidgets('R54 actual clubs route $locale $size text $scale',(tester) async {
          final semantics=tester.ensureSemantics();
          try {
          tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
          addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
          final api=ClubsApi(locale);
          // Keep a single fake behind the actual ClubsPage API boundary.
          final live=ClubsController(api)..localeCode=locale..serverConnected=true;
          addTearDown(live.dispose);
          final key=GlobalKey();await tester.pumpWidget(app(live,key,scale:scale));await tester.pumpAndSettle();
          expect(find.byType(ClubsPage),findsOneWidget);expect(api.loads,1);
          expect(find.byKey(const ValueKey('r54-clubs-header')),findsOneWidget);
          final dimensions='${size.width.toInt()}x${size.height.toInt()}';
          if(review.reviewDirectory.isNotEmpty && scale==1) {
            await review.capture(tester,key,'$locale-r54-clubs-header-$dimensions');
          }
          final first=find.byKey(const ValueKey('r21-club-1'));
          await revealClubWidget(tester,first);await tester.pumpAndSettle();
          final rect=tester.getRect(first),second=tester.getRect(find.byKey(const ValueKey('r21-club-2')));
          final columns=size.width-28>=1000?3:size.width-28>=650?2:1;
          expect(rect.width,closeTo((size.width-28-(columns-1)*12)/columns,.5));
          if(columns==1) {expect(second.top,greaterThanOrEqualTo(rect.bottom+11));}
          else {expect(second.top,closeTo(rect.top,.5));expect(locale=='ar'?rect.left>second.left:rect.left<second.left,isTrue);}
          final title=tester.widget<Text>(find.byKey(const ValueKey('r54-club-name-1')));
          expect(title.style!.fontSize,20);expect(contrast(title.style!.color!,R35ReferenceColors.navy),greaterThanOrEqualTo(7));
          final join=find.byKey(const ValueKey('r21-club-join-1'));
          await revealClubWidget(tester,join);await tester.pumpAndSettle();
          expect(tester.getSize(join).height,greaterThanOrEqualTo(48));
          final style=tester.widget<FilledButton>(join).style!;
          expect(contrast(style.foregroundColor!.resolve({})!,style.backgroundColor!.resolve({})!),greaterThanOrEqualTo(7));
          expect(contrast(style.foregroundColor!.resolve({WidgetState.disabled})!,style.backgroundColor!.resolve({WidgetState.disabled})!),greaterThanOrEqualTo(7));
          if(review.reviewDirectory.isNotEmpty && (scale==1 || size.width==320 || size.width==844)) {
            await review.capture(tester,key,'$locale-r54-clubs-card-$dimensions-text${scale==1?1:16}');
          }
          for(final id in [3,4]) {
            expect(tester.widget<FilledButton>(find.byKey(ValueKey('r21-club-join-$id'))).onPressed,isNull);
          }
          final search=find.byKey(const ValueKey('r21-club-search'));
          await revealClubWidget(tester,search);await tester.enterText(search,locale=='ar'?'فرسان':'KNIGHTS');await tester.pump();
          expect(find.byKey(const ValueKey('r21-club-2')),findsNothing);
          expect(tester.widget<Text>(find.byKey(const ValueKey('r54-club-count'))).data,r21ClubCountLabel(locale,1));
          await tester.enterText(search,'');await tester.pump();
          final filter=find.byKey(const ValueKey('r21-club-available'));
          await revealClubWidget(tester,filter);await tester.tap(filter);await tester.pump();
          expect(find.byKey(const ValueKey('r21-club-3')),findsNothing);
          expect(find.byKey(const ValueKey('r21-club-4')),findsNothing);
          expect(tester.widget<Text>(find.byKey(const ValueKey('r54-club-count'))).data,r21ClubCountLabel(locale,2));
          expect(api.joins,0);expect(api.loads,1);expect(tester.takeException(),isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          } finally {semantics.dispose();}
        });
      }
    }
    testWidgets('R54 actual request join stays pending and details open $locale',(tester) async {
      final api=ClubsApi(locale),key=GlobalKey();
      final controller=ClubsController(api)..localeCode=locale..serverConnected=true;addTearDown(controller.dispose);
      final coins=controller.coins;
      await tester.pumpWidget(app(controller,key));await tester.pumpAndSettle();
      final request=find.byKey(const ValueKey('r21-club-join-2'));
      await revealClubWidget(tester,request);await tester.tap(request);await tester.pumpAndSettle();
      expect(api.joins,1);expect(api.pending,2);
      expect(tester.widget<FilledButton>(request).onPressed,isNull);
      expect(find.descendant(of:request,matching:find.text(locale=='ar'?'الطلب قيد المراجعة':'Request pending')),findsOneWidget);
      final card=find.byKey(const ValueKey('r21-club-1'));
      await revealClubWidget(tester,card);await tester.tap(find.byKey(const ValueKey('r54-club-name-1')));await tester.pumpAndSettle();
      expect(api.details,1);expect(find.byType(DraggableScrollableSheet),findsOneWidget);
      Navigator.of(tester.element(find.byType(ClubsPage))).pop();await tester.pumpAndSettle();
      expect(controller.coins,coins);expect(tester.takeException(),isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
    testWidgets('R54 actual join locks repeated taps until server response $locale',(tester) async {
      final api=ClubsApi(locale)..joinResponse=Completer<Map<String,dynamic>>();
      final controller=ClubsController(api)..localeCode=locale..serverConnected=true;addTearDown(controller.dispose);
      final coins=controller.coins;await tester.pumpWidget(app(controller,GlobalKey()));await tester.pumpAndSettle();
      final join=find.byKey(const ValueKey('r21-club-join-1'));
      await revealClubWidget(tester,join);await tester.tap(join);await tester.pump();await tester.tap(join);await tester.pump();
      expect(api.joins,1);expect(api.joined,isNull);
      for(final id in [1,2]) {
        expect(tester.widget<FilledButton>(find.byKey(ValueKey('r21-club-join-$id'))).onPressed,isNull);
      }
      expect(find.descendant(of:join,matching:find.text(locale=='ar'?'جارٍ الإرسال…':'Sending…')),findsOneWidget);
      api.joined=1;api.joinResponse!.complete({'ok':true,'status':'accepted'});await tester.pumpAndSettle();
      expect(api.loads,2);expect(api.joins,1);expect(controller.coins,coins);
      expect(tester.widget<FilledButton>(join).onPressed,isNull);expect(tester.takeException(),isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
    testWidgets('R54 stale clubs cannot open or join during failed refresh $locale',(tester) async {
      final api=ClubsApi(locale);
      final live=ClubsController(api)..localeCode=locale..serverConnected=true;
      addTearDown(live.dispose);
      await tester.pumpWidget(app(live,GlobalKey()));await tester.pumpAndSettle();
      api.nextLoad=Completer<Map<String,dynamic>>();
      final refresh=find.byKey(const ValueKey('r54-clubs-refresh'));
      await revealClubWidget(tester,refresh);await tester.tap(refresh);await tester.pump();
      final join=find.byKey(const ValueKey('r21-club-join-1'));
      expect(tester.widget<FilledButton>(join).onPressed,isNull);
      api.nextLoad!.completeError(const ApiException('Unavailable',statusCode:503));await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(join).onPressed,isNull);
      final title=find.byKey(const ValueKey('r54-club-name-1'));
      await revealClubWidget(tester,title);await tester.tap(title);await tester.pumpAndSettle();
      expect(api.details,0);expect(api.joins,0);
      api.nextLoad=null;await revealClubWidget(tester,refresh);await tester.tap(refresh);await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(join).onPressed,isNotNull);expect(api.loads,3);
      expect(tester.takeException(),isNull);await tester.pumpWidget(const SizedBox.shrink());
    });
    testWidgets('R54 offline actual route never invents clubs or calls API $locale',(tester) async {
      final api=ClubsApi(locale);
      final offline=ClubsController(api)..localeCode=locale;addTearDown(offline.dispose);
      await tester.pumpWidget(app(offline,GlobalKey()));await tester.pumpAndSettle();
      expect(api.loads,0);expect(api.joins,0);expect(find.byType(R54ClubCard),findsNothing);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton,locale=='ar'?'أسّس ناديك':'Found your club')).onPressed,isNull);
      expect(tester.takeException(),isNull);await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
