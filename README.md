# Heirs of Fortune — 2.0.1

## Current edition scope

A complete offline life/finance loop: four birth origins,31 events/93 decisions, traits, five business upgrades plus expansion, stocks/crypto, EUR/GBP/JPY with spread, inflation, quarter-based grants, inheritance, dynasty and persistent victory/defeat/second-chance scenes. All active controls act on that model. Boot/loading hints and explicit failed-save exit handling are included in this edition.

Archived design notes are scoped by [the promise matrix](docs/PROMISE_MATRIX.md). This edition has no multiplayer, live market data, real-money investments or advertisement network. Store-production signing and every-device certification are excluded. Android is omitted from this release: the host cannot boot an emulator. Earlier1.4 emulator results are historical evidence only. The Windows release does not claim Android runtime acceptance.

## 2.0.1 repair

Ordinary Git checkouts now use the committed LF bytes consistently: critical-data hashes and the compiled trust anchor match those bytes, and interface SFX provenance identifies the unchanged canonical generator source. Real checkout regressions exercise both `core.autocrlf=true` and `false` without local attribute overrides; CI and the source runner enforce them. Existing public tags and assets remain immutable.

Both localization CSV files have explicit LF checkout rules, preserving embedded canonical Russian line breaks on Windows.

Retained: Live RU/EN presentation with606 catalog keys, four mood compositions and two musical finales, independent audio levels, reduced motion, credits and protected1.4.0 profiles. Current content: 31 events/93 choices, four origins, business progression, investments, EUR/GBP/JPY trading with a disclosed0.35% spread each way, inflation, inheritance and illustrated victory/defeat.

## Русский

Исправлена воспроизводимая сборка из обычного Git-checkout: манифест данных, происхождение интерфейсных звуков и переносы строк локализации согласованы с исходными LF-байтами. Канонический русский текст, музыка, экономика и защищённые сохранения не меняются.

## Validation and limits

Normal Exit, window close and guarded QA rejection now wait for actual audio playback disposal before terminating. Save failures retain Retry/Stay/Discard, repeated accepted dialog callbacks cannot write twice, and private verifier cleanup remains reusable. Source test drivers drain audio explicitly and the runner rejects resource-leak warnings.

Coverage: 55 rendered Godot cases per locale;112 mechanics cells; all93 decision layouts plus currency, inflation, save, integrity and finale routes, plus Python checkout/provenance/license/copy/export contracts. Fresh complete source/native/soak results and exact artifact hashes are recorded by the release gate and current acceptance certificate. Earlier release measurements are historical and do not establish acceptance of this patch.

See [patch notes](docs/RELEASE_2.0.1.md), [acceptance certificate](docs/ACCEPTANCE_CERTIFICATE.md), [mechanics coverage](docs/MECHANICS_MATRIX.md), [save integrity](SAVE-INTEGRITY.md) and [the scoped promise inventory](docs/PROMISE_MATRIX.md). Portable Windows x64; Godot Compatibility/OpenGL-capable GPU; offline. The EXE is not Authenticode signed. Android artifacts are omitted. Finite automated tests do not replace owner play/listening checks or guarantee zero possible bugs, unbreakable offline security or AAA scale.

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
python tools/build_manifest.py --check
# Set GODOT_SCRIPT_ENCRYPTION_KEY and GODOT_WINDOWS_RELEASE_TEMPLATE privately in the build environment.
python tools/export_release.py --godot /path/to/godot --output /fresh/staging/HeirsOfFortune.exe
python tests/run_tests.py --godot /path/to/godot --rendered --artifacts /path/to/logs
```

The current source runner contains55 Godot invocations per locale, including import, plus Python export, copy/edition contracts, inherited-license bytes, isolation, soundtrack and audio-asset checks. These cover 23 core regressions, 606 localization keys, all 93 decision layouts, independent audio buses, all four birth origins, full victory, market exit without liquidation, mobile lifecycle, save compatibility and audio. `tests/capture_gallery.gd` checks portrait bounds while capturing the main screens.

## Release scope and verification

Version 2.0.0 was the localization, soundtrack and presentation update to the portable Windows desktop edition, built with Godot 4.7 Stable. It remains a small standalone game with original illustrations and licensed assets. Earlier design documents include broader ideas for future development; they are not a list of promised features in this edition.

The test runner imports the real project in Godot, exercises gameplay, save/load, audio controls and rendered UI. Public executables physically omit the complete-playthrough verifier and reject QA arguments. Only the separate, unpublished QA preset supports `-- --verify-build` with `GAME_QA=1`; it starts a fresh QA game in isolated APPDATA/LOCALAPPDATA folders. QA is silent through `GAME_AUDIO_MUTED=1`; this does not remove the player's music/effects controls. Folders and formats from the previous game names remain compatible.

The release report records the exact tested files, hashes, routes, screenshots and platform limits. Tests are automated in the actual engine; they do not constitute a long independent human playtest or testing on every graphics card. Portable Windows executables are not Authenticode signed. Keep third_party/Godot/LICENSE.txt, COPYRIGHT.txt and assets/audio/LICENSE.md when redistributing. The soundtrack “Last Call at Three” has its own generation/provenance record; procedural sound effects are covered separately.

## 1.1.0 update

EUR, GBP and JPY can be bought and sold from Markets → Currencies. Fictional rates move after turns; both sides charge a disclosed 0.35% spread. Holdings count toward wealth and inheritance and persist with quote history and RNG state. Annualized inflation is displayed; rising living costs reduce idle cash purchasing power. The dashboard and event copy are shorter, and music credits are kept in the asset records.

The game has its own distinct per-mood soundtrack. See assets/CREDITS.md for creator licenses, font notices and generation records.

## 1.2.0 update

Victory and defeat now have separate full-screen illustrated finales with animated atmosphere and readable actions. The ending restores after relaunch; second chance and inheritance use the same game rules. The opt-in exported verifier also accepts `--defeat` to exercise an ordinary losing route, one revive and the next generation.

Offline tamper evidence, schema/resource validation and atomic saves protect normal play and recover known-good backups. Valid legacy saves migrate once. Keep the whole user-data folder, including its installation key, when backing up protected saves. See SAVE-INTEGRITY.md for the precise guarantees and limitations.

V2 visual pass: eight-point design tokens, curated source-asset review, consistent Prata display headings, labelled currency charts and180ms capital settlement that does not alter the model. See docs/ART_DIRECTION.md and docs/ASSET_REVIEW.json; historical release evidence is documented in docs/RELEASE_2.0.0.md.

## Release integrity

Public Windows packs omit the private verifier; the separate Windows QA preset additionally requires GAME_QA=1. All pack entries and the directory are encrypted using a matching custom Godot template and an environment-only build key. Encryption makes modification harder; it is not DRM. The compiled critical-data trust root rejects a replacement manifest and starts changed installations with trusted fallback data, a localized warning and no progress/settings writes. Authenticated save recovery records a local integrity log and shows a localized message. See SAVE-INTEGRITY.md for exact boundaries.

Money is stored as bounded integer cents, including cash, prices, income, costs and inheritance. Dollar properties are compatibility/presentation boundaries. Foreign holdings use integer thousandths; acquisition and liquidation round down and same-quote trades lose spread. Grants use saved integer half-quarter ticks, with duplicate-claim prevention and no wall-clock dependency.

## 2.0.1 acceptance and distribution

Current [acceptance certificate](docs/ACCEPTANCE_CERTIFICATE.md), [owner checklist](docs/HANDOFF.md), [final report](docs/FINAL_REPORT.md) and [announcement kit](docs/ANNOUNCE_KIT.md) describe this patch. Older diagnostic documents/images refer to preserved historical attempts. Only the published gated patch ZIP and its exact versioned sums file are distribution artifacts.

## Country birth update

The birth lottery now draws from 192 countries in the bundled historical dataset and shows the birthplace in a dedicated card and dashboard. Starting conditions vary; the income effect converges to neutral by age 52. The new save fields are bounded and validated, and older profiles receive neutral historical defaults. Fresh acceptance for this runtime is required; previous candidate receipts are superseded.
