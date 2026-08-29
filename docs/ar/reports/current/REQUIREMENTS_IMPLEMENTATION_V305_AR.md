# مصفوفة تنفيذ تعليمات المستخدم — Warqnaa V1.3.1+305

هذه المصفوفة تربط تعليمات ملف «تعليماتي كارت» بحالة النسخة الحالية. B305 لا يعيد بناء الخصائص المنفذة في B304؛ بل يحافظ عليها ويضيف عقد الطاولة الواحدة النهائي.

## اللعب والمحركات
- Tarneeb وعائلتها: عرض الطلب/صاحب الطلب، الطلب 7–13 + Pass، إظهار آخر ورقة/صاحبها، نتيجة اللمة والنقاط — محفوظ ضمن واجهة ومحرك اللعب.
- توزيع الورق: server-authoritative secure randomness مع balanced-deal certification وآلاف السيناريوهات؛ لا يوجد استهداف لاعب حسب الاسم/المستوى/الرصيد.
- Hand/Banakil: manual ordering + meld/meld_many/layoff مع إبراز المجموعات ضمن تدفق اللعب.
- Basra: لاعبان فقط.
- الألعاب المحذوفة للمستخدم: Jackaroo/Backgammon/Domino/Chess مخفية من customer catalog.
- AFK/abandon: الجلسات المهجورة تنتهي ولا تعاد في اليوم التالي؛ حد lifecycle محفوظ.
- Bot profiles/AI والسياسات القانونية للمحركات محفوظة من B304 مع Engine Gold/Stress gates.

## الطاولة وظهر الورق — التغيير النهائي B305
- طاولة واحدة فقط مرئية/قابلة للاختيار: `v305_table_emerald_royal`.
- مجانية: price = 0.
- Portrait-first.
- Deep emerald felt + wood/gold edge palette.
- ظهر ورق واحد فقط: `v305_cardback_emerald_royal`، مجاني.
- Laravel يعطل كل legacy table/card_back rows ثم يفعّل V305 فقط.
- Flutter يخفي أي legacy table/card back حتى لو بقي كسجل تاريخي في المصدر.
- أي اختيار قديم محفوظ للمستخدم يتم تطبيعه إلى V305 تلقائيًا.
- Rewards لا تستطيع إعادة تفعيل طاولة قديمة.

## المتجر والإدارة
- Admin يستطيع تعديل/إخفاء عناصر المتجر عبر أدوات الإدارة الموجودة.
- Badges/Effects غير ظاهرة للمستخدم وموقوفة.
- Profile Colors شهرية حقيقية بأسعار 100,000+.
- Boosters لا تعرض تسمية Warqnaa Booster القديمة.
- الصناديق والدولاب والعروض والتحديات وRewarded Ads محفوظة من B304.
- Challenge Road متعدد المراحل ومكافآته المؤقتة محفوظة؛ لا يستخدم طاولات محذوفة في B305.
- Level-up يمنح مكافأتين مؤقتتين ولا يعيد طاولة محذوفة.

## الحسابات والبروفايل
- Primary admin role مستوى 99 ورصيد عرض Unlimited محفوظ.
- كلمات مرور المدير/النائب لا تُخزن كنص صريح داخل Git؛ يتم provisioning من Environment/local ignored file.
- حسابات demo المحلية محفوظة وفق سياسة opt-in/بيئة التطوير.
- تغيير username/email/password ومسارات re-auth/session revocation محفوظة.
- Avatar editor دائري، profile مختصر، settings منفصلة، font scaling محفوظة.

## اللغات والثيمات والواجهة
- اللغات الفعالة: العربية والإنجليزية فقط.
- اللغات المستقبلية موجودة كmetadata فقط وليست قابلة للاختيار حتى اكتمال audit.
- contrast-aware themes محفوظة لتباين النص في الخلفيات الفاتحة/الداكنة.
- Home يعطي الأولوية للمسابقات بدل Social.
- Responsive/portrait table geometry محفوظة للموقع والتطبيق.

## الأمان وGitHub
لا ترفع: `.env`, `.warqnaa-admin.local.env`, قواعد البيانات، SQL dumps، signing keys/keystores، private keys، service credentials، vendor/build/node_modules/.dart_tool.
Privacy Gate مدمج داخل CI.

## بوابات تحقق B305
- Historical Python contracts: PASS قبل الإغلاق النهائي.
- V305 single-table contract: PASS.
- PHP syntax: PASS.
- 3000-scenario fair-deal: PASS.
- Official rules audit: PASS.
- 360 engine stress scenarios: PASS.
- Engine Gold smoke: 100 matches / 20 engines / 9354 legal transitions: PASS.
- Privacy gate: PASS.
- Global release preflight: PASS.
- Static validate_release: PASS.
- Release version consistency: PASS.
- Flutter SDK وComposer غير متوفرين في بيئة التغليف؛ لذلك `flutter analyze/test/build` وLaravel `artisan test` تبقى mandatory داخل GitHub Actions.
