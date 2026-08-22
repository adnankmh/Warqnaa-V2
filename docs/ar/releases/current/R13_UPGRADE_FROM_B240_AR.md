# ترقية R13 من R12 Build 240

1. خذ نسخة احتياطية من المشروع وملف `.env` وقاعدة البيانات.
2. تحقق أن المصدر الحالي هو **0.7.0+240**.
3. فك حزمة Upgrade في جذر المشروع مع استبدال الملفات المرفقة فقط.
4. لا تحذف `storage` ولا `.env` ولا بيانات المستخدم.
5. شغّل `composer install` داخل `backend-laravel` عند توفر Composer.
6. شغّل `CHECK_WARQNA_WINDOWS.bat` أو `scripts/unix/current/check-v250.sh`.
7. ارفع إلى GitHub وانتظر نجاح بوابة R13 Release Gold.

R13 لا يضيف Migration. إذا لم تكن الشجرة B240 مطابقة، استخدم Full Repository بدلاً من Upgrade.
