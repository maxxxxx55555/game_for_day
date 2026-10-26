# Heirs of Fortune — owner handoff

> Announcement hold: the newer [ACCEPTANCE_CERTIFICATE.md](ACCEPTANCE_CERTIFICATE.md) records failed clean-tag source contracts. Earlier finite results below remain historical. The five manual checks cannot waive these mandatory blockers.

Accepted Windows release: [v2.0.0](https://github.com/maxxxxx55555/game_for_day/releases/tag/v2.0.0). Immutable game source: `b5a9aba0821ae9af8a202a4c835e17981425e09a`. Post-tag closeout commits add documentation only; use the versioned release ZIP for play. [FINAL_REPORT.md](FINAL_REPORT.md) contains full hashes, F1–F8 acceptance, native guard output, soundtrack provenance and limitations.

## Five checks before announcement

1. **Download and check the exact files.** Download [HeirsOfFortune-Windows-2.0.0.zip](https://github.com/maxxxxx55555/game_for_day/releases/download/v2.0.0/HeirsOfFortune-Windows-2.0.0.zip) and [HeirsOfFortune-SHA256SUMS-2.0.0.txt](https://github.com/maxxxxx55555/game_for_day/releases/download/v2.0.0/HeirsOfFortune-SHA256SUMS-2.0.0.txt) into the same empty folder. In Git Bash, WSL/Linux or a shell providing `sha256sum`, run the command below. Keep the exact capitalization; do not rename either download. The closeout independently downloaded these public files and got the shown exit0 result.
2. **Extract and launch.** Extract the entire ZIP to a writable ordinary Windows folder and run `HeirsofFortune/HeirsofFortune.exe`. Keep its matching `.pck`, licenses and README together. Use a clean test profile for a new game. Public builds reject verifier flags even with `GAME_QA=1`; no private QA build/key is needed for normal play.
3. **Check presentation and audio.** Select English and Русский in settings, switch live and restart once to confirm persistence. Check window size, readable buttons, keyboard focus/Back and reduced motion. Set a comfortable Music level and personally listen to the four moods plus victory/defeat cues listed in FINAL_REPORT; verify Master/Music/SFX/UI controls independently and open Credits. Mood contexts are welcome/intro, study (age under26), career (under50), and tycoon (wealth at least$50million); the highest wealth stage takes priority. Automated waveform/routing tests have passed; independent listening is not claimed.
4. **Check ordinary play and profile migration on copies.** Play a new session through key actions, save, close and Continue. Inspect victory and defeat presentation. Before opening an old installation, close both games and back up the entire profile directory below, including `save_integrity.key`, guard files and backups. Test a disposable copy of a valid protected 1.4.0 profile. Do not move only a save file or overwrite your only original copy. The original protected1.4.0 profile was actually accepted in source and the public native build; no separate1.5.0 migration is claimed. New-life deliberately clears its checkpoint.
5. **Review distribution and honest claims.** Keep credits, creator licenses and music terms with the build; verify the release page/download names before sharing. The portable EXE has no Authenticode signature, so Windows may show its normal unsigned-app warning. Complete an independent human play/listening session before a marketing announcement if that assurance is desired. Android/emulator and store certification, broad device coverage, universal zero bugs, invulnerability and AAA scale are outside this accepted Windows release.

```sh
sha256sum -c HeirsOfFortune-SHA256SUMS-2.0.0.txt
```

Actual fresh-download closeout output:

```text
HeirsOfFortune-Windows-2.0.0.zip: OK
exit: 0
```

ZIP SHA256: `dd4511d281fd6f2b53b98d4b58e1b1fa972a8e7860446515bb2d46b252d65f0f`.
Checksum-file SHA256: `1e9af09ecc81542defb7040687b1a30d7b2b270f0a1b533242d256d9f119a84b`.

Legacy profile directory (kept unchanged for compatibility):

```text
%APPDATA%/Godot/app_userdata/Forbes Ladder- Dynasty & Markets v2
```

Back up the whole directory while the app is closed. Keep your installation key private. If a problem appears, record the version, Windows/GPU information and exact actions; retain the affected profile privately and avoid posting keys or personal paths publicly.

## What this handoff establishes

The finite accepted edition passed complete EN/RU suites (46 Godot invocations per locale plus Python contracts), 14 mechanics / 112 executed cells,50 complete distinct seeds, rendered soak, exact native wins/defeat, original protected-profile compatibility, public/private QA separation, critical-data tamper/read-only fallback, encrypted pack checks, license-byte/provenance checks and fresh public download checksums. Full tests were run before release; closeout reran only the requested download, native guards and API/isolation checks because no game files changed.

## Deliberate exclusions and preservation

Offline integrity cannot prevent a device owner from modifying code or extracting local keys. No independent extended human playtest or every-device/audio-hardware certification is asserted. Android is omitted under the accepted unavailable-emulator fallback. Private signing/build keys and QA executables are not included. The unique unmerged branch is preserved with evidence in FINAL_REPORT; it is not part of the released game.
