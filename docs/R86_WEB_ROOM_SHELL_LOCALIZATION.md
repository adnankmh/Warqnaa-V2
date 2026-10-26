# R86 — bilingual Laravel room shell

R86 localizes the server-rendered room summary, status, score, bidding labels,
Hand/Banakil workspace, accessibility names and embedded game chat for Arabic
and English. It uses the existing Laravel locale and keeps the selected theme,
room routes, action names and payloads unchanged.

The engine remains authoritative. No deck, hand, meld, economy, permission,
networking or hidden-state behavior is changed. The existing dynamic rummy
controls continue to validate every action against the latest public
available-actions snapshot before submission.
