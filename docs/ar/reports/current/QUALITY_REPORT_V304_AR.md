# تقرير جودة Warqnaa — Build 304

B304 هو إصدار Gameplay/LiveOps/UI/Security تراكمي، لا يعيد بناء المشروع من الصفر ولا يحذف عقود المحركات التاريخية التي يحتاجها Regression.

## محاور الجودة
- **Gameplay:** Tarneeb 7–13 + Pass، Basra لاعبان، Hand/Banakil manual ordering/melds، trick ownership/collection، round-result visibility، AFK lifecycle.
- **Fairness:** shuffle خادمي آمن، لا يستخدم اسم/رصيد/مستوى/seat لاستهداف لاعب، مع fair-deal certification.
- **LiveOps:** rewarded ads متدرجة، offers cadences، challenge road، temporary level-up rewards.
- **Customization:** 10 portrait tables، card back واحد، profile gradients، Avatar crop دائري، font scaling وcontrast-aware themes.
- **Security:** role-based primary admin، local private provisioning، privacy gate، account re-authentication/session revocation.
- **Compatibility:** R8→R14.3 ثم B300→B304 cumulative source contracts.

بيئة التغليف الحالية لا تحتوي Flutter SDK أو Composer، لذلك `flutter analyze/test/build` واختبارات Laravel التي تتطلب vendor تبقى إلزامية داخل GitHub Actions، بينما source/PHP/engine/privacy/fair-deal gates يتم تشغيلها قبل إنشاء الحزمة.
