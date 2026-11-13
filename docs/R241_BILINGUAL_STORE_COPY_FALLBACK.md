# R241 — Safe bilingual server-store copy fallback

Issue: #204. Baseline main: `1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`.

## Existing implementation
`R36ServerStore.storeTextR36` already supplies server catalogue names and
descriptions to the real `ProductCardV170` widget. Empty localized fields
could previously hide otherwise valid server copy. This change is limited to
presentation; it does not modify the price, purchase flow, balances, inventory,
entitlements, authorization, network calls or gameplay engines.

## Change
- Ignore whitespace-only localized strings.
- Prefer the requested language, then English, then Arabic.
- Support both nested `payload.description` translations and flat
  `payload.description_ar` / `payload.description_en` fields.
- Fall back to existing local product copy when no nonblank server text exists.

## Tests
`flutter_app/test/r241_store_copy_fallback_test.dart` covers two server
fallback/quote cases and eight actual `ProductCardV170` portrait cases:
Arabic RTL / English LTR × blue light / blue dark × 320 / 390 px.
Each widget case checks visible localized copy, direction, blue theme,
server quote immutability and absence of Flutter layout exceptions.

## Validation / constraints
All five CI gates must pass on one final PR HEAD; this branch remains draft
and must not be merged before that plus conflict and visual review.
No third-party assets or copied reference UI are included.
