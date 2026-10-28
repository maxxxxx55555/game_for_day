# Heirs of Fortune 2.0.1 — final release report

Release URL: [Heirs of Fortune 2.0.1](https://github.com/maxxxxx55555/game_for_day/releases/tag/v2.0.1). Runtime source `2ca971ba27d78a931d792912d45bdb8bf4245537`; source-suite commit `2ca971ba27d78a931d792912d45bdb8bf4245537`.

Automated acceptance: EN 53/53, RU 53/53; 50/50 distinct complete seed routes; 3/3 consecutive native victories plus defeat; legacy read/write round-trips and tamper rejection; measured soak 1850.625s, 69 complete loops; 40 reviewed raw frames. Full receipts: [certificate](ACCEPTANCE_CERTIFICATE.md), [kit](ANNOUNCE_KIT.md), `acceptance-2.0.1/`.

Patch changes: canonical critical-data and audio-generator bytes, stable Windows localization CSV serialization where applicable, bounded audio teardown for normal/QA exits, safe retry handling and stricter leak detection. Runtime balance, music recordings, save schema and licensed assets are retained. Earlier failed source acceptance is preserved in historical evidence; these passes use repaired source.

Unique-content branch exception: `jules-game-enhancements-12581546528437518941`, tip `5fcd0e64f169a7c3bb7b3dfe719ab68ffca7687b`, merge base `86b5344dc8e1b88aca3c48383ffac588a50bb36e`; 4 unmerged commits retained. No unique work was deleted.

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
