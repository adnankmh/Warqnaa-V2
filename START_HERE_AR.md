# ابدأ من هنا — Warqnaa R14.3 Build 263

الإصدار الحالي: **1.0.3+263**  
المرحلة: **R14.3 — CI Engine Security**

R14.3 مبني فوق R14 ويحافظ على R8/R9/R9.1/R10/R10.1/R11/R12/R13/R14 وكل المحركات والاقتصاد والمتجر وSocial World وCompetitive Arena. هذه الحزمة Full Repository مستقلة ولا تحتاج نسخة سابقة.

## إصلاحات R14.3

- إصلاح أخطاء Flutter Analyzer والأيقونات والرموز غير المعرفة.
- إصلاح توقف Engine Gold عندما لا تغيّر حركة Bot الحالة.
- إصلاح فحص الأسرار حتى يسمح بملف `.env` المؤقت غير المتتبع ويمنع الملف الملتزم داخل Git.
- مركز أمان لتغيير البريد وكلمة المرور من الويب وFlutter مع طلب كلمة المرور الحالية.
- منع Seeder من إعادة بيانات الدخول إلى القيم الافتراضية بعد أن يغيّرها المستخدم.

## توثيق R14

- العقد: `docs/ar/releases/current/R14_GLOBAL_RELEASE_CONTRACT_AR.md`
- Checklist الإطلاق: `docs/ar/deployment/R14_GLOBAL_LAUNCH_CHECKLIST_AR.md`
- الترقية: `docs/ar/releases/current/R14_UPGRADE_FROM_B250_AR.md`
- تقرير الجودة: `docs/ar/reports/current/QUALITY_REPORT_V260_AR.md`

## التشغيل على Windows / XAMPP

1. ضع المشروع في:
   `C:\xampp\htdocs\Warqnaa`
2. شغّل:
   `START_WARQNA_WINDOWS.bat`
3. اختر المنفذ 8007 أو 8008 أو 8009 أو 8010.
4. قبل الرفع إلى GitHub شغّل:
   `CHECK_WARQNA_WINDOWS.bat`
5. بعد نجاح الفحص اعمل Commit ثم Push واترك GitHub Actions يكمل Flutter analyze/test والبناء.
6. GitHub Actions يشغّل Engine Gold؛ الإنتاج يحتاج كذلك Cron لـ`php artisan schedule:run` كل دقيقة لتشغيل Social World وCompetitive lifecycle.

## أهم ما يضيفه R13

- اعتماد 20 محركًا بعقود server-authoritative موحّدة.
- 2,000 مباراة لكل محرك في Release Gate و5,000 في Scheduled Certification.
- بذور قابلة لإعادة التشغيل، منع deadlock، وفحص سلامة الحركة والحالة والهاش.
- Bot AI حتمي يوازن قوة اليد، النوع، المرحلة والمجموعات القانونية.
- تقرير JSON آلي محفوظ في GitHub Actions.

## توثيق R13

- عقد النسخة: `docs/ar/releases/current/R13_ENGINE_GOLD_CONTRACT_AR.md`
- ملاحظات الإصدار: `docs/ar/releases/current/RELEASE_NOTES_V250_AR.md`
- دليل Upgrade: `docs/ar/releases/current/R13_UPGRADE_FROM_B240_AR.md`
- تقرير الجودة: `docs/ar/reports/current/QUALITY_REPORT_V250_AR.md`
- تعليمات GitHub: `docs/ar/deployment/GITHUB_UPLOAD_V250_AR.md`
- بيان الإصدار: `releases/manifests/current/RELEASE_MANIFEST_V250.json`

## أهم ما يضيفه R12

- Ranked Matchmaking عادل بلا Bots، ولا نتيجة موثوقة من العميل.
- MMR عام ولكل لعبة مع Placements وSoft Reset وAbandon penalty.
- مواسم وثمانية Tiers وLeaderboards ومكافآت لا تُصرف مرتين.
- بطولات وجداول متعددة الجولات، بطولات أندية ودول، وتأهل خادمي.
- Anti-cheat Review يوقف MMR والتأهل والجائزة حتى قرار الإدارة.
- Admin Competitive كامل على الويب وFlutter.
- `warqna:competitive-tick --dry-run` لفحص التشغيل دون تغيير البيانات.

## توثيق R12

- عقد النسخة: `docs/ar/releases/current/R12_COMPETITIVE_ARENA_CONTRACT_AR.md`
- ملاحظات الإصدار: `docs/ar/releases/current/RELEASE_NOTES_V240_AR.md`
- دليل Upgrade: `docs/ar/releases/current/R12_UPGRADE_FROM_B230_AR.md`
- تقرير الجودة: `docs/ar/reports/current/QUALITY_REPORT_V240_AR.md`
- تعليمات GitHub: `docs/ar/deployment/GITHUB_UPLOAD_V240_AR.md`
- بيان الإصدار: `releases/manifests/current/RELEASE_MANIFEST_V240.json`

## أهم ما يضيفه R11

- Social World في Flutter والويب: موجز، متابعة، اقتراحات، حضور، أحداث وإحصاءات.
- إعدادات خصوصية دقيقة قابلة للتغيير من المستخدم وتُطبّق خادميًا على المسارات القديمة والجديدة.
- مشاهدة مباشرة Read-only دون أوراق اللاعبين أو رزمة السحب أو الأسرار أو حالة RNG.
- إعادة مباريات موقعة بـSHA-256، مع Public/Friends/Private وتحكم المالك والإدارة.
- Clubs 2.0 مع الاكتشاف والإنشاء والانضمام والإعلانات والفعاليات.
- Social Gifts آمنة مرتبطة بالمحفظة وإيرادات الإدارة.
- Admin Social World للإعدادات والمحتوى والأحداث والإعادات والمشاهدين وسجل التدقيق.
- عقد R11 واختبارات انحدار تراكمية R8–R11 داخل GitHub Actions.

## توثيق R11

- عقد النسخة: `docs/ar/releases/current/R11_SOCIAL_WORLD_CONTRACT_AR.md`
- تقرير الجودة: `docs/ar/reports/current/QUALITY_REPORT_V230_AR.md`
- تعليمات GitHub: `docs/ar/deployment/GITHUB_UPLOAD_V230_AR.md`
- بيان الإصدار: `releases/manifests/current/RELEASE_MANIFEST_V230.json`

## أهم ما يضيفه R10.1

- طاولة هاتف Portrait طولية، وعند التدوير Landscape، والويب/اللابتوب عريض؛ زخرفة الطاولة Inlay متناسبة داخل السطح وليست Cover مشوّهة.
- 18 صورة WebP حديثة مستقلة للألعاب في Flutter والويب.
- إخفاء الألعاب Server-only من العميل والويب والمنافسات والـbootstrap، مع بقائها متاحة للإدارة والتطوير.
- تعطيل لعبة من GUI الإدارة يبقى محترماً ولا يعيدها Sync تلقائياً.
- 6 ثيمات كاملة تغير الخلفيات والبطاقات والأزرار والحقول والحوارات والتنقل في Flutter والويب.
- صورة شخصية دائرية ومعاينة مباشرة قبل الحفظ.
- تجارة/شراء حقيقي ببنية Server Receipt Verification؛ لا يتم إضافة Tokens لأن الهاتف ادعى نجاح الدفع فقط.
- عروض يومية وأسبوعية وشهرية وسنوية قابلة للتحكم.
- Rewarded Ads + Interstitial محدود بعد الخروج من اللعب فقط، ولا إعلانات أثناء المباراة.
- دولاب فاخر بـ12 جائزة مصرحاً بها من السيرفر ومتطابقة مع Flutter.
- Command Center للإدارة يشمل التجارة والإعلانات والعروض إلى جانب أدوات الموقع والمتجر والألعاب الموجودة سابقاً.
- العربية والإنجليزية هما لغتا المنتج المدعومتان حالياً.

## مهم بخصوص الدفع الحقيقي

الكود وبنية التحقق موجودان، لكن الإنتاج الحقيقي يحتاج لاحقاً مفاتيح وحسابات Google Play / Apple / مزود الويب. لا تضع أي Secret داخل GitHub أو المشروع؛ استخدم Environment/Secrets فقط.

## R10 Asset Delivery

R10 ما زال فعالاً بالكامل: WebP/OGG، Asset Manifest، SHA-256، Data Saver، Hybrid CDN + Local fallback.
راجع: `docs/ar/deployment/R10_CDN_SETUP_AR.md`.
