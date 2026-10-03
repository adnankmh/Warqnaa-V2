import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  for (final locale in ['ar', 'en']) {
    test('R19 selected font reaches theme surfaces in $locale', () {
      for (final family in ['Roboto', 'Arial', 'Tahoma', 'Verdana', 'serif', 'monospace']) {
        final theme = r101Theme('midnight_cyan', '#25e4df', fontFamily: family, localeCode: locale);
        final styles = <TextStyle?>[
          theme.textTheme.bodyMedium,
          theme.textTheme.headlineLarge,
          theme.primaryTextTheme.bodyMedium,
          theme.appBarTheme.titleTextStyle,
          theme.inputDecorationTheme.labelStyle,
          theme.chipTheme.labelStyle,
          theme.snackBarTheme.contentTextStyle,
          theme.navigationBarTheme.labelTextStyle?.resolve({}),
          theme.filledButtonTheme.style?.textStyle?.resolve({}),
          theme.outlinedButtonTheme.style?.textStyle?.resolve({}),
          theme.textButtonTheme.style?.textStyle?.resolve({}),
        ];
        for (final style in styles) {
          expect(style?.fontFamily, family);
        }
        expect(theme.textTheme.headlineLarge?.letterSpacing, locale == 'ar' ? 0 : -.7);
        expect(theme.filledButtonTheme.style?.textStyle?.resolve({})?.letterSpacing, locale == 'ar' ? 0 : .15);
      }
    });

    testWidgets('R19 font updates propagate to rendered text in $locale', (tester) async {
      Future<void> showFont(String family) => tester.pumpWidget(MaterialApp(
        theme: r101Theme('midnight_cyan', '#25e4df', fontFamily: family, localeCode: locale),
        home: Directionality(
          textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(body: Center(child: Text(locale == 'ar' ? 'ورقنا' : 'Warqnaa'))),
        ),
      ));
      for (final family in ['Arial', 'Tahoma']) {
        await showFont(family);
        await tester.pumpAndSettle();
        final label = find.text(locale == 'ar' ? 'ورقنا' : 'Warqnaa');
        final richText = tester.widget<RichText>(find.descendant(of: label, matching: find.byType(RichText)));
        expect(richText.text.style?.fontFamily, family);
        final paragraph = tester.renderObject<RenderParagraph>(find.descendant(of: label, matching: find.byType(RichText)));
        expect(paragraph.textDirection, locale == 'ar' ? TextDirection.rtl : TextDirection.ltr);
        expect(tester.takeException(), isNull);
      }
    });
  }
}
