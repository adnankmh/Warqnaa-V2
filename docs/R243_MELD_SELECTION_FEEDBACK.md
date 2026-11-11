# R243 — bilingual meld selection feedback (#204)

Existing R36MeldWorkspace selects hand positions, permits reversible preview sorting and submits grouped cards to the existing validated game engine. The original blue Material palette is preserved.

This change adds a visible, screen-reader live-region count of cards currently selected, localized for Arabic RTL and English LTR. It updates after selecting or deselecting cards, without changing card ownership, grouping, submit payloads, network, economy or permissions.

Eight widget configurations cover 320/390px portrait widths, both directions and blue-seeded light/dark themes. They assert the live count changes, inherited direction, theme ink and absence of widget exceptions.

Base main: `1ff82f8dae7a16f3713363d10da4e95c1a9b1ce9`.
Keep draft; all five CI gates must pass on the same final HEAD, merge must be conflict-free and visual review accepted. No third-party artwork, wording or layout copied.
