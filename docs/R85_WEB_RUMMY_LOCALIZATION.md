# R85 — bilingual web rummy controls and public player names

R85 completes Arabic/English localization for the Laravel web-room controls
used by Hand and Banakil. Stock, discard, buried-fire selection, confirmation,
cancel and accessibility labels now follow the document locale and direction.

Shared and individual meld surfaces resolve names only from the engine's
existing public `players` array. They fall back to localized Player/Bot labels
when public metadata is absent; no hidden hand or private profile data is
introduced.

The change is presentation-only. The same server-authoritative action names,
selected discard count, ownership identifiers and team restrictions remain in
place. The script asset version is advanced to 85 so deployed clients do not
retain the older Arabic-only bundle in browser caches.
