# R223 — Scrollable Ranked setup (Issue #204)

Existing Ranked matchmaking presents game, player count, region, and server-authoritative submit in a bottom sheet. Its fixed non-scrollable Column could overflow on short portrait displays and with large text.

This increment wraps the **existing** form in a SafeArea and vertical SingleChildScrollView with keyboard-aware padding. It retains original Warqnaa blue theme, options, values, callbacks, backend verification, matchmaking API, network authority, and permissions. No third-party art, code, or screen layouts were copied.

Tests: `flutter test test/r223_ranked_queue_portrait_test.dart` — eight RTL/LTR × blue light/dark × 320/390-width portrait widget cases, plus one short landscape case. They check direction, theme, reachable confirmation and no render overflow. CI and R7 visual review are pending; screenshots must not be claimed until produced.
