# ترقية R14 من R13 Build 250

خذ Backup، وتأكد أن المصدر 0.8.0+250، ثم طبّق حزمة Upgrade بأداتها المرفقة. تتحقق الأداة من SHA-256 لملفات B250، تنشئ Backup، تطبق الفرق وتنفذ Preflight مع Rollback تلقائي. لا توجد Migration في R14. استخدم Full Repository إذا لم تكن الشجرة B250 مطابقة.
