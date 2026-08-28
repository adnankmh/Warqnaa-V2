# ابدأ هنا — Warqnaa V1.3.0 Build 304 — VERTICAL LEGEND

هذه الحزمة هي **Full Repository** تراكمية فوق B303، وليست Patch.

## أهم ما يميز B304

- العربية والإنجليزية فقط كلغات المنتج الفعالة، مع Registry مستقل لإضافة لغات مستقبلًا بعد تدقيق ترجمتها.
- حذف Jackaroo وBackgammon وDomino وChess من كتالوج المستخدم، مع إبقاء أي محركات تاريخية داخلية لازمة لاختبارات Regression فقط.
- 10 طاولات رأسية Premium فقط + ظهر ورق رأسي واحد في المتجر الجديد.
- Basra لاعبان فقط، وTarneeb بطلب 7–13 + Pass.
- توزيع خادمي آمن ومتوازن باستخدام secure randomness واختبار آلاف السيناريوهات دون استهداف لاعب بعينه.
- Bot AI أفضل، وإظهار الورقة أمام صاحبها ثم فائز اللمة وسحب الأوراق إليه بسلاسة.
- انتهاء الجلسة المهجورة بعد 10 دقائق وعدم إحياء مباراة اليوم السابق.
- Profile Colors لمدة 30 يومًا، Avatar editor دائري، خطوط أكبر/أصغر، contrast-aware themes، بروفايل مختصر وSettings منفصلة.
- Rewarded Ads متدرجة حتى 8 مشاهدات يوميًا، وعروض Daily/Weekly/Monthly/Annual/Custom، وتحديات بمراحل ومكافآت مؤقتة.
- Level-up يمنح مقتنيين مختلفين مؤقتين لمدة 7 أيام.
- إعداد المدير والنائب من **ملف خاص منفصل لا يُرفع إلى GitHub**، مع Privacy Gate داخل CI.

## التشغيل على Windows

1. فك ضغط Full Repository.
2. إذا أردت بيانات المدير المتفق عليها، فك ملف **PRIVATE LOCAL ADMIN SETUP — DO NOT UPLOAD** فوق مجلد `src` ثم شغّل `INSTALL_PRIVATE_ADMIN_B304.bat`.
3. أو شغّل مباشرة `START_WARQNA_WINDOWS.bat` للتشغيل المحلي ببيانات آمنة مولدة محليًا.
4. قبل GitHub شغّل `scripts/windows/current/RUN_GITHUB_READY_B304.bat`.

> لا ترفع `.env` أو `.warqnaa-admin.local.env` أو قواعد بيانات محلية أو مفاتيح التوقيع أو private keys أو SQL dumps إلى GitHub.
