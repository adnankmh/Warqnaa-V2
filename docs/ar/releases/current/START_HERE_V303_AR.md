# ابدأ هنا — Warqnaa V1.2.0 Build 303

B303 هو إصدار Runtime Social Stability + Global Premium UI تراكمي فوق B302، ويحافظ على كل ميزات R8–R14.3 وWORLD EXPERIENCE واللغات الست والثيمات والاقتصاد والاجتماعيات والأمان.

## أهم إصلاحات B303

- إصلاح تبديل هوية مستخدم Mobile API بين Bearer tokens عبر `AuthenticatedActor` لإزالة stale guard state الذي تسبب في 409 داخل Clubs World.
- إعادة تحميل صلاحيات الإدارة من قاعدة البيانات لكل طلب حساس لإزالة 403 الخاطئ بعد منح `social_world` بنفس access token.
- إضافة `V303RuntimeStabilityTest` لإعادة سيناريوهات V230 التي فشلت في GitHub Actions.
- إصلاح أخطاء وتحذيرات Flutter analyzer الظاهرة في `r11_social_world.dart` و`r12_competitive.dart` و`v175_release.dart`.
- Premium Home/Lobby جديد للويب وFlutter مع Hero عالمي وLive status وGame Hub متجاوب.
- تنظيف تلقائي لملفات Dart القديمة المتعقبة قبل GitHub push عبر B303 Flutter lib manifest.
- بوابة CI `test_v303_runtime_premium_contract.py` على Backend/Android/iOS/Web/Global Release.

على Windows: شغّل `START_WARQNA_WINDOWS.bat`. قبل GitHub شغّل `CHECK_WARQNA_WINDOWS.bat`. للرفع شبه التلقائي استخدم `scripts/windows/current/RUN_GITHUB_READY_B303.bat`.
