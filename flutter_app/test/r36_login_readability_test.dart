import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

double contrast(Color foreground, Color background) {
  final a=Color.alphaBlend(foreground,background).computeLuminance();
  final b=background.computeLuminance();
  return a>b?(a+.05)/(b+.05):(b+.05)/(a+.05);
}

void main() {
  setUp(() {SharedPreferences.setMockInitialValues({});AppSounds.enabled=false;});
  for(final locale in ['ar','en']) {
    for(final paletteName in ['dark','midnight_cyan','light']) {
      testWidgets('enabled login actions remain readable in $locale / $paletteName',(tester) async {
        tester.view.physicalSize=const Size(390,844);tester.view.devicePixelRatio=1;
        addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
        final controller=AppController()..localeCode=locale..themeCode=paletteName;
        final palette=AppPalette.fromCode(paletteName);
        await tester.pumpWidget(MaterialApp(locale:Locale(locale),
          supportedLocales:const [Locale('ar'),Locale('en')],
          localizationsDelegates:GlobalMaterialLocalizations.delegates,
          theme:r101Theme(paletteName,'#25e4df',localeCode:locale),
          home:LoginScreen(controller:controller)));
        await tester.pumpAndSettle();
        void check(Finder label,Color surface) {
          expect(label,findsOneWidget);
          final paragraph=tester.renderObject<RenderParagraph>(label);
          final style=paragraph.text.style;
          final color=style?.color ?? style?.foreground?.color;
          expect(color,isNotNull);
          expect(contrast(color!,surface),greaterThanOrEqualTo(4.5),
            reason:'Enabled action text must be readable on its actual panel.');
        }
        check(find.text(locale=='ar'?'نسيت كلمة المرور؟':'Forgot password?'),palette.panel);
        check(find.text(authTextV151(locale,'noAccount')),palette.panel);
        check(find.text(locale=='ar'?'جرّب اللعب دون حساب':'Try without an account'),palette.panel);
        check(find.descendant(of:find.byKey(const ValueKey('r9-local-admin-login')),
          matching:find.byType(Text)),palette.bg);
        check(find.text(locale=='ar'?'خيارات دخول أخرى':'More sign-in options'),palette.bg);
        expect(tester.takeException(),isNull);
        await tester.pumpWidget(const SizedBox.shrink());controller.dispose();
      });
    }
  }
}
