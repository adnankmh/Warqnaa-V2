# R231 — RTL/LTR original-blue shared section lighting

The existing `R9Section` rendered light/dark blue gradient surfaces with fixed physical top-left to bottom-right direction. In Arabic RTL, the lighting did not mirror. Both gradients now use `AlignmentDirectional.topStart` and `AlignmentDirectional.bottomEnd`. Colors, shadows, borders, dimensions and children remain unchanged.

Nine Flutter widget tests in `flutter_app/test/r231_directional_blue_section_test.dart`: eight portrait combinations (Arabic RTL / English LTR, 320/390 widths, light/dark blue) plus RTL landscape. Tests assert gradient endpoints, original palette and border colors, direction and no layout exception.

Only original Warqnaa styling; no reference-game assets or layout copied. No changes to game engines, economy, networking, privacy, permissions or server authority. No screenshot is claimed without real runtime evidence.

Do not merge until all five CI gates pass on identical HEAD, merge conflict check is clean and visual review is complete.
