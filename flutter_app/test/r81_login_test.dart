import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

Widget loginHost(AppController controller) => AnimatedBuilder(
  animation: controller,
  builder: (context, _) => MaterialApp(
    locale: Locale(controller.localeCode),
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: r101Theme('dark', '#ffcf67'),
    home: controller.isAuthenticated ? HomeShell(controller: controller) : LoginScreen(controller: controller),
  ),
);

class PendingGuestController extends AppController {
  final gate = Completer<void>();
  int attempts = 0;
  @override
  Future<void> loginAsGuest() async {
    attempts++;
    await gate.future;
    await super.loginAsGuest();
  }
}

void main() {
  setUp(() { SharedPreferences.setMockInitialValues({}); AppSounds.enabled = false; });
  for (final locale in ['ar', 'en']) {
    for (final size in [const Size(320, 640), const Size(390, 844), const Size(844, 390), const Size(1280, 800)]) {
      testWidgets('sign-in and registration remain usable $locale $size', (tester) async {
        tester.view.physicalSize = size; tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
        final controller = AppController()..localeCode = locale;
        await tester.pumpWidget(loginHost(controller));
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);
        expect(find.textContaining('Laravel'), findsNothing);
        expect(find.text('Google'), findsNothing);
        final guest = find.byKey(const ValueKey('r81-login-guest'));
        expect(guest, findsOneWidget);
        if (size == const Size(390, 844)) {
          expect(tester.getBottomRight(guest).dy, lessThanOrEqualTo(size.height));
        }
        final toggle = find.byKey(const ValueKey('r81-login-switch'));
        await tester.ensureVisible(toggle); await tester.tap(toggle); await tester.pump();
        expect(find.byKey(const ValueKey('r81-login-email')), findsOneWidget);
        expect(guest, findsNothing);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(toggle); await tester.tap(toggle); await tester.pump();
        expect(find.byKey(const ValueKey('r81-login-email')), findsNothing);
        expect(guest, findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink()); controller.dispose();
      });
    }

    testWidgets('guest button opens the lobby once and clears online identity $locale', (tester) async {
      tester.view.physicalSize = const Size(390, 844); tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
      final controller = PendingGuestController()..localeCode = locale..authToken = 'stale-session'..isAdmin = true..serverConnected = true;
      controller.api.token = 'stale-session';
      await tester.pumpWidget(loginHost(controller));
      final guest = find.byKey(const ValueKey('r81-login-guest'));
      await tester.ensureVisible(guest); await tester.tap(guest); await tester.tap(guest);
      await tester.pump();
      expect(controller.attempts, 1);
      expect(tester.widget<OutlinedButton>(guest).onPressed, isNull);
      controller.gate.complete();
      for (var i = 0; i < 40 && find.byType(R8HomeLobby).evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(controller.isAuthenticated, isTrue);
      expect(controller.serverConnected, isFalse);
      expect(controller.isAdmin, isFalse);
      expect(controller.authToken, isNull);
      expect(controller.api.token, isNull);
      expect(find.byType(R8HomeLobby), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink()); controller.dispose();
    });
  }
}
