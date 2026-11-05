import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppSounds.enabled = false;
  });

  testWidgets(
      'R205 room chat metadata follows portrait RTL and LTR themes at 11px',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> verify({
      required String locale,
      required Brightness brightness,
    }) async {
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0a8f62),
          brightness: brightness,
        ),
      );
      final controller = AppController()..localeCode = locale;

      await tester.pumpWidget(MaterialApp(
        locale: Locale(locale),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: theme,
        home: TarneebRoomPage(
          controller: controller,
          game: gamesCatalog.first,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byIcon(Icons.chat_bubble_outline).first);
      await tester.pump(const Duration(milliseconds: 250));

      final subtitle = tester.widget<Text>(
        find.byKey(const ValueKey('r205-room-chat-subtitle')),
      );
      final message = tester.widget<Text>(
        find.byKey(const ValueKey('r205-room-chat-message-0')),
      );
      expect(subtitle.style!.fontSize, greaterThanOrEqualTo(11));
      expect(message.style!.fontSize, greaterThanOrEqualTo(11));
      expect(subtitle.style!.color, theme.colorScheme.primary);
      expect(message.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(
        Directionality.of(
          tester.element(
            find.byKey(const ValueKey('r205-room-chat-subtitle')),
          ),
        ),
        locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 6));
      controller.dispose();
    }

    await verify(locale: 'ar', brightness: Brightness.light);
    await verify(locale: 'en', brightness: Brightness.dark);
  });
}
