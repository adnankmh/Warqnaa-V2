# رفع Warqnaa V1.3.0+304 إلى GitHub — الطريقة الآمنة

## المسموح رفعه
ارفع محتويات **Full Repository / src** فقط.

## ممنوع رفعه
- `backend-laravel/.env`
- `backend-laravel/.warqnaa-admin.local.env`
- أي `*.sqlite`, `*.db`, `*.sql`, `*.dump`
- `*.jks`, `*.keystore`, `key.properties`
- `*.pem`, `*.key`, `*.p8`, `*.p12`
- service-account / Firebase Admin / credentials JSON
- `vendor/`, `node_modules/`, `build/`, `.dart_tool/`
- ملف **PRIVATE LOCAL ADMIN SETUP** كاملًا.

## أقل تدخل ممكن
إذا كان عندك Repository قديم مرتبط بـGitHub، انسخ محتويات B304 `src` فوقه مع إبقاء `.git` ثم شغّل:

`scripts/windows/current/RUN_GITHUB_READY_B304.bat`

السكربت يقوم بـ:
1. تنظيف ملفات Dart القديمة المتعقبة وغير الموجودة في B304.
2. تشغيل CHECK B304 والـPrivacy Gate.
3. `git add -A`.
4. إنشاء commit.
5. طلب تأكيد واحد قبل `git push`.

الـPrivacy Gate موجود أيضًا داخل GitHub Actions، لذلك أي ملف secret معروف يُسقط الـCI بدل نشره.
