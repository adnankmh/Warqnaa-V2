# رفع Warqnaa R11 Build 230 إلى GitHub

1. ارفع محتوى **Full Repository** إلى جذر المستودع، أو طبّق Upgrade على B221 المطابق فقط.
2. لا ترفع `backend-laravel/.env` أو مفاتيح Firebase/AdMob/TURN/الدفع.
3. شغّل `CHECK_WARQNA_WINDOWS.bat` محليًا.
4. اعمل Commit وPush.
5. انتظر نجاح Backend CI وFlutter Android/Web/iOS وProduction Release Gate.
6. نفّذ migrations قبل تحويل Traffic للإصدار الجديد.
7. ثبّت Cron لتنفيذ `php artisan schedule:run` كل دقيقة، ثم جرّب `php artisan warqna:cleanup-social-world --dry-run`.
8. افحص `/health` و`/ready` ثم Social World والمدرجات والإعادات بحسابين منفصلين.

GitHub Actions يعيد تشغيل عقود R8 وR9 وR9.1 وR10 وR10.1 وR11، وتدقيق PHP، واختبارات Laravel، وFlutter analyze/test، وتدقيق المحركات.
