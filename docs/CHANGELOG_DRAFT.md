# CHANGELOG — v2 integration draft

## 2.1.0 Legacy & Chains — published 2026-10-30, re-issued 2026-10-31

- Added eight two-link threads with stored flags, five-quarter delays, recalled choices, variant outcomes and momentum.
- Added the five-section dynasty ledger and a twelve-life hall of fame.
- Added eight legacy perks bought with persistent points and three starting ambitions with real economic modifiers.
- Added the five-level Ascension NG+ path from the victory finale.
- Added milestone retrospectives at 18/25/35/50/65 and momentum; Continue never advances the world.
- Added card reveal, signed delta chips, outcome tones, a live 24-sample portfolio pulse and reduced-motion snapping.
- Added the two-skin appearance system: dark (ink and gold) and light (warm paper and bronze) resolved through `scripts/ui/Palette.gd`, a theme switch on the intro and in settings, a per-country plate in the event card, chrome/cover/print cues and 1.75px vector interface icons (six drawn; `globe.svg` ships unused). Text colour is named by token, so switching repaints every control that took a colour at build time. See [APPEARANCE.md](APPEARANCE.md).
- Added Unbounded/Onest type and emoji-free displayed copy.
- Added chains, dynasty-progression and card-feel suites; mechanics matrix is now 19 rows / 152 cells.
- 2.1 save fields remain optional; 1.4.0 and 2.0.x profiles load with neutral defaults.
- Publication gate PASS at `466a8c1` (15 steps, 4,477.5 s, clean tree); tag `v2.1.0` names that commit; release assets are `HeirsOfFortune-Windows-2.1.0.zip` and its versioned sums file, whose digests are recorded in [RELEASE_2.1.0.md](RELEASE_2.1.0.md) and [ACCEPTANCE_CERTIFICATE.md](ACCEPTANCE_CERTIFICATE.md).
- The theme switch has its own case: `tests/test_theme_switch.gd` measures that all fourteen tokens differ, that contrast floors hold in both skins, that no label keeps the other skin's colour, that the switch costs no quarter and no RNG, and that Back over the ledger in the other skin leaves the pending event intact.

## Earlier v2 notes (historical, unchanged by 2.1.0)

- Reconciled archived promises against the compact edition, with explicit exclusions and a complete original-line registry.
- Removed mixed historical design scope; new negative guard tests catch copied design/runtime references.
- Added branded boot/loading hints and explicit retry/stay/discard handling after a failed exit save.
- Added contextual disabled explanations and retained real transaction prices in tooltips.
- Publication remains locked until all v2 phase evidence and the final gate pass.

- F2: audited literal keys and blank scene defaults; verified both locale catalogs and actual typeface glyphs.
- Remaining birth/business/inheritance model copy uses existing keys while preserving canonical Russian identities. Added a v1.4.0 original-copy and ordered-event regression fixture; opening copy refreshes on live language changes.

F3: published art tokens and individual 10-file source review; unified Prata display headings, legible currency units/scale/sample labels, and interruptible 180ms presentation-only capital updates with reduced-motion snapping. Source gallery and final gate evidence are tracked separately.

V2 F4: preserve the four distinct recorded mood tracks and two finales; add quiet focus/unavailable synthesis with honest CC0 hashes, one contextual acknowledgment per action, restrained cosmetic pitch variation and real rejected-action regressions. QA remains muted.

## F5 — integrity integration, awaiting final gate

Separate encrypted public/private QA exports and environment-only keys; physically excluded public verifier. Compiled critical-data manifest/trusted fallback and localized read-only safe mode. Localized authenticated-save recovery and stable unchanged round trips. New regression tests cover replacement manifests, safe-mode write/deletion boundaries, key preflight, public flags and save recovery.
Integer-cent money ledger, bounded fixed-precision FX wallet, no same-quote cent creation, atomic overflow refusal and saved monotonic grant ticks. Android artifacts omitted for this v2 cycle under section 16; no emulator claim.
