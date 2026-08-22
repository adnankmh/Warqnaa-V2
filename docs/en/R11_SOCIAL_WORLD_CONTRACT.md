# Warqnaa R11 Social World Contract

Release: **0.6.0+230**

R11 is cumulative and preserves R8–R10.1. Social discovery, feed, events, Clubs 2.0, spectator stands, privacy-safe replays, animated gifts, and the admin control plane share one server-authoritative contract.

Spectators are read-only: they never receive hands, deck order, legal-action hints, credentials, contact details, passwords, secrets, tokens, RNG material, player voice, or private chat. Legacy realtime room chat is player/admin-only. Spectating and replay sharing require consent from every human participant and respect every block boundary.

Replays store only recursively sanitized public state and carry a SHA-256 integrity digest that is verified before playback. Replay recording is best-effort and can never interrupt an authoritative game action. Animated gifts are social-only and cannot influence dealing, legal moves, results, or competitive progression.

Spectator capacity, event attendance, club membership, and join-request acceptance are serialized with database transactions and row locks. `warqna:cleanup-social-world` runs through the Laravel scheduler to expire stale presence, finish events, and enforce replay retention. Production must run Laravel's scheduler every minute.

Administrative mutations require the `social_world` permission and are recorded through the admin audit service.
