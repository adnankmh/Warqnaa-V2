# Warqnaa R16 — التشغيل المحلي وجاهزية الإنتاج

## التشغيل المحلي السريع على Windows

1. ضع المشروع في مسار مثل `C:\xampp\htdocs\Warqnaa`.
2. شغّل `START_WARQNA_WINDOWS.bat` من جذر المشروع.
3. اختر منفذًا متاحًا من المنافذ التي يدعمها المشغل، مثل 8007–8010.
4. افتح العنوان المحلي الذي يعرضه المشغل في المتصفح.
5. لفحص المشروع قبل أي رفع إلى GitHub شغّل `CHECK_WARQNA_WINDOWS.bat`.
6. لتشغيل Flutter Web بصورة مستقلة استخدم `flutter_app\RUN_FLUTTER_WEB.bat`.

## إعداد حساب primary_admin محليًا

لا تضع كلمة المرور أو البريد الخاص في Git. عرّف القيم التالية في البيئة المحلية أو `.env` غير المتعقب:

- `WARQNAA_ADNAN_ADMIN_EMAIL`
- `WARQNAA_ADNAN_ADMIN_PASSWORD`

ثم نفّذ أمر إعداد المدير من بيئة Laravel الموثوقة. حالة `primary_admin` تعيد تلقائيًا مستوى 99، Pasha 36500 يومًا، الرصيد الإداري، الصلاحيات الكاملة، مقتنيات المتجر، والتذاكر إلى الحدود الإدارية المعتمدة.

## الصوت

التجربة المحلية تستخدم STUN افتراضيًا. للعمل بين شبكات عامة مختلفة بصورة موثوقة في الإنتاج يجب ضبط TURN من متغيرات البيئة:

- `VOICE_TURN_URLS`
- `VOICE_TURN_USERNAME`
- `VOICE_TURN_CREDENTIAL`

كما يحتاج الهاتف الفعلي إلى Laravel API منشور عبر HTTPS بدل `localhost`.

## الدفع الحقيقي

لا يمنح Warqnaa أي توكنز بناءً على نجاح يرسله العميل فقط. التحقق يجب أن يكون خادميًا.

يدعم R16 تجهيز التحقق عبر:

- Trusted verifier لـ Google Play.
- Trusted verifier لـ Apple IAP.
- Trusted verifier للويب.
- Stripe PaymentIntent للويب عند ضبط السر الإنتاجي.

متغيرات الإنتاج تبقى خارج Git:

- `WARQNAA_GOOGLE_PLAY_VERIFIER_URL`
- `WARQNAA_GOOGLE_PLAY_VERIFIER_SECRET`
- `WARQNAA_APPLE_VERIFIER_URL`
- `WARQNAA_APPLE_VERIFIER_SECRET`
- `WARQNAA_WEB_VERIFIER_URL`
- `WARQNAA_WEB_VERIFIER_SECRET`
- `WARQNAA_STRIPE_SECRET`

## اللعب الجماعي العام

الكود يحافظ على اللعب server-authoritative ويدعم heartbeat وreconnect وparties والغرف والمنافسات. لكي يصبح اللعب عامًا بين أجهزة حقيقية يجب نشر Laravel API/Runtime على عنوان HTTPS عام وضبط قاعدة البيانات والخدمات الإنتاجية، ثم اختبار عدة أجهزة وشبكات فعلية.

## حدود النشر

لا تعتبر Production signing أو Google Play/App Store publication مكتملة من المصدر وحده. هذه الخطوات تحتاج حسابات المالك ومفاتيح التوقيع وأسرار النشر الخاصة به، ويجب ألا تدخل المستودع.
