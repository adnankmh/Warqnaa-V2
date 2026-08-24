# رفع R14.3 Build 263 إلى GitHub

شغّل الفحص المحلي، ارفع المصدر، ثم نفّذ Workflow `R14 Global Release Gate`. لا تنشئ Tag عالميًا إلا بعد نجاح foundation/backend-image/android-web/ios/release-evidence. سيُنشئ CI ملف `.env` مؤقتًا للاختبار دون اعتباره سرًا ملتزمًا. ضع الأسرار في GitHub Environments فقط، ولا ترفع `.env` أو keystore أو شهادات Apple.
