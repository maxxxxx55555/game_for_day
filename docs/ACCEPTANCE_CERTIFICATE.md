# Heirs of Fortune 2.0.0 — acceptance certificate

Issued: 2026-10-27, Europe/Moscow. Cycle started2026-10-26.

**Verdict: NOT ACCEPTED / ANNOUNCEMENT HOLD.** The requested clean-tag gate failed. The existing Windows download remains published and byte-unchanged; its finite historical/native passes are not a substitute for fresh source acceptance. No new feature, original-repository game-file edit, tag move or release-asset mutation was performed. Godot normalized newline-only import metadata in scratch checkouts; those files are not copied back to main.

Independent revalidation here means new source checkouts/import caches/profiles and a second automated read-only review. It is not independent human certification or audible listening approval.

## Identity and zero game delta

| Item | Evidence |
|---|---|
| Public release | [v2.0.0](https://github.com/maxxxxx55555/game_for_day/releases/tag/v2.0.0) |
| Immutable release commit | `b5a9aba0821ae9af8a202a4c835e17981425e09a` |
| Immutable source tree | `e13c284bb2ed6c1956f2fce52458f72dbb3b1e40` |
| Baseline main before this docs cycle | `fb15b75eab813a80fdb19abf46f77fd51d8b5bf1` |
| Compare tag...main | Only docs/ paths; final receipt enumerates all certificate/kit/evidence/press additions |
| Release composition | Exactly one ZIP + one canonical sums; asset IDs/digests unchanged |
| Fresh source isolation | Existing guard rescanned tag checkout:0disallowed markers; documented shared-tool exceptions retained |
| Baseline strict CI | [run40371258808](https://github.com/maxxxxx55555/game_for_day/actions/runs/40371258808) success; latest docs-head CI is in the final session receipt |
| Human owner acceptance | NOT PERFORMED; five HANDOFF checks remain necessary after automated blockers are resolved |

Fresh public download verification:

```text
$ sha256sum -c HeirsOfFortune-SHA256SUMS-2.0.0.txt
HeirsOfFortune-Windows-2.0.0.zip: OK
exit: 0
```

- `HeirsOfFortune-Windows-2.0.0.zip` — SHA256 `dd4511d281fd6f2b53b98d4b58e1b1fa972a8e7860446515bb2d46b252d65f0f`; 69730345bytes.
- `HeirsOfFortune-SHA256SUMS-2.0.0.txt` — SHA256 `1e9af09ecc81542defb7040687b1a30d7b2b270f0a1b533242d256d9f119a84b`; 99bytes.

[Published binary smoke receipt](acceptance/published-binary-smoke.json): actual freshly downloaded EXE/PCK ordinary boot and public verifier rejection pass. These checks are explicitly not new tag exports or private verifier runs. The fresh-source warning is not inferred to exist in the unchanged distributed Windows binary; published-binary results are reported separately.

## Current mandatory acceptance results

| Requirement | Status | Evidence |
|---|---|---|
| §2.1–2.5 docs delta/assets/branches/isolation/CI | PASS scoped metadata audit | API snapshot/final receipt; fresh sums; tag guard; compiler CI |
| §3.1 complete rendered RU/EN suites | FAIL | Both full runner commands exit1 in Python prechecks;0Godot cases ran |
| §3.2 public/private tag export; authorized verifier; victory/defeat | BLOCKED | Public and QA preflight both exit2 because critical-data manifest is stale; no new binaries generated |
| §3.3 original1.4.0 saves | PARTIAL | Exact original private-copy read loads pass; profile/key/original bytes preserved; new writes, stable write round-trip and tamper suite acceptance blocked |
| §3.4 fresh bilingual gallery | FAIL visual acceptance | 20new frames reviewed; integrity warning obstructs screens; staged/failed fixtures are labelled |
| §3.5 music hashes/paths/channels/durations | PASS for six music WAVs; FAIL full audio contract | Four distinct mood paths, six unique WAV hashes; SFX generator-source provenance mismatch |
| §3.6 three verifier runs and30minute soak | NOT ACCEPTED | New verifier cannot be built; measured soak1802.545s, rawPASS, source integrity anomalies present |

## Phase sign-off F1–F8

| Phase | Current sign-off | Evidence |
|---|---|---|
| F1 content | Historical published-edition scope retained; not a new full-route pass | FINAL_REPORT.md and old finite native evidence |
| F2 localization | Partial; fresh complete suite not accepted | suite-en.log / suite-ru.log; checkout copy findings where applicable |
| F3 art | FAIL fresh presentation acceptance | New warning-obstructed frames and visual-review.json |
| F4 audio | Music WAVs PASS; source provenance FAIL | audio-verification.json / audio-assets.log |
| F5 hardening | New source export BLOCKED | Public and QA export preflight both exit2 |
| F6 stability/mechanics | NOT REACCEPTED under current source gate | Measured soak acceptance, source integrity anomalies |
| F7 complete validation | FAIL | Both full runner commands abort in prechecks;0Godot gameplay cases |
| F8 existing publication | Published download integrity PASS; new publication forbidden; announcement HOLD | Fresh checksums/public smoke; immutable assets; final external receipt |

## Fresh runner output

| Locale | Result | Exit | Godot invocations | Console SHA256 |
|---|---|---|---|---|
| RU | FAIL | 1 | 0 | `aa6a23c0d682cbe6dd41b731fbe87eefc30713fa9cf88197405e0deee40497b1` |
| EN | FAIL | 1 | 0 | `aa6a23c0d682cbe6dd41b731fbe87eefc30713fa9cf88197405e0deee40497b1` |

Logs: [RU](acceptance/suite-ru.log), [EN](acceptance/suite-en.log). The complete existing runner was invoked with `--rendered --language ru/en --audio-driver Dummy`; its early precheck failures mean the rendered gameplay cases did not execute. No fixture, expected hash, test or trust rule was weakened to obtain a pass.

## Blocking source-byte findings

The critical manifest expects CRLF working-copy bytes, while the immutable tag stores LF for4JSONfiles. Converting those tag bytes to CRLF reproduces every expected digest. Read-only safe mode therefore activates on legitimate fresh source and disables progress/settings writes. Both fresh export preflights correctly refuse to bless those bytes.

| Resource | Expected manifest SHA256 | Actual immutable-tag/fresh SHA256 |
|---|---|---|
| `assets/audio/catalog.json` | `83cccf589e292a6c0a90f6d1ff9befb52a854864b8cc2852d327cef50a43968c` | `c32c99222a11b305cb04ab6164e2eef326c253865700d1046ecac59d855739f9` |
| `data/events.json` | `b986ca1e1c43cfb9e550fb573348dcc544f10781efadbc6f60d7bf712c572959` | `0cc14454201506e326526830b941b2daaac00cba21c34d3f4b5179bb3b68d6ef` |
| `data/strings/choice_aliases.json` | `213c10d14cce306fc4b722b420b31650daba45543135f7da365ee2bf564f8f4d` | `a40256647b7226e2e29fc4bcfd79f419662ae6446f66229b3e1980dcf39e216e` |
| `data/strings/localization.json` | `75f9bf64118f7e94330e6e2915c0290abe1c39eff57c5c94c87c27f439e255c9` | `63583221889fa0a82ace95df3215ddf9bff3d7e88e61c8b8f02cfc66e982e0be` |

Windows checkout converts20multiline canonical Russian values from LF to CRLF; the tagged CSV itself matches the legacy fixture. This portability failure aborts the copy contract.

The interface SFX provenance additionally records a CRLF generator hash instead of the LF tagged Python file. Music recordings themselves match their recorded WAV hashes. The discrepancy is source-byte/provenance portability, not evidence that a different composition was substituted. Detailed proofs: [source blockers](acceptance/source-blockers.json), [audio verification](acceptance/audio-verification.json), [public export preflight](acceptance/public-export-preflight.log), [QA export preflight](acceptance/qa-export-preflight.log).

Correcting canonical data/trust, CSV checkout policy where applicable and generator-source provenance would require changes outside this documentation-only freeze and a new acceptance cycle. No such correction was made; tags/assets were not republished.

## Soundtrack evidence

| Mood | File | Actual channels/rate/duration | Actual WAV SHA256 |
|---|---|---|---|
| welcome | `last_call_at_three.wav` | 2 / 32000Hz / 118.372s | `d42da2f8051e5bb00c3a69aeddbdcea0aade4ae1ff0937c90a450cb7e350366a` |
| study | `after_hours_ledger.wav` | 2 / 32000Hz / 124.000s | `46f5cc6e2eb600577df89ea0c9aed83842aa8685897015b55c055e087553cfae` |
| career | `opening_bell_swing.wav` | 2 / 32000Hz / 124.000s | `b24c1e3a4c70ccdcc914883844c07340193d311b6a328d0392dcced12f4b75ab` |
| tycoon | `the_long_dividend.wav` | 2 / 32000Hz / 124.000s | `9039517d664e5a08d28b1ea3aa9fa6ff94d7a74b1fc93630fd3149dcc19b2735` |
| victory | `a_fortune_remembered.wav` | 2 / 32000Hz / 20.000s | `7c4271f77bb9cef720f42ffb2269f572511013df79c9d7e88f18eb8c1e8c5de1` |
| defeat | `the_closing_ledger.wav` | 2 / 32000Hz / 20.000s | `1b4901e66ec803e2dd73eab699687d6d4936b3138a07bb50762d4ad4c871d6a0` |

[Music contract](acceptance/music-wavs.log) passes4distinct mood recordings plus2finales. [Full audio-assets contract](acceptance/audio-assets.log) fails the generator-source SHA256 assertion. Automated wave/routing evidence does not establish human listening acceptance.

## Soak and save scope

Raw measured run: 1802.545s, 279life/campaign loops, 4336checkpoints. Engine counters: `{"nodes":{"first":27,"last":27,"delta":0,"all_constant":true},"resources":{"first":34,"last":34,"delta":0,"all_constant":true},"objects":{"first":1911,"last":1911,"delta":0,"all_constant":true},"orphans":{"first":0,"last":0,"delta":0,"all_constant":true}}`. OS private-byte quarter medians: `[345010176, 345804800, 345370624, 345899008]`, delta `888832`bytes. These are measured allocator/cache variations, not a literal zero-byte growth claim.

The1802.545second simulation completed279life loops with flat post-cycle structural counts, but startup critical-data integrity anomalies/read-only mode invalidate it as ordinary persistence acceptance.

Fresh legacy loads verify only read compatibility and preserve original/profile/key bytes. Source writes remain blocked. Historical complete native wins, old-profile public-native upgrades,50seeded routes and the previous soak are retained as historical evidence, never relabelled as passes of this new source gate.

## All historical gate items revisited

The prior59-item publication gate was historical and passed on its recorded inputs. The table below revisits this repository's own items against the current acceptance cycle; it is not a new100%sign-off. The target-tag-free item is inapplicable because no new tag may be created.

| Original gate item | Current status | Evidence / scope |
|---|---|---|
| F1 completed and retained | HISTORICAL ONLY | Historical gate `f1c89509c002c05e3e586079970a0a00192bb858c649316e1f3141ee7806b652`; not counted as a new pass. |
| F2 completed and retained | PARTIAL / FAIL | Fresh copy/key evidence; 20canonical multiline checkout mismatches. |
| F3 completed and retained | FAIL | New gallery cases and visual-review.json; integrity modal visible. |
| F4 completed and retained | PARTIAL FAIL | 6WAV hashes valid; SFX generator-source SHA256 does not match provenance. |
| F5 complete | BLOCKED | Both fresh tag export preflights exit2; no new artifact created. |
| F6 complete | FAIL / NOT REACCEPTED | Fresh suites fail; source integrity activates read-only mode; soak not accepted. |
| F7 complete | FAIL / NOT REACCEPTED | Fresh suites fail; source integrity activates read-only mode; soak not accepted. |
| test_promise_matrix.py | PASS | Fresh supplemental-contracts receipt and inherited license checks. |
| test_license_bytes.py | PASS | Fresh supplemental-contracts receipt and inherited license checks. |
| every original promise indexed with tested scoped resolution | PASS inventory | Fresh promise matrix contract; edition exclusions retained. |
| every mechanics cell executed | HISTORICAL ONLY | Historical gate `f1c89509c002c05e3e586079970a0a00192bb858c649316e1f3141ee7806b652`; not counted as a new pass. |
| EN/RU final full source sweeps | FAIL / NOT REACCEPTED | Fresh suites fail; source integrity activates read-only mode; soak not accepted. |
| per-mood music provenance and audio acceptance | PARTIAL FAIL | 6WAV hashes valid; SFX generator-source SHA256 does not match provenance. |
| art direction and accepted real-engine galleries | FAIL | New gallery cases and visual-review.json; integrity modal visible. |
| hardening parity and exact native exports | BLOCKED | Both fresh tag export preflights exit2; no new artifact created. |
| legacy profiles preserved in source and actual public native | PARTIAL | Fresh read-only legacy load passes; new writes/round-trip and rebuilt native acceptance blocked. |
| 50 unique full cycles plus measured soak and 3 stability runs | FAIL / NOT REACCEPTED | Fresh suites fail; source integrity activates read-only mode; soak not accepted. |
| accepted logs clean and no known unresolved edition bugs | FAIL / NOT REACCEPTED | Fresh suites fail; source integrity activates read-only mode; soak not accepted. |
| exact-head hosted strict compilation | PASS compiler only | Baseline main CI40371258808 success; warning-only CI does not check these runtime-byte contracts. |
| post-push repository tree identity and isolation | BASELINE PASS; final receipt pending | Initial docs-only metadata/isolation proof; final pushed documentation commit attested by accompanying SESSION_RECEIPT.json. |
| inherited license bytes and provenance | PARTIAL | 8 inherited license bytes pass; interface generator source provenance does not. |
| real committed checkout byte contracts | FAIL | Critical-data hashes and generator provenance fail; see source-blockers.json/audio-verification.json. |
| tracked tree credential/generated/foreign-content audit | PASS scoped audit | Fresh tag guard0disallowed markers; final docs-only diff/source and release immutability receipt. |
| actual private export keys absent from all tracked content | PASS scoped literal scan | literal-key-absence.json: raw/hex/Base64 key representations absent in tracked source plus new docs. Snapshot only; no exported-engine secrecy claim. Final HEAD scan is in the package receipt. |
| versions match and target tag is free | N/A new tag | Existing immutable version verified; tag creation is forbidden in this cycle. |
| exact final archives and delivery-name native boot | PASS published binary only | Current-cycle download SHA256/sha256sum-c and ordinary boot/public QA rejection pass. |
| default main; obsolete branches ancestry-reviewed | PASS | Baseline/final API branches and documented unique-content exception. |
| Android fallback explicit | N/A omitted | No Android artifact/runtime/store acceptance; no emulator available. |
| clean committed main | BASELINE PASS; final receipt pending | Final source/game delta0 and clean docs-only commit are attested after push in accompanying SESSION_RECEIPT.json. |

Final post-push/main/CI status is intentionally not pre-signed here. The accompanying handoff package contains SESSION_RECEIPT.json for the actual docs commit and its final CI; its main revision is later than this certificate baseline.

## Known limitations and owner handoff

Portable Windows executables have no Authenticode signature; normal Windows warnings can appear. Android/emulator and store certification are outside this Windows edition. One available Windows/GPU host and automated routes are not every-device certification, a human playtest, audible review, proof against every bug or unbreakable offline protection. Private installation/build key values or files are not included in the evidence or press files. [Literal source/docs scan](acceptance/literal-key-absence.json) found zero key representations. This says nothing about secrecy of native engine binaries, which necessarily contain their pack key.

The unique branch exception remains documented in FINAL_REPORT where applicable. The owner’s later checks are:1download+sha256sum-c,2launch and select EN/RU,3listen to four moods plus stingers and inspect credits,4save/Continue and test a backed-up1.4.0 profile,5verify filenames before distribution. See [HANDOFF.md](HANDOFF.md). These checks do not waive current mandatory source blockers.

The requested positive acceptance sentence is withheld because issuing it would contradict the observed failures. The announcement copy and eight images in [ANNOUNCE_KIT.md](ANNOUNCE_KIT.md) are rejected drafts.

Редакция не принята по текущему гейту; анонс приостановлен до устранения и повторной проверки обязательных блокеров.

## Supplemental checkout reproduction — 2026-10-27

The separate [diagnostic reproduction report](CHECKOUT_REPRODUCTION.md) records full rendered EN/RU passes after local checkout-serialization overrides. It preserves canonical tag blobs while deliberately changing selected scratch working bytes. Those overrides contradict the tagged LF checkout policy, so they do not clear the default-checkout failures or change this **NOT_ACCEPTED / ANNOUNCEMENT HOLD** verdict. No new export, soak or native acceptance is substituted. Original game files, tags and release assets remain unchanged.
