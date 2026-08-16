# ابدأ من هنا — Warqnaa V0.4.4+200 Full Fusion Pro — CI Fixed R2

## Windows / XAMPP
1. فك الحزمة داخل `C:\xampp\htdocs\`.
2. افتح مجلد المشروع.
3. استخدم `START_WARQNA_WINDOWS.bat` أو ملفات التشغيل داخل `scripts/windows/current/`.
4. البورت الرئيسي المقترح: **8007**. البدائل: **8008، 8009، 8010**.
5. افتح المتصفح على `http://127.0.0.1:8007` عند اختيار 8007.

## GitHub Desktop
1. افتح GitHub Desktop.
2. اختر **File → Add Local Repository** وحدد هذا المجلد.
3. اعمل Commit ثم Push/Publish للمستودع.
4. افتح **Actions** وانتظر نجاح Production Release Gate وBackend CI.
5. شغّل Android يدويًا من workflow **Build Android APK and AAB** للحصول على APK/AAB.

## Flutter Web / GitHub Pages
- Workflow يبني Flutter Web دائمًا.
- حتى لو GitHub Pages غير مفعّل، لن يفشل الـworkflow لهذا السبب؛ ستحصل على Build داخل **Artifacts**.
- إذا أردت نشره كصفحة GitHub Pages، فعّل Pages للمستودع واجعل Source = **GitHub Actions**؛ في التشغيل التالي سيكتشفه الـworkflow وينشر تلقائيًا.

## الفحص المحلي
شغّل:
- `python tools\validate_release.py`
- `python tools\test_ci_release_compat_contract.py`
- `scripts\windows\current\CHECK_V200_WINDOWS.bat`

## الإصدار
المصدر المرجعي الوحيد لرقم الإصدار هو `RELEASE_VERSION.json`، والـCI يتحقق من اتساقه مع Flutter وLaravel وManifest.
