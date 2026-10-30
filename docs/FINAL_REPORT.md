# Heirs of Fortune 2.1.0 — final release report

Publication status: the publication gate returned PASS at source commit `807ba09c551134c76f23b4167ab7b5783dd7199e` (engine 4.7.stable.official.5b4e0cb0f, Windows x64, clean tree). The tag `v2.1.0` names that commit; the two release assets are `HeirsOfFortune-Windows-2.1.0.zip` and `HeirsOfFortune-SHA256SUMS-2.1.0.txt`. The previous published release is [Heirs of Fortune 2.0.1](https://github.com/maxxxxx55555/game_for_day/releases/tag/v2.0.1); the 2.0.2 candidate was verified in source but never tagged or published.

Automated acceptance at the gate: strict compile over 34 shipping scripts with all 49 warning categories as errors; 49 headless and 50 rendered source cases in Russian and in English with zero failures; four exports; nine exported-binary runs (three victories, three defeats, three verifier-refusal guards); 100 of 100 seeded cycles with 100 distinct final states; 1.4.0 and 2.0.x profile round-trips; a 1,817.032-second rendered soak with 84 complete cycles, 1,333 checkpoints, zero failures and flat engine object counts. Total gate wall time 5,685 seconds. Full receipts: [certificate](ACCEPTANCE_CERTIFICATE.md), [kit](ANNOUNCE_KIT.md), [release notes](RELEASE_2.1.0.md).

Balance: 112 scripted lives in 1,214.5 seconds under a conservative and an aggressive policy over the four birth origins, with no dominance finding. Meteor reaches victory about three years earlier than its siblings and pays for it in measured stress; heir pays a tenth of quarterly income for a larger inheritance and finishes later; steady is the reference. Perks and ascension levels shift age and stress without producing a free win.

Performance: measured against a 2.0.2 worktree in interleaved attempts on this host with isolated save profiles — median frame 16.665 ms versus 16.675 ms, p95 17.272 ms versus 17.263 ms, dashboard ready 528 ms versus 545.5 ms against a baseline attempt spread of 159 ms. No regression is claimed beyond that noise, and no every-device claim is made.

Presentation: the gallery was re-rendered at `e9b0256` after the Heir copy changed — 66 frames in four labelled contact sheets plus 12 ambition-row frames covering each ambition in both locales at 540x960 and 720x1280. Five earlier defects (raw rank printing, milestone card width, dynasty ghosting, thread phrase, age plural) remain fixed; the anti-AI-slop audit passes over displayed copy, palette, type and icon geometry.

## Defects found and repaired while closing this edition

- QA capture folders were being packed into the shipped PCK; `export_presets.cfg` now excludes `builds/`, and the repository isolation check refuses a tracked path under it.
- The soak trend rule reported allocator oscillation at a ~350 MB plateau as a leak; the rule now scales its allowance to the plateau and still flags a synthetic 150 B/s leak.
- The heir ambition was strictly dominant — upside with no cost. It now trades a tenth of quarterly income for its inheritance bonus, and both the model cost and the disclosure on the description the player reads are asserted by tests.
- Bulk document spacing had edited byte-pinned promise snapshots; the snapshots were restored verbatim and the promise inventory re-hashed, rather than loosening the promise test.
- The mechanics matrix carried an `execution_evidence` path that never existed in the repository; it now names the suites that actually run, and ambitions gained their own row with per-column assertions that exist.

## Music file checksums

| Mood/cue | Title | SHA256 |
|---|---|---|
| welcome | Last Call at Three | `d42da2f8051e5bb00c3a69aeddbdcea0aade4ae1ff0937c90a450cb7e350366a` |
| study | After Hours Ledger | `46f5cc6e2eb600577df89ea0c9aed83842aa8685897015b55c055e087553cfae` |
| career | Opening Bell Swing | `b24c1e3a4c70ccdcc914883844c07340193d311b6a328d0392dcced12f4b75ab` |
| tycoon | The Long Dividend | `9039517d664e5a08d28b1ea3aa9fa6ff94d7a74b1fc93630fd3149dcc19b2735` |
| victory | A Fortune Remembered | `7c4271f77bb9cef720f42ffb2269f572511013df79c9d7e88f18eb8c1e8c5de1` |
| defeat | The Closing Ledger | `1b4901e66ec803e2dd73eab699687d6d4936b3138a07bb50762d4ad4c871d6a0` |

Known limitations: no human/audible final acceptance, Android/store certification or Authenticode; the QA harnesses share the real user-data profile with the game, so save-writing harnesses and suites are never run concurrently; the balance sweep measures two scripted policies rather than the whole strategy space. No AAA or universal no-bug/invulnerability claim. See HANDOFF. Published at https://github.com/maxxxxx55555/game_for_day/releases/tag/v2.1.0 from tag `v2.1.0`, which peels to the gated commit `807ba09c551134c76f23b4167ab7b5783dd7199e`. The release carries exactly two assets: `HeirsOfFortune-Windows-2.1.0.zip` (85,736,652 bytes, SHA256 `c7199222573d17c8996d8774ffdd6238feef240753eaf803b137eba38b456226`) and `HeirsOfFortune-SHA256SUMS-2.1.0.txt`. Both were downloaded fresh from the release into an empty directory and `sha256sum -c HeirsOfFortune-SHA256SUMS-2.1.0.txt` printed `HeirsOfFortune-Windows-2.1.0.zip: OK` with exit code 0.
