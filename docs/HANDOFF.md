# Heirs of Fortune 2.1.0 — owner handoff

Release: **2.1.1 "Legacy & Chains" is published at https://github.com/maxxxxx55555/game_for_day/releases/tag/v2.1.1 — pending the gate run.**

1. Download only the exact 2.1.0 Windows ZIP and its versioned sums file; require `sha256sum -c` to report OK and exit 0.
2. Extract the entire folder, launch the EXE and select English/Russian.
3. Open Dynasty: buy one legacy perk, start a thread from the Threads section, make a choice and confirm the delta chips and flag. Return after five quarters, accept the recalled follow-up, then press Back and verify the pending event survives.
4. Walk every ledger section. Read a milestone retrospective at 18, finish a $250B victory and try Ascension; the hall must gain exactly one record per life. Choose each of the three ambitions on the intro screen and confirm the Heir description states the income cost it charges.
5. Check the four musical moods, finale cues, each audio slider, reduced motion, Credits and an older 1.4.0/2.0.x profile. Keep its installation key and original backup.

Checks 1-5 describe the 2.1.1 build at the gated commit. 2.1.1 is a patch on 2.1.0 and changes no mechanic, screen or asset, so the checklist is the same walk; the appearance system it carries is the repainted one ([APPEARANCE.md](APPEARANCE.md)). Check 5 also covers the switch by hand: pick the paper skin, walk the ledger, the milestone card and settings, and confirm nothing keeps the ink palette. `tests/test_theme_switch.gd` measures the same thing automatically, so the owner pass is a confirmation, not the only evidence. Earlier publications stay reachable: 2.1.0 from 2026-10-30 (`807ba09`, no appearance system), 2026-10-31 (`b38e9df`, no skin repaint) and the 2026-11-01 re-issue (`466a8c1`); 2.1.1 supersedes them for current claims and deletes none of them.

What a machine already did on the delivered archive, so a human can spend the pass on what only a human can judge:

Machine coverage of checks 1, 2, 3 and 4: the published archive was downloaded fresh on 2026-11-01, its sums pair verified with `sha256sum -c`, extracted and booted, and all 19 installed-archive checks passed, among them the guards that must refuse every QA route with exit 64. Checks 3 and 4 have a driven route in exported binaries, and the distinction matters: 9 runs walk the victories, the defeats and the Russian and English dynasty ledgers on the private QA export built from this same source and template, while 3 runs execute the pack you install and prove only that it refuses those arguments with exit 64. The skin switch in check 5 is driven by `tests/test_theme_switch.gd`. None of that is the owner pass: no finite test judges how a reveal feels, what a cue does to a room, or whether the numbers read as one life.

These owner checks are not claimed complete: they need a human at the keyboard and ears, and automated suites cannot stand in for them. Unsigned executable, finite testing and offline-integrity limits are explained in the acceptance certificate and release notes.
