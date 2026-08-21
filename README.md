# Warqnaa V0.5.1+221 — R10.1 Commerce & Visual Experience

الإصدار الحالي: **0.5.1+221**


R10.1 يبني فوق R10 بدون حذف ميزاته: يضيف Commerce/Ads foundation بتحقق إيصالات خادمي، عروض يومية/أسبوعية/شهرية/سنوية، صور حديثة منفصلة لكل لعبة، إخفاء الألعاب Server-only من واجهة العميل، ثيمات كاملة موحدة، طاولات Portrait/Landscape بصور داخلية متناسبة لا تغطي السطح، معاينة صورة شخصية دائرية، وواجهة إدارة موسعة للتجارة والإعلانات.

R10 يبني مباشرة فوق R9.1 Build 210 ويحافظ على كل محركات اللعب والمتجر والإدارة والتحديات والاقتصاد الموجودة، ثم يعيد بناء طريقة تسليم الصور والأصوات لتقليل حجم التطبيق والويب بدون التضحية بالأصول الأصلية.

## إضافات R10.1 النهائية

- 18 Game Covers مستقلة في التطبيق والويب.
- Server-only games مخفية من واجهات العملاء، مع بقاء تحكم المدير وActive state محفوظاً.
- طاولات هاتف Portrait وLandscape/desktop عريضة مع artwork inlay متناسب.
- 6 ثيمات كاملة مشتركة بين Flutter وLaravel.
- Avatar دائري مع live preview.
- Commerce + server receipt verification + daily/weekly/monthly/annual offers.
- Rewarded ads وInterstitial محدود بعد الخروج فقط، بدون إعلان أثناء اللعب.
- Lucky Wheel بـ12 جائزة متزامنة مع السيرفر.
- Command Center موسع للتجارة والإعلانات إضافة إلى أدوات الإدارة السابقة.

## أهم ما تغير في R10

- Flutter يشحن WebP/OGG محسنة بدل مجلدات الصور/WAV الثقيلة داخل APK/AAB.
- الأصول المعلنة فعلياً في `pubspec.yaml` انخفضت إلى نحو **12.7 MiB** بدل نحو **51 MiB** قبل R10.
- الرسومات الأصلية ما زالت محفوظة في المصدر لإعادة التوليد والمراجعة، لكنها لا تدخل كلها إلى حزمة التطبيق.
- Asset Manifest مركزي Versioned + SHA-256 + thumbnails + local/remote paths.
- Remote/CDN-ready delivery مع Local fallback وعدم تعطيل اللعب عند غياب CDN.
- Data Saver داخل Flutter وصور مصغرة للمقتنيات الاختيارية.
- ضغط أصوات اللعبة إلى OGG مع بقاء نظام الصوت السابق ووظائفه.
- Laravel public runtime أخف ويستخدم WebP للمتجر مع Lazy Loading وBrotli/Gzip/immutable caching hints.
- Endpoint عام للـAsset Manifest مع ETag وCache-Control.
- أدوات إعادة توليد الأصول والـmanifest وتجهيز مجلد CDN للنشر.
- جميع عقود R8 وR9 وR9.1 تبقى ضمن بوابات CI ولا يتم تجاوزها.

## تشغيل سريع

1. ضع المشروع في `C:\\xampp\\htdocs\\Warqnaa`.
2. شغّل `START_WARQNA_WINDOWS.bat`.
3. اختر أحد المنافذ 8007–8010.
4. قبل GitHub شغّل `CHECK_WARQNA_WINDOWS.bat`.

لإعداد CDN لاحقاً راجع:

`docs/ar/deployment/R10_CDN_SETUP_AR.md`
