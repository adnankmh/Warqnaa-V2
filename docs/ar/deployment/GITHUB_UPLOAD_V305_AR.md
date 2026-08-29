# رفع Warqnaa V1.3.1+305 إلى GitHub — الطريقة الآمنة

## ارفع
محتويات `src` من الحزمة الكاملة بعد نجاح `CHECK_WARQNA_WINDOWS.bat`.

## لا ترفع أبدًا
- `backend-laravel/.env`
- `backend-laravel/.warqnaa-admin.local.env`
- أي `*.sqlite`, `*.db`, `*.sql`, `*.dump`
- `*.jks`, `*.keystore`, `key.properties`
- `*.pem`, `*.key`, `*.p8`, `*.p12`
- service-account / Firebase Admin / credentials JSON
- `vendor/`, `node_modules/`, `build/`, `.dart_tool/`
- أي ملف يحتوي كلمة مرور المدير أو النائب أو مفاتيح API خاصة

إذا كان المستودع الحالي مرتبطًا بـGitHub، انسخ محتويات `src` فوقه مع إبقاء `.git` فقط، ثم شغّل `CHECK_WARQNA_WINDOWS.bat` قبل commit/push.

Privacy Gate موجود أيضًا داخل GitHub Actions ويمنع الحزمة عند اكتشاف الأسرار المعروفة.
