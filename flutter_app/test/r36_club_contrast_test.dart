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
      expect(tester.takeException(), isNull);
    });
  }
}
