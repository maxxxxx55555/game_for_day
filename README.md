# Heirs of Fortune — 1.2.1

Typed RNG and event-value validation now rejects malformed legacy sessions before assignment. Failed disk writes show a non-blocking warning; successful retries clear it without hiding a separate outstanding dynasty-save failure. Constructor nesting is bounded before parsing. Existing currency trading, inflation, distinctive jazz music and illustrated victory/defeat scenes are retained.

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

Version 1.2.0 is the finale, integrity and visual update to the portable Windows desktop edition, built with Godot 4.7 Stable. It remains a small standalone game with original illustrations and licensed assets. Earlier design documents include broader ideas for future development; they are not a list of promised features in this edition.

The test runner imports the real project in Godot, exercises gameplay, save/load, audio controls and rendered UI. Packaged executables also contain an opt-in complete-playthrough verifier: `-- --verify-build`. It starts a new QA game, so use isolated APPDATA/LOCALAPPDATA folders. QA is silent through `GAME_AUDIO_MUTED=1`; this does not remove the player's music/effects controls. Folders and formats from the previous game names remain compatible.

The release report records the exact tested files, hashes, routes, screenshots and platform limits. Tests are automated in the actual engine; they do not constitute a long independent human playtest or testing on every graphics card. Portable Windows executables are not Authenticode signed. Keep third_party/Godot/LICENSE.txt, COPYRIGHT.txt and assets/audio/LICENSE.md when redistributing. The soundtrack “Last Call at Three” has its own generation/provenance record; procedural sound effects are covered separately.

## 1.1.0 update

EUR, GBP and JPY can be bought and sold from Markets → Currencies. Fictional rates move after turns; both sides charge a disclosed 0.35% spread. Holdings count toward wealth and inheritance and persist with quote history and RNG state. Annualized inflation is displayed; rising living costs reduce idle cash purchasing power. The dashboard and event copy are shorter, and music credits are kept in the asset records.

Both games have different newly generated music. See assets/CREDITS.md for creator licenses, font notices and generation records.

## 1.2.0 update

Victory and defeat now have separate full-screen illustrated finales with animated atmosphere and readable actions. The ending restores after relaunch; second chance and inheritance use the same game rules. The opt-in exported verifier also accepts `--defeat` to exercise an ordinary losing route, one revive and the next generation.

Offline tamper evidence, schema/resource validation and atomic saves protect normal play and recover known-good backups. Valid legacy saves migrate once. Keep the whole user-data folder, including its installation key, when backing up protected saves. See SAVE-INTEGRITY.md for the precise guarantees and limitations.
