# R49 friendly-room seats and invitation delivery

Based on main 7e373c710b85f7df14eca9ccaa052be315287364 and the reviewed
existing PR #42. The previous R49 seat-selection fix and Flutter-triggered
backend security gate are preserved. Legacy draft PR #7 is untouched.

## Result

An invited friend can replace a default bot. The bot selector reflects the
actual saved seat mix. Once the server creates a room, its board is shown
immediately; slow invitation delivery no longer keeps it behind a spinner.
Rejected invitations are counted and reported in Arabic/English while the
remaining invitations continue. Invitation failures do not recreate the room
or silently switch it to offline practice. Leaving the widget stops subsequent
invitations and suppresses stale notices. Joining an existing room sends no
creation invitations.

No new account privileges, balance grants, prices, payment verification or
game-rule changes are introduced.

## Verification

Existing AR/EN Hand/Banakil friendly-seat widget tests are retained. New real
room-widget tests use a controllable API transport to exercise pending,
rejected and successful invitation responses, disposal and joining. They
assert the room code, actual API request bodies and room-creation count.
This is synthetic transport coverage, not a claim of real push delivery.

The existing isolated runtime job additionally runs these widget scenarios
and captures four actual invitation-failure frames, Arabic/English in portrait
and landscape. Sanitized PNGs are saved with the other runtime screenshots;
chunked base64 log evidence makes visual review possible without a connected
local executor. All existing HTTP journeys and table review captures remain.

The five release workflows and visual evidence must be reviewed on the same
final head before merge. Public Laravel hosting/API configuration, production
credentials/signing and physical-device validation remain separate deployment
requirements. GitHub Pages hosts only the static Flutter client.
