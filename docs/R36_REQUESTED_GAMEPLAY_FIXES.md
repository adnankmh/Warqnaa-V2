# R36 gameplay, administration and store integration

This change addresses active routes and server behavior, in addition to the reference artwork.

- The game lobby offers direct play for all 12 customer engines. Switching from an existing game requires leaving that table through its server API. Room initialization waits for the first frame before updating shared application state.
- The authenticated administrator has a visible command-center entry. The effective primary-administrator balance is the exact string `9999999999999999999`; formatting never casts it to PHP integers or JavaScript numbers. The protected non-depleting BIGINT reserve remains an internal implementation detail.
- Bootstrap and engagement inventory responses are complete. Owned-but-unequipped rows are recognized by positive quantity. A full account snapshot replaces stale ownership from the preceding account.
- Flutter reads prices, offer discounts, names, descriptions, duration and active status from the server. Newly created server catalogue products appear in the application. Checkout confirms the displayed quote and refreshes after a stale-price response.
- Connected administrator store edits use the authenticated API. Persistent store overrides preserve edited, hidden, custom and deleted products across catalogue synchronization. They require the new `2026_10_15_000370` database migration.
- Daily/weekly offer classification derives from each real offer's dates. Mission cadence filters use server records and reset timestamps. Failed online requests display an error instead of fabricated fallback missions.
- The production Banakil factory now advertises, validates and applies multi-card fire-pile draws. Hand's web multi-group action reaches the actual production adapter. Flutter and Web have local meld drafts with duplicate-card-safe selection, grouping and undo; the server validates the complete opening atomically.
- Individual Hand permits legal attachments to other players' melds after opening. Banakil retains partnership restrictions.
- Online and local rummy bots evaluate useful public discards, protect connected/wild cards, combine opening groups and attach legal cards. Their draw policies do not inspect opponents' hands or the stock. Casual deal scoring evaluates each seat's own hand rather than using seat zero when testing other candidates. Ranked dealing remains on the existing server fairness path.
- The six family illustrations and all Pasha color variants replace the packaged production artwork on both platforms, within existing asset budgets. Variant game labels remain real, accessible interface text.

Validation must be reported for the final exact commit. Earlier green builds do not certify these changes. Run the complete Backend, Flutter Web, Android APK/AAB, runtime/visual and release workflows before merging. Production backend hosting, live account repair and store signing still require an actual configured environment; a pull-request build does not update a user's installed application.
