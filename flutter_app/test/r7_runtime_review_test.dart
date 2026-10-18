import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/premium_v149.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

const runtimeUrl = String.fromEnvironment('R7_RUNTIME_URL');
const reviewDirectory = String.fromEnvironment('R7_REVIEW_DIR');

Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
  // Real asset decoding needs real async time, not a fake-clock pump.
  final providers = tester.widgetList<Image>(find.byType(Image)).map((image) => image.image).toSet();
  final imageErrors = <Object>[];
  await tester.runAsync(() async {
    await Future.wait(providers.map((provider) => precacheImage(
      provider, key.currentContext!, onError: (error, stack) => imageErrors.add(error),
    )));
  });
  expect(imageErrors, isEmpty, reason: 'Review screenshots must include their image assets');
  await tester.pump(const Duration(milliseconds: 400));
  expect(tester.takeException(), isNull);
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$reviewDirectory/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(png!.buffer.asUint8List());
    image.dispose();
  });
}

ButtonStyle reviewButtonStyle(ButtonStyle? style) => (style ?? const ButtonStyle()).copyWith(
  textStyle: WidgetStateProperty.resolveWith((states) =>
    (style?.textStyle?.resolve(states) ?? const TextStyle()).copyWith(
      fontFamily: 'R7Review', fontFamilyFallback: const ['R7Emoji'],
    )),
);

ThemeData reviewTheme(AppController controller) {
  final theme = r101Theme(controller.themeCode, controller.uiAccentHex);
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: 'R7Review', fontFamilyFallback: const ['R7Emoji']),
    primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'R7Review', fontFamilyFallback: const ['R7Emoji']),
    filledButtonTheme: FilledButtonThemeData(style: reviewButtonStyle(theme.filledButtonTheme.style)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: reviewButtonStyle(theme.outlinedButtonTheme.style)),
    textButtonTheme: TextButtonThemeData(style: reviewButtonStyle(theme.textButtonTheme.style)),
    chipTheme: theme.chipTheme.copyWith(labelStyle: theme.chipTheme.labelStyle?.copyWith(fontFamily: 'R7Review')),
  );
}

Widget reviewApp(Widget child, AppController controller, GlobalKey key) => RepaintBoundary(
  key: key,
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: Locale(controller.localeCode),
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    // A real Arabic-capable review font replaces Flutter test's Ahem blocks.
    // These renders are review evidence, not platform-specific pixel goldens.
    theme: reviewTheme(controller),
    home: child,
  ),
);

class R19ReactionReview extends StatelessWidget {
  final String locale;
  const R19ReactionReview({super.key, required this.locale});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xff050b12),
    body: SafeArea(
      child: LayoutBuilder(builder: (context, area) {
        final reaction = reactionCatalog.firstWhere((item) => item.id == 'r91_good_game');
        // Widget tests have no native audio plugin; this review surface must
        // render the honest motion-only state without starting an audio stream.
        final stage = Center(child: FloatingReaction(reaction: reaction, locale: locale, soundEnabled: false));
        final dock = ReactionDock(locale: locale, soundEnabled: false, onSelected: (_) {});
        if (area.maxHeight < 500) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [Expanded(child: stage), const SizedBox(width: 10), SizedBox(width: 330, child: dock)]),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [Expanded(child: stage), const SizedBox(height: 10), SizedBox(height: 330, child: dock)]),
        );
      }),
    ),
  );
}

class R19BotReview extends StatelessWidget {
  final String locale;
  const R19BotReview({super.key, required this.locale});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xff050b12),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: BotRosterShowcase(locale: locale, profiles: botProfiles.take(12).toList()),
          ),
        ),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    final report=FlutterError.onError;
    FlutterError.onError=(details) {
      // Preserve the widget/constraint diagnostics even when capture() consumes
      // the exception to assert it. The test must still fail normally.
      debugPrint(details.toString());
      report?.call(details);
    };
    addTearDown(() { FlutterError.onError=report; });
  });
  setUpAll(() async {
    if (runtimeUrl.isEmpty) return;
    final fontBytes = await File(const String.fromEnvironment('R7_REVIEW_FONT')).readAsBytes();
    // Component defaults such as app bars may retain the Roboto family.
    for (final family in ['R7Review', 'Roboto']) {
      final font = FontLoader(family)..addFont(Future.value(ByteData.sublistView(fontBytes)));
      await font.load();
    }
    final icons = FontLoader('MaterialIcons')..addFont(
      File(const String.fromEnvironment('R7_MATERIAL_FONT')).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
    );
    await icons.load();
    const emojiPath = String.fromEnvironment('R7_EMOJI_FONT');
    if (emojiPath.isNotEmpty) {
      final emoji = FontLoader('R7Emoji')..addFont(
        File(emojiPath).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
      );
      await emoji.load();
    }
  });

  for (final locale in ['ar', 'en']) {
    testWidgets('R7 live identity and layouts $locale', (tester) async {
      final oldOverride = HttpOverrides.current;
      HttpOverrides.global = null; // Opt this integration test into its loopback server.
      addTearDown(() => HttpOverrides.global = oldOverride);
      final previousError = FlutterError.onError;
      FlutterError.onError = (details) { debugPrint(details.toString()); previousError?.call(details); };
      SharedPreferences.setMockInitialValues({});
      AppSounds.enabled = false;
      final controller = AppController()..customApiUrl = runtimeUrl;
      var reviewClubs = <Map<String, dynamic>>[];
      var reviewCups = <Map<String, dynamic>>[];
      controller.api.updateBaseUrl(runtimeUrl);
      addTearDown(() { controller.connectivityTimerV173?.cancel(); controller.dispose(); });
      await tester.runAsync(() async {
        expect(await controller.login(const String.fromEnvironment('R7_PLAYER_LOGIN'), const String.fromEnvironment('R7_PLAYER_PASSWORD')), isNull);
        expect(controller.serverConnected, isTrue);
        expect(controller.currentUserId, int.parse(const String.fromEnvironment('R7_PLAYER_ID')));
        expect(controller.level, int.parse(const String.fromEnvironment('R7_PLAYER_LEVEL')));
        // Restore the saved online session through the production bootstrap path.
        await controller.load();
        expect(controller.serverConnected, isTrue);
        expect(controller.currentUserId, int.parse(const String.fromEnvironment('R7_PLAYER_ID')));
        expect(controller.level, int.parse(const String.fromEnvironment('R7_PLAYER_LEVEL')));
        expect(controller.selectedTable, 'v305_table_emerald_royal');
        expect(controller.selectedCardBack, 'v305_cardback_emerald_royal');
        final clubs = await controller.api.clubsWorldR11();
        final competitive = await controller.api.competitiveR12();
        reviewClubs = (clubs['clubs'] as List).map((item) => Map<String, dynamic>.from(item as Map)).toList();
        reviewCups = ((competitive['competitive'] as Map)['tournaments'] as List).map((item) => Map<String, dynamic>.from(item as Map)).where((cup) => cup['key'].toString().startsWith('r21_review_')).toList();
        expect(reviewClubs, isNotEmpty); expect(reviewCups, hasLength(3));
      });
      controller.localeCode = locale;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1;
      for (final size in [const Size(390, 844), const Size(844, 390), const Size(1280, 800)]) {
        tester.view.physicalSize = size;
        final dimensions = '${size.width.toInt()}x${size.height.toInt()}';
        for (final page in <(String, Widget)>[
          ('login', LoginScreen(controller: controller)),
          ('home', HomeShell(controller: controller)),
          ('profile', R61ProfilePage(controller: controller)),
          ('store', Scaffold(body: StorePage(controller: controller))),
          ('store-collections', Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: R20StoreCollections(controller: controller)))),
          ('social', Scaffold(body: R61SocialHubPage(controller: controller))),
          ('r21-clubs', Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: R21ClubDirectory(clubs: reviewClubs, locale: locale, allowJoin: false, onOpen: (_) {}, onJoin: (_) {})))),
          ('r21-cups', Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: R21TournamentDirectory(cups: reviewCups, locale: locale, onOpen: (_) {})))),
          ('table', TarneebRoomPage(controller: controller, game: gamesCatalog.firstWhere((game) => game.id == 'tarneeb'))),
        ]) {
          final key = GlobalKey();
          await tester.pumpWidget(reviewApp(page.$2, controller, key));
          await capture(tester, key, '$locale-${page.$1}-$dimensions');
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 5));
        }
      }
    }, skip: runtimeUrl.isEmpty);
  }

  for (final locale in ['ar', 'en']) {
    testWidgets('R9 local studio renders and restores offline $locale', (tester) async {
      SharedPreferences.setMockInitialValues({});
      AppSounds.enabled = false;
      final controller = AppController()..localeCode = locale;
      addTearDown(() { controller.connectivityTimerV173?.cancel(); controller.dispose(); });
      await controller.loginAsLocalAdmin();
      await controller.updateHomeGames(['trix', 'basra']);
      await tester.runAsync(() => controller.load());
      expect(controller.isLocalAdmin, isTrue);
      expect(controller.api.token, isNull);
      expect(controller.homeGameIds, ['trix', 'basra']);
      // Exercise the completed R19 identity composition with an active Pasha
      // entitlement and a non-default style in real rendered review evidence.
      controller.selectedPashaStyle = 'blue';
      controller.selectedProfileColorB304 = 'r19_profile_sapphire_pasha_30d';
      controller.activeXpMultiplier = 2.5;
      controller.boosterExpiresAtV173 = DateTime.now().add(const Duration(hours: 6));
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1;
      for (final size in [const Size(320, 640), const Size(390, 844), const Size(844, 390), const Size(1280, 800)]) {
        tester.view.physicalSize = size;
        final dimensions = '${size.width.toInt()}x${size.height.toInt()}';
        for (final page in <(String, Widget)>[
          ('local-studio', R9LocalStudio(controller: controller)),
          ('local-home', HomeShell(controller: controller)),
          ('local-profile', R61ProfilePage(controller: controller)),
          (
            'local-booster',
            Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: R19BoosterStatus(controller: controller, onBrowse: () {}),
              ),
            ),
          ),
          ('local-reaction', R19ReactionReview(locale: locale)),
          ('local-bots', R19BotReview(locale: locale)),
        ]) {
          final key = GlobalKey();
          await tester.pumpWidget(reviewApp(page.$2, controller, key));
          await capture(tester, key, '$locale-${page.$1}-$dimensions');
          await tester.pumpWidget(const SizedBox.shrink());
        }
      }
    }, skip: runtimeUrl.isEmpty);
  }

  testWidgets('R7 live primary role remains authoritative in Flutter', (tester) async {
    final oldOverride = HttpOverrides.current;
    HttpOverrides.global = null;
    addTearDown(() => HttpOverrides.global = oldOverride);
    SharedPreferences.setMockInitialValues({});
    final controller = AppController()..customApiUrl = runtimeUrl;
    controller.api.updateBaseUrl(runtimeUrl);
    addTearDown(() { controller.connectivityTimerV173?.cancel(); controller.dispose(); });
    await tester.runAsync(() async {
      expect(await controller.login(const String.fromEnvironment('R7_ADMIN_LOGIN'), const String.fromEnvironment('R7_ADMIN_PASSWORD')), isNull);
      await controller.load();
      expect(controller.isPrimaryAdmin, isTrue);
      expect(controller.level, 99);
      expect(controller.vipDays, greaterThanOrEqualTo(36500));
      expect(controller.coins, greaterThanOrEqualTo(BigInt.parse('9000000000000000000')));
      expect(controller.currentUserId, int.parse(const String.fromEnvironment('R7_ADMIN_ID')));
    });
  }, skip: runtimeUrl.isEmpty);

  for (final locale in ['ar','en']) {
    for (final size in [const Size(320,640),const Size(390,844)]) {
      testWidgets('R40 public fire-pile preview and confirmed count $locale $size',(tester) async {
        SharedPreferences.setMockInitialValues({}); AppSounds.enabled=false;
        tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
        addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
        final controller=AppController()..localeCode=locale;
        addTearDown(controller.dispose);
        final key=GlobalKey(); int? submitted;
        await tester.pumpWidget(reviewApp(Scaffold(body:Builder(builder:(context)=>TextButton(
          onPressed:()async{submitted=await showDialog<int>(context:context,builder:(_)=>AlertDialog(
            title:Text(locale=='ar'?'السحب من النار':'Take discard cards'),
            content:R40DiscardStackPicker(maxCount:4,cards:const ['JOKER_R','Q_spades','K_spades','A_spades'],ar:locale=='ar'),
          ));},child:const Text('open-preview')))),controller,key));
        await tester.tap(find.text('open-preview'));await tester.pumpAndSettle();
        expect(tester.widgetList<PlayingCard>(find.byType(PlayingCard)).map((card)=>card.label),['K♠','A♠']);
        await tester.tap(find.byKey(const ValueKey('r40-discard-count')));await tester.pumpAndSettle();
        await tester.tap(find.text('3').last);await tester.pumpAndSettle();
        expect(tester.widgetList<PlayingCard>(find.byType(PlayingCard)).map((card)=>card.label),['Q♠','K♠','A♠']);
        expect(submitted,isNull,reason:'Changing the preview must not submit a draw.');
        await tester.tap(find.byKey(const ValueKey('r40-discard-count')));await tester.pumpAndSettle();
        await tester.tap(find.text('4').last);await tester.pumpAndSettle();
        expect(tester.widgetList<PlayingCard>(find.byType(PlayingCard)).map((card)=>card.label),['🃏','Q♠','K♠','A♠']);
        expect(find.text('JK'),findsNWidgets(2),reason:'The Joker has a readable identity at both corners.');
        if(reviewDirectory.isNotEmpty)await capture(tester,key,'$locale-r40-fire-preview-${size.width.toInt()}x${size.height.toInt()}');
        await tester.ensureVisible(find.byKey(const ValueKey('r40-confirm-discard-stack')));
        await tester.tap(find.byKey(const ValueKey('r40-confirm-discard-stack')));await tester.pumpAndSettle();
        expect(submitted,4);expect(tester.takeException(),isNull);
        submitted=null;
        await tester.tap(find.text('open-preview'));await tester.pumpAndSettle();
        await tester.binding.handlePopRoute();await tester.pumpAndSettle();
        expect(submitted,isNull,reason:'Closing the preview must not draw cards.');
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }



  for (final locale in ['ar','en']) {
    for (final size in [const Size(320,640),const Size(390,844)]) {
      for (final gameId in ['backgammon','jackaroo']) {
        testWidgets('R41 readable $gameId board $locale $size',(tester) async {
          tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
          addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
          final controller=AppController()..localeCode=locale;
          addTearDown(controller.dispose);
          final board=gameId=='backgammon'
              ? R41BackgammonBoard(ar:locale=='ar',points:const {
                  '24':{'count':2,'owner':'user:1'},
                  '13':{'count':5,'owner':'bot:1'},
                  '8':{'count':3,'owner':'user:1'},
                  '6':{'count':5,'owner':'bot:1'},
                })
              : R41JackarooBoard(ar:locale=='ar',pieces:const {
                  'user:Adnan':[-1,12,37,56],
                  'bot:Samer':[-1,9,41,57],
                });
          final key=GlobalKey();
          await tester.pumpWidget(reviewApp(Scaffold(body:SafeArea(child:Center(
            child:SizedBox(height:420,child:board),
          ))),controller,key));
          await tester.pump();
          expect(tester.takeException(),isNull);
          if(gameId=='backgammon'){
            final point=tester.widget<Text>(find.text('24'));
            expect(point.style?.fontSize,11);
          }
          if(reviewDirectory.isNotEmpty)await capture(tester,key,'$locale-r41-$gameId-${size.width.toInt()}x${size.height.toInt()}');
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }


  for (final locale in ['ar','en']) {
    for (final size in [const Size(320,640),const Size(390,844)]) {
      testWidgets('R42 readable home game tile $locale $size',(tester) async {
        tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
        addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
        final controller=AppController()..localeCode=locale;
        addTearDown(() {
          controller.connectivityTimerV173?.cancel();
          controller.dispose();
        });
        final key=GlobalKey();
        await tester.pumpWidget(reviewApp(
          Scaffold(
            body:SafeArea(
              child:Center(
                child:SizedBox(
                  width:size.width<360?148:180,
                  height:200,
                  child:R8GameTile(
                    game:gamesCatalog.first,
                    locale:locale,
                    onTap:(){ },
                  ),
                ),
              ),
            ),
          ),
          controller,
          key,
        ));
        await tester.pump();
        final prompt=tester.widget<Text>(
          find.text(locale=='ar'?'ابدأ اللعب الآن':'Play now'),
        );
        expect(prompt.style?.fontSize,11);
        expect(tester.takeException(),isNull);
        if(reviewDirectory.isNotEmpty) {
          await capture(tester,key,'$locale-r42-home-tile-${size.width.toInt()}x${size.height.toInt()}');
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }


  for (final locale in ['ar','en']) {
    testWidgets('R43 readable social navigation $locale 320x640',(tester) async {
      tester.view.physicalSize=const Size(320,640);tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
      final controller=AppController()..localeCode=locale;
      addTearDown(() {
        controller.connectivityTimerV173?.cancel();
        controller.dispose();
      });
      final key=GlobalKey();
      await tester.pumpWidget(reviewApp(
        Scaffold(
          body:R61SocialHubPage(controller:controller),
          bottomNavigationBar:R61BottomNavigation(
            controller:controller,
            selectedIndex:3,
            onSelected:(_){ },
          ),
        ),
        controller,
        key,
      ));
      await tester.pump();
      final friends=tester.widget<Text>(
        find.text(locale=='ar'?'الأصدقاء':'Friends').first,
      );
      expect(friends.style?.fontSize,11);
      expect(tester.takeException(),isNull);
      if(reviewDirectory.isNotEmpty) {
        await capture(tester,key,'$locale-r43-social-navigation-320x640');
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final locale in ['ar','en']) {
    testWidgets('R44 readable session continuity $locale 320x640',(tester) async {
      tester.view.physicalSize=const Size(320,640);tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
      final controller=AppController()
        ..localeCode=locale
        ..activeGame='tarneeb'
        ..activeRoomCode='R44-7K2';
      addTearDown(() {
        controller.connectivityTimerV173?.cancel();
        controller.dispose();
      });
      final key=GlobalKey();
      await tester.pumpWidget(reviewApp(
        Scaffold(
          body:SafeArea(
            child:Column(children:[
              R9SessionBanner(controller:controller),
              ActiveGameBanner(controller:controller,onResume:(){ }),
            ]),
          ),
        ),
        controller,
        key,
      ));
      await tester.pump();
      expect(find.text(locale=='ar'?'العودة إلى اللعبة':'Return to game'),findsOneWidget);
      expect(find.byTooltip(locale=='ar'?'الخروج من اللعبة':'Exit game'),findsOneWidget);
      expect(tester.takeException(),isNull);
      if(reviewDirectory.isNotEmpty) {
        await capture(tester,key,'$locale-r44-session-continuity-320x640');
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

}
