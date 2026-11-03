import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  testWidgets('R160 competition text follows theme and direction',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final light = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff245f80),
        brightness: Brightness.light,
      ),
    );
    final dark = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff245f80),
        brightness: Brightness.dark,
      ),
    );

    Future<List<Color>> inspect(
      ThemeData theme,
      TextDirection direction,
      bool ar,
    ) async {
      final metadata = ar ? 'تفاصيل المنافسة' : 'Competition details';
      final fee = ar ? 'رسوم الدخول' : 'Entry fee';
      final prize = ar ? 'الجائزة' : 'Prize';

      await tester.pumpWidget(MaterialApp(
        key: ValueKey('r160-competition-${theme.brightness}'),
        theme: theme,
        builder: (context, child) => Directionality(
          textDirection: direction,
          child: child!,
        ),
        home: Scaffold(
          body: Column(
            children: <Widget>[
              CompetitionToneTextV173(
                text: metadata,
                tone: CompetitionToneV173.metadata,
                height: 1.5,
              ),
              CompetitionToneTextV173(
                text: fee,
                tone: CompetitionToneV173.fee,
                fontWeight: FontWeight.w900,
              ),
              CompetitionToneTextV173(
                text: prize,
                tone: CompetitionToneV173.prize,
              ),
            ],
          ),
        ),
      ));
      await tester.pump();

      Text textFor(String value) => tester.widget<Text>(find.text(value));
      final metadataText = textFor(metadata);
      final feeText = textFor(fee);
      final prizeText = textFor(prize);

      expect(metadataText.style?.color, theme.colorScheme.onSurfaceVariant);
      expect(metadataText.style?.height, 1.5);
      expect(feeText.style?.color, theme.colorScheme.primary);
      expect(feeText.style?.fontWeight, FontWeight.w900);
      expect(prizeText.style?.color, theme.colorScheme.tertiary);
      expect(Directionality.of(tester.element(find.text(metadata))), direction);
      expect(tester.takeException(), isNull);
      return <Color>[
        metadataText.style!.color!,
        feeText.style!.color!,
        prizeText.style!.color!,
      ];
    }

    final lightColors = await inspect(light, TextDirection.rtl, true);
    final darkColors = await inspect(dark, TextDirection.ltr, false);
    expect(darkColors, isNot(lightColors));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
