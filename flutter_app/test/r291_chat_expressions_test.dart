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
