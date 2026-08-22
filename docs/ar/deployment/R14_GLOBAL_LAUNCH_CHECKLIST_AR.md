# Checklist الإطلاق العالمي R14

- اضبط `APP_ENV=production` و`APP_DEBUG=false` وHTTPS.
- اربط PostgreSQL/Redis/Queue/Storage ونسخًا احتياطية مراقبة.
- أضف Secrets الدفع والإعلانات والصوت وPush خارج المستودع.
- وقّع Android AAB وiOS Archive من حسابات المتاجر الرسمية.
- راجع النصوص والصور وسياسات الخصوصية بالعربية والإنجليزية.
- فعّل DNS/TLS والمراقبة والتنبيهات وخطة Rollback.
- شغّل `warqna:global-release-check --strict --json` في بيئة الإنتاج.
- لا تطلق قبل نجاح Global Release Gate وأدلة SHA-256.
