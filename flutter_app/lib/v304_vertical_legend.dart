part of 'main.dart';

/// B304 keeps Arabic and English as the only active product locales.
/// Additional locales can be re-enabled later by adding them to this set and
/// completing the translation audit; the inactive list is metadata only.
const Set<String> b304ActiveLocaleCodes = <String>{'ar', 'en'};
const Set<String> b304FutureLocaleCodes = <String>{'de', 'tr', 'fr', 'es'};
const Set<String> b304BannedCustomerGames = <String>{'jackaroo', 'backgammon', 'domino', 'chess'};

const List<String> b304VerticalTableIds = <String>[
  'b304_table_aurora',
  'b304_table_obsidian',
  'b304_table_royal',
  'b304_table_emerald',
  'b304_table_crimson',
  'b304_table_desert',
  'b304_table_ocean',
  'b304_table_phoenix',
  'b304_table_sapphire',
  'b304_table_palace',
];
const String b304CardBackId = 'b304_cardback_vertical';

const List<StoreProduct> b304VerticalStoreProducts = <StoreProduct>[
  StoreProduct(id:'b304_table_aurora',category:'tables',icon:'🌌',nameAr:'طاولة الشفق العمودية',nameEn:'Vertical Aurora Table',descriptionAr:'طاولة رأسية فاخرة بإضاءة شفق هادئة ومساحة لعب واضحة.',descriptionEn:'Premium portrait table with refined aurora lighting and a clear play zone.',price:180000,value:'b304_table_aurora',previewColor1:Color(0xff062b31),previewColor2:Color(0xff67e8f9),collection:'b304_vertical'),
  StoreProduct(id:'b304_table_obsidian',category:'tables',icon:'◆',nameAr:'طاولة الأوبسيديان العمودية',nameEn:'Vertical Obsidian Table',descriptionAr:'طاولة سوداء معدنية بحدود مضيئة وتباين احترافي.',descriptionEn:'Metallic black portrait table with luminous borders and professional contrast.',price:240000,value:'b304_table_obsidian',previewColor1:Color(0xff020617),previewColor2:Color(0xff94a3b8),collection:'b304_vertical'),
  StoreProduct(id:'b304_table_royal',category:'tables',icon:'👑',nameAr:'طاولة التاج الملكي',nameEn:'Royal Crown Vertical Table',descriptionAr:'هوية ملكية زرقاء وذهبية مخصصة للوضع الرأسي.',descriptionEn:'Royal blue-and-gold portrait table built for vertical gameplay.',price:320000,value:'b304_table_royal',previewColor1:Color(0xff0b1f4d),previewColor2:Color(0xfffacc15),collection:'b304_vertical'),
  StoreProduct(id:'b304_table_emerald',category:'tables',icon:'💚',nameAr:'طاولة الزمرد العمودية',nameEn:'Emerald Vertical Table',descriptionAr:'زمرد عميق مع مركز لعب نظيف وحواف هادئة.',descriptionEn:'Deep emerald portrait table with a clean center and subtle framing.',price:380000,value:'b304_table_emerald',previewColor1:Color(0xff052e26),previewColor2:Color(0xff10b981),collection:'b304_vertical'),
  StoreProduct(id:'b304_table_crimson',category:'tables',icon:'🔥',nameAr:'طاولة القرمزي العمودية',nameEn:'Crimson Vertical Table',descriptionAr:'قرمزي داكن مع توهج ذهبي خفيف للبطولات.',descriptionEn:'Dark crimson portrait table with a subtle golden competitive glow.',price:460000,value:'b304_table_crimson',previewColor1:Color(0xff3f0712),previewColor2:Color(0xfffb7185),collection:'b304_vertical'),
  StoreProduct(id:'b304_table_desert',category:'tables',icon:'🏜️',nameAr:'طاولة الصحراء الملكية',nameEn:'Royal Desert Vertical Table',descriptionAr:'رمال ذهبية وهوية عربية راقية بتنسيق رأسي.',descriptionEn:'Golden sand and refined Arab-inspired styling in a portrait layout.',price:540000,value:'b304_table_desert',previewColor1:Color(0xff3b2410),previewColor2:Color(0xffd97706),collection:'b304_vertical'),
  StoreProduct(id:'b304_table_ocean',category:'tables',icon:'🌊',nameAr:'طاولة المحيط العمودية',nameEn:'Ocean Vertical Table',descriptionAr:'درجات بحرية عميقة مع لمعان سماوي هادئ.',descriptionEn:'Deep ocean tones with calm cyan highlights for portrait gameplay.',price:620000,value:'b304_table_ocean',previewColor1:Color(0xff06233a),previewColor2:Color(0xff22d3ee),collection:'b304_vertical'),
  StoreProduct(id:'b304_table_phoenix',category:'tables',icon:'🦅',nameAr:'طاولة العنقاء العمودية',nameEn:'Phoenix Vertical Table',descriptionAr:'تدرج ناري أسطوري وحواف مضيئة دون تشتيت اللعب.',descriptionEn:'Legendary fire gradient and luminous edges without distracting gameplay.',price:760000,value:'b304_table_phoenix',previewColor1:Color(0xff450a0a),previewColor2:Color(0xffff7a18),collection:'b304_vertical'),
  StoreProduct(id:'b304_table_sapphire',category:'tables',icon:'💎',nameAr:'طاولة الياقوت العمودية',nameEn:'Sapphire Vertical Table',descriptionAr:'أزرق ياقوتي متوازن مع مظهر بطولة عالمي.',descriptionEn:'Balanced sapphire-blue portrait table with a global tournament look.',price:880000,value:'b304_table_sapphire',previewColor1:Color(0xff172554),previewColor2:Color(0xff60a5fa),collection:'b304_vertical'),
  StoreProduct(id:'b304_table_palace',category:'tables',icon:'🏰',nameAr:'طاولة القصر الأسطورية',nameEn:'Legendary Palace Vertical Table',descriptionAr:'أفخم طاولة B304 بتفاصيل ذهبية ومساحة لعب رأسية كاملة.',descriptionEn:'The flagship B304 portrait table with premium gold detailing and a full play field.',price:1000000,value:'b304_table_palace',previewColor1:Color(0xff2a1805),previewColor2:Color(0xffffd166),collection:'b304_vertical'),
  StoreProduct(id:b304CardBackId,category:'cards',icon:'🂠',nameAr:'ظهر ورق VERTICAL LEGEND',nameEn:'VERTICAL LEGEND Card Back',descriptionAr:'ظهر الورق الرسمي الوحيد في B304، مصمم للوضوح في الوضع الرأسي.',descriptionEn:'The single official B304 card back, optimized for clear portrait play.',price:0,value:b304CardBackId,previewColor1:Color(0xff071827),previewColor2:Color(0xffd6aa59),collection:'b304_vertical'),
  StoreProduct(id:'b304_profile_aurora_30d',category:'profile_colors',icon:'🌈',nameAr:'لون بروفايل الشفق',nameEn:'Aurora Profile Color',descriptionAr:'تدرج هادئ يملأ بطاقة البروفايل لمدة 30 يومًا.',descriptionEn:'A refined gradient that fills the profile card for 30 days.',price:100000,durationDays:30,value:'#0f766e|#67e8f9',previewColor1:Color(0xff0f766e),previewColor2:Color(0xff67e8f9),collection:'b304_profile'),
  StoreProduct(id:'b304_profile_royal_30d',category:'profile_colors',icon:'👑',nameAr:'لون بروفايل ملكي',nameEn:'Royal Profile Color',descriptionAr:'أزرق ملكي مع ذهبي خفيف لمدة 30 يومًا.',descriptionEn:'Royal blue with subtle gold for 30 days.',price:140000,durationDays:30,value:'#172554|#facc15',previewColor1:Color(0xff172554),previewColor2:Color(0xfffacc15),collection:'b304_profile'),
  StoreProduct(id:'b304_profile_emerald_30d',category:'profile_colors',icon:'💚',nameAr:'لون بروفايل زمردي',nameEn:'Emerald Profile Color',descriptionAr:'زمرد عميق متدرج لمدة 30 يومًا.',descriptionEn:'Deep emerald profile gradient for 30 days.',price:170000,durationDays:30,value:'#052e26|#10b981',previewColor1:Color(0xff052e26),previewColor2:Color(0xff10b981),collection:'b304_profile'),
  StoreProduct(id:'b304_profile_crimson_30d',category:'profile_colors',icon:'🔥',nameAr:'لون بروفايل قرمزي',nameEn:'Crimson Profile Color',descriptionAr:'قرمزي فاخر مع توهج دافئ لمدة 30 يومًا.',descriptionEn:'Premium crimson gradient with a warm glow for 30 days.',price:210000,durationDays:30,value:'#450a0a|#fb7185',previewColor1:Color(0xff450a0a),previewColor2:Color(0xfffb7185),collection:'b304_profile'),
  StoreProduct(id:'b304_profile_obsidian_30d',category:'profile_colors',icon:'◆',nameAr:'لون بروفايل أوبسيديان',nameEn:'Obsidian Profile Color',descriptionAr:'أسود معدني متدرج لمدة 30 يومًا.',descriptionEn:'Metallic obsidian profile gradient for 30 days.',price:260000,durationDays:30,value:'#020617|#64748b',previewColor1:Color(0xff020617),previewColor2:Color(0xff64748b),collection:'b304_profile'),
  StoreProduct(id:'b304_profile_legend_30d',category:'profile_colors',icon:'💎',nameAr:'لون بروفايل الأسطورة',nameEn:'Legend Profile Color',descriptionAr:'تدرج ألماسي أسطوري لمدة 30 يومًا.',descriptionEn:'Legendary diamond profile gradient for 30 days.',price:320000,durationDays:30,value:'#1e1b4b|#c4b5fd',previewColor1:Color(0xff1e1b4b),previewColor2:Color(0xffc4b5fd),collection:'b304_profile'),
];

List<Color> b304ProfileGradient(AppController controller) {
  final product = storeProductById(controller.selectedProfileColorB304);
  return <Color>[
    product?.previewColor1 ?? const Color(0xff0f172a),
    product?.previewColor2 ?? const Color(0xff334155),
  ];
}

class B304HomeDashboard extends StatelessWidget {
  const B304HomeDashboard({super.key, required this.controller, required this.onTab});
  final AppController controller;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    final games = customerGamesR101;
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(colors: <Color>[Theme.of(context).colorScheme.surfaceContainerHighest, Theme.of(context).colorScheme.surface]),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: .22)),
              ),
              child: Row(children: <Widget>[
                Container(width: 54,height:54,decoration:BoxDecoration(shape:BoxShape.circle,gradient:LinearGradient(colors:<Color>[Theme.of(context).colorScheme.primary,Theme.of(context).colorScheme.secondary])),child:const Icon(Icons.style_rounded,color:Colors.black,size:28)),
                const SizedBox(width: 13),
                Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:<Widget>[
                  Text(ar ? 'Warqnaa • VERTICAL LEGEND' : 'Warqnaa • VERTICAL LEGEND',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:18)),
                  const SizedBox(height:4),
                  Text(ar ? 'اختر لعبتك وابدأ مباشرة. واجهة واضحة، منافسات، جوائز وتجربة لعب خادمية عادلة.' : 'Choose a game and play. Clear UI, competitions, rewards and fair server-authoritative gameplay.',style:TextStyle(fontSize:11,height:1.45,color:Theme.of(context).colorScheme.onSurface.withValues(alpha:.68))),
                ])),
                IconButton(onPressed:()=>showNotifications(context,controller),icon:const Icon(Icons.notifications_none_rounded)),
              ]),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal:14,vertical:6),
          sliver: SliverToBoxAdapter(child:Wrap(spacing:8,runSpacing:8,children:<Widget>[
            FilledButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>R12CompetitiveArenaPage(controller:controller))),icon:const Icon(Icons.emoji_events_outlined),label:Text(ar?'المسابقات':'Competitions')),
            OutlinedButton.icon(onPressed:()=>onTab(0),icon:const Icon(Icons.storefront_outlined),label:Text(ar?'المتجر':'Store')),
            OutlinedButton.icon(onPressed:()=>Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>PrizeBoxesPageV02(controller:controller))),icon:const Icon(Icons.inventory_2_outlined),label:Text(ar?'الصناديق':'Prize boxes')),
            OutlinedButton.icon(onPressed:()=>Navigator.of(context).push(MaterialPageRoute<void>(builder:(_)=>LuckyWheelPageV182(controller:controller))),icon:const Icon(Icons.casino_outlined),label:Text(ar?'الدولاب':'Wheel')),
          ])),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(14,10,14,6),
          sliver: SliverToBoxAdapter(child:Row(children:<Widget>[
            Expanded(child:Text(ar?'الألعاب':'Games',style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900))),
            Text('${games.length}',style:TextStyle(color:Theme.of(context).colorScheme.primary,fontWeight:FontWeight.w900)),
          ])),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(14,0,14,18),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context,index){final game=games[index];return GameCard(game:game,lang:controller.localeCode,onTap:()=>showGameLobby(context,controller,game));},childCount:games.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:MediaQuery.sizeOf(context).width>=900?4:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:.92),
          ),
        ),
      ],
    );
  }
}
