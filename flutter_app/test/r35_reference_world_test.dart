import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in ['ar', 'en']) {
    for (final viewport in [const Size(320, 640), const Size(844, 390), const Size(1280, 800)]) {
      testWidgets('R36 championship banner fits $locale $viewport with larger text', (tester) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(() { tester.view.resetPhysicalSize(); tester.view.resetDevicePixelRatio(); });
        final controller = AppController()..localeCode = locale;
        addTearDown(controller.dispose);
        await tester.pumpWidget(MaterialApp(home: MediaQuery(
          data: MediaQueryData(size: viewport, textScaler: TextScaler.linear(1.5)),
          child: Directionality(textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(body: ListView(children: [R35ChampionBanner(controller: controller)]))),
        )));
        expect(find.byKey(const ValueKey('r36-championship-art')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('R36 top counter preserves the full primary-admin balance on narrow phones',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    const balance = '9,999,999,999,999,999,999';
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Center(
      child: SizedBox(
        width: 108,
        child: B307TopCounter(
          icon: Icons.monetization_on_rounded,
          value: balance,
          accent: B307SkyLuxury.goldSoft,
        ),
      ),
    ))));
    final label = tester.widget<Text>(find.text(balance));
    expect(label.maxLines, 1);
    expect(label.softWrap, isFalse);
    expect(find.ancestor(of: find.text(balance), matching: find.byType(FittedBox)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('R35 original coastline and trophy render at both orientations',
      (tester) async {
    for (final viewport in <Size>[const Size(390, 844), const Size(1240, 720)]) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(
        child: SizedBox(
          width: viewport.width > 600 ? 620 : 340, height: 210,
          child: const Stack(fit: StackFit.expand, children: <Widget>[
            CustomPaint(painter: R35CoastalBannerPainter()),
            Align(alignment: Alignment.centerRight,
              child: SizedBox(width: 160, height: 195,
                child: CustomPaint(painter: R35GoldTrophyPainter()))),
          ]),
        ),
      ))));
      expect(tester.takeException(), isNull, reason: 'scenic canvas at $viewport');
    }
  });

  testWidgets('R35 gold CTA is accessible and invokes a real callback',
      (tester) async {
    var activated = false;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(
      child: R35GoldAction(label: 'Explore tournaments',
        icon: Icons.emoji_events_rounded, onTap: () => activated = true),
    ))));
    await tester.tap(find.text('Explore tournaments'));
    expect(activated, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final locale in ['ar', 'en']) {
    for (final viewport in [const Size(320, 640), const Size(844, 390)]) {
      testWidgets('R35 illustrated real-art game card opens actual game action; R36 readable label $locale $viewport',
          (tester) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        var selected = false;
        await tester.pumpWidget(MaterialApp(home: Directionality(
          textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(body: Center(
            child: SizedBox(
              width: viewport.width < 400 ? 92 : 130,
              height: viewport.height < 500 ? 150 : 170,
              child: R35ArtGameCard(
                game: const GameInfo('tarneeb', '♠', 4, Color(0xFF0B70B3)),
                locale: locale,
                onTap: () => selected = true,
              ),
            ),
          )),
        )));
        final label = tester.widget<Text>(find.text(L.t(locale, 'tarneeb')));
        expect(label.style?.fontSize, 12.5);
        expect(label.style?.fontWeight, FontWeight.w900);
        expect(label.style?.color, Colors.white);
        await tester.tap(find.byKey(const ValueKey('r35-game-tarneeb')));
        expect(selected, isTrue);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('R35 wide world exposes functional panels without layout overflow',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final controller = AppController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: R35ReferenceWorldDashboard(controller: controller, onTab: (_) {}),
    )));
    expect(find.byKey(const ValueKey('r35-reference-world-dashboard')), findsOneWidget);
    expect(find.byKey(const ValueKey('r35-sky-grand-tournament-banner')), findsOneWidget);
    expect(find.byKey(const ValueKey('r35-game-tarneeb')), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  for (final locale in ['ar', 'en']) {
    testWidgets('R36 luxury store hero keeps readable contrast $locale',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final controller = AppController()..localeCode = locale;
      addTearDown(controller.dispose);
      final title = locale == 'ar' ? 'متجر ورقنا المميز' : 'Warqnaa Luxury Store';
      final subtitle = locale == 'ar'
          ? 'عروض حقيقية، مقتنيات، مسرّعات وهوية بصرية — مع تحقق خادمي قبل منح أي رصيد.'
          : 'Real offers, collectibles, boosters and visual identity — server verified before currency is granted.';
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.light(),
        home: Directionality(
          textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(body: SingleChildScrollView(
            child: R101CommerceShowcase(controller: controller),
          )),
        ),
      ));
      expect(tester.widget<Text>(find.text(title)).style?.color, Colors.white);
      final subtitleText = tester.widget<Text>(find.text(subtitle));
      expect(subtitleText.style?.color, Colors.white70);
      expect(subtitleText.style?.fontSize, 12);
      expect(subtitleText.style?.fontWeight, FontWeight.w600);
      expect(tester.takeException(), isNull);
    });
  }

  for (final locale in ['ar', 'en']) {
    for (final viewport in [
      const Size(320, 640),
      const Size(390, 844),
      const Size(844, 390),
    ]) {
      testWidgets('R36 store item names stay readable $locale $viewport',
          (tester) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        final controller = AppController()..localeCode = locale;
        addTearDown(controller.dispose);
        final sample = products.firstWhere(
          (product) => product.id == 'table_v173_royal_01',
        );
        await tester.pumpWidget(MaterialApp(home: Directionality(
          textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(body: SingleChildScrollView(
            child: R35StoreTreasureStrip(controller: controller),
          )),
        )));
        final label =
            tester.widget<Text>(find.text(sample.name(controller.localeCode)));
        expect(label.maxLines, 3);
        expect(label.style?.fontSize, 11.5);
        expect(label.style?.height, 1.15);
        expect(label.style?.fontWeight, FontWeight.w900);
        expect(label.style?.color, Colors.white);
        expect(tester.takeException(), isNull);
      });
    }
  }

}
