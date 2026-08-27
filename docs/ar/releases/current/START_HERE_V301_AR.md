# ابدأ هنا — Warqnaa V1.1.1 Build 301

Build 301 هو Hotfix تراكمي فوق WORLD EXPERIENCE Build 300. لا يحذف أي ميزة من R8–R14.3 أو V300، ويعالج تعارض عقود GitHub Actions التاريخية مع توسعة اللغات والثيمات.

أهم إصلاحات B301:

- عقود R9/R10/R10.1/V0.3 أصبحت تراكمية ولا تمنع إضافة لغات أو ثيمات جديدة.
- العربية والإنجليزية والألمانية والتركية والفرنسية والإسبانية موحدة بين Flutter وLaravel وMobile API ولوحة الإدارة.
- حفظ لغة اللاعب في قاعدة البيانات ومزامنتها من Flutter.
- إصلاح indentation/command wiring في backend-ci.yml وglobal-release.yml.
- بوابة جديدة `test_v301_ci_i18n_contract.py` مربوطة بكل قنوات CI.
- الحفاظ على V300 WORLD EXPERIENCE: Party، reconnect/AFK، spectators، matchmaking، economy audit، WORLD OPS، Lottie، profile frames، 15+ themes.

على Windows شغّل `START_WARQNA_WINDOWS.bat`. السكربت يستخدم SQLite افتراضيًا، ينشئ البيئة المحلية والمفتاح وقاعدة البيانات تلقائيًا، ويثبت Composer dependencies إذا كانت Composer متاحة.

قبل GitHub شغّل `CHECK_WARQNA_WINDOWS.bat`.
