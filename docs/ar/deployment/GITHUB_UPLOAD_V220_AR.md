# رفع Warqnaa R10 إلى GitHub

1. ثبّت R10 فوق R9.1 أو استخدم المستودع الكامل.
2. تأكد أن `backend-laravel/.env` محلي وغير متتبع.
3. شغّل `CHECK_WARQNA_WINDOWS.bat`.
4. راجع أن `RELEASE_VERSION.json` يعرض `0.5.0+220`.
5. Commit ثم Push.
6. انتظر Backend CI وFlutter Android/Web/iOS contracts.

R10 لا يحتاج CDN كي ينجح CI؛ CDN اختياري ويعمل بنمط hybrid مع fallback محلي.
