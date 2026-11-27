import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/chat_expressions_r291.dart';

void main(){
  test('R291 catalog has unique expressions and bounded draft append',(){
    expect(animatedExpressionsR291.toSet().length,32);
    expect(chatPhrasesR291.length,20);
    expect(appendExpressionR291('hello','👋'),'hello 👋');
    final full=List.filled(500,'a').join();
    expect(appendExpressionR291(full,'👋'),full);
  });
  test('R292 recognizes exact catalog phrases only',(){
    expect(phraseForMessageR292('👋 السلام عليكم'),('السلام عليكم','ar'));
    expect(phraseForMessageR292('⏩ Please hurry up'),('Please hurry up','en'));
    expect(phraseForMessageR292('👋 السلام عليكم extra'),isNull);
    expect(phraseForMessageR292('arbitrary chat'),isNull);
  });

  testWidgets('R292 playback is opt-in, and mute disables playback',(tester)async{
    var calls=0;
    Future<bool> play(String text,String lang)async{
      calls++;
      expect(text,'السلام عليكم');
      expect(lang,'ar');
      return true;
    }
    Widget app(bool enabled)=>MaterialApp(home:Scaffold(body:PhraseSpeakButtonR292(
      phrase:'السلام عليكم',language:'ar',locale:'ar',soundEnabled:enabled,play:play,
    )));
    await tester.pumpWidget(app(false));
    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed,isNull);
    expect(calls,0);
    await tester.pumpWidget(app(true));
    expect(calls,0);
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(calls,1);
    expect(tester.takeException(),isNull);
  });

  for(final locale in ['ar','en']){
    for(final brightness in Brightness.values){
      testWidgets('R291 picker 320 portrait $locale $brightness',(tester)async{
        tester.view.physicalSize=const Size(320,640);
        tester.view.devicePixelRatio=1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        String? selected;
        await tester.pumpWidget(MaterialApp(theme:ThemeData(brightness:brightness),home:Scaffold(body:MediaQuery(
          data:const MediaQueryData(size:Size(320,640),disableAnimations:true),
          child:ChatExpressionsR291(locale:locale,soundEnabled:false,groups:const [('Existing',['😀'])],onSelected:(v)=>selected=v),
        ))));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('r291-glyph-0')));
        expect(selected,'😂');
        await tester.tap(find.byKey(const ValueKey('r291-expression-tab-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('r291-phrase-0')));
        expect(selected,locale=='ar'?'👋 السلام عليكم':'👋 Peace be upon you');
        expect(tester.takeException(),isNull);
      });
    }
  }
}
