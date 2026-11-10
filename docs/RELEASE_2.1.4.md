# Heirs of Fortune 2.1.4 — honest text, no click-through, lighter build

Status: **source release**. This patch applies the safe fixes from the
independent audit of 2.1.2 (three auditors: gameplay/content, tech/Android,
audio/art). The audit found the game release-ready overall — strict compile
PASS, full gate PASS, localization 1090/1090, no dead-end choices — and the
fixes below are the ones that were safe to take without authoring new
content or changing mechanics.

## What changed

- **Milestone card click-through fixed.** Clicking outside the milestone
  card fell through to the event-choice buttons underneath and applied a
  choice the player never read. The overlay root now swallows clicks
  (`MilestoneCard.gd`: `MOUSE_FILTER_IGNORE` → `STOP`).
- **Ambition texts now match the implementation.** «Meteor» promised
  income +25%, but the bonus applies only to choice payouts; «Heir»
  promised income −10%, but the cut applies only to passive income. The
  descriptions now say exactly that, in RU and EN.
- **Lighter export.** The public and QA presets now exclude files the
  build never needs: the removed portrait atlas, two unused fonts
  (Alegreya, Manrope), `globe.svg`, the localization source CSVs and
  translation binaries, `choice_aliases.json`. Measured A/B on the
  exported pack: 22 767 792 → 20 532 228 bytes (−2.2 MB).
- **Dead code removed**: `BirthLottery.total_births()`,
  `DynastyPanel.add_heading()`, `FortuneDashboard.birthplace_region()`,
  `GameManager.has_seen_intro` — all verified to have zero callers.
- **Stale records cleaned**: the `interface-provenance.json` for the
  deleted `ui_focus`/`ui_error` WAVs is removed, along with the dead
  branch about them in `test_audio_assets.py`; the «32+ events» comment
  now correctly says 31 (15 in code + 16 from `data/events.json`).
- `docs/PROMISE_MATRIX.md` updated: the portrait atlas is no longer
  «archived assets» in the repo — it was removed in 2.1.3; the archive
  lives in git history.

## What did not change

No mechanic, balance number or save format changed. Music volume stays as
documented (quiet mastering is a deliberate decision, not an oversight).
The localization keys themselves are unchanged — only two description
strings were reworded, and the trust anchor was regenerated for them.

## Validation

- Strict compile and the full `tests/run_tests.py` suite on Godot 4.7 —
  exit 0 on the re-run (playthroughs to rank 1). The first run failed on
  `test_ui_audio_feedback.gd`; the same checks fail intermittently on the
  pristine 2.1.2 tree, so it is a pre-existing timing flake in the test
  (a 0.09 s click vs slow frames), not a 2.1.4 regression. Follow-up: make
  that test timing-tolerant instead of re-running the gate until it passes.
- Windows export A/B: the pack shrinks by 2 235 564 bytes and the
  excluded paths are gone from it.

## Open (audit P0 — needs authoring, not a safe patch)

- **Templated JSON events**: the 16 events in `data/events.json` share
  one skeleton — 3 outcome texts for 48 choices, identical «rest» deltas.
  Needs 48 unique outcome texts (RU+EN) and varied deltas.
- **Event repeats**: a life runs ~256 choices over pools of 6–10 events
  per stage, with protection only against an immediate repeat. Needs a
  used-event memory per life.
- **Event art**: one city illustration for all 31 events. Needs at least
  one distinct illustration per stage.
- Android: no code blockers — needs a preset, a package name, JDK/SDK
  and a signing keystore from the owner.
- Owner play check on Windows; executable is unsigned; Windows x64 only.
