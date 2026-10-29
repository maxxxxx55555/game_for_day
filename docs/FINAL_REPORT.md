# Heirs of Fortune 2.0.2 — final release report

Publication status: this 2.0.2 candidate was verified but never tagged or published; the latest published release is [Heirs of Fortune 2.0.1](https://github.com/maxxxxx55555/game_for_day/releases/tag/v2.0.1). Runtime source `1ec7668a02998043f9ba6d7307cc661ed0f7f9d1`; source-suite commit `1ec7668a02998043f9ba6d7307cc661ed0f7f9d1`.

Automated acceptance: EN 55/55, RU 55/55; 50/50 distinct complete seed routes; 3/3 consecutive native victories plus defeat; legacy read/write round-trips and tamper rejection; measured soak 1835.234s, 47 complete loops; 44 reviewed raw frames. Full receipts: [certificate](ACCEPTANCE_CERTIFICATE.md), [kit](ANNOUNCE_KIT.md), `acceptance-2.0.2-birth/`.

This update refines the in-game presentation; the previous reproducibility, integrity and audio fixes remain in place. Music recordings and licensed art remain retained; per-game gameplay and save changes are documented below. Earlier failed source acceptance is preserved in historical evidence; these passes use repaired source.

The retained 192-country birth system includes: weighted birth draw, country-specific starting capital/health/intellect/cost/lifespan and income opportunity converging at age 52; a dark ledger UI with live EN/RU birth labels. Three optional validated birth save fields use neutral defaults for older profiles. Localization now contains 816 keys. All mandatory finance-game QA was rerun on the merged repaired source; prior 53-case evidence is historical.

Unique-content branch exception: `jules-game-enhancements-12581546528437518941`, tip `5fcd0e64f169a7c3bb7b3dfe719ab68ffca7687b`, merge base `86b5344dc8e1b88aca3c48383ffac588a50bb36e`; 4 unmerged commits retained. No unique work was deleted.

The birth card now includes a subdued decorative crop of the existing fictional city illustration; it does not depict the selected country.

## Music file checksums

| Mood/cue | Title | SHA256 |
|---|---|---|
| welcome | Last Call at Three | `d42da2f8051e5bb00c3a69aeddbdcea0aade4ae1ff0937c90a450cb7e350366a` |
| study | After Hours Ledger | `46f5cc6e2eb600577df89ea0c9aed83842aa8685897015b55c055e087553cfae` |
| career | Opening Bell Swing | `b24c1e3a4c70ccdcc914883844c07340193d311b6a328d0392dcced12f4b75ab` |
| tycoon | The Long Dividend | `9039517d664e5a08d28b1ea3aa9fa6ff94d7a74b1fc93630fd3149dcc19b2735` |
| victory | A Fortune Remembered | `7c4271f77bb9cef720f42ffb2269f572511013df79c9d7e88f18eb8c1e8c5de1` |
| defeat | The Closing Ledger | `1b4901e66ec803e2dd73eab699687d6d4936b3138a07bb50762d4ad4c871d6a0` |

Known limitations: no human/audible final acceptance, Android/store certification or Authenticode; no AAA or universal no-bug/invulnerability claim. See HANDOFF. Final ZIP hashes and remote verification are recorded after publication.
