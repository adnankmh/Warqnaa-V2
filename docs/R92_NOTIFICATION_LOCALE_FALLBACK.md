# R92 — locale-correct notification drawer

R92 aligns the global Laravel notification drawer with the full notifications
page. Notification titles and bodies now use the active Arabic or English
locale, fall back to the other supported locale when content is missing, and
finally fall back to the notification type for a missing title.

The drawer omits an empty body instead of rendering an empty paragraph.
Notification records, types, routes, read/delete behavior, counters, economy,
permissions and gameplay are unchanged.
