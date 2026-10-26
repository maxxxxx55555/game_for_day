## Current edition scope — v2 integration in progress

A complete offline life/finance loop: four birth origins,31 events/93 decisions, traits, five business upgrades plus expansion, stocks/crypto, EUR/GBP/JPY with spread, inflation, quarter-based grants, inheritance, dynasty and persistent victory/defeat/second-chance scenes. All active controls act on that model. Boot/loading hints and explicit failed-save exit handling are included in the v2 integration. The new public release remains locked until the full gate passes.

Archived design notes are scoped by [the promise matrix](docs/PROMISE_MATRIX.md). This edition has no multiplayer, live market data, real-money investments or advertisement network. Store-production signing and every-device certification are excluded. The current-cycle Android preview has **not been run on an emulator**: the host denies virtual-machine acceleration and documented software attempts fail before boot. Earlier1.4 emulator results are historical evidence only. Under v2 section16, any APK supplied in this cycle is clearly labelled an untested development-signed preview, or omitted.

# Heirs of Fortune — 2.0.0 preparation (publication locked)

Complete live Russian/English presentation with 606 catalog keys, stable saved event identities and all 93 decision layouts. Four distinct Gemini/Lyria mood compositions, two 20-second musical finales, independent Master/Music/SFX/UI levels, reduced motion, functional credits and coherent application icons. Existing protected profiles and legacy user-data directories remain compatible.

## Русский

Полная русская и английская локализация, выбор языка без потери текущего события. Разные композиции для четырёх настроений, музыкальные финалы, четыре уровня звука, настройка анимации и экран авторов. Каталоги старых сохранений сохранены.

Target release: v2.0.0; unpublished until the v2 gate passes. Detailed provenance: assets/audio/SOUNDTRACK.md. Localization: docs/LOCALIZATION.md. Scope remains stylized indie art and does not claim GTA V scale. Portable Windows executables are not Authenticode-signed; offline save tamper evidence is not unbreakable DRM.

---

# Heirs of Fortune —1.4.0

Native decision cards now separate concise action titles from readable effects. Cost, probability and requirements remain visible, with original full text retained for tooltips/accessibility. A short outcome notice replaces repeated event paragraphs, and the main illustration uses the freed space. Smooth rounded controls and shorter introductory/market copy reduce clutter; all 93 choice layouts are checked at a small portrait size. The original money, RNG, turns, currency/inflation, soundtrack and protected-save rules remain.

# Heirs of Fortune — 1.3.0

Onest body text, restrained Unbounded headings and authored chamfered satin-blue controls replace the previous interface. A fictional illustrated portrait ages through four life stages on the dashboard. Keyboard focus, disabled states and small portrait layouts are checked. Currency trading, inflation, life finales, distinct jazz music and protected saves are retained.

Presentation remains stylized indie art; this update does not claim GTA V scale. Existing save directories and gameplay rules are preserved.

# Heirs of Fortune — 1.2.1

Typed RNG and event-value validation now rejects malformed legacy sessions before assignment. Failed disk writes show a non-blocking warning; successful retries clear it without hiding a separate outstanding dynasty-save failure. Constructor nesting is bounded before parsing. Existing currency trading, inflation, distinctive jazz music and illustrated victory/defeat scenes are retained.

# Heirs of Fortune

A portrait life-and-finance strategy game. Build a business dynasty, balance your health against ambition and reach the world's number-one wealth rank ($250 billion).

## Play

Extract the whole Windows archive and run `HeirsOfFortune.exe`. Roll a birth origin, choose a trait and make one quarterly decision at a time. Businesses and stocks generate income; living costs and inflation continue each quarter. Markets and business menus let you manage capital without consuming a quarter unless the action explicitly says otherwise. The portfolio's dedicated Back button keeps investments and the current life event.

There are four birth origins, 31 events with 93 decisions, five business upgrades followed by expansion, stocks, crypto, recurring grants, inheritance and advanced dynasty traits. Reaching the target produces a persistent victory; death and retirement feed the next generation. The dashboard shows actual capital, available cash, income, costs and four condition meters.

Click/tap choices and navigation. Scroll the event card if its text is long. Settings provide independent Master, Music, SFX and UI levels, live Russian/English selection and reduced motion. On Android, Back closes a submenu; backgrounding saves the session. Normal purchases do not advance a quarter. Grants have a four-quarter cooldown and require no advertisement or network connection.

## Android status in this v2 cycle

The v2 release omits Android artifacts under specification section16. This host cannot boot the emulator; existing older APK/static-signature results do not establish runtime acceptance for the new encrypted build. The active export presets therefore target Windows only. Existing Android lifecycle code remains covered by source tests; it is not a claim of device certification.

## Build and test

Open `project.godot` in Godot 4.7 and press F5, or use:

```text
python tools/build_manifest.py
# Set GODOT_SCRIPT_ENCRYPTION_KEY and GODOT_WINDOWS_RELEASE_TEMPLATE privately in the build environment.
python tools/export_release.py --godot /path/to/godot --output /fresh/staging/HeirsOfFortune.exe
python tests/run_tests.py --godot /path/to/godot --rendered --artifacts /path/to/logs
```

The current source runner executes37 Godot cases per locale, plus Python export, copy/edition contracts, isolation, soundtrack and audio-asset checks. These cover 23 core regressions, 606 localization keys, all 93 decision layouts, independent audio buses, all four birth origins, full victory, market exit without liquidation, mobile lifecycle, save compatibility and audio. `tests/capture_gallery.gd` checks portrait bounds while capturing the main screens.

## Release scope and verification

Version 2.0.0 is the localization, soundtrack and presentation update to the portable Windows desktop edition, built with Godot 4.7 Stable. It remains a small standalone game with original illustrations and licensed assets. Earlier design documents include broader ideas for future development; they are not a list of promised features in this edition.

The test runner imports the real project in Godot, exercises gameplay, save/load, audio controls and rendered UI. Packaged executables also contain an opt-in complete-playthrough verifier: `-- --verify-build`. It starts a new QA game, so use isolated APPDATA/LOCALAPPDATA folders. QA is silent through `GAME_AUDIO_MUTED=1`; this does not remove the player's music/effects controls. Folders and formats from the previous game names remain compatible.

The release report records the exact tested files, hashes, routes, screenshots and platform limits. Tests are automated in the actual engine; they do not constitute a long independent human playtest or testing on every graphics card. Portable Windows executables are not Authenticode signed. Keep third_party/Godot/LICENSE.txt, COPYRIGHT.txt and assets/audio/LICENSE.md when redistributing. The soundtrack “Last Call at Three” has its own generation/provenance record; procedural sound effects are covered separately.

## 1.1.0 update

EUR, GBP and JPY can be bought and sold from Markets → Currencies. Fictional rates move after turns; both sides charge a disclosed 0.35% spread. Holdings count toward wealth and inheritance and persist with quote history and RNG state. Annualized inflation is displayed; rising living costs reduce idle cash purchasing power. The dashboard and event copy are shorter, and music credits are kept in the asset records.

The game has its own distinct per-mood soundtrack. See assets/CREDITS.md for creator licenses, font notices and generation records.

## 1.2.0 update

Victory and defeat now have separate full-screen illustrated finales with animated atmosphere and readable actions. The ending restores after relaunch; second chance and inheritance use the same game rules. The opt-in exported verifier also accepts `--defeat` to exercise an ordinary losing route, one revive and the next generation.

Offline tamper evidence, schema/resource validation and atomic saves protect normal play and recover known-good backups. Valid legacy saves migrate once. Keep the whole user-data folder, including its installation key, when backing up protected saves. See SAVE-INTEGRITY.md for the precise guarantees and limitations.

V2 visual pass: eight-point design tokens, curated source-asset review, consistent Prata display headings, labelled currency charts and180ms capital settlement that does not alter the model. See docs/ART_DIRECTION.md and docs/ASSET_REVIEW.json; final release acceptance remains gated.

## V2 integrity integration (release gate remains locked)

Public Windows packs omit the private verifier; the separate Windows QA preset additionally requires GAME_QA=1. All pack entries and the directory are encrypted using a matching custom Godot template and an environment-only build key. Encryption makes modification harder; it is not DRM. The compiled critical-data trust root rejects a replacement manifest and starts changed installations with trusted fallback data, a localized warning and no progress/settings writes. Authenticated save recovery records a local integrity log and shows a localized message. See SAVE-INTEGRITY.md for exact boundaries.

Money is stored as bounded integer cents, including cash, prices, income, costs and inheritance. Dollar properties are compatibility/presentation boundaries. Foreign holdings use integer thousandths; acquisition and liquidation round down and same-quote trades lose spread. Grants use saved integer half-quarter ticks, with duplicate-claim prevention and no wall-clock dependency.
