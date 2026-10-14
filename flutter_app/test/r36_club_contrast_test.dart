import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in ['ar', 'en']) {
    testWidgets('R36 club join action remains legible $locale', (tester) async {
      final club = <String, dynamic>{
        'id': 36,
        'name': 'Warqnaa Review Majlis',
        'description': 'Synthetic club for release review',
        'league': <String, String>{'ar': 'برونزي', 'en': 'Bronze'},
        'visibility': 'public',
        'members_count': 2,
        'capacity': 20,
        'membership': null,
        'join_request_pending': false,
        'weekly_points': 0,
      };
      Widget directory(bool allowJoin) => MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(body: SingleChildScrollView(child: R21ClubDirectory(
          clubs: <Map<String, dynamic>>[club],
          locale: locale,
          allowJoin: allowJoin,
          onOpen: (_) {},
          onJoin: (_) {},
        ))),
      );

      await tester.pumpWidget(directory(false));
      var button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('r21-club-join-36')),
      );
      expect(button.style?.backgroundColor?.resolve(<WidgetState>{WidgetState.disabled}),
          const Color(0xFF24483A));
      expect(button.style?.foregroundColor?.resolve(<WidgetState>{WidgetState.disabled}),
          Colors.white70);

      await tester.pumpWidget(directory(true));
      button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('r21-club-join-36')),
      );
      expect(button.style?.backgroundColor?.resolve(<WidgetState>{}),
          B307SkyLuxury.cyan);
      expect(button.style?.foregroundColor?.resolve(<WidgetState>{}),
          B307SkyLuxury.navy);

      club['membership'] = <String, dynamic>{'role': 'member'};
      await tester.pumpWidget(directory(false));
      final membershipAction = find.byKey(
        const ValueKey('r21-club-join-36'),
      );
      expect(
        find.descendant(
          of: membershipAction,
          matching: find.text(locale == 'ar' ? 'ناديك' : 'Your club'),
        ),
        findsOneWidget,
      );
      button = tester.widget<FilledButton>(membershipAction);
      expect(button.child, isA<Row>());
      // The button theme supplies the active font. A local ButtonStyle
      // textStyle without a family falls back to Ahem blocks in review renders.
      expect(button.style?.textStyle, isNull);
      final membershipLabel = tester.widget<Text>(
        find.descendant(
          of: membershipAction,
          matching: find.text(locale == 'ar' ? 'ناديك' : 'Your club'),
        ),
      );
      expect(membershipLabel.style?.fontWeight, FontWeight.w900);
      expect(membershipLabel.style?.fontFamily, isNull);
      expect(
        find.descendant(
          of: membershipAction,
          matching: find.byIcon(Icons.verified_rounded),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
