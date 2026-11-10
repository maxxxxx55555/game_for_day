# Heirs of Fortune 2.1.2 — Quality audio & stage art

Status: **exported Windows build**. The full source gate passed on this
commit, and a Windows Desktop build was exported on Godot 4.7 with the
standard 4.7 release templates (non-encrypted pack, as in 2.1.1, because
the encryption key and custom template live outside this environment).

## What changed

- **Short effects, rebuilt.** `purchase.wav` and `grant.wav` were
  byte-for-byte the same 0.38 s sine beep. All eight short effects are now
  synthesized at runtime in `scripts/audio/ProceduralSfx.gd` (CC0-1.0):
  `ui_click`, `ui_focus`, `ui_error`, `coin`, `purchase`, `sale`, `grant`,
  `upgrade` — each with its own pitch contour, duration (0.06–1.05 s) and
  timbre, peak normalized to 0.60. `tests/test_procedural_sfx.gd` proves
  all eight are distinct and clean at both edges. The director falls back
  to the recorded WAVs only for music and the victory/defeat finales, and
  its shutdown and the private QA verifier now track and release the
  synthesized streams too — no ObjectDB leaks.
- **Louder by default.** New profiles start with music at 0.65 instead of
  0.30; effect bus levels were raised as well. Existing saves keep the
  levels their owners chose.
- **Stage art.** The event illustration no longer shows the same frame for
  every quarter: `Main.apply_stage_art()` crops a different band of
  `city_folio.png` per stage and tints it (dawn river, bank, brass dusk,
  blue night), and the art stays visible during a life.
- **Catalog and trust anchor.** `assets/audio/catalog.json` moved the eight
  effects to `synth_sfx`; `data/critical-manifest.json` and
  `scripts/security/TrustedData.gd` were regenerated with
  `tools/build_manifest.py --check` passing. Tests that read the audio
  catalog (`test_audio_scope.gd`, `test_qa_audio_lifetime.gd`,
  `test_audio_shutdown.gd`, `test_ui_audio_feedback.gd`,
  `test_context_audio.gd`) were updated to the new layout instead of
  being weakened.

## What did not change

- Gameplay, balance, event/choice counts (31 events / 93 decisions, 8
  chains), save format, localization (1090 keys RU/EN), music and finale
  recordings, fonts, icons and the two skins.
- The published 2.1.0 release: its tag, assets and receipts stay where
  they are. 2.1.1 remains an unpublished source patch.

## Verification (this commit, Godot 4.7.stable.official)

| Step | Result |
| --- | --- |
| Strict compile | PASS — 39 scripts, 49 warning categories |
| Full `tests/run_tests.py` | PASS — exit 0, all cases, incl. playthroughs to rank 1 and the balance sweep |
| Audio assets / soundtrack | PASS — 6 WAV assets; 4 unique mood compositions and two finales |
| Critical-data trust anchor | PASS — `tools/build_manifest.py --check` |

## Export receipt (2026-11-10, Godot 4.7.stable.official)

- `HeirsOfFortune.exe` — 131 825 344 bytes,
  SHA256 `31a7abc7f66e441e445f4a7449905bd98bb7e61f5acaa535867427714292b3e9`
- `HeirsOfFortune-Windows-2.1.2.zip` — 59 434 945 bytes,
  SHA256 `6a886ea014d1018826b1dcade3d61d179dc4c87c3fd06e70de8fb179512fbdf8`
- Checked in the exported exe: it contains the new `ProceduralSfx` /
  `synth_sfx` audio system, no `ReleaseVerification` (QA verifier is
  excluded from the public preset, as designed), and no legacy
  `purchase.wav` / `grant.wav`.

## Open

- Owner play/listening check on Windows: the exe was built and inspected
  here, but this Linux host cannot run a Windows binary (no Wine), so
  the human playthrough is still open.
- The unused legacy WAV effect files (`ui_click`, `purchase`, `sale`,
  `coin`, `upgrade`, `grant`, `ui_focus`, `ui_error`) were removed from
  the repo in eight follow-up commits after `9c2bf87`, HEAD `9ad9de2`.
- Executable is unsigned; Windows x64 only; no Android artifact.
- The GitHub Release itself (tag `v2.1.2` + asset upload) is still open:
  it is being created in the browser, because the connector has no
  release-creation call.
