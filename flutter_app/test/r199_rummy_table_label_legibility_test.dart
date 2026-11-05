import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('R199 compact rummy labels stay legible in portrait RTL and LTR',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final players = <Map<String, dynamic>>[
      <String, dynamic>{'key': 'user:0', 'name': 'Adnan'},
      <String, dynamic>{'key': 'bot:1', 'name': 'Kinan'},
      <String, dynamic>{'key': 'bot:2', 'name': 'Bayan'},
      <String, dynamic>{'key': 'bot:3', 'name': 'Omar'},
    ];
    final state = <String, dynamic>{
      'deck_count': 47,
      'discard': <String>['9_C', '8_H'],
      'melds': <String, dynamic>{
        'bot:1': <Map<String, dynamic>>[
          <String, dynamic>{'cards': <String>['3_H', '4_H', '5_H']},
        ],
        'bot:2': <Map<String, dynamic>>[
          <String, dynamic>{'cards': <String>['A_C', 'A_D', 'A_S']},
        ],
      },
      'teams': <String, dynamic>{
        'teamA': <String>['user:0', 'bot:2'],
        'teamB': <String>['bot:1', 'bot:3'],
      },
    };

    Future<(List<TextStyle>, TextDirection)> inspect({
      required bool ar,
      required Brightness brightness,
      required TextDirection direction,
    }) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          brightness: brightness,
        ),
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 204,
                height: 300,
                child: R44RummyTableOverlay(
                  state: state,
                  players: players,
                  ar: ar,
                  partnership: true,
                  cardLabel: (card) => card,
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();

      final labels = <Finder>[
        find.text(ar ? 'فريق ب • Kinan' : 'Team B • Kinan'),
        find.text('Kinan'),
        find.text(ar ? 'الرزمة · 47' : 'Stock · 47'),
        find.text(ar ? 'الرمي · 2' : 'Discard · 2'),
      ];
      for (final label in labels) {
        expect(label, findsOneWidget);
      }
      expect(tester.takeException(), isNull);

      return (
        labels.map((label) => tester.widget<Text>(label).style!).toList(),
        Directionality.of(tester.element(labels.first)),
      );
    }

    final arabic = await inspect(
      ar: true,
      brightness: Brightness.light,
      direction: TextDirection.rtl,
    );
    for (final style in arabic.$1) {
      expect(style.fontSize, greaterThanOrEqualTo(11));
    }
    expect(arabic.$2, TextDirection.rtl);

    final english = await inspect(
      ar: false,
      brightness: Brightness.dark,
      direction: TextDirection.ltr,
    );
    for (final style in english.$1) {
      expect(style.fontSize, greaterThanOrEqualTo(11));
    }
    expect(english.$2, TextDirection.ltr);
  });
}
