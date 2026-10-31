import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R158 party member icons follow theme and direction',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff286c88),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff286c88),
        brightness: Brightness.dark,
      ),
    );

    Future<List<Color>> inspect(
      ThemeData theme,
      TextDirection direction,
      bool ar,
    ) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r158-party-member-icons-${theme.brightness}'),
        theme: theme,
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: child!,
        ),
        home: Scaffold(
          body: Row(
            children: <Widget>[
              const R65PartyMemberIcon(owner: true),
              Text(ar ? 'المالك' : 'Owner'),
              const R65PartyMemberIcon(owner: false),
              Text(ar ? 'عضو' : 'Member'),
            ],
          ),
        ),
      ));
      await tester.pump();

      final ownerFinder =
          find.byKey(const ValueKey('r158-party-member-icon-owner'));
      final memberFinder =
          find.byKey(const ValueKey('r158-party-member-icon-member'));
      final ownerIcon = tester.widget<Icon>(ownerFinder);
      final memberIcon = tester.widget<Icon>(memberFinder);

      expect(ownerIcon.icon, Icons.star_outline);
      expect(ownerIcon.color, theme.colorScheme.primary);
      expect(memberIcon.icon, Icons.person_outline);
      expect(memberIcon.color, theme.colorScheme.onSurfaceVariant);
      expect(Directionality.of(tester.element(ownerFinder)), direction);
      expect(find.text(ar ? 'المالك' : 'Owner'), findsOneWidget);
      expect(find.text(ar ? 'عضو' : 'Member'), findsOneWidget);
      expect(tester.takeException(), isNull);
      return <Color>[ownerIcon.color!, memberIcon.color!];
    }

    final lightColors = await inspect(light, TextDirection.rtl, true);
    final darkColors = await inspect(dark, TextDirection.ltr, false);
    expect(darkColors, isNot(lightColors));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
