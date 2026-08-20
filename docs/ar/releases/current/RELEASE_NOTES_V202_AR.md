# Warqnaa V202 – Elite UI & Gameplay Expansion

## أهم ما تم تنفيذه

1. **الطاولات الطولية للموبايل**
   - عند استخدام التطبيق أو الموقع بوضع الجوال الطولي أصبحت الطاولة طولية/قريبة للمربعة مع توزيع أوضح للمقاعد والورق.
   - عند التحويل للوضع العرضي تصبح الطاولة عريضة وفخمة بشكل احترافي.

2. **تحسين دولاب الحظ والصناديق**
   - التدويرة المجانية أصبحت كل **12 ساعة** بدل 24 ساعة.
   - حزمة الجوائز/الصندوق المجاني أصبحت كل **12 ساعة** كذلك حتى بدون لعب.

3. **أدوات توزيع مباشرة للإدارة**
   - تم إضافة أداة سريعة لتوزيع **التوكن** و**أيام الباشا** على لاعب محدد أو أكثر بسهولة.
   - الملف: `backend-laravel/tools/grant_tokens_pasha.php`
   - ملف ويندوز السريع: `scripts/windows/current/GRANT_TOKENS_PASHA_WINDOWS.bat`

4. **توسعة المتجر – V202 Elite**
   - طاولات جديدة: Obsidian Vertical, Royal Square, Arena Landscape.
   - ظهر ورق جديد Midnight Glass.
   - مؤثر جديد Victory Burst.
   - Badge جديد Grandmaster.
   - Cover جديد Galaxy Luxury.
   - Emoji Pack جديد Majestic Majlis.

5. **صور سكرين شوتس مرفقة**
   - تمت إضافة معاينات ضمن: `docs/previews/v202/`

## ملاحظات تشغيل سريعة
- لتشغيل الموقع استمر على ملفات `START_WARQNA_V201_PORT_8007.bat` إلى `8010`.
- لتوزيع توكن/باشا بسرعة على ويندوز:

```bat
GRANT_TOKENS_PASHA_WINDOWS.bat username_or_email 5000 3 promo_campaign
```

## مثال سطر أوامر مباشر

```bash
php backend-laravel/tools/grant_tokens_pasha.php --user=player@example.com --tokens=10000 --pasha-days=7 --reason=vip_campaign
```
