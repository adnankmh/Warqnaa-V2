# Warqnaa R10 — إعداد CDN وRemote Assets

R10 لا يشترط وجود CDN حتى يعمل التطبيق. الوضع الافتراضي يبقى **Local/Hybrid مع Fallback محلي**، وبالتالي لا تتعطل الطاولات أو الورق أو الأصوات إذا لم يتم إعداد CDN بعد.

## لماذا هذه البنية؟

- التطبيق يحمل Core assets صغيرة ومحسنة WebP/OGG.
- المقتنيات الثقيلة تستطيع لاحقاً الانتقال إلى تنزيل عند الطلب.
- كل أصل له Version وSHA-256 وThumbnail ومسار Remote في `assets/manifest/r10_asset_manifest.json`.
- Data Saver يستطيع طلب Thumbnail أخف بدل النسخة الكاملة.
- فشل الشبكة أو CDN لا يكسر اللعب؛ Flutter يرجع إلى الأصل المحلي المضمن عندما يكون متاحاً.

## 1. إنشاء مجلد CDN جاهز للنشر

من جذر المشروع:

```bash
python3 tools/r10_stage_cdn.py --clean
```

سيتم إنشاء:

```text
dist/r10-cdn/
  warqnaa/r10/manifest.json
  warqnaa/r10/full/...
  warqnaa/r10/audio/...
  warqnaa/r10/thumbs/...
  R10_CDN_DEPLOY_INFO.json
```

يمكن رفع محتويات `dist/r10-cdn` كما هي إلى S3/R2/CloudFront أو أي Static HTTPS origin.

## 2. إعداد Laravel

في `backend-laravel/.env` المحلي/الإنتاجي فقط، وليس في Git:

```env
WARQNA_ASSET_MODE=hybrid
WARQNA_ASSET_CDN_URL=https://cdn.example.com
WARQNA_ASSET_MANIFEST_TTL=3600
WARQNA_ASSET_DATA_SAVER_DEFAULT=false
```

القيم:

- `local`: لا يستخدم CDN.
- `hybrid`: يعلن عن CDN مع fallback محلي؛ الموصى به في بداية R10.
- `remote`: مخصص لمرحلة لاحقة عندما تكون الأصول المطلوبة منشورة ومراقبة بالكامل.

## 3. Cache headers الموصى بها

للملفات ذات الإصدارات الثابتة داخل `warqnaa/r10/full`, `audio`, `thumbs`:

```text
Cache-Control: public, max-age=31536000, immutable
```

للـmanifest:

```text
Cache-Control: public, max-age=300
ETag: enabled
```

## 4. التحقق قبل الإنتاج

1. افتح `/api/mobile/v1/assets/manifest`.
2. تحقق أن `cdn_enabled=true` في وضع hybrid/remote عندما URL صالح.
3. فعّل Data Saver من إعدادات Flutter وتأكد أن الصور الاختيارية تستخدم thumbnails.
4. افصل الإنترنت وتأكد أن العناصر الأساسية ما زالت تظهر من Local fallback.
5. لا تحذف الأصول المحلية الأساسية من APK/AAB في R10؛ النقل الكامل للأصول الاختيارية يتم تدريجياً في R10.1 وما بعدها بعد قياس الاستقرار.

## ملاحظة أمنية

SHA-256 هنا للتحقق من سلامة الملف المنزّل وعدم تلفه/استبداله عشوائياً، وليس بديلاً عن HTTPS أو صلاحيات التخزين أو توقيع الإصدارات.
