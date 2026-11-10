# CHANGELOG — Heirs of Fortune

## 2.1.2 — quality audio & stage art (2026-11-10)

- Replaced the primitive short sound effects with runtime-synthesized ones
  (`scripts/audio/ProceduralSfx.gd`, CC0-1.0): eight distinct designs, so
  `purchase` and `grant` are no longer the same file — purchase is a warm
  C-E-G arpeggio, grant is a six-note rising harp gliss. Peak is normalized
  to 0.60, attack/release edges are clean, and a new `test_procedural_sfx.gd`
  proves all eight are distinct, audible and non-clipping. Music and the
  victory/defeat finales stay as the recorded WAV assets.
- Music is finally audible by default: `music_volume` default 0.30 → 0.65,
  and effect levels raised (`ui_focus` −24 → −18 dB, `ui_error` −10 → −6 dB,
  other effects −5 → −2 dB). Saved profiles keep their own levels.
- One city illustration, four readings: the event art now crops a different
  band of `city_folio.png` per life stage (river, bank, towers, skyline)
  with a stage tint, and it stays visible during a life instead of hiding
  once a birth country is chosen. No new bitmap was added.
- `assets/audio/catalog.json` now lists the eight effects under `synth_sfx`;
  the trust anchor (`data/critical-manifest.json`,
  `scripts/security/TrustedData.gd`) was regenerated with
  `tools/build_manifest.py`. The old WAV effect files are unused and are
  removed in a follow-up commit.
- No mechanic, screen layout or balance number changed. Save format untouched.

Source validation 2.1.2: PASS — strict compile (39 scripts, 49 categories)
and the full `tests/run_tests.py` suite on Godot 4.7.stable.official,
including headless playthroughs to rank 1 and the balance sweep.
Windows export 2.1.2: PASS — `HeirsOfFortune-Windows-2.1.2.zip`
(59 434 945 bytes, SHA256 `6a886ea0…fbdf8`), exe 131 825 344 bytes.
Committed to `main` as `9c2bf87`; the eight unused legacy WAV effects
were then removed, HEAD `9ad9de2`. Owner play check on Windows and the
GitHub Release (tag `v2.1.2`) are still open.

## 2.1.1 — source-complete patch, publication gated

- Moved the exact ambition figures into `ambition.<mode>.desc`, the string the intro draws in the
  description line and in each ambition button's tooltip, and deleted `ambition.steady.button`,
  `ambition.meteor.button` and `ambition.heir.button`, which held those percentages in rows no control
  ever displayed. One suite case asserted against that invisible string; it now asserts against the
  visible description and tooltip, so the disclosure is proven on screen instead of in the catalogue.
- `project.godot` and both export presets now say 2.1.1. The save format is untouched, so 1.4.0 and
  2.0.x profiles still load with neutral ambition, empty threads and no milestones; no migration added.
- The optional `settings/theme_mode` value in the authenticated dynasty profile is now explicitly
  validated as `dark` or `light`; older profiles without it remain valid. This is an integrity guard,
  not a change to any mechanic, screen or balance number.
- The release record no longer claims an unpublished ZIP, gate result, checksum, owner pass or
  performance receipt for 2.1.1.
- The default-checkout contract keeps its disposable fixture under the validation artifacts, so a
  host-side bulk-delete guard cannot turn cleanup into a false contract failure.
- Withdrew the 2.1.0 attribution of the longer intro-to-first-card walk: scene and panel construction
  happens before the measurement timer starts. A 2.1.1 segment probe is planned to test whether the
  first frames presented after each screen switch explain the difference, but it has not run and no
  receipt exists. The disclosed verdict stays REVIEW; nothing was moved across the timer boundary.
- No mechanic, screen, balance number or asset changed. The 2.1.0 release stays published with its tag,
  assets and receipts.

Source validation 2.1.1: PASS — strict compile and EN/RU headless/rendered source runners, recorded in [acceptance-2.1.1/source-validation.json](acceptance-2.1.1/source-validation.json). This is not the export gate.

Publication gate 2.1.1: not run; no exported commit, ZIP, checksums or download verification exists yet.

## 2.1.0 Legacy & Chains — published 2026-10-30, intermediate build 2026-10-31, re-issued 2026-11-01

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
- Historical note: publication remained locked until all v2 phase evidence and that edition’s final gate passed.

- F2: audited literal keys and blank scene defaults; verified both locale catalogs and actual typeface glyphs.
- Remaining birth/business/inheritance model copy uses existing keys while preserving canonical Russian identities. Added a v1.4.0 original-copy and ordered-event regression fixture; opening copy refreshes on live language changes.

F3: published art tokens and individual 10-file source review; unified Prata display headings, legible currency units/scale/sample labels, and interruptible 180ms presentation-only capital updates with reduced-motion snapping. Source gallery and final gate evidence are tracked separately.

V2 F4: preserve the four distinct recorded mood tracks and two finales; add quiet focus/unavailable synthesis with honest CC0 hashes, one contextual acknowledgment per action, restrained cosmetic pitch variation and real rejected-action regressions. QA remains muted.

## F5 — integrity integration (historical)

Separate encrypted public/private QA exports and environment-only keys; physically excluded public verifier. Compiled critical-data manifest/trusted fallback and localized read-only safe mode. Localized authenticated-save recovery and stable unchanged round trips. New regression tests cover replacement manifests, safe-mode write/deletion boundaries, key preflight, public flags and save recovery.
Integer-cent money ledger, bounded fixed-precision FX wallet, no same-quote cent creation, atomic overflow refusal and saved monotonic grant ticks. Android artifacts omitted for this v2 cycle under section 16; no emulator claim.
