# تقرير جودة Warqnaa — Build 305

B305 إصدار تراكمي فوق B304 يركز على توحيد تجربة الطاولة بدل تعدد Skins.

## محاور الجودة
- **Single-table UX:** طاولة واحدة مجانية، portrait-first، أخضر داكن وحواف خشبية/ذهبية، وظهر ورق واحد مجاني.
- **Catalog integrity:** Flutter يخفي كل legacy tables/card backs وLaravel يعطلها نهائيًا قبل تفعيل V305.
- **Reward integrity:** لا توجد مكافأة تحدي أو مستوى تشير إلى طاولة محذوفة.
- **Gameplay:** Tarneeb 7–13 + Pass، Basra لاعبان، Hand/Banakil manual ordering/melds، trick ownership/collection، round results وAFK lifecycle.
- **Fairness:** secure server shuffle بدون استهداف لاعب، مع fair-deal certification.
- **LiveOps:** rewarded ads، offers، challenge road، temporary level-up rewards.
- **Security:** primary-admin role، local private provisioning، privacy gate، re-authentication/session revocation.
- **Compatibility:** العقود التاريخية R8→R14.3 ثم B300→B304 بالإضافة إلى عقد B305.

تظل `flutter analyze/test/build` وLaravel runtime tests إلزامية في GitHub Actions عند توفر Flutter SDK وComposer/vendor.
