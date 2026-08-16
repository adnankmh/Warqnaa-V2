# Warqnaa V0.4.4+200 — Full Fusion Pro — CI Fixed R2

هذه هي الحزمة الكاملة المبنية فوق مشروع Warqnaa الكبير مع Laravel + Flutter + Web + جميع الـAssets.

الإصدار الحالي: **0.4.4+200**

## التشغيل المحلي
ابدأ من `START_HERE_AR.md`. البورت الافتراضي المقترح هو **8007**، مع دعم **8008 / 8009 / 8010**.

## بنية المشروع
- `flutter_app/`: تطبيق Flutter للويب وAndroid وiOS/PWA.
- `backend-laravel/`: Laravel API/Website، الحسابات، الغرف، الاقتصاد ومحركات اللعب.
- `assets/`: أصول النشر والمتاجر.
- `docs/`: أدلة التشغيل، تقارير الجودة وسجل الإصدارات.
- `tools/`: Release Gates وعقود التوافق وفحوص CI.
- `scripts/`: أدوات Windows وLinux/macOS.
- `.github/workflows/`: Backend CI وAndroid وiOS وFlutter Web وبوابات الإصدار.

## GitHub Actions
المسارات الأساسية:
- **Production Release Gate**
- **Backend CI and Security Foundation**
- **Build Android APK and AAB**
- **Flutter iOS**
- **Build and deploy Flutter Web**

بناء Flutter Web لا يعتمد على تفعيل GitHub Pages: يتم رفع Build كـActions Artifact دائمًا. إذا كان Pages مفعّلًا مسبقًا، يتم النشر إليه تلقائيًا.

## ملاحظة الإصلاح R2
تمت إزالة تثبيت عقود V183/V0.3 على الإصدار القديم `0.3.3+184`، وأصبحت عقودًا تراكمية تقبل الإصدار الحالي وما بعده مع الاحتفاظ بمتطلبات الميزات القديمة. كما تم تحديث GitHub Pages وCheckout إلى إجراءات متوافقة مع Node 24.
