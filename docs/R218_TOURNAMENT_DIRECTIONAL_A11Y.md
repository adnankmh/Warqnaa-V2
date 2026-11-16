# R218 — directional tournament navigation and accessibility

Issue: #204. Based on main `1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`.

The existing R35 tournament card was already a real InkWell with an active navigation callback and original Warqnaa blue gradient. Its trailing chevron was fixed to point right even in Arabic RTL; its text and tap target were not grouped into one descriptive screen-reader button.

This focused change:
- Mirrors the chevron using ambient `Directionality` (left in RTL, right in LTR).
- Exposes one accessible button with title, detail, and the same navigation callback; hides duplicate child semantics only, not the visible InkWell.
- Preserves the original blue gradient, original icons, layout, and all existing navigation/business logic.

New regression test `r218_tournament_directional_a11y_test.dart`: 8 widget cases across Arabic/English, light/dark blue-seeded themes, and 320/390px portrait widths. Assert chevron direction, semantic button/label/tap, callback, blue gradient, and no Flutter layout exception.

No game engine, network, wallet, entitlement, or permissions changes. No third-party art, assets, text, or UI layouts were copied.

Merge only after all five required CI workflows succeed on one exact head SHA and GitHub reports no merge conflict.
