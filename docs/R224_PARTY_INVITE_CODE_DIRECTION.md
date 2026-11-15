# R224 — Stable party invitation code direction (Issue #204)

## Existing behavior
The party screen already uses a server-backed seven-character invitation flow,
validates the code locally, and supports selecting/copying the issued code.
In Arabic RTL, the displayed code and entry field inherited RTL text direction,
which is inappropriate for a mixed letter/number identifier.

## Scope
- Keep the **party page and labels RTL in Arabic**, while displaying and entering
  invite identifiers LTR in both locales.
- Center the selectable issued code and preserve its Warqnaa theme primary color.
- Disable autocorrect/suggestions on the invitation input so a keyboard cannot
  silently alter a code. Preserve seven-character maximum and existing uppercase
  normalization and server validation.
- No changes to party membership, authorization, backend, multiplayer engine,
  economy, networking, or any external artwork.

## Verification
`flutter test test/r224_party_invite_code_direction_test.dart`:
8 Arabic/English × light/dark Warqnaa blue × 320/390 portrait cases plus
one short landscape case. Tests assert the actual code order, input direction,
label localization, primary theme color, and preserved input.

Screenshots and final CI outcomes must be confirmed from GitHub Actions;
none are claimed by this document.
