import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R125 voice room notices follow active theme and direction',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

    Future<Color> noticeColor(
      ThemeData theme,
      TextDirection direction,
      String message,
    ) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: R125VoiceRoomNotice(message: message),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      final notice = tester.widget<Text>(
        find.byKey(const ValueKey('r125-voice-room-notice')),
      );
      final align = tester.widget<Align>(
        find.ancestor(
          of: find.byKey(const ValueKey('r125-voice-room-notice')),
          matching: find.byType(Align),
        ).first,
      );
      expect(notice.data, message);
      expect(align.alignment, AlignmentDirectional.centerStart);
      expect(tester.takeException(), isNull);
      return notice.style!.color!;
    }

    final lightColor = await noticeColor(
      light,
      TextDirection.rtl,
      'بانتظار انضمام لاعبين حقيقيين للصوت…',
    );
    expect(lightColor, light.colorScheme.onSurfaceVariant);

    final darkColor = await noticeColor(
      dark,
      TextDirection.ltr,
      'Waiting for real players to join voice…',
    );
    expect(darkColor, dark.colorScheme.onSurfaceVariant);
    expect(darkColor, isNot(equals(lightColor)));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
