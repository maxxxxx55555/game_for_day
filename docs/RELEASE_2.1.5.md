# Heirs of Fortune 2.1.5 — events stop repeating, and stop sounding the same

Status: **published**. GitHub Release `v2.1.5` is live and marked Latest:
https://github.com/maxxxxx55555/game_for_day/releases/tag/v2.1.5
(2026-11-10, target `main`, assets: the Windows ZIP, 57 419 616 bytes,
SHA256 `f08541a1…31c8c6`, and SHA256SUMS; verified via the public GitHub
API). This patch fixes two of the audit's P0 problems: events repeated
dozens of times per life, and the 16 JSON events were all built from one
template.

## What changed

- **Event rotation memory.** `Main.pick_modular_event()` now prefers
  events this life has not shown yet and only restarts the rotation once
  the whole stage pool is exhausted. The seen list is stored in the
  session save, so reloading mid-life keeps it, and a new generation
  starts fresh because session saves are generation-gated.
- **Test.** New `tests/test_event_variety.gd` (registered as `event-variety`
  in `run_tests.py`): picks a full survival pool without a repeat, checks
  the rotation restarts after exhaustion, and checks the seen list
  survives a session save/restore.
- **48 unique outcome texts.** The 16 JSON events shared 3 outcome texts
  across 48 choices. Every choice now has its own outcome (RU+EN, 48
  unique keys), written to match its own delta, and the «rest» choice now
  has 16 different deltas instead of one identical `[0, 9, 0, −22, 10, 32]`.
  The rest choice's label changed with its numbers, so it stays honest.
  Localization grows 1090 → 1150 keys; the 4 old template keys are gone.
  The canonical copy-contract fixture was re-snapshotted for the new
  external events.

## What did not change

No mechanic, balance number or save format changed — the session dict
gains one new optional key (`used_event_titles`); old saves load with an
empty list. The immediate-repeat guard is kept for pools of one.

## Validation

- Strict compile and the full `tests/run_tests.py` suite on Godot 4.7 —
  result recorded in the changelog before the commit.

## Open (audit P0)

- **Event art**: one city illustration for all 31 events. Needs at least
  one distinct illustration per stage.
- Android: no code blockers — needs a preset, a package name, JDK/SDK
  and a signing keystore from the owner.
- Owner play check on Windows; executable is unsigned; Windows x64 only.
