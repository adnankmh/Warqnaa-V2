# تقرير جودة Warqnaa R9 — Visual Revolution & Architecture Cleanup

الإصدار: **0.4.9+209**

## ما تم تثبيته في R9

- Design System موحد للتطبيق والويب ولوحة الإدارة.
- Lobby/Home جديد بدل التجميع القديم للبطاقات.
- الطاولات والـPreview: Portrait طولي على الهاتف وLandscape عريض عند التدوير/الويب، مع تغطية الصورة لكامل سطح الطاولة.
- المنتج الفعلي يدعم العربية والإنجليزية فقط؛ العربية RTL والإنجليزية LTR.
- تنظيف آمن لأول دفعة Assets مكررة، مع تقرير Audit مركزي.
- تطبيع أسماء المتجر إلى ar/en وإيقاف التكرارات المتطابقة بدل حذف مشتريات تاريخية.
- هوية BOT واضحة وتقليل الوهج الزائد.
- Sound bus بقنوات منفصلة للورق/UI/التفاعلات/المكافآت/الاجتماعي.
- Live Ops foundation للإعلانات والعروض اليومية/الأسبوعية/الشهرية/السنوية، بدون إعلانات داخل المباراة.
- Warqnaa Command Center بصريًا بدل إبراز أسماء الإصدارات التاريخية في لوحة الإدارة.

## اختبارات التسليم

- R9 Contract: PASS
- R8 Compatibility Contract: PASS
- Release Preflight: PASS
- PHP Syntax: 323 / 323 PASS
- R8 Deep Tarneeb/Hand/Banakil Rules: PASS
- Engine Stress: 900 randomized scenarios / 18 engines PASS
- Multi-step Playthrough: 5,812 state transitions / 18 engines PASS

## الحجم

تم خفض Flutter Assets بأول تنظيف آمن إلى أقل من 54MB، مع بقاء أكثر من 50MB من الأصول الفعلية. تقرير `R9_ASSET_AUDIT_AR.md` يحصي التكرارات المتبقية؛ التكرار الكبير بين Flutter وLaravel لن يُحذف عشوائيًا في R9، بل سيُنقل تدريجيًا في R10 إلى Single Source + Remote Asset/CDN pipeline.

## ما لم ندّعِ اكتماله في R9

- الدفع الحقيقي وAdMob production credentials: R10.
- Remote CDN الكامل وتنزيل المقتنيات عند الطلب: R10.
- Voice production / Replay / Spectator / Clubs 2.0: R11.
- Ranked/MMR/Seasons: R12.
- Certification بآلاف المباريات لكل محرك: R13.

R9 هو إعادة تأسيس المنتج بصريًا ومعماريًا مع المحافظة على محركات R8.1، وليس نهاية خارطة التطوير.
