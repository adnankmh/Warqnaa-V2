# ابدأ هنا — Warqnaa V1.3.1 Build 305 — SINGLE TABLE LEGEND

هذه الحزمة **Full Repository** تراكمية فوق B304، وليست Patch.

## أهم ما يميز B305

- طاولة لعب واحدة فقط للمستخدم، مجانية بالكامل، رأسية، أخضر زمردي داكن مع حواف خشبية/ذهبية احترافية.
- ظهر ورق واحد فقط، مجاني، متوافق بصريًا مع الطاولة.
- تعطيل كل الطاولات وظهور الورق القديمة في Laravel وإخفاؤها في Flutter، مع تطبيع أي اختيار قديم تلقائيًا.
- لا توجد مكافآت تحديات/ترقية يمكنها إعادة تفعيل طاولة محذوفة.
- العربية والإنجليزية فقط كلغات فعالة، مع Registry مستقل للغات المستقبلية.
- حذف Jackaroo وBackgammon وDomino وChess من كتالوج المستخدم.
- Basra لاعبان فقط، وTarneeb بطلب 7–13 + Pass.
- توزيع خادمي آمن ومتوازن، Bot AI، ملكية اللمة، عرض النتائج والنقاط، AFK lifecycle.
- Rewarded Ads وعروض وتحديات ومكافآت مؤقتة وإدارة متجر كاملة.
- Profile Colors، Avatar دائري، Font scaling، contrast-aware themes، Profile مختصر وSettings منفصلة.
- المدير الأساسي محمي بهوية role، وبياناته السرية محلية ولا ترفع إلى GitHub.

## التشغيل على Windows

1. فك ضغط الحزمة الكاملة.
2. شغّل `START_WARQNA_WINDOWS.bat`.
3. لأول تشغيل سيُنشئ Laravel `.env` محليًا ويثبت dependencies عند توفر Composer.
4. إعداد المدير الحقيقي يتم فقط عبر الملف المحلي المستثنى `.warqnaa-admin.local.env` أو متغيرات البيئة.
5. قبل الرفع إلى GitHub شغّل `CHECK_WARQNA_WINDOWS.bat`.

> لا ترفع `.env` أو `.warqnaa-admin.local.env` أو قواعد البيانات المحلية أو مفاتيح التوقيع أو private keys أو SQL dumps أو أي credentials إلى GitHub.
