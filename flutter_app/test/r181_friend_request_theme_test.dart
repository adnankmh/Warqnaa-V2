import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R181 friend request actions follow portrait RTL and LTR themes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<(Color?, Color?, TextDirection)> inspect({
      required Brightness brightness,
      required TextDirection direction,
    }) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0f766e),
          brightness: brightness,
        ),
      );

      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: const Scaffold(
            body: Row(
              children: [
                FriendRequestAcceptIconR181(),
                FriendRequestRejectIconR181(),
              ],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final acceptFinder = find.byKey(
        const ValueKey('r181-friend-request-accept-icon'),
      );
      final rejectFinder = find.byKey(
        const ValueKey('r181-friend-request-reject-icon'),
      );
      expect(acceptFinder, findsOneWidget);
      expect(rejectFinder, findsOneWidget);

      final accept = tester.widget<Icon>(acceptFinder);
      final reject = tester.widget<Icon>(rejectFinder);
      expect(accept.icon, Icons.check);
      expect(accept.color, theme.colorScheme.primary);
      expect(reject.icon, Icons.close);
      expect(reject.color, theme.colorScheme.error);
      expect(Directionality.of(tester.element(acceptFinder)), direction);
      expect(Directionality.of(tester.element(rejectFinder)), direction);
      expect(tester.takeException(), isNull);

      return (
        accept.color,
        reject.color,
        Directionality.of(tester.element(acceptFinder)),
      );
    }

    final lightRtl = await inspect(
      brightness: Brightness.light,
      direction: TextDirection.rtl,
    );
    final darkLtr = await inspect(
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );

    expect(darkLtr.$1, isNot(lightRtl.$1));
    expect(darkLtr.$2, isNot(lightRtl.$2));
  });
}
