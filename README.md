# Warqnaa V1.0.2+262 — R14.2 Secure Account & CI Reliability

الإصدار الحالي: **1.0.2+262**

R14 هو الإغلاق العالمي للمشروع عبر Backend وWeb وAndroid وiOS. يضيف بوابة إطلاق موحدة، Production/Store preflight، أدلة SHA-256، ويفرض سلسلة R8–R14 مع Engine Gold قبل اعتبار أي Tag إصدارًا عالميًا.

## إضافات R14 النهائية

- Global Release Gate بأربع قنوات مستقلة لا ينجح إلا بنجاحها جميعًا.
- Backend Docker image، Android AAB، Web release، وiOS unsigned build للتوقيع الرسمي.
- تحقق تلقائي من أيقونة 512×512 وFeature Graphic 1024×500 وWeb manifest.
- أمر `warqna:global-release-check` بوضع عادي أو strict أو JSON.
- فصل واضح بين جاهزية المصدر وبين أسرار الإنتاج والتوقيع وحسابات المتاجر وDNS/TLS.
- وثائق إطلاق عربية/إنجليزية وChecklist إنتاج وحزم Full/Upgrade موثقة.

عقد R14.1: `docs/ar/releases/current/R14_1_LEGENDARY_EXPERIENCE_CONTRACT_AR.md`

عقد R14.2: `docs/ar/releases/current/R14_2_SECURE_ACCOUNT_CONTRACT_AR.md`

عقد R14 Global Release محفوظ في `docs/ar/releases/current/R14_GLOBAL_RELEASE_CONTRACT_AR.md`.

## R13 المحفوظ بالكامل

R13 يحوّل محركات Warqnaa العشرين إلى منظومة اعتماد قابلة للقياس وإعادة التشغيل. بوابة الإصدار تشغّل 2,000 مباراة محدودة وآمنة لكل محرك، والجدولة الدورية تشغّل 5,000 مباراة لكل محرك مع تقرير JSON محفوظ.

## إضافات R13 النهائية

- Engine Gold Registry لجميع المحركات العشرين الظاهرة للعميل.
- Replayable seeds للمحركات المزروعة، لتكرار حالات الفشل بدقة.
- تحقق من أن كل حركة معلنة تمر عبر `validate` وتغيّر الحالة عبر `apply`.
- منع الحالات غير القابلة للتسلسل، الأدوار غير الصالحة، الأوراق الفارغة، أخطاء الحالة والـdeadlocks.
- سياسة Bot محسّنة، حتمية وقوة/نوع/مرحلة-aware، ولا تختار إلا من الحركات القانونية.
- Smoke محلي وCI سريع، Release Gold بـ2,000 مباراة/محرك، وScheduled Gold بـ5,000 مباراة/محرك.
- تقرير JSON آلي لكل محرك: المباريات، الانتقالات، المكتمل، المحدود والزمن.
- GitHub Actions تشغّل سلسلة R8–R13 ثم Laravel وFlutter والبناء متعدد المنصات.

للبدء راجع `START_HERE_AR.md`، ولعقد الإصدار راجع:

`docs/ar/releases/current/R13_ENGINE_GOLD_CONTRACT_AR.md`

## R12 المحفوظ بالكامل

R12 يضيف إلى Social World ساحة تنافسية عالمية: Ranked/MMR، مواسم وTiers، Leaderboards، دوريات وكؤوس وجداول متعددة المراحل، بطولات أندية ودول، جوائز موسمية، وAdmin Competitive مستقل.

## إضافات R12 النهائية

- Ranked Matchmaking بلا Bots وبنافذة MMR عادلة ثنائية الجانب، مع المنطقة والحظر وقفل Queue واحد.
- MMR عام ولكل لعبة، Placements وSoft Reset وسلاسل انتصارات وعقوبات انسحاب.
- ثمانية Tiers ومواسم وتصنيفات عالمية/دولية/أندية ومكافآت ذرية لا تتكرر.
- Brackets حتمية متعددة المراحل، غرف من المحرك الخادمي، وتأهل تلقائي بعد اعتماد النتيجة.
- بطولات Global/Club/Country وحدود MMR وقفل التسجيل والانسحاب بعد بدء الجدول.
- Anti-cheat hold قبل MMR أو التأهل، ومراجعة إدارية كاملة مع Audit Log.
- صرف جائزة البطولة في النهائي فقط ومرة واحدة.
- واجهات Competitive Arena وAdmin Competitive على Flutter والويب.
- `warqna:competitive-tick` للمواسم والمطابقة واسترداد النتائج ولقطات الترتيب.
- GitHub Actions تشغّل عقود R8–R12 والمحركات واختبارات Laravel وFlutter متعددة المنصات.

عقد R12: `docs/ar/releases/current/R12_COMPETITIVE_ARENA_CONTRACT_AR.md`

## إضافات R11 النهائية

- Social World موحد على Flutter والويب مع موجز، اقتراحات، أحداث وإحصاءات.
- إعدادات خصوصية دقيقة للاكتشاف والملف والحضور والرسائل والدعوات والنشاط.
- Spectator Mode للقراءة فقط مع حالة عامة منقّاة من الأوراق والأسرار وبيانات RNG.
- Match Replays موقّعة بـSHA-256 مع نطاقات Public/Friends/Private وإخفاء من المالك أو الإدارة.
- Clubs 2.0: اكتشاف وإنشاء وانضمام وإعلانات وفعاليات ومشاركة اجتماعية.
- Social Gifts مرتبطة بالمحفظة والعائد الإداري مع تحقق خادمي كامل.
- Admin Social World لإدارة الإعدادات والمحتوى والأحداث والإعادات والمشاهدين مع Audit Log.
- تنظيف مجدول للحضور والفعاليات والإعادات المنتهية عبر `warqna:cleanup-social-world`؛ يتطلب Laravel Scheduler في الإنتاج.
- GitHub Actions بوابات تراكمية لعقود R8–R11 وبناء Android وiOS والويب والخلفية.

عقد R11 التاريخي المحفوظ داخل R12:

`docs/ar/releases/current/R11_SOCIAL_WORLD_CONTRACT_AR.md`

النسخة المرجعية لـR10.1 هي **0.5.1+221**، وهي محفوظة بالكامل داخل R11. R10.1 يبني فوق R10 بدون حذف ميزاته: يضيف Commerce/Ads foundation بتحقق إيصالات خادمي، عروض يومية/أسبوعية/شهرية/سنوية، صور حديثة منفصلة لكل لعبة، إخفاء الألعاب Server-only من واجهة العميل، ثيمات كاملة موحدة، طاولات Portrait/Landscape بصور داخلية متناسبة لا تغطي السطح، معاينة صورة شخصية دائرية، وواجهة إدارة موسعة للتجارة والإعلانات.

R10 يبني مباشرة فوق R9.1 Build 210 ويحافظ على كل محركات اللعب والمتجر والإدارة والتحديات والاقتصاد الموجودة، ثم يعيد بناء طريقة تسليم الصور والأصوات لتقليل حجم التطبيق والويب بدون التضحية بالأصول الأصلية.

## إضافات R10.1 النهائية

- 18 Game Covers مستقلة في التطبيق والويب.
- Server-only games مخفية من واجهات العملاء، مع بقاء تحكم المدير وActive state محفوظاً.
- طاولات هاتف Portrait وLandscape/desktop عريضة مع artwork inlay متناسب.
- 6 ثيمات كاملة مشتركة بين Flutter وLaravel.
- Avatar دائري مع live preview.
- Commerce + server receipt verification + daily/weekly/monthly/annual offers.
- Rewarded ads وInterstitial محدود بعد الخروج فقط، بدون إعلان أثناء اللعب.
- Lucky Wheel بـ12 جائزة متزامنة مع السيرفر.
- Command Center موسع للتجارة والإعلانات إضافة إلى أدوات الإدارة السابقة.

## أهم ما تغير في R10

- Flutter يشحن WebP/OGG محسنة بدل مجلدات الصور/WAV الثقيلة داخل APK/AAB.
- الأصول المعلنة فعلياً في `pubspec.yaml` انخفضت إلى نحو **12.7 MiB** بدل نحو **51 MiB** قبل R10.
- الرسومات الأصلية ما زالت محفوظة في المصدر لإعادة التوليد والمراجعة، لكنها لا تدخل كلها إلى حزمة التطبيق.
- Asset Manifest مركزي Versioned + SHA-256 + thumbnails + local/remote paths.
- Remote/CDN-ready delivery مع Local fallback وعدم تعطيل اللعب عند غياب CDN.
- Data Saver داخل Flutter وصور مصغرة للمقتنيات الاختيارية.
- ضغط أصوات اللعبة إلى OGG مع بقاء نظام الصوت السابق ووظائفه.
- Laravel public runtime أخف ويستخدم WebP للمتجر مع Lazy Loading وBrotli/Gzip/immutable caching hints.
- Endpoint عام للـAsset Manifest مع ETag وCache-Control.
- أدوات إعادة توليد الأصول والـmanifest وتجهيز مجلد CDN للنشر.
- جميع عقود R8 وR9 وR9.1 تبقى ضمن بوابات CI ولا يتم تجاوزها.

## تشغيل سريع

1. ضع المشروع في `C:\\xampp\\htdocs\\Warqnaa`.
2. شغّل `START_WARQNA_WINDOWS.bat`.
3. اختر أحد المنافذ 8007–8010.
4. قبل GitHub شغّل `CHECK_WARQNA_WINDOWS.bat`.

لإعداد CDN لاحقاً راجع:

`docs/ar/deployment/R10_CDN_SETUP_AR.md`
