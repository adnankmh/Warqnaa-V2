import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R136 open room card follows theme and RTL/LTR locale',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppSounds.enabled = false;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AppController();
    addTearDown(() {
      controller.connectivityTimerV173?.cancel();
      controller.dispose();
    });
    var joinCount = 0;
    final room = <String, dynamic>{
      'voice_enabled': true,
      'players': 1,
      'max_players': 4,
      'min_level': 3,
      'avatars': <dynamic>[],
    };
    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff0a8f62),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff0a8f62),
        brightness: Brightness.dark,
      ),
    );

    Future<Color?> pumpCard(ThemeData theme, String locale) async {
      controller.localeCode = locale;
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r136-open-room-$locale'),
        locale: Locale(locale),
        supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: theme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: OpenRoomCardV170(
              controller: controller,
              game: gamesCatalog.first,
              room: room,
              onJoin: () => joinCount++,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final waiting = find.byKey(const ValueKey('r136-open-room-waiting'));
      expect(waiting, findsOneWidget);
      expect(
        Directionality.of(tester.element(waiting)),
        locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
      return tester.widget<Text>(waiting).style?.color;
    }

    final lightColor = await pumpCard(light, 'ar');
    expect(lightColor, light.colorScheme.onSurfaceVariant);
    expect(find.text('غرفة'), findsOneWidget);
    expect(find.textContaining('🎙️ صوتية'), findsOneWidget);
    expect(find.text('بانتظار لاعبين…'), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    expect(joinCount, 1);

    final darkColor = await pumpCard(dark, 'en');
    expect(darkColor, dark.colorScheme.onSurfaceVariant);
    expect(darkColor, isNot(equals(lightColor)));
    expect(find.text('Room'), findsOneWidget);
    expect(find.textContaining('🎙️ Voice room'), findsOneWidget);
    expect(find.text('Waiting for players…'), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    expect(joinCount, 2);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
