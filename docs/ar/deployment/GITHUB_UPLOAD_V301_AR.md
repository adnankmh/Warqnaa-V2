# رفع Warqnaa V1.1.1+301 إلى GitHub

## أقل تدخل ممكن

1. استبدل محتويات المستودع الحالي بمحتويات هذه الحزمة مع إبقاء مجلد `.git` الموجود عندك.
2. شغّل `CHECK_WARQNA_WINDOWS.bat` مرة واحدة.
3. إذا نجح الفحص، نفذ من مجلد المشروع:

```bat
git add -A
git commit -m "Warqnaa v1.1.1+301 CI i18n stability"
git push origin main
```

إذا كان اسم فرعك غير `main` استبدله باسم الفرع الظاهر في `git branch`.

GitHub Actions في B301 تشغّل عقود R8–R14.3 ثم V300 ثم V301. GitHub Pages اختياري؛ فشل صلاحية إنشاء Pages لا يمنع Web build artifact.

لا ترفع `.env` أو كلمات المرور أو مفاتيح التوقيع إلى GitHub.
