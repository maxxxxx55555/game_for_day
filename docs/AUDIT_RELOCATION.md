# Heirs of Fortune: repository isolation audit

2026-10-25. The adopted audit was checked against the actual 1.4 source before editing. No new misplaced asset needing transfer was found. Shared audio-generation tooling is intentional and explicitly allowlisted; no game content is copied between repositories. Original license bytes and legacy save directories stay intact.

| Item | Finding / action |
|---|---|
| C1–C2 | Unused spatial audio and irrelevant effect entries confirmed; replace with 2D-only audio and rename the used pickup award cue to grant. No transfer: the canonical source already owns its assets. |
| C3 | Four moods shared one background file. New per-mood compositions and finale stingers are tracked in the release audio catalog/provenance. |
| C4 | The supplied audit incorrectly described English-only text. Actual 1.4 text is Russian-only; add complete English and switchable RU/EN presentation. |
| C5–C6 | Release work is directly on main as requested. Ancestry is recorded before deleting only fully merged branches; unique branches are preserved. |
| C7 | Unsafe root push helper removed; no legacy script is executed. Use explicit guarded origin/refs and stage paths. |
| C8 | Published history is immutable. New commit titles begin with this game name. |
| C9 | Legacy user-data directory deliberately unchanged for authenticated-save compatibility. |
| C10 | Baseline counts verified against executed suite logs; final counts must include the new suites. |

## Commit guard
`tools/check_repo_isolation.py` scans staged content before every local commit. Its negative fixtures include foreign identifiers deliberately; the guard and tests are documented shared tooling by design. It blocks real credential values, generated builds/caches and foreign content, without deleting anything. It also supports a full tracked-tree audit via `--tree`. Ordinary words in third-party license notices are not rewritten. Public history is not rewritten.

## Final tracked-tree audit
Two historical1.4 planning documents contained a joint project plan. They now retain only this project's own design and validation scope; the other project already has its own originals, so no content transfer was needed. The full tracked-tree isolation check covers historical documents as well as shipping sources.

## v2 reconciliation (2026-10-26)
C11: the obsolete ACTIONS table is already removed; ChoiceCopy resolves current catalog aliases and retains full native-button copy/callbacks. Existing choice sweep exercises all93 decisions. F2 will audit both displayed languages again. C12: Main presentation uses catalog keys; remaining model/business/birth response literals are canonical Russian values and will be extracted without changing their bytes or saved IDs.

## C13: historical design-copy contamination found by v2
Three archived design/plan files still mixed unrelated runtime architecture and validation scope despite lacking an exact foreign game title. Each now contains only this game's own design. The canonical design content already exists in its proper repository; no new asset transfer or license edit was necessary. Two new negative tests reproduce the old guard's failure. The guard now rejects copied design labels and foreign runtime paths as well as game names. Full tracked-tree scanning catches the old text before cleanup and passes afterward.

## F2 closure evidence
Keyed copy and empty scene defaults now have an enforced source contract. See LOCALIZATION_AUDIT.md for canonical-copy fixtures, actual current case counts and exact presentation exceptions. C10 counts are based on executed cases rather than the inherited file-count estimate. C12 model/business/birth/inheritance strings now reference their pre-existing keys; serialized canonical values remain unchanged.

## Final byte-contract review
The40 original promise entries remain indexed, including an immutable pre-release README snapshot. Portable LF input digests and opaque inherited-license/profile attributes survive fresh Git checkouts. All8 inherited license files match the original1.4.0 archive; six line-ending-only differences were restored, without wording changes. C10 is31 events/93 decisions (16 external +15 inline),46 rendered Godot invocations per locale and23 core regressions.
