# Warqnaa V0.4.4+200 — CI Fixed R2

## المشاكل التي تم إصلاحها
1. `test_v183_overhaul_contract.py` كان يفرض `0.3.3+184` ويكسر جميع الإصدارات الأحدث. أصبح يتحقق من build 184 أو أحدث ومن اتساق `RELEASE_VERSION.json`.
2. `test_v030_contract.py` كان يحتوي على نفس التثبيت القديم، وتم تحويله إلى عقد توافق تاريخي تراكمي.
3. Flutter Web كان يستخدم `enablement: true` مع `actions/configure-pages` ويحاول إنشاء Pages site عبر `GITHUB_TOKEN`، ما قد ينتج 403. أصبح بناء الويب مستقلاً عن Pages، والنشر يتم فقط إذا كان Pages موجودًا بالفعل.
4. تحديث `actions/configure-pages` إلى v6 و`actions/deploy-pages` إلى v5 و`actions/checkout` إلى v6 لمسار Node 24.
5. إضافة `tools/test_ci_release_compat_contract.py` لمنع رجوع تثبيت الإصدارات القديمة أو إعداد Pages المسبب للخطأ.
6. تحديث `validate_release.py` ليتوافق مع `checkout@v6`.

## النتيجة المحلية
- Production source preflight: PASS
- PHP syntax: PASS (317 files)
- Official engine rules: PASS
- Engine stress: PASS (360 scenarios / 18 engines)
- Workflow YAML parse: PASS
