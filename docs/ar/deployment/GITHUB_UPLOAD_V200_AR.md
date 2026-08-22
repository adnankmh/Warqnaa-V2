# رفع Warqnaa V0.4.4+200 إلى GitHub

1. افتح مجلد المشروع في GitHub Desktop.
2. Publish repository أو أضف Remote للمستودع الجديد.
3. Push فرع `main`.
4. راقب Backend CI وFlutter Android وFlutter Web وFlutter iOS وProduction Release Check.
5. لا تحتاج Android Studio لبناء APK/AAB؛ GitHub Actions ينفذ البناء.


## إصلاح GitHub Actions / Pages في نسخة CI-fixed
- بناء Flutter Web يعمل دائمًا ويرفع `warqnaa-flutter-web-v200` كـ Actions Artifact حتى لو لم يتم تفعيل GitHub Pages.
- النشر إلى Pages يعمل تلقائيًا فقط إذا كان Pages مفعّلًا مسبقًا للمستودع.
- الـworkflow لا يستخدم `enablement: true` لأن `GITHUB_TOKEN` العادي لا يملك صلاحية إنشاء Pages site في بعض إعدادات المستودعات.
- إجراءات GitHub الرسمية المستخدمة في مسار Pages محدثة لإصدارات Node 24: `configure-pages@v6` و`deploy-pages@v5`.
