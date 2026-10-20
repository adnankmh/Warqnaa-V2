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
          R35ReferenceColors.deep);
      expect(button.style?.foregroundColor?.resolve(<WidgetState>{WidgetState.disabled}),
          R35ReferenceColors.paleGold);

      await tester.pumpWidget(directory(true));
      button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('r21-club-join-36')),
      );
      expect(button.style?.backgroundColor?.resolve(<WidgetState>{}),
          R35ReferenceColors.gold);
      expect(button.style?.foregroundColor?.resolve(<WidgetState>{}),
          R35ReferenceColors.navy);

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
      // R54 explicitly enlarges the themed button style without losing its
      // font family (a family-less override caused Ahem blocks in old reviews).
      final themedLabel=Theme.of(tester.element(membershipAction)).textTheme.labelLarge!;
      final buttonText=button.style!.textStyle!.resolve(<WidgetState>{})!;
      expect(buttonText.fontFamily,themedLabel.fontFamily);
      expect(buttonText.fontSize,16);expect(buttonText.fontWeight,FontWeight.w800);
      final membershipLabel = tester.widget<Text>(
        find.descendant(
          of: membershipAction,
          matching: find.text(locale == 'ar' ? 'ناديك' : 'Your club'),
        ),
      );
      expect(membershipLabel.style, isNull);
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
