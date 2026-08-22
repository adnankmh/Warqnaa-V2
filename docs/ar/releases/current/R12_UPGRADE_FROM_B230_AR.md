# ترقية Warqnaa من R11 Build 230 إلى R12 Build 240

1. خذ نسخة احتياطية من قاعدة البيانات و`backend-laravel/.env` وملفات المستخدمين.
2. تأكد أن المصدر هو **0.6.0+230**. لا تطبق حزمة Upgrade على B221 أو إصدار أقدم.
3. فك حزمة `R12_COMPETITIVE_ARENA_FINAL_UPGRADE_FROM_B230` فوق جذر المشروع مع الحفاظ على `.env` المحلي.
4. نفّذ `composer install --no-dev --prefer-dist --optimize-autoloader` في الإنتاج.
5. نفّذ `php artisan migrate --force` ثم `php artisan optimize:clear`.
6. شغّل `php artisan warqna:competitive-tick --dry-run`.
7. شغّل `CHECK_WARQNA_WINDOWS.bat` محلياً أو بوابات GitHub Actions.
8. افحص `/health` و`/ready`، ثم Ranked وAdmin Competitive بحسابين تجريبيين، بما يشمل الانسحاب وإعادة الاتصال وعدم ظهور Bot.
9. أبقِ `php artisan schedule:run` كل دقيقة.
10. راقب فشل مهمة Scheduler؛ دورة R12 تكمل العناصر السليمة لكنها تعيد Exit Code فاشلاً عند وجود `error_refs` يحتاج إلى معالجة.

حزمة Upgrade يجب أن تطابق Full Repository بعد تطبيقها فوق B230، ولا تحتوي `.env` أو Vendor أو Build cache. لا تضع أي Secret في GitHub. للعودة، أعد قاعدة البيانات والملفات من النسخة الاحتياطية؛ لا تستخدم migration down في إنتاج حي دون خطة استعادة مجرّبة.
