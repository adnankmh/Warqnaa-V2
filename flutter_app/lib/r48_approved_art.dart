part of 'main.dart';

/// Same catalogue identifiers, ownership and prices; only artwork is replaced.
const r48ApprovedTables = <String, String>{
  'table_v173_royal_09': 'purple',
  'table_v173_royal_21': 'ocean',
  'table_v173_showcase_04': 'eagle',
};

String? r48TableDesign(String id) => r48ApprovedTables[id.replaceFirst('r61_cardback_', '')];

String r48TableAsset(String design, {required bool portrait}) =>
    'assets/optimized/r48/${design}_${portrait ? 'portrait' : 'landscape'}.webp';

class R48ApprovedTableArt extends StatelessWidget {
  const R48ApprovedTableArt({super.key, required this.design, this.portrait});
  final String design;
  final bool? portrait;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final vertical = portrait ?? constraints.maxHeight > constraints.maxWidth;
    return ClipRRect(
      borderRadius: BorderRadius.circular(design == 'eagle' && !vertical ? constraints.maxHeight * .43 : 18),
      child: Image.asset(
        r48TableAsset(design, portrait: vertical),
        key: ValueKey('r48-table-$design-${vertical ? 'portrait' : 'landscape'}'),
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
        excludeFromSemantics: true,
      ),
    );
  });
}

/// These are the server catalogue's explicit tags, never inferred from price,
/// list order or a localized promotional badge.
List<Map<String, dynamic>> r48FilterCashPackages(List<Map<String, dynamic>> packages, String category) =>
    packages.where((item) => category == 'all' ||
      (item['categories'] is List && (item['categories'] as List).contains(category))).toList(growable: false);

const r48StorePanel = Color(0xff103d62);
const r48StoreTile = Color(0xff164d76);

/// The main storefront uses the same live catalogue as the checkout page.
/// Legacy marketing examples never become purchasable prices or entitlements.
class R48LiveCashOffers extends StatefulWidget {
  const R48LiveCashOffers({super.key, required this.controller});
  final AppController controller;
  @override
  State<R48LiveCashOffers> createState() => _R48LiveCashOffersState();
}

class _R48LiveCashOffersState extends State<R48LiveCashOffers> {
  Future<Map<String,dynamic>>? catalogue;
  late bool connected;
  @override
  void initState() { super.initState(); _load(); }
  void _load() {
    connected=widget.controller.serverConnected;
    catalogue=connected ? widget.controller.api.commerceCatalogR101() : null;
  }
  @override
  void didUpdateWidget(covariant R48LiveCashOffers oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (connected!=widget.controller.serverConnected || oldWidget.controller!=widget.controller) {
      _load();
    }
  }
  @override
  Widget build(BuildContext context) {
    final ar=widget.controller.localeCode=='ar';
    if (!connected) {
      return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(ar?'اتصل بالخادم لعرض العروض والأسعار الحالية.':'Connect to see current offers and prices.',
        style: const TextStyle(color:B307SkyLuxury.navy,fontSize:12,fontWeight:FontWeight.w700)),
      );
    }
    return FutureBuilder<Map<String,dynamic>>(
      future:catalogue,
      builder:(context,snapshot) {
        if(snapshot.connectionState!=ConnectionState.done) {
          return const SizedBox(height:80,child:Center(child:CircularProgressIndicator()));
        }
        final raw=snapshot.data?['commerce'];
        final commerce=raw is Map?raw:const <String,dynamic>{};
        final rawPackages=commerce['packages'];
        final packages=rawPackages is List?rawPackages.whereType<Map>().map((p)=>Map<String,dynamic>.from(p)).toList():<Map<String,dynamic>>[];
        if(snapshot.hasError || commerce['enabled']==false || packages.isEmpty) {
          return Padding(
          padding:const EdgeInsets.all(12),
          child:Text(ar?'لا توجد عروض متاحة حاليًا.':'No offers available right now.',style:const TextStyle(color:B307SkyLuxury.navy,fontSize:12)),
          );
        }
        return SizedBox(
          key:const ValueKey('r48-live-store-offers'),height:230,
          child:ListView.separated(
            scrollDirection:Axis.horizontal,itemCount:packages.length,
            separatorBuilder:(_,__)=>const SizedBox(width:10),
            itemBuilder:(_,index)=>SizedBox(width:244,child:B307CashOfferCard(controller:widget.controller,data:packages[index])),
          ),
        );
      },
    );
  }
}
