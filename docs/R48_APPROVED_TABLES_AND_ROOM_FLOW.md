# R48 — approved tables, real friendly setup and card artwork

Base: R47 main `270d3e3dca3f890507224dc0b92a93e255c3e353`.
Only the preserved draft PR7 was open at the initial review. All five main
workflows were green. R41–R47 changes were reviewed and retained.

## Actual implementation

- Friendly Match opens the real room settings directly. The retained root
  navigator survives dismissal of the lobby/settings sheet; creation no longer
  depends on the application-global navigator key. Settings pass the real room
  name, privacy, speed, seats, bots, invitations and round options to the existing
  online/offline launch path. English strings are added alongside Arabic.
- Three approved table concepts replace artwork for existing curated SKUs:
  royal 09 (purple), royal 21 (ocean), showcase 04 (eagle). Their identities,
  prices, ownership and admin overrides are retained. The free emerald starter
  remains free and all previous catalogue entries remain available.
- Production table surfaces and store previews render full-bleed artwork.
  Transparent exteriors reveal the page rather than a dark rectangular backing;
  turn messages use an opaque readable panel over detailed artwork.
  Portrait uses a dedicated upright derivative, landscape the supplied image.
  Paired card backs use the upright image. Laravel uses responsive picture
  sources; Flutter uses the actual surface constraints.
- Offers and collection surfaces use solid blue panels and readable light text.
  The main storefront carousel now reads real checkout packages from the server
  instead of displaying hardcoded daily/weekly/monthly/annual marketing prices.
  It clears those prices offline; existing timed collectible discounts remain
  sourced from the catalogue quote service.
  Cash tabs filter explicit server-provided category tags, including an honest
  empty weekly state when no package is tagged weekly. Prices, checkout and
  receipt verification stay server controlled.
- Web card faces are original vector artwork for all 52 cards and Jokers,
  including correct red/black suits, pip counts and gold court-card details.
  Native court cards receive matching gold crowns; the existing 52-face pip
  painter and whole-Joker handling remain in use.
- Banakil fire-stack count validation rejects fractional/coerced counts without
  mutating cards; valid whole-number pickups retain ordered physical cards.
  Existing Hand/Banakil draw, multi-meld, wild replacement, layoff, scoring,
  fair-deal and bot suites remain mandatory. This increment is not a claim that
  every possible rule variant has been independently certified.
- Web room cosmetic selection excludes expired/consumed inventory and resolves
  the actual table/card-back images from catalogue payloads.

## Artwork provenance

The three source PNGs were recovered from the user's attachments dated
2026-10-18 15:38:50, 15:42:09 and 15:43:41 UTC. The images are not screenshots
substituting for functionality. They are runtime background assets.
`R48_ART_PROVENANCE.json` records original and optimized SHA-256 fingerprints.
Landscape sources are only re-encoded to WebP. Portrait derivatives were made
with the built-in ImageGen tool, then compressed as project assets.

Prompt set: edit the corresponding supplied table into a 2:3 upright portrait,
preserving its purple/silver/gold velvet frame, ocean/whale/turtle gold frame,
or brown/gold eagle/mountain identity; retain four sides and corners, preserve
upright subjects, use transparent pixels outside the rounded table, and include
no text, cards, controls or UI. These derivatives are adaptations of approved
concepts, not a claim of pixel-identical new user-approved portrait originals.

Assets: `flutter_app/assets/optimized/r48/` and the matching
`backend-laravel/public/assets/store/r48/` files. Portrait images retain their
1024×1536 resolution. WebP colour/alpha compression reduces the six-image set
from 1.79 MiB to 0.87 MiB, with identical bytes in both clients. The R47 asset
budgets remain measured separately under the reviewed R48 allowance.

## Verification and deployment boundary

New native tests exercise Friendly Match through actual settings into a live
Hand/Banakil table without a global navigator key, in Arabic/English at narrow
portrait and short landscape sizes. Cash-tab tests use the actual API surface.
R7 captures all three real Banakil table designs in both orientations/locales,
the settings sheet, and the 52-face/Joker gallery. PHP tests exercise production
factory count validation, image routes and server catalogue categories. Node
tests exercise all vector faces, suit colours, pips, Jokers and hostile input.

Merge requires Backend, Flutter Web/Chrome, Android, R7 runtime/visual and
Production Release success on the same final commit, plus visual inspection.
Framework execution is delegated to CI because this workspace has no Flutter
or PHP SDK. Local Node and Python contract results alone are not release gates.

GitHub Pages remains a static Flutter Web client. It is not a Laravel host.
Public API hosting/configuration, production signing/payment inputs and physical
device validation remain separate deployment requirements.
