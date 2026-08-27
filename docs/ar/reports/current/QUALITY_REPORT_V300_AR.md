# تقرير جودة Warqnaa WORLD EXPERIENCE — Build 300

يحافظ Build 300 على إصلاحات R14.3 ويضيف اختبارات تعاقدية جديدة للمحاور الستة. تم توسيع دورة المباراة بخادم heartbeat/reconnect/AFK، وإضافة Party للأصدقاء، وتدقيق اقتصاد بدرجة مخاطر، وست لغات، و15 ثيم، وحزمة Lottie محلية، و20+ غلاف جديد وإطارات بروفايل، وWORLD OPS داخل لوحة الإدارة.

تم تعديل Global Release ليقرأ رقم الإصدار ديناميكيًا من `RELEASE_VERSION.json` بدل تثبيت رقم قديم. تم جعل Pages اختياريًا بالكامل مع بقاء Flutter Web artifact متاحًا. يجب أن تبقى اختبارات Laravel وFlutter والبناء الفعلي إلزامية داخل GitHub Actions لأن بيئة تجهيز الحزمة قد لا تحتوي Composer/Flutter.
