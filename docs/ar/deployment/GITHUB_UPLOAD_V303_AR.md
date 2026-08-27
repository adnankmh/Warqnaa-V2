# رفع Warqnaa V1.2.0+303 إلى GitHub

لأقل تدخل: انسخ محتويات B303 فوق مستودع Warqnaa الحالي مع إبقاء `.git`، ثم شغّل `scripts/windows/current/RUN_GITHUB_READY_B303.bat`.

قبل `git add -A` يشغّل السكربت `CLEAN_STALE_FLUTTER_B303.bat`، الذي يحذف ملفات Dart القديمة المتعقبة داخل `flutter_app/lib` إذا لم تكن موجودة في Manifest الإصدار الحالي. هذا يمنع Copy/Replace من إبقاء ملفات Flutter تاريخية معطوبة.

ثم يشغّل CHECK_V303، ويضيف التغييرات والحذف والاستبدالات، ويطلب تأكيدًا واحدًا قبل commit/push.

لا ترفع `.env` أو مفاتيح التوقيع أو secrets أو ملفات قواعد بيانات محلية.
