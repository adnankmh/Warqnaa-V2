import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  test('R242 never mistakes missing voice data for disabled services', () {
    expect(
      productionVoiceStatusV242('ar', <String, dynamic>{}),
      contains('غير متاحة'),
    );
    expect(
      productionVoiceStatusV242('en', <String, dynamic>{}),
      contains('requires server data'),
    );
    expect(
      productionVoiceStatusV242('en', <String, dynamic>{
        'enabled': null,
        'turn_required': 'false',
      }),
      contains('Unknown'),
    );
    expect(
      productionVoiceStatusV242('ar', <String, dynamic>{
        'enabled': false,
        'turn_required': true,
      }),
      contains('غير مفعّلة • TURN: مطلوب'),
    );
  });

  for (final locale in <String>['ar', 'en']) {
    for (final brightness in <Brightness>[
      Brightness.light,
      Brightness.dark,
    ]) {
      for (final width in <double>[320, 390]) {
        testWidgets(
          'R242 voice readiness $locale ${brightness.name} ${width.toInt()} portrait',
          (tester) async {
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final handle = tester.ensureSemantics();
            addTearDown(handle.dispose);

            final direction =
                locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
            final theme = ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xff1765bc),
                brightness: brightness,
              ),
            );

            Future<void> verify(Map<String, dynamic> voice) async {
              await tester.pumpWidget(MaterialApp(
                theme: theme,
                home: Directionality(
                  textDirection: direction,
                  child: Scaffold(
                    body: SafeArea(
                      child: ListTile(
                        leading: const ProductionActionIconV153(
                          action: ProductionActionV153.voice,
                        ),
                        title: Text(locale == 'ar'
                            ? 'جاهزية الغرف الصوتية'
                            : 'Voice-room readiness'),
                        subtitle: ProductionVoiceReadinessV242(
                          locale: locale,
                          voice: voice,
                        ),
                      ),
                    ),
                  ),
                ),
              ));
              await tester.pump();

              final finder = find.byKey(
                const ValueKey('r242-production-voice-readiness'),
              );
              final label = productionVoiceStatusV242(locale, voice);
              final widget = tester.widget<Text>(finder);
              final icon = tester.widget<Icon>(find.byIcon(Icons.mic_rounded));
              expect(widget.data, label);
              expect(widget.semanticsLabel, label);
              expect(find.bySemanticsLabel(RegExp(RegExp.escape(label))), findsWidgets);
              expect(widget.style!.color, theme.colorScheme.onSurfaceVariant);
              expect(icon.color, theme.colorScheme.primary);
              expect(Directionality.of(tester.element(finder)), direction);
              expect(tester.takeException(), isNull);
            }

            await verify(<String, dynamic>{});
            await verify(<String, dynamic>{
              'enabled': true,
              'turn_required': false,
            });
            expect(
              productionVoiceStatusV242(locale, <String, dynamic>{
                'enabled': true,
                'turn_required': false,
              }),
              contains(locale == 'ar'
                  ? 'مفعّلة • TURN: غير مطلوب'
                  : 'Enabled • TURN: Not required'),
            );
            await tester.pumpWidget(const SizedBox.shrink());
          },
        );
      }
    }
  }
}
