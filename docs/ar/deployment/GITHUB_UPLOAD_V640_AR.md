# رفع Warqnaa R6.4 Build 640 إلى GitHub

1. شغّل `CHECK_V640_WINDOWS.bat` أو `check-v640.sh`.
2. تأكد من نجاح فحص الأسرار والخصوصية وعدم وجود `.env` أو بيانات مدير.
3. ارفع فرع R6.4 وافتح Pull Request إلى `main`.
4. بعد الدمج شغّل `composer install --no-dev` ثم `php artisan migrate --seed --force`.
5. ابنِ Flutter باستخدام `WARQNA_APP_VERSION=1.7.0` و`WARQNA_APP_BUILD=640`.

الترقية تراكمية وآمنة فوق Build 610 ولا تتطلب استيراد أي Patch سابق.
