# Heirs of Fortune — final release report

Closeout date: 2026-10-26. The accepted Windows release is handed to its owner. The new closeout commit contains documentation only; `main` is a docs-only descendant of the immutable release tag. Game files, source version, tag and distributed game bytes are unchanged by this closeout.

## Release identity and artifacts

| Field | Accepted value |
|---|---|
| Game / platform | Heirs of Fortune / Windows x86_64 |
| Version / immutable tag | 2.0.0 / `v2.0.0` |
| Release URL | [v2.0.0](https://github.com/maxxxxx55555/game_for_day/releases/tag/v2.0.0) |
| Released source commit | `b5a9aba0821ae9af8a202a4c835e17981425e09a` |
| Released source tree | `e13c284bb2ed6c1956f2fce52458f72dbb3b1e40` |
| Engine | Godot 4.7 Stable, compatibility renderer |
| Gate before publication | 59/59 checks; 100%; gate SHA256 `f1c89509c002c05e3e586079970a0a00192bb858c649316e1f3141ee7806b652` |

| Public artifact | Bytes | SHA256 |
|---|---|---|
| [HeirsOfFortune-Windows-2.0.0.zip](https://github.com/maxxxxx55555/game_for_day/releases/download/v2.0.0/HeirsOfFortune-Windows-2.0.0.zip) | 69730345 | `dd4511d281fd6f2b53b98d4b58e1b1fa972a8e7860446515bb2d46b252d65f0f` |
| [HeirsOfFortune-SHA256SUMS-2.0.0.txt](https://github.com/maxxxxx55555/game_for_day/releases/download/v2.0.0/HeirsOfFortune-SHA256SUMS-2.0.0.txt) | 99 | `1e9af09ecc81542defb7040687b1a30d7b2b270f0a1b533242d256d9f119a84b` |
| Distributed executable | — | `7d0cefc46b1042839817314c1ef87d165f2236b9c6df8db680ca76204cfbbc59` |
| Distributed PCK | — | `0f7482bb77ff0ce0e2d1e4721ae867d7988f501b3c093d93d68a427aec0b40ff` |

The canonical checksum was already byte-correct and was verified unchanged against a fresh download. The obsolete `HeirsofFortune-SHA256SUMS-2.0.0-original.txt` asset (id678076637) was removed after preserving its exact local bytes. The canonical file names `HeirsOfFortune-Windows-2.0.0.zip` exactly, including capitalization. No unnecessary checksum replacement or ZIP upload was performed. Published bilingual download clarification was updated. The ZIP retains its original internal `HeirsofFortune` folder/EXE/PCK spelling; this is its tested Windows package.

Fresh ZIP and sums were downloaded from the published GitHub release, into a new directory. Exact checksum line bytes were compared before the real native BusyBox `sha256sum` command below; Python hashing was an additional independent check, not a substitute for this command.

```text
$ sha256sum -c HeirsOfFortune-SHA256SUMS-2.0.0.txt
HeirsOfFortune-Windows-2.0.0.zip: OK
exit: 0
```

## Completed F1–F8 work

| Phase | Delivered scope / acceptance |
|---|---|
| F1 content and loop | 4 origins, 31 events / 93 decisions, businesses, stocks, crypto, EUR/GBP/JPY with 0.35% each-way spread, inflation, generations, persistent victory/defeat and legitimate second chance; boot/loading hints, save-aware exits and comfort/settings flows. Explicit edition boundaries are retained in README and PROMISE_MATRIX. |
| F2 localization | 606 keyed entries, live EN/RU presentation, glyph/placeholder/copy checks, canonical saved IDs and original profile keys retained. |
| F3 art direction | Curated per-game art/font/UI direction and licensed assets; 40 accepted engine captures across EN/RU and 540×960 / 720×1280; focus, disabled states, layout and reduced-motion checks. See ART_DIRECTION.md and ASSET_REVIEW.md. |
| F4 audio | Four distinct background mood recordings plus victory/defeat cues; independent Master/Music/SFX/UI controls, contextual effects, routing/levels/seam/provenance checks. |
| F5 hardening | Authenticated bounded saves, atomic writes/backups, compiled critical-data trust and read-only safe mode, encrypted public packs and physical exclusion of private verifiers. |
| F6 mechanics | 14 mechanics / 112 executed cells; 50 distinct complete seeded runs; measured rendered soak 1813.547 seconds; 77 complete lives; 1202 checkpoints; zero orphan nodes and flat post-cycle structural counters. OS allocations varied and are measured, not claimed constant. |
| F7 final QA | Complete EN/RU suites below; three exact native complete victories, defeat route, real legacy 1.4.0 public-native migrations, tamper, encrypted pack parity, gallery and performance checks. |
| F8 release | Exact accepted public ZIP, licenses, separate sums, immutable tag, public bilingual release, server digests, isolated remote trees and clean pushed sources; final closeout only updates documentation/release checksum housekeeping. |

Named regression coverage includes: Choice transaction reentry, destroyed settings listeners, exact finite profile restoration, currency chart drawing and native verifier owner lifetime. Accepted edition scope has no known unfixed defect in the tested scenarios and no unexpected final errors. Original failed RED and environmental diagnostics remain distinct from accepted final passes.

## QA by suite and locale

| Suite | Locale | Result | Retained console SHA256 |
|---|---|---|---|
| Complete Godot runner + Python contracts | EN | 46 invocations; PASS | `fae1418d1d46235bb2fbc6b3c2f638d2250758867efdbba53e9ed2a4f8c99934` |
| Complete Godot runner + Python contracts | RU | 46 invocations; PASS | `b6eef17816898fbf8760d92e951898fed10207258e8b5e91c625089226851468` |

The final full suites use Dummy audio to keep unattended QA quiet. Python contracts cover inherited licenses, promises, public exports, repository isolation, soundtrack and critical trust. Strict shipping/private compiler checks enforce all49 warning categories on 27 scripts. The released commit's [Shipping GDScript warnings CI](https://github.com/maxxxxx55555/game_for_day/actions/runs/40318824354) passed; new docs-only `main` commits trigger the same unmodified workflow. This report does not re-label older tests as runs of changed game code: there are no closeout game-code changes.

### Fresh native public/private guard rerun

The exact public EXE and matching PCK were hash-matched to the package manifest. Separate Windows QA export metadata and private executable SHA256 were checked. Each run used a new isolated profile. Public cases deliberately supply `GAME_QA=1`; the environment alone cannot unlock QA. The private missing-env case still rejects, and the authorized private route completes.

| Native case | Result | Exit | Console SHA256 |
|---|---|---|---|
| public-rejects-verifier | PASS | 64 | `2c21d3cdf5762f471a8f9ef46096cd98d3de0143074bce2f534ffe4c3e1a0985` |
| public-rejects-route | PASS | 64 | `2c21d3cdf5762f471a8f9ef46096cd98d3de0143074bce2f534ffe4c3e1a0985` |
| private-requires-env | PASS | 64 | `2c21d3cdf5762f471a8f9ef46096cd98d3de0143074bce2f534ffe4c3e1a0985` |
| private-accepts-verifier | PASS | 0 | `746ec999131d535a0e16761df0a8da3962a4ee9adead0fb15684a0e8000c7e96` |

```text
public --verify-build, GAME_QA=1: QA arguments require a private QA export and GAME_QA=1 (exit64)
public route-only argument, GAME_QA=1: QA arguments require a private QA export and GAME_QA=1 (exit64)
private --verify-build, GAME_QA=0: QA arguments require a private QA export and GAME_QA=1 (exit64)
private --verify-build, GAME_QA=1: EXPORTED PLAYTHROUGH: PASS (exit0)
```

The authorized private route completes a real native life and victory with its verifier surviving UI cleanup. Private verifier resources/build keys are absent from public downloads. The private QA executable is not a release asset.

## Save/data integrity and threat limits

Purpose-bound HMAC-SHA256, per-installation random keys, bounded/finite validation, exact finite-float metadata, stable schema4 domains, atomic replacement and authenticated backup recovery protect ordinary profile integrity. A changed critical-data manifest or payload enters localized read-only safe mode with compiled trusted fallback and no profile/key mutation. PCK entries/directories are encrypted; stock/wrong-key engines reject them. Native templates omit debugger/path-override support. See [SAVE-INTEGRITY.md](../SAVE-INTEGRITY.md).

Cash uses bounded integer cents, FX quantities use integer thousandths, acquisition/liquidation include spread and rounding, grant eligibility uses saved simulation ticks rather than the system clock, and repeated/reentrant transactions are rejected before mutation.

This is offline integrity protection. The owner of a machine can extract local keys, restore complete old profiles, inspect memory or modify a native executable. No server-authoritative anti-cheat, kernel protection or claim of invulnerability is supplied.

## Music: mood → file → actual WAV SHA256

| Mood | Tracked file | SHA256 |
|---|---|---|
| welcome | `assets/audio/last_call_at_three.wav` | `d42da2f8051e5bb00c3a69aeddbdcea0aade4ae1ff0937c90a450cb7e350366a` |
| study | `assets/audio/after_hours_ledger.wav` | `46f5cc6e2eb600577df89ea0c9aed83842aa8685897015b55c055e087553cfae` |
| career | `assets/audio/opening_bell_swing.wav` | `b24c1e3a4c70ccdcc914883844c07340193d311b6a328d0392dcced12f4b75ab` |
| tycoon | `assets/audio/the_long_dividend.wav` | `9039517d664e5a08d28b1ea3aa9fa6ff94d7a74b1fc93630fd3149dcc19b2735` |
| victory | `assets/audio/a_fortune_remembered.wav` | `7c4271f77bb9cef720f42ffb2269f572511013df79c9d7e88f18eb8c1e8c5de1` |
| defeat | `assets/audio/the_closing_ledger.wav` | `1b4901e66ec803e2dd73eab699687d6d4936b3138a07bb50762d4ad4c871d6a0` |

These hashes were recomputed during closeout and match `assets/audio/music-provenance.json`. Background recordings and finales are actual Gemini/Lyria output, including Lyria RealTime recordings; they are not represented as human performances, exclusive copyrights or CC0 music. Separate synthetic interface/action SFX retain their own CC0 provenance. Sources/prompts/mastering/terms are in [SOUNDTRACK.md](../assets/audio/SOUNDTRACK.md), [music-provenance.json](../assets/audio/music-provenance.json), [LICENSE.md](../assets/audio/LICENSE.md) and the credits. No independent audible human listening review is claimed.

## Transfer audit, branches and post-push isolation

[AUDIT_RELOCATION.md](AUDIT_RELOCATION.md) records C1–C13. Historical mixed design copies were reduced to their proper project scope. Intentional shared tooling stays explicitly allowlisted. Original licensed assets remain with their proper project; all 8 inherited license files match the original1.4.0 release bytes. No new inter-project asset transfer occurred in final closeout.

Direct GitHub API audit of `v2.0.0` resolved annotated tag → commit → recursive tree `e13c284bb2ed6c1956f2fce52458f72dbb3b1e40`, fetched all 237 unique UTF-8 text blobs for 238 paths through the API, recomputed each Git blob SHA, and applied the existing guard's exact foreign/secret patterns and documented shared-tool/third-party-notice exceptions. Result: **PASS, 0 disallowed matches**. Binary/non-UTF-8 blobs are counted separately, as in the source guard. Both the immutable release tree and docs-only `main` receive isolation checks.

The requested branch `jules-game-enhancements-12581546528437518941` is preserved under the explicit unique-content exception: tip `5fcd0e64f169a7c3bb7b3dfe719ab68ffca7687b`, merge base `86b5344dc8e1b88aca3c48383ffac588a50bb36e`, `git merge-base --is-ancestor` exit 1, 4 unique commits, 263 paths differing from the release tag, GitHub comparison `diverged`. It is excluded from this release. Deleting it would discard unique work. Seven obsolete merged local release branches were safely removed after ancestry proofs; remote refs were pruned. Local branches exactly match the remaining remote `main` and preserved branch.

Main upstreams are explicitly `origin/main`; local branches equal remaining remote branches, ahead/behind0, with no unstaged/staged work after the documentation commit/push. New main history is allowed to differ from the tag only by these handoff/report documents. The accepted game tree and public ZIP hashes stay unchanged. The 1.4.0 finance profile is the accepted legacy fixture. There is no claim that a separate 1.5.0 finance release or migration fixture was tested. This game has no iron-mode mechanic. Final closeout corrected the inapplicable legacy iron-mode template sentence and primary ZIP capitalization in published release notes; the tagged historical note file remains unchanged.

## Open questions and honest limitations

No unresolved scoped-edition release blocker remains in the accepted finite scenarios. The unique unmerged branch is deliberately retained, documented and excluded; merging it would be new work outside this closeout.

Windows binaries are unsigned (no Authenticode certificate). Android is omitted because no emulator boots on this host; no Android runtime or store acceptance is claimed. One Windows AMD integrated-GPU host and automated native routes do not establish all-device compatibility, independent human playtest, universal absence of bugs, unbreakable security or AAA production scale. Measured engine/OS allocation and frame times are evidence for that host only.

Earlier Windows WASAPI device invalidation is retained as a rejected environmental run; three actual-audio retries passed, and final quiet repeats used Dummy. Owner listening and an independent ordinary play session remain recommended pre-announcement checks, not silently claimed completed.

The archive is immutable and does not contain these later documentation-only handoff files. Read current [HANDOFF.md](HANDOFF.md) for the five owner checks before announcement. All detailed raw evidence remains in the session output `release-1.5.1-and-2.0.0/final-closeout` with historical F1–F8 evidence alongside it; no private keys/profiles are published.
