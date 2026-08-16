Warqnaa CI Hotfix R3
=====================

هذا الملف إصلاح فقط للنسخة:
Warqnaa V0.4.4+200 Full Fusion Pro CI Fixed R2

الإصلاحات:
1) إضافة backend-laravel/config/view.php بمسار Blade cache صالح وثابت.
   يحل: Please provide a valid cache path.

2) تحديث اختبار V161 ليتوافق مع عقد XP الحالي V200:
   بدون باشا = 10 XP لكل جولة
   مع باشا = 20 XP لكل جولة
   المسرع يطبق بعد ذلك حسب نسبته.
   لذلك الاختبار الصحيح مع الباشا وحده هو 20 XP، وليس 120 XP من العقد القديم.

طريقة التطبيق:
- فك ZIP داخل جذر مشروع Warqnaa الحالي.
- وافق على Replace/Overwrite للملفات.
- شغّل APPLY_AND_TEST_FIX_WINDOWS.bat

لا يحتوي هذا الـHotfix على Assets أو نسخة المشروع كاملة؛ هو فقط ملفات الإصلاح المطلوبة.
