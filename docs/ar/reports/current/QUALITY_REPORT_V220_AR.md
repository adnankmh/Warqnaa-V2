# تقرير جودة Warqnaa R10 — Build 220

## الهدف

R10 يعيد بناء تسليم الصور والصوت لتقليل حجم التطبيق والموقع مع المحافظة على R9.1 ومحركات R8 وجميع ميزات المتجر/التحديات/الإدارة الموجودة.

## نتائج الحجم

- Flutter assets المعلنة فعلياً في `pubspec.yaml`: **12.68 MiB**.
- قبل R10 كانت طبقة runtime assets قرابة **50.98 MiB**؛ الانخفاض في الطبقة المضمنة يقارب **75%**.
- WebP المحسنة داخل `assets/optimized/r10`: **10.45 MiB**.
- OGG داخل `assets/sounds/r10`: **0.26 MiB**.
- Laravel `public` runtime: **8.57 MiB** بعد نقل صور المتجر إلى WebP وحذف النسخ العامة الثقيلة المستبدلة.
- Asset Manifest: **205** أصل، منها **134 on-demand** و**71 core**.
- الرسومات الأصلية التاريخية تبقى محفوظة في Source Repository ولا تُحمّل كلها داخل APK/AAB.

## بنية R10

- Asset Manifest مركزي + Version + SHA-256 + Local/Remote path + thumbnails.
- CDN اختياري بنمط `local / hybrid / remote` مع fallback محلي.
- Data Saver في Flutter واستخدام thumbnail عند الإمكان.
- فحص SHA-256 للملف البعيد قبل عرضه.
- Memory cache محدود لمنع نمو الذاكرة بلا سقف.
- Endpoint للـmanifest مع ETag وCache-Control.
- WebP للمتجر وLazy Loading في الويب.
- Brotli/Gzip/cache hints في Apache عند توفر الوحدات.
- أداة `tools/r10_stage_cdn.py` تجهز شجرة CDN قابلة للنشر دون تعديل يدوي.

## حماية التوافق

تم إبقاء عقود R8 وR9 وR9.1 داخل CI، بالإضافة إلى عقد R10. اختبارات المحركات وقواعد Tarneeb/Hand/Banakil تبقى جزءاً من Release Gate ولا يتم تعطيلها بهدف تقليل الحجم.

## ملاحظة Flutter

بيئة التجهيز المحلية لا تحتوي Flutter SDK، لذلك `flutter analyze` و`flutter test` الحقيقيان يبقيان بوابة GitHub Actions النهائية. العقود الساكنة وPHP syntax واختبارات المحركات وRelease Preflight يتم تشغيلها محلياً قبل التغليف.
