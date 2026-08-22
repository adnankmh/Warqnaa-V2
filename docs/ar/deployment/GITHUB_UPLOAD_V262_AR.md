# رفع Warqnaa Build 262 إلى GitHub

1. ارفع محتويات Full Repository إلى جذر المستودع دون رفع `.env` أو مفاتيح التوقيع.
2. شغّل `CHECK_WARQNA_WINDOWS.bat` قبل الرفع.
3. راقب Backend CI وAndroid وiOS وFlutter Web وGlobal Release.
4. بناء Web ينجح كـActions artifact حتى عندما تكون GitHub Pages غير مفعّلة.
5. بعد النشر عيّن `ADMIN_EMAIL` و`ADMIN_PASSWORD` للإنشاء الأول فقط؛ التغييرات اللاحقة تتم من مركز أمان الحساب.
