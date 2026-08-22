# تقرير جودة Warqnaa R11 Build 230

الإصدار: **0.6.0+230 — R11 Social World**

## بوابة التوافق

- R8 Engine Integrity
- R9 Visual Revolution
- R9.1 Gameplay Polish
- R10 Asset Delivery
- R10.1 Commerce & Visual Experience
- R11 Social World Contract
- Release version consistency
- Clean-root and secrets policy

## تدقيق R11

- Social World API/Web/Flutter wiring.
- Privacy and presence enforcement on legacy social/realtime endpoints.
- Player/admin-only realtime room chat; spectators cannot read or publish to it.
- Spectator read-only route boundary.
- Recursive redaction of hands, deck, credentials, contact data, passwords, secrets, tokens and RNG state.
- Consent from every human participant for spectator and replay sharing.
- Atomic capacity checks for spectator stands, event attendance, and Clubs 2.0 membership.
- Player-only voice contract.
- Replay integrity digest and visibility policy.
- Best-effort replay capture that cannot interrupt authoritative gameplay.
- Scheduled retention/lifecycle cleanup with a dry-run mode.
- Admin permission and audit boundary.
- Animated gifts remain outside competitive engines.

## نتيجة بيئة التجهيز

- `tools/test_v230_r11_contract.py`: **PASS**.
- `tools/validate_release.py`: **PASS**.
- عقود R8/R9/R9.1/R10/R10.1: **PASS** ضمن فحص المصدر.
- فحص JSON/YAML/XML وبنية Dart وClean-root والإصدار: **PASS**.
- هذه بيئة التجهيز لا تحتوي PHP/Composer أو Flutter/Dart SDK؛ لذلك يبقى PHP syntax، Laravel PHPUnit، اختبار المحركات التنفيذي، `flutter analyze/test`، وبناء Android/iOS/Web بوابات إلزامية في GitHub Actions.
