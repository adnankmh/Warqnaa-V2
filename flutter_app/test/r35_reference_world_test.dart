import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
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

  testWidgets('R35 illustrated real-art game card opens actual game action',
      (tester) async {
    var selected = false;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(
      child: SizedBox(width: 160, height: 200,
        child: R35ArtGameCard(
          game: const GameInfo('tarneeb', '♠', 4, Color(0xFF0B70B3)),
          locale: 'ar',
          onTap: () => selected = true,
        )),
    ))));
    await tester.tap(find.byKey(const ValueKey('r35-game-tarneeb')));
    expect(selected, isTrue);
    expect(tester.takeException(), isNull);
  });

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
}
