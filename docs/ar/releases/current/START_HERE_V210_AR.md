# Warqnaa V0.4.10+210 — R9 Engine Integrity

هذه هي نقطة البدء للإصدار R9.

## التشغيل على Windows
1. فك المشروع داخل `C:\xampp\htdocs\Warqnaa`.
2. شغّل `START_WARQNA_WINDOWS.bat`.
3. اختر البورت 8007 (الموصى به) أو 8008/8009/8010.
4. في أول تشغيل فقط سيقوم المشغل بتثبيت Composer إذا كانت `vendor` غير موجودة، ثم ينشئ `.env` وSQLite ويفعّل migrations.
5. افتح `http://127.0.0.1:8007`.

## الفحص
شغّل `CHECK_WARQNA_WINDOWS.bat`. يقوم R9 بفحص الإصدار، العقود، قواعد طرنيب/هاند/بناكل، Stress لجميع المحركات، ثم Playthrough متعدد الحركات. إذا كانت dependencies مثبتة يشغّل Laravel PHPUnit أيضًا.

## Flutter بدون Android Studio
ارفع المشروع إلى GitHub ثم استخدم GitHub Actions لبناء APK/AAB/Web/iOS unsigned. يمكن تشغيل Flutter Web محليًا من ملف التشغيل الموجود داخل `flutter_app`.
