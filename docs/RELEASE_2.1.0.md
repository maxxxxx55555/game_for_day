# Heirs of Fortune 2.1.0 — Legacy & Chains

Status: **published, re-issued 2026-10-31 and re-gated for the skin repaint.** The gate figures quoted below come from the run at `b38e9df`; this tree's own run is recorded in `docs/acceptance-2.1.0/gate.json` and its numbers are restated in the documentation commit that follows it. The publication gate returned PASS at the commit named in `docs/acceptance-2.1.0/gate.json` and the release ships the build exported from that commit: https://github.com/maxxxxx55555/game_for_day/releases/tag/v2.1.0. The tag `v2.1.0` names the exported commit; commits after it change documentation only. Owner play and listening checks stay with the owner and are not claimed here.

This edition was first published on 2026-10-30 from `807ba09`. It was re-issued a day later because `main` had meanwhile taken the two-skin appearance system, and publishing a 2.1.0 that excluded work already sitting on the main branch would have left the shipped build and the published source disagreeing. The superseded build and its digests are recorded in the [final report](FINAL_REPORT.md).

## New systems

- **Threads of fate (G1).** Eight player-started chains with two links each. The first choice stores a flag; the follow-up returns after five quarters with a recall of the exact label and resolves through a flag-specific variant. Completion grants momentum and is recorded once.
- **Dynasty ledger and hall of fame (G2).** Five sections — journal, legacy perks, threads, hall of fame and ascension. Up to twelve finished lives are kept with generation, wealth, rank, ambition, ascension, thread and milestone counts.
- **Legacy meta-progression (G3).** Eight permanent perks cost 4–15 points. Points survive generations; warm start raises the first balance by $2,000.
- **Ascension (G4).** A five-level NG+ path from the victory finale. Each level raises inflation, volatility and difficulty and pays bonus legacy; the next life starts clean with its ascension level recorded.
- **Milestones and momentum (G5).** Retrospectives at 18, 25, 35, 50 and 65 grant momentum. The card records the read but never pauses or advances the world.
- **Ambitions (G6).** Steady, meteor and heir change real economic trade-offs: meteor raises stress gains and market swings, heir takes a 1.25 inheritance multiplier and a larger legacy payout in exchange for a tenth of quarter income.
- **Card feel (G7).** A short reveal, signed delta chips for every changed stat, outcome tones, a live 24-sample portfolio pulse and reduced-motion snapping. Presentation never enters the saved model.
- **Two skins (carried into this re-issue).** Dark ink-and-gold and light paper-and-bronze, resolved through `scripts/ui/Palette.gd`, switched on the intro and in settings, and stored with the other interface settings in `dynasty_save.cfg`; the choice never enters the life payload or the canonical Russian copy. See [APPEARANCE.md](APPEARANCE.md).

## Design pass

Repository-authored 1.75px vector icons for market, business, grant, dynasty, settings, theme and globe; Unbounded 600/700 display and Onest 400/500 body type; displayed strings omit emoji. The palette below is what the first publication painted; the re-issued build paints the two skins documented in [APPEARANCE.md](APPEARANCE.md), whose dark skin keeps the brass, deep brass, quiet green and clay values. See [ART_DIRECTION.md](ART_DIRECTION.md).

Palette of the first publication: #14181D / #2E4057 / #3E5C76 / #C9A227 / #F1EEE7 / #7FB069 / #C4614F.

## Compatibility

All 2.1 save fields are optional. 1.4.0 and 2.0.x profiles load with neutral ambition, empty threads, no milestones and no legacy records. Canonical Russian copy and legacy user-data folders are unchanged. The complete persistent model is hashed across pause/background, live locale changes and authenticated save/restart by the profile contract.

## Verification scope

The mechanics matrix maps 19 mechanics and 152 executable cells. The publication gate runs every step to exit 0 at the gated commit on 2026-10-31 in 5,148.6 seconds on a clean tree:

| Gate step | Result |
|---|---|
| Trust anchor | PASS — 5 critical data files verified against `data/critical-manifest.json`. |
| Localization compile | PASS — 1093 keys, `ru.csv` and `en.csv` rows identical, generated catalogue matches the committed JSON. |
| Strict compile | PASS — 38 shipping scripts, all 49 warning categories treated as errors. |
| Source suites | PASS — 50 headless and 51 rendered cases in RU and in EN, 0 failures. |
| Exports | PASS — public EXE 94,063,944 B `ca7147bd246f1716b71f801fdb860bd27448171533b6c8d3d78a7c7c24567202`, public PCK 22,816,572 B `3275646de463050610c57c4dad1ddaf837a00a56f8d7a7690f612909ee2050b6`, plus the private QA EXE/PCK pair (`59c476f2a4810947264b91ed20f81fcfb25388c814fb7caad43dfd3f6cdcabb7`, `5c2cb8bee9bfb8a436d955cd579d28da211e9dca02cac50b16bf2eedae6b7a4c`) built from the same template `a82cbeedcf7edb62d974ae6875b3dddb956ad2a0d0b430cf9b772fa39d670905`. |
| Exported native runs | PASS — 9 runs: three victory routes, three defeat routes and three guards that must refuse the verifier (each refused with exit 64). |
| Seeded cycles | PASS — 100 of 100 requested cycles completed in 2,084.9 s, seeds 101–200, 100 distinct final states. |
| Legacy profiles | PASS — 1.4.0 and 2.0.x profiles round-trip with stable payload hashes and tamper rejection. |
| Soak | PASS — 1,807.078 s rendered at normal speed, 60 complete cycles, 954 checkpoints, 1,806 allocation samples, 0 failures, 0 script errors, 0 integrity warnings. Engine nodes and resources stayed flat at 20 and 46 with zero orphans throughout. Object counts warmed from 2,023 to a 2,109 plateau reached at 847.98 s, with 32 stable cycles after it; post-warm-up growth 1,245,184 B against a 6,752,747 B allowance, final six-minute window net 196,608 B against 4,501,832 B, plateau 450,183,168 B. |

The soak's warm-up rule was sharpened while closing this re-issue: the post-warm-up window now starts where the per-cycle engine counts stop changing for the rest of the run, instead of at a fixed 120 s. Counts that never settle, settle with fewer than ten stable cycles left, or only settle after half the run are failures, and `builds/release-2.1.0/validate_trend.py` grades eight synthetic profiles through the rule — a flat plateau and a bounded warm-up must pass; 150 B/s, 1 KiB/s and ~6 MiB/run leaks, a never-settling object count, that count combined with a memory leak, and orphan nodes must fail. All eight behave as declared.

Balance sweep on this source: 112 lives across two scripted policies in 1,540.9 s with no dominance finding. Under the conservative policy every ambition wins (steady at a median age 59, meteor at 56, heir at 60.5), and under the aggressive policy none of the three reaches victory, so no ambition is a free improvement over its siblings.

Performance on this host, measured against a 2.0.2 worktree in interleaved attempts with isolated save profiles: median frame 16.687 ms versus 16.675 ms, p95 frame 17.226 ms versus 17.263 ms, dashboard ready 522 ms versus 545.5 ms (the baseline's own attempt spread was 159 ms). Nothing in this build is slower than the accepted baseline beyond the measurement noise.

Presentation was reviewed from frames re-rendered at `2ff705d`, whose only difference from the exported commit is documentation: 136 gallery frames — both skins, both locales, both acceptance resolutions — assembled into eight labelled contact sheets, plus 24 ambition-row frames with each ambition selected in both skins. Fourteen presentation defects were found and repaired while closing this edition, none open. The anti-AI-slop audit passes over displayed copy, 26 documented tokens across both skins, all seven interface vectors at 1.75px, fonts and licences. Finite automated tests do not replace owner play/listening checks and do not prove the absence of every possible defect.

## Archive

`HeirsOfFortune-Windows-2.1.0.zip` — 84,631,852 bytes (80.7 MB), SHA256 `dbc13f80ae2f54fcc925ff1bb6fa1d9a407a4e554cf4e2f04c33241587fba011`, 240 entries — with `HeirsOfFortune-SHA256SUMS-2.1.0.txt` (99 bytes, SHA256 `f821ccb77b50f4794b266e6f4338d91b7bc9e07f815e4848984610878a9d6b1e`) naming that exact filename. Both files were downloaded fresh from the release into an empty directory on 2026-11-01 and `sha256sum -c HeirsOfFortune-SHA256SUMS-2.1.0.txt` printed `HeirsOfFortune-Windows-2.1.0.zip: OK` with exit code 0; GitHub's own asset digests matched the locally computed ones. Reading the downloaded archive back, it contains the public EXE `ca7147bd246f1716b71f801fdb860bd27448171533b6c8d3d78a7c7c24567202` (94,063,944 bytes) and PCK `3275646de463050610c57c4dad1ddaf837a00a56f8d7a7690f612909ee2050b6` (22,816,572 bytes) — the gate exports from `b38e9df` — and the bundled `docs/acceptance-2.1.0/exports.json` names those same two digests rather than the superseded ones. The private QA pair is not inside it, and no key material appears in any loose file. The archive's documentation tree is the tree committed as `1a32532`; the receipts that describe the archive itself necessarily land after it.

## Limits

Windows x64 only; Android artifacts are omitted. The executable is not Authenticode signed. Offline tamper evidence makes modification harder but is not DRM, and the custom export template necessarily carries the pack-decryption key. No AAA-scale or "no bugs" claim is made.

## Русский

Версия 2.1.0 «Наследие и нити»: **опубликована, перевыпуск 31 октября 2026 года.** Публикационный гейт прошёл целиком на коммите, указанном в `docs/acceptance-2.1.0/gate.json`, релиз несёт сборку, экспортированную из него; тег `v2.1.0` указывает на этот коммит, все более поздние коммиты затрагивают только документацию. Ручные проверки владельцем не выполнены и не объявлены пройденными.

Изначально 2.1.0 была опубликована 30 октября с `807ba09`. Перевыпуск через сутки нужен потому, что в `main` за это время легла система двух оформлений, и выпускать 2.1.0 без работы, которая уже лежит в основной ветке, означало бы разъезд опубликованной сборки с опубликованным исходником. Отменённая сборка с её дайджестами записана в финальном отчёте.

Восемь «нитей судьбы» живут в двух звеньях: выбор запоминается флагом, возвращается через пять кварталов с точной цитатой и получает вариантную развязку; завершённая нить даёт импульс и записывается один раз. Панель династии содержит журнал, восемь постоянных перков за 4–15 очков, нити, зал славы на двенадцать жизней и восхождение на пять уровней NG+, которое усиливает инфляцию, волатильность и сложность. Вехи в 18, 25, 35, 50 и 65 лет показывают ретроспективу, не останавливая мир. Три амбиции меняют реальные экономические условия: наследник берёт множитель 1,25 к наследству и долю 25 % вместо 20 % в обмен на десятую часть квартального дохода, и эта цена записана в его описании на обоих языках. Карточки получили раскрытие, чипы изменений, тональность исхода и живой пульс портфеля. Обе темы — тёмная «чернила и золото» и светлая «бумага и бронза» — рисуются одним кодом через `scripts/ui/Palette.gd`, переключаются на старте и в настройках и не попадают в сохранение.

Гейт: 15 шагов с нулевым кодом за 5148,6 с на чистом дереве — якорь доверия (5 файлов), локализация (1093 ключа, совпадающие строки ru/en), строгий компилятор (38 скриптов, 49 категорий), 50 headless и 51 rendered кейсов на русском и английском, четыре экспорта, двенадцать нативных прогонов (три победы, три поражения, два маршрута журнала династии и четыре отказа публичной сборки), 100 из 100 сеяных циклов со 100 различными финалами за 2084,9 с, совместимость 1.4.0/2.0.x и соук 1807,078 с с 60 циклами, 954 контрольными точками и 1806 сэмплами. Узлы и ресурсы движка оставались плоскими (20 и 46) без сирот, счётчики объектов вышли на плато 2109 за 847,98 с, рост после прогрева 1 245 184 Б при допуске 6 752 747 Б. Правило прогрева в соуке ужесточено: окно измеряется от точки, где счётчики движка перестают меняться, а синтетические профили доказывают, что неоседающие счётчики и утечки 150 Б/с, 1 КиБ/с и ~6 МиБ по-прежнему падают. Баланс: 112 жизней за 1540,9 с, доминирующих вариантов нет. Производительность против базы 2.0.2 на этом хосте: медиана кадра 16,687 мс против 16,675 мс, p95 17,226 мс против 17,263 мс, готовность панели 522 мс против 545,5 мс при разбросе самой базы в 159 мс. Визуальная приёмка: 136 кадров галереи в обеих темах, обеих локалях и обоих разрешениях, 24 кадра ряда амбиций, шестнадцать исправленных дефектов, открытых нет; аудит на «ИИ-шаблонность» зелёный. Тесты не заменяют ручное прохождение и прослушивание и не доказывают отсутствие всех возможных дефектов.

Windows x64; Android-артефакты опущены; EXE без Authenticode; офлайн-защита не является DRM.
