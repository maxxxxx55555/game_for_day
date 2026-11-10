# Heirs of Fortune 2.1.3 — English that actually shows, and art that actually shows

Status: **source release**. This patch fixes what the rendered visual QA
of 2.1.2 found on real frames (Xvfb + Mesa llvmpipe, 540×960, 15 frames
reviewed by eye in `~/workspace/visual-qa-2.1.2/`).

## What changed

- **English on the intro and the country plate.** The intro title
  («Наследники удачи») and the country plate («Мозамбик / АФРИКА ЮЖНЕЕ
  САХАРЫ») stayed Russian when the game ran in English. Cause: custom-drawn
  text used `LocalizationManager.source()`, which always returns the
  canonical Russian copy, while the engine's auto-translation only applies
  to control properties. Fixed by using `get_string()` in `IntroCover.gd`,
  `CountryPlate.gd` and `BirthLottery.country_name()` / `region_name()`.
  A new guard in `test_copy_contract.py` fails any future
  `draw_string(... source(...))`.
- **Art strips re-aimed.** The billionaire strip cropped the top of the
  painting — ~85% empty night sky (mean brightness 55, the flattest of the
  four). It now starts at `y=150`, so the dome and the towers show. The
  survival strip cropped the bottom — nearly all water (`y=948`); it now
  starts at `y=800`, so the bridge, boats and embankment show. Crop
  brightness was measured per candidate window before choosing.
- **Theme picker in settings** showed the theme from launch time; it now
  follows `GameManager.theme_changed`.
- **Removed the unused portrait atlas** `assets/art/life-portraits.png`
  (2.36 MB, plus its provenance file): no code references it, it is
  photo-realistic against a painted city, and it shows one face for 192
  countries. Portraits stay out of the game on purpose.

## What did not change

No mechanic, screen layout or balance number changed. Save format untouched.
The painted city, the soundtrack and the synthesized effects are unchanged.

## Validation

- Strict compile and the full `tests/run_tests.py` suite on Godot 4.7 —
  result recorded in the changelog before the commit.
- Visual QA re-run on the fixed build: intro EN, country plate EN,
  billionaire strip and theme picker re-checked on real frames.

## Open

- Owner play check on Windows for 2.1.2/2.1.3 (this host cannot run a
  Windows binary).
- Windows export of 2.1.3 and its GitHub Release follow the same pipeline
  as 2.1.2.
- Cosmetic: some panels (country plate, birth, perks, market) still have
  200–300 px of empty middle space; content sits at the top, buttons at
  the bottom. Not broken, but the screens look under-filled.
- Executable is unsigned; Windows x64 only; no Android artifact.
