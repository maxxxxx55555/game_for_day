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
