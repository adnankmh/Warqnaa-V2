# رفع Warqnaa R12 Build 240 إلى GitHub

1. ارفع محتوى **Full Repository** إلى جذر المستودع، أو طبّق Upgrade على R11 B230 المطابق فقط.
2. لا ترفع `backend-laravel/.env` أو مفاتيح Firebase/AdMob/TURN/الدفع.
3. شغّل `CHECK_WARQNA_WINDOWS.bat` أو `scripts/unix/current/check-v240.sh`.
4. اعمل Commit وPush وانتظر نجاح Backend CI وFlutter Android/Web/iOS وProduction Release Gate.
5. نفّذ migrations قبل تحويل Traffic.
6. ثبّت Cron كل دقيقة لـ`php artisan schedule:run`.
7. نفّذ `php artisan warqna:competitive-tick --dry-run` ثم افحص `/health` و`/ready`.
8. جرّب Queue بلا Bots، عدالة البحث، الانسحاب وإعادة الاتصال، نتيجة MMR، Anti-cheat hold، تعادل/استبدال مباراة، نهائي وجائزة، ثم تحقق من Social World.

GitHub Actions يشغّل عقود R8 وR9 وR9.1 وR10 وR10.1 وR11 وR12، والفحص البنيوي الاحتياطي لـPHP، وتدقيق المحركات، واختبارات Laravel، وFlutter analyze/test والبناء متعدد المنصات.
