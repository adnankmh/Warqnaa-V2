# رفع Warqnaa V1.1.0+300 إلى GitHub

1. فك الحزمة الكاملة في مجلد نظيف أو استبدل مستودعك الحالي بهذه الشجرة الكاملة.
2. احتفظ بمجلد `.git` إن كنت تستبدل الملفات داخل المستودع الحالي.
3. شغّل `CHECK_WARQNA_WINDOWS.bat`.
4. نفذ `git add -A` ثم Commit ثم Push.
5. راقب GitHub Actions: Backend CI، Android APK/AAB، Flutter Web، iOS، Production Release Gate، وGlobal Release.
6. GitHub Pages اختياري: إذا لم يكن مفعّلًا سيظل Build Web ينجح ويُرفع كـ Actions artifact، ولن يحاول الـ workflow إنشاء Pages بصلاحيات غير متاحة.
7. أسرار الإنتاج ومفاتيح التوقيع لا تُحفظ داخل المستودع.
