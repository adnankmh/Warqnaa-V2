part of 'main.dart';

/// V305 SINGLE TABLE — the only customer-facing gameplay surface.
/// Legacy table/card-back registries remain in source strictly for historical
/// regression and old-inventory compatibility; they are never selectable.
const String v305PremiumTableId = 'v305_table_emerald_royal';
const String v305CardBackId = 'v305_cardback_emerald_royal';
const Set<String> v305CustomerTableIds = <String>{v305PremiumTableId};

const List<StoreProduct> v305PremiumStoreProducts = <StoreProduct>[
  StoreProduct(
    id:v305PremiumTableId,
    category:'tables',
    icon:'♠',
    nameAr:'طاولة ورقنا الملكية',
    nameEn:'Warqnaa Royal Table',
    descriptionAr:'الطاولة الرسمية المجانية الوحيدة: رأسية، أخضر زمردي داكن، وحواف خشبية ذهبية هادئة لقراءة الورق بوضوح.',
    descriptionEn:'The single official free portrait table: deep emerald felt with refined wood-and-gold edging for maximum card clarity.',
    price:0,
    value:v305PremiumTableId,
    previewColor1:Color(0xff073b2b),
    previewColor2:Color(0xffb8893e),
    collection:'v305_single_table',
  ),
  StoreProduct(
    id:v305CardBackId,
    category:'cards',
    icon:'🂠',
    nameAr:'ظهر ورقنا الملكي',
    nameEn:'Warqnaa Royal Card Back',
    descriptionAr:'ظهر الورق الرسمي المجاني الوحيد، بتصميم أخضر داكن وذهبي متوافق مع الطاولة الرأسية.',
    descriptionEn:'The single official free card back, in deep emerald and gold to match the portrait table.',
    price:0,
    value:v305CardBackId,
    previewColor1:Color(0xff063326),
    previewColor2:Color(0xffd4af67),
    collection:'v305_single_table',
  ),
];
