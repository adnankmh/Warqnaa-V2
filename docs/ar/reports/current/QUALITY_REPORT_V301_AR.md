# تقرير جودة Warqnaa — Build 301

سبب الإصدار: GitHub Actions كان يتوقف في `test_v209_r9_contract.py` لأن العقد التاريخي كان يشترط أن المنتج يدعم العربية والإنجليزية فقط، بينما V300 أضاف de/tr/fr/es. بعد إزالة ذلك الحاجز ظهر عقد V0.3 قديم يفرض ستة ثيمات بالضبط رغم أن WORLD EXPERIENCE يحتوي 15 ثيمًا.

تم الإصلاح بطريقة تراكمية: العقود القديمة تتحقق من بقاء خطها الأساسي ولا تمنع خصائص الإصدارات الأحدث. أضيف عقد V301 مستقل يفرض الآن ست لغات عبر Flutter وLaravel وMobile API ولوحة الإدارة وحفظ لغة المستخدم.

تم كذلك إصلاح wiring غير صحيح لاختبار V300 في `backend-ci.yml` و`global-release.yml`، وإضافة migration لحقل locale في profiles.

الفحوصات المنفذة على المصدر:

- سلسلة Python التي تظهر في GitHub Actions: PASS.
- `verify_release_versions.py`: PASS.
- `validate_release.py`: PASS بعد إنشاء ملفات إصدار B301.
- YAML parsing لكل workflows: PASS.
- PHP syntax lint لكل 397 ملف PHP: PASS.
- اختبارات PHP المستقلة للمحركات والقواعد: PASS.
- R8 playthrough: 8,718 انتقال حالة validated: PASS.
- V184 randomized stress: 360 سيناريو: PASS.

اختبارات Composer/Laravel framework وFlutter runtime/build تبقى ضمن GitHub Actions لأن حزمة المصدر لا تشحن `vendor` أو `.dart_tool`.
