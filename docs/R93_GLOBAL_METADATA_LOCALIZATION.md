# R93 — locale-aware global metadata

Date: 27 October 2026.

## Scope

The shared Laravel shell now emits metadata that matches the active Arabic or English locale before JavaScript runs:

- the default document title;
- description and keyword metadata;
- Open Graph description;
- JSON-LD `inLanguage` and application description;
- the signed-in user's avatar alternative text.

Canonical URLs, routes, theme identifiers, manifests, notification behavior, permissions, economy and gameplay are unchanged.

## Verification

`R93GlobalMetadataLocalizationTest` guards both language variants and prevents a return to the former fixed Arabic JSON-LD language or generic avatar label. The pull request must remain unmerged until all five required GitHub Actions gates pass on one head and the current branch/main SHAs are rechecked.
