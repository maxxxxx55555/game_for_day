# Heirs of Fortune 2.0.0 implementation plan

**Goal:** Deliver the adopted bilingual release specification on main with evidence.
**Architecture:** Localized presentation preserves stable simulation and save identities. Audio, settings and release tooling have separate responsibilities.
**Tech stack:** Godot 4.7 Compatibility, GDScript, Python, JSON/CSV, PCM WAV.
**Execution:** Inline, with independent process operations only; user already authorizes autonomous completion.

## Global constraints
Every Git command verifies the expected origin; explicit paths only. No force push or history rewrite. Legacy user-data directories and license bytes remain unchanged. Never publish credentials or private profile keys. Work directly on main.

- [ ] Baseline: run `tests/run_tests.py --godot <installed Godot> --rendered --artifacts <isolated logs>`. Record original main/ref ancestry and preserve complete 1.4 profiles privately.
- [ ] Isolation: create `tools/check_repo_isolation.py` with staged foreign-identifier and secret checks, reasoned shared-tooling exceptions and negative fixtures. Review every staged path. Add failing audio-node/bus/catalog tests, implement a 2D-only AudioDirector and contextual grant SFX cleanup. Commit the runnable stage.
- [ ] Localization: add failing `tests/test_localization.gd` for parity, placeholder safety, live-state identity, persistence and font glyphs. Implement `scripts/autoload/LocalizationManager.gd`, compiled `data/strings/localization.json`, display templates and locale-aware money formatting; preserve event/callback save values. Compile catalogs; run both locales and layout suites before committing.
- [ ] Audio: extend audio tests for unique paths, per-track hashes and stinger lengths. Generate/fetch per-game tracks outside the repo, master stereo32kHz loops with overlap and edge taper, integrate catalog/provenance/credits and preserve multi-track regeneration. Run both runtime and WAV tests before committing.
- [ ] Presentation: localized credits reachable from menu, live language and four sound levels, compact tutorial and readable controls; inspect actual captures and test actions.
- [ ] QA: complete both locale suites, native exports and three sequential routes, old-profile migration, negative save/audio cases and performance. Build APK and verify upgrade/touch/lifecycle/recovery/entrypoint behavior on the existing emulator. Fix failures, then repeat the complete protocol.
- [ ] Publish: set version 2.0.0, update own docs/audit/credits, explicit-path commit with `Heirs of Fortune:` prefix, guarded push main, explicit tag v2.0.0, bilingual release and matching assets/checksums, remote-tree/digest audit and merged-branch cleanup. Save full report and gallery under outputs.
