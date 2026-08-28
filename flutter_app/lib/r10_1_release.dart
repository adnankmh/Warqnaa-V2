part of 'main.dart';

const String warqnaaR101Release = '0.5.1+221';

/// R10.1 keeps unfinished server-dependent titles out of the customer lobby.
List<GameInfo> get customerGamesR101 => gamesCatalog.where((game) => !game.serverOnly && !b304BannedCustomerGames.contains(game.id)).toList(growable: false);

class R101ThemeSpec {
  const R101ThemeSpec({required this.code, required this.accent, required this.accent2, required this.background, required this.surface, required this.light});
  final String code;
  final Color accent;
  final Color accent2;
  final Color background;
  final Color surface;
  final bool light;
}

const Map<String, R101ThemeSpec> r101Themes = <String, R101ThemeSpec>{
  'dark': R101ThemeSpec(code:'dark',accent:Color(0xffe9c46a),accent2:Color(0xff2a9d8f),background:Color(0xff07111d),surface:Color(0xff111e2e),light:false),
  'light': R101ThemeSpec(code:'light',accent:Color(0xff8b5e34),accent2:Color(0xff0f766e),background:Color(0xfff3eee5),surface:Color(0xfffffbf4),light:true),
  'green': R101ThemeSpec(code:'green',accent:Color(0xff34d399),accent2:Color(0xffd4af37),background:Color(0xff03261c),surface:Color(0xff084936),light:false),
  'gold': R101ThemeSpec(code:'gold',accent:Color(0xfff5c75b),accent2:Color(0xffc08457),background:Color(0xff211709),surface:Color(0xff3a2a12),light:false),
  'purple': R101ThemeSpec(code:'purple',accent:Color(0xffc4a7ff),accent2:Color(0xffff7ab8),background:Color(0xff160f2b),surface:Color(0xff2b2050),light:false),
  'classic': R101ThemeSpec(code:'classic',accent:Color(0xfff3d27a),accent2:Color(0xffb24a4a),background:Color(0xff10221b),surface:Color(0xff19382b),light:false),
  'ocean': R101ThemeSpec(code:'ocean',accent:Color(0xff38bdf8),accent2:Color(0xff22d3ee),background:Color(0xff041b2d),surface:Color(0xff0b2d45),light:false),
  'sky': R101ThemeSpec(code:'sky',accent:Color(0xff0284c7),accent2:Color(0xff0ea5e9),background:Color(0xffe0f2fe),surface:Color(0xfff0f9ff),light:true),
  'forest': R101ThemeSpec(code:'forest',accent:Color(0xff84cc16),accent2:Color(0xff22c55e),background:Color(0xff102a16),surface:Color(0xff183c20),light:false),
  'desert': R101ThemeSpec(code:'desert',accent:Color(0xffd97706),accent2:Color(0xfff59e0b),background:Color(0xff2b1b0f),surface:Color(0xff4a2f18),light:false),
  'rose': R101ThemeSpec(code:'rose',accent:Color(0xfffb7185),accent2:Color(0xfff472b6),background:Color(0xff2c0b17),surface:Color(0xff4c1024),light:false),
  'graphite': R101ThemeSpec(code:'graphite',accent:Color(0xff94a3b8),accent2:Color(0xff64748b),background:Color(0xff0f172a),surface:Color(0xff1e293b),light:false),
  'royal_blue': R101ThemeSpec(code:'royal_blue',accent:Color(0xff60a5fa),accent2:Color(0xff818cf8),background:Color(0xff0a1740),surface:Color(0xff13275a),light:false),
  'emerald_light': R101ThemeSpec(code:'emerald_light',accent:Color(0xff047857),accent2:Color(0xff0d9488),background:Color(0xffecfdf5),surface:Color(0xfff0fdfa),light:true),
  'sunset': R101ThemeSpec(code:'sunset',accent:Color(0xffff8a4c),accent2:Color(0xfff43f5e),background:Color(0xff2a0d14),surface:Color(0xff4b1720),light:false),
};

ThemeData r101Theme(String code, String fallbackAccentHex) {
  final fallbackAccent = colorFromHex(fallbackAccentHex);
  final spec = r101Themes[code] ?? R101ThemeSpec(
    code: code,
    accent: fallbackAccent,
    accent2: fallbackAccent,
    background: const Color(0xff07111d),
    surface: const Color(0xff111e2e),
    light: false,
  );
  final base = R9Design.theme(light: spec.light, accent: spec.accent);
  final scheme = base.colorScheme.copyWith(
    primary: spec.accent,
    secondary: spec.accent2,
    surface: spec.surface,
    onSurface: spec.light ? const Color(0xff241f1a) : const Color(0xfff7f4ed),
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: spec.background,
    cardTheme: base.cardTheme.copyWith(color: spec.surface.withValues(alpha: spec.light ? .94 : .88)),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      backgroundColor: Color.lerp(spec.surface, spec.background, .22),
      indicatorColor: spec.accent.withValues(alpha: .18),
    ),
    appBarTheme: base.appBarTheme.copyWith(foregroundColor: scheme.onSurface),
    dialogTheme: base.dialogTheme.copyWith(backgroundColor: Color.lerp(spec.surface, spec.background, .08)),
    bottomSheetTheme: base.bottomSheetTheme.copyWith(
      backgroundColor: Color.lerp(spec.surface, spec.background, .08),
      modalBackgroundColor: Color.lerp(spec.surface, spec.background, .08),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: Color.lerp(spec.surface, spec.background, spec.light ? .08 : .20),
      labelStyle: TextStyle(color: scheme.onSurface.withValues(alpha: .72), fontWeight: FontWeight.w700),
      prefixIconColor: spec.accent,
      suffixIconColor: scheme.onSurface.withValues(alpha: .66),
    ),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
      backgroundColor: spec.accent,
      foregroundColor: spec.light ? Colors.white : const Color(0xff111111),
      textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      minimumSize: const Size(44, 46),
    )),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
      foregroundColor: scheme.onSurface,
      side: BorderSide(color: spec.accent.withValues(alpha: .36)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      minimumSize: const Size(44, 46),
    )),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(
      foregroundColor: spec.accent,
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    )),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: spec.surface,
      selectedColor: spec.accent.withValues(alpha: .22),
      side: BorderSide(color: spec.accent.withValues(alpha: .22)),
      labelStyle: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w800),
    ),
    listTileTheme: base.listTileTheme.copyWith(
      textColor: scheme.onSurface,
      iconColor: spec.accent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
    ),
    snackBarTheme: base.snackBarTheme.copyWith(
      backgroundColor: Color.lerp(spec.surface, spec.background, .18),
      contentTextStyle: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior: SnackBarBehavior.floating,
    ),
    dividerColor: spec.accent.withValues(alpha: .16),
    pageTransitionsTheme: const PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      TargetPlatform.linux: ZoomPageTransitionsBuilder(),
    }),
  );
}

String r101GameArtAsset(String gameId) => 'assets/optimized/r101/games/$gameId.webp';

class R101CommercialOffer {
  const R101CommercialOffer({required this.key, required this.titleAr, required this.titleEn, required this.subtitleAr, required this.subtitleEn, required this.badge, required this.priceLabel, required this.icon, required this.cadence});
  final String key;
  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;
  final String badge;
  final String priceLabel;
  final String icon;
  final String cadence;
}

const List<R101CommercialOffer> r101CommercialOffers = <R101CommercialOffer>[
  R101CommercialOffer(key:'daily',titleAr:'عرض اليوم',titleEn:'Daily Drop',subtitleAr:'توكنز + مسرّع قصير + فرصة صندوق',subtitleEn:'Tokens + short booster + box chance',badge:'24H',priceLabel:'US\$0.99',icon:'☀️',cadence:'daily'),
  R101CommercialOffer(key:'weekly',titleAr:'حزمة الأسبوع',titleEn:'Weekly Bundle',subtitleAr:'توكنز أكثر + طاولة مؤقتة + إيموت متحرك',subtitleEn:'More tokens + temporary table + animated emote',badge:'7D',priceLabel:'US\$3.99',icon:'✨',cadence:'weekly'),
  R101CommercialOffer(key:'monthly',titleAr:'حزمة النخبة',titleEn:'Monthly Elite',subtitleAr:'مقتنيات موسمية + تذاكر + مسرّعات',subtitleEn:'Seasonal cosmetics + tickets + boosters',badge:'30D',priceLabel:'US\$9.99',icon:'💎',cadence:'monthly'),
  R101CommercialOffer(key:'annual',titleAr:'عام ورقنا',titleEn:'Warqnaa Year',subtitleAr:'هوية سنوية حصرية ومكافآت شهرية بدون أفضلية لعب',subtitleEn:'Annual identity and monthly rewards with no gameplay advantage',badge:'365D',priceLabel:'US\$39.99',icon:'👑',cadence:'annual'),
];

class R101CommerceShowcase extends StatelessWidget {
  const R101CommerceShowcase({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ar = controller.localeCode == 'ar';
    return R9Section(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children:[
          Container(width:42,height:42,decoration:BoxDecoration(borderRadius:BorderRadius.circular(14),gradient:LinearGradient(colors:[Theme.of(context).colorScheme.primary,Theme.of(context).colorScheme.secondary])),child:const Icon(Icons.workspace_premium_outlined,color:Colors.black87)),
          const SizedBox(width:10),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(ar?'العروض والشراء الحقيقي':'Offers & real-money store',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:16)),Text(ar?'الدفع الحقيقي يبقى معتمدًا على التحقق الخادمي من الإيصال.':'Real-money purchases remain server receipt-verified.',style:TextStyle(fontSize:10,color:Theme.of(context).colorScheme.onSurface.withValues(alpha:.62)))])),
        ]),
        const SizedBox(height:12),
        SizedBox(height:164,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:r101CommercialOffers.length,separatorBuilder:(_,__)=>const SizedBox(width:10),itemBuilder:(context,index){
          final offer=r101CommercialOffers[index];
          return Container(width:238,padding:const EdgeInsets.all(14),decoration:BoxDecoration(borderRadius:BorderRadius.circular(22),gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Theme.of(context).colorScheme.primary.withValues(alpha:.18),Theme.of(context).colorScheme.surface,Theme.of(context).colorScheme.secondary.withValues(alpha:.11)]),border:Border.all(color:Theme.of(context).colorScheme.primary.withValues(alpha:.22))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Text(offer.icon,style:const TextStyle(fontSize:28)),const Spacer(),Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(borderRadius:BorderRadius.circular(99),color:Colors.black.withValues(alpha:.18)),child:Text(offer.badge,style:const TextStyle(fontSize:9,fontWeight:FontWeight.w900)))]),const SizedBox(height:8),Text(ar?offer.titleAr:offer.titleEn,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:14)),const SizedBox(height:3),Text(ar?offer.subtitleAr:offer.subtitleEn,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:9,height:1.35,color:Theme.of(context).colorScheme.onSurface.withValues(alpha:.68))),const Spacer(),Row(children:[Text(offer.priceLabel,style:TextStyle(fontWeight:FontWeight.w900,color:Theme.of(context).colorScheme.primary)),const Spacer(),Icon(Icons.lock_outline_rounded,size:15,color:Theme.of(context).colorScheme.onSurface.withValues(alpha:.42))]) ]));
        })),
      ]),
    );
  }
}
