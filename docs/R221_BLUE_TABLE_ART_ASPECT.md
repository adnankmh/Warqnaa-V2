# R221 — Blue table artwork aspect and fallback

Tracking: #204

## Scope
The existing Warqnaa-owned table artwork in `R48ApprovedTableArt` used `BoxFit.fill`, which can distort card/table motifs on portrait devices. This change uses `BoxFit.cover` with centered alignment, so the original artwork keeps its aspect ratio while filling the available table surface. Cropping at the edges is preferable to stretching the artwork.

An original Warqnaa-blue gradient (`R9Design.skyPanel` → `R9Design.midnight`) is always behind the image. If an approved asset cannot load, a small decorative fallback appears over that gradient rather than a blank or error-colored table. The image remains excluded from accessibility semantics because the table background is decorative; gameplay controls and information remain separately accessible.

## Verification
`flutter_app/test/r221_blue_table_art_aspect_test.dart` exercises the actual `R48ApprovedTableArt` widget in eight portrait combinations (Arabic RTL / English LTR × blue light/dark × 320/390px), one landscape scenario, and one deliberately unavailable image. Assertions cover aspect-preserving fit, correct portrait/landscape asset, blue fallback surface, and absence of widget exceptions.

Run `cd flutter_app && flutter test test/r221_blue_table_art_aspect_test.dart`, then the full Backend, Flutter Web, Android APK/AAB, R7 Visual Runtime, and Production Release workflows on the **same commit SHA**. Do not merge until all five are successful and the PR is conflict-free.

## Boundaries
No changes to catalog IDs, asset licenses, artwork files, commerce/ledger, gameplay engines, multiplayer, permissions, or server authority. The design is original to Warqnaa; no Jawaker assets or layout were copied.
