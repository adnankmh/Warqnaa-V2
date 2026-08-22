# رفع R13 Build 250 إلى GitHub

قبل Push شغّل الفحص المحلي. بعد الرفع يجب أن تنجح:

- Backend CI: عقود R8–R13، اختبارات المحركات، Laravel وProduction preflight.
- Production Release Gate: 2,000 مباراة لكل محرك وتقرير `warqnaa-r13-engine-gold-release`.
- Android/iOS/Web: عقود الإصدار، التحليل والاختبارات والبناء.
- R13 Engine Gold Scheduled Certification: 5,000 مباراة لكل محرك وتقرير محفوظ 30 يوماً.

لا ترفع `.env` أو مفاتيح الإنتاج. استخدم GitHub Environments/Secrets فقط.
