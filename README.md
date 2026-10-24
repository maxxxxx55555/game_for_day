# Heirs of Fortune

A portrait life-and-finance strategy game. Build a business dynasty, balance your health against ambition and reach the world's number-one wealth rank ($250 billion).

## Play

Extract the whole Windows archive and run `HeirsOfFortune.exe`. Roll a birth origin, choose a trait and make one quarterly decision at a time. Businesses and stocks generate income; living costs and inflation continue each quarter. Markets and business menus let you manage capital without consuming a quarter unless the action explicitly says otherwise. The portfolio's dedicated Back button keeps investments and the current life event.

There are four birth origins, 31 events with 93 decisions, five business upgrades followed by expansion, stocks, crypto, recurring grants, inheritance and advanced dynasty traits. Reaching the target produces a persistent victory; death and retirement feed the next generation. The dashboard shows actual capital, available cash, income, costs and four condition meters.

Click/tap choices and navigation. Scroll the event card if its text is long. Settings provide independent music/effect levels. On Android, Back closes a submenu; backgrounding saves the session. Normal purchases do not advance a quarter. Grants have a four-quarter cooldown and require no advertisement or network connection.

## Android preview

The separately supplied APK is an emulator-tested preview, signed with a development key. It is not a Google Play production artifact. It contains ARM64, ARMv7 and x86_64 libraries, targets API 36 and needs OpenGL ES 3. No phone or tablet hardware was available for testing. Publishing to a store needs the owner's durable production signing key and the store's own submission process. Do not upload this development-signed APK as a production app.

## Build and test

Open `project.godot` in Godot 4.7 and press F5, or use:

```text
godot --headless --path . --export-release "Windows Desktop" builds/windows/HeirsOfFortune.exe
python tests/run_tests.py --godot /path/to/godot --rendered --artifacts /path/to/logs
```

The suite covers 23 core regressions, all four birth origins, full victory, market exit without liquidation, mobile lifecycle, save compatibility and audio. `tests/capture_gallery.gd` checks portrait bounds while capturing the main screens.

## Release scope and verification

Version 1.0.0 is the initial portable Windows desktop edition, built with Godot 4.7 Stable. It is a small standalone game with original stylized/procedural visuals. Earlier design documents include broader ideas for future development; they are not a list of promised features in this edition.

The test runner imports the real project in Godot, exercises gameplay, save/load, audio controls and rendered UI. Packaged executables also contain an opt-in complete-playthrough verifier: `-- --verify-build`. It starts a new QA game, so use isolated APPDATA/LOCALAPPDATA folders. QA is silent through `GAME_AUDIO_MUTED=1`; this does not remove the player's music/effects controls. Folders and formats from the previous game names remain compatible.

The release report records the exact tested files, hashes, routes, screenshots and platform limits. Tests are automated in the actual engine; they do not constitute a long independent human playtest or testing on every graphics card. Portable Windows executables are not Authenticode signed. Keep third_party/Godot/LICENSE.txt, COPYRIGHT.txt and assets/audio/LICENSE.md when redistributing. The soundtrack “Where the Fog Rests” has its own generation/provenance record; procedural sound effects are covered separately.
