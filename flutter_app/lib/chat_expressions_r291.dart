import 'package:flutter/material.dart';
import 'services/app_sounds.dart';
import 'services/phrase_speech_r292.dart';

/// Text transport is deliberately unchanged; no new permissions or server API.
const animatedExpressionsR291 = <String>[
  '😂','🤣','😍','🥳','👏','🙌','👋','👍','🤝','💪','🔥','✨','🎉','💥','⚡','🌟',
  '😎','😜','🤔','😱','😴','😅','😭','😡','🥰','🤩','❤️','🌹','☕','⏳','🎯','🫡',
];
const chatPhrasesR291 = <(String,String,String)>[
  ('👋','السلام عليكم','Peace be upon you'),
  ('🤝','وعليكم السلام','And peace be upon you'),
  ('😊','مرحبا','Hello'),
  ('⏩','أسرع لو سمحت','Please hurry up'),
  ('⏳','لحظة من فضلك','One moment please'),
  ('🙏','شكرًا جزيلًا','Thank you very much'),
  ('👏','أحسنت','Well played'),
  ('🎉','مبروك','Congratulations'),
  ('💪','بالتوفيق','Good luck'),
  ('🃏','دورك الآن','Your turn now'),
  ('😅','آسف','Sorry'),
  ('🤗','ولا يهمك','No worries'),
  ('👍','تمام','All right'),
  ('🔥','لعبة رائعة','Great game'),
  ('🤔','فكر جيدًا','Think carefully'),
  ('🫡','جاهز','Ready'),
  ('☕','استراحة قصيرة','Short break'),
  ('🌹','إلى اللقاء','See you later'),
  ('😂','يا سلام','Wow'),
  ('🙌','هيا نلعب','Let us play'),
];

/// Match only known catalog messages, never arbitrary player text.
(String,String)? phraseForMessageR292(String message) {
  final body=message.trim();
  for(final (glyph,ar,en) in chatPhrasesR291){
    if(body=='$glyph $ar')return (ar,'ar');
    if(body=='$glyph $en')return (en,'en');
  }
  return null;
}

String appendExpressionR291(String draft,String expression) {
  final current=draft.trimRight();
  final next=current.isEmpty?expression:'$current $expression';
  return next.runes.length<=500?next:draft;
}

Future<String?> showChatExpressionsR291(
  BuildContext context, {
  required String locale,
  required bool soundEnabled,
  required List<(String,List<String>)> groups,
}) => showModalBottomSheet<String>(
  context:context,isScrollControlled:true,showDragHandle:true,useSafeArea:true,
  builder:(sheetContext)=>ChatExpressionsR291(
    locale:locale,soundEnabled:soundEnabled,groups:groups,
    onSelected:(value)=>Navigator.of(sheetContext).pop(value),
  ),
);

class ChatExpressionsR291 extends StatefulWidget {
  const ChatExpressionsR291({super.key,required this.locale,required this.soundEnabled,required this.groups,required this.onSelected});
  final String locale;
  final bool soundEnabled;
  final List<(String,List<String>)> groups;
  final ValueChanged<String> onSelected;
  @override
  State<ChatExpressionsR291> createState()=>_ChatExpressionsR291State();
}

class _ChatExpressionsR291State extends State<ChatExpressionsR291> {
  int tab=0;
  bool get ar=>widget.locale=='ar';
  void pick(String value){
    if(widget.soundEnabled)AppSounds.fire('emoji');
    widget.onSelected(value);
  }
  @override
  Widget build(BuildContext context){
    final scheme=Theme.of(context).colorScheme;
    final height=MediaQuery.sizeOf(context).height;
    final labels=[ar?'متحركة':'Animated',ar?'عبارات':'Phrases',...widget.groups.map((g)=>g.$1)];
    final glyphs=tab==0?animatedExpressionsR291:tab==1?const <String>[]:widget.groups[tab-2].$2;
    return Directionality(
      textDirection:ar?TextDirection.rtl:TextDirection.ltr,
      child:SizedBox(
        height:(height*.68).clamp(160.0,440.0).toDouble(),
        child:Column(children:[
          Padding(padding:const EdgeInsets.symmetric(horizontal:12),child:Row(children:[
            Icon(Icons.emoji_emotions_outlined,color:scheme.primary),
            const SizedBox(width:8),
            Expanded(child:Text(ar?'تعبيرات ورقنا':'Warqnaa expressions',style:Theme.of(context).textTheme.titleMedium)),
          ])),
          SizedBox(height:48,child:ListView.separated(
            scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:12),
            itemCount:labels.length,separatorBuilder:(_,__)=>const SizedBox(width:6),
            itemBuilder:(_,i)=>ChoiceChip(key:ValueKey('r291-expression-tab-$i'),label:Text(labels[i]),selected:tab==i,onSelected:(_)=>setState(()=>tab=i)),
          )),
          Expanded(child:tab==1
            ? ListView.builder(
              key:const ValueKey('r291-phrase-list'),padding:const EdgeInsets.symmetric(horizontal:12),
              itemCount:chatPhrasesR291.length,itemBuilder:(_,i){
                final (glyph,a,b)=chatPhrasesR291[i];final text=ar?a:b;
                return ListTile(
                  key:ValueKey('r291-phrase-$i'),
                  leading:Text(glyph,style:const TextStyle(fontSize:26)),
                  title:Text(text),
                  trailing:PhraseSpeakButtonR292(
                    phrase:text,language:ar?'ar':'en',locale:widget.locale,
                    soundEnabled:widget.soundEnabled,
                  ),
                  onTap:()=>pick('$glyph $text'),
                );
              })
            : GridView.builder(
              key:ValueKey('r291-glyph-grid-$tab'),padding:const EdgeInsets.all(10),
              gridDelegate:const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent:74,crossAxisSpacing:6,mainAxisSpacing:6),
              itemCount:glyphs.length,itemBuilder:(_,i){
                final glyph=glyphs[i];
                return Material(color:scheme.surfaceContainerHighest,borderRadius:BorderRadius.circular(12),child:InkWell(
                  key:ValueKey('r291-glyph-$i'),borderRadius:BorderRadius.circular(12),onTap:()=>pick(glyph),
                  child:Center(child:tab==0?ExpressionMotionR291(glyph:glyph,variant:i%5):Text(glyph,style:const TextStyle(fontSize:28))),
                ));
              })),
        ]),
      ),
    );
  }
}

/// Finite entry motion, honoring OS accessibility preferences.
class ExpressionMotionR291 extends StatelessWidget {
  const ExpressionMotionR291({super.key,required this.glyph,required this.variant});
  final String glyph;
  final int variant;
  @override
  Widget build(BuildContext context){
    final child=Text(glyph,style:const TextStyle(fontSize:28));
    if(MediaQuery.disableAnimationsOf(context))return child;
    return TweenAnimationBuilder<double>(
      tween:Tween(begin:0,end:1),duration:const Duration(milliseconds:450),curve:Curves.easeInOut,
      child:child,builder:(context,t,child){
        final phase=1-(2*t-1).abs();
        return switch(variant){
          0=>Transform.translate(offset:Offset(0,-5*phase),child:child),
          1=>Transform.translate(offset:Offset(3*phase,0),child:child),
          2=>Transform.scale(scale:1+.12*phase,child:child),
          3=>Transform.rotate(angle:.22*phase,child:child),
          _=>Transform.rotate(angle:-.3*phase,child:child),
        };
      },
    );
  }
}


/// A separate, explicit listening control; tapping it never sends a message.
class PhraseSpeakButtonR292 extends StatefulWidget {
  const PhraseSpeakButtonR292({super.key,required this.phrase,required this.language,required this.locale,required this.soundEnabled,this.play});
  final String phrase,language,locale;
  final bool soundEnabled;
  final Future<bool> Function(String,String)? play;
  @override
  State<PhraseSpeakButtonR292> createState()=>_PhraseSpeakButtonR292State();
}
class _PhraseSpeakButtonR292State extends State<PhraseSpeakButtonR292>{
  bool busy=false;
  bool get ar=>widget.locale=='ar';
  Future<void> listen()async{
    if(busy||!widget.soundEnabled)return;
    setState(()=>busy=true);
    var ok=false;
    try{
      ok=await (widget.play??PhraseSpeechR292.play)(widget.phrase,widget.language);
    }catch(_){}
    if(!mounted)return;
    setState(()=>busy=false);
    if(!ok){
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
        content:Text(ar?'الصوت غير متاح الآن. تحقق من لغة النطق وإعدادات الصوت.':'Speech is unavailable. Check device voices and sound settings.'),
      ));
    }
  }
  @override
  Widget build(BuildContext context)=>IconButton(
    tooltip:!widget.soundEnabled?(ar?'الصوت مغلق':'Sound disabled'):(ar?'استمع إلى العبارة':'Listen to phrase'),
    onPressed:widget.soundEnabled&&!busy?listen:null,
    icon:Icon(!widget.soundEnabled?Icons.volume_off_outlined:Icons.volume_up_outlined),
  );
}
