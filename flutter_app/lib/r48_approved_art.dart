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
