import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R151 operations deployment notice follows theme and direction',
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

    Future<Color> inspect(
      ThemeData theme,
      bool ar,
      TextDirection direction,
    ) async {
      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r151-operations-notice-${theme.brightness}-$ar'),
        theme: theme,
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: child!,
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: R65OperationsDeploymentNotice(ar: ar),
          ),
        ),
      ));
      await tester.pump();

      final noticeFinder =
          find.byKey(const ValueKey('r151-operations-deployment-notice'));
      final notice = tester.widget<Text>(noticeFinder);

      expect(notice.style!.color, theme.colorScheme.onSurfaceVariant);
      expect(notice.style!.height, 1.7);
      expect(
        notice.data,
        ar
            ? 'HTTP ووضع التطوير طبيعيان محليًا. يلزم HTTPS وإيقاف وضع التطوير للنشر العام. صحة الجدولة تعني تسجيل تشغيل فعلي خلال آخر ثلاث دقائق.'
            : 'HTTP and debug mode are expected locally. Public deployment requires HTTPS and debug disabled. Scheduler health needs a recorded run within three minutes.',
      );
      expect(Directionality.of(tester.element(noticeFinder)), direction);
      expect(tester.takeException(), isNull);
      return notice.style!.color!;
    }

    final lightColor = await inspect(light, true, TextDirection.rtl);
    final darkColor = await inspect(dark, false, TextDirection.ltr);
    expect(darkColor, isNot(lightColor));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
