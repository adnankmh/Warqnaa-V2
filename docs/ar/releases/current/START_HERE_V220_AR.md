# Warqnaa R10 — ابدأ من هنا

الإصدار: **0.5.0+220** — R10 Asset Delivery & Size Revolution.

يحافظ R10 على كل وظائف R9.1 Build 210 ويضيف طبقة أصول هجينة: WebP/OGG مضغوطة داخل التطبيق، Manifest بإصدارات وSHA-256، دعم CDN اختياري، Data Saver، صور مصغرة، fallback محلي، وتهيئة Cache-Control/Brotli/Gzip للموقع.

## التشغيل على Windows
شغّل `START_WARQNA_WINDOWS.bat`، أو استخدم ملفات المنافذ 8007–8010 الموجودة في `scripts/windows/current`.

## الفحص
شغّل `CHECK_WARQNA_WINDOWS.bat`. لا ترفع إلى GitHub إذا ظهر FAIL.

## CDN اختياري
اترك `WARQNA_ASSET_MODE=hybrid` بدون رابط CDN أثناء التطوير؛ التطبيق سيستخدم الملفات المضغوطة المحلية. في الإنتاج اضبط `WARQNA_ASSET_CDN_URL` إلى أصل HTTPS ثم ارفع حزمة CDN التي يولدها R10.
