# Heirs of Fortune 2.1.0 — Legacy & Chains

Status: **the publication gate returned PASS on 2026-10-30 at commit `807ba09c551134c76f23b4167ab7b5783dd7199e`**, and this note describes the Windows x64 portable release built from that commit. The tag `v2.1.0` sits on the exported commit; later commits on `main` change documentation only. Owner play and listening checks stay with the owner and are not claimed here.

## New systems

- **Threads of fate (G1).** Eight player-started chains with two links each. The first choice stores a flag; the follow-up returns after five quarters with a recall of the exact label and resolves through a flag-specific variant. Completion grants momentum and is recorded once.
- **Dynasty ledger and hall of fame (G2).** Five sections — journal, legacy perks, threads, hall of fame and ascension. Up to twelve finished lives are kept with generation, wealth, rank, ambition, ascension, thread and milestone counts.
- **Legacy meta-progression (G3).** Eight permanent perks cost 4–15 points. Points survive generations; warm start raises the first balance by $2,000.
- **Ascension (G4).** A five-level NG+ path from the victory finale. Each level raises inflation, volatility and difficulty and pays bonus legacy; the next life starts clean with its ascension level recorded.
- **Milestones and momentum (G5).** Retrospectives at 18, 25, 35, 50 and 65 grant momentum. The card records the read but never pauses or advances the world.
- **Ambitions (G6).** Steady, meteor and heir change real economic trade-offs: meteor raises stress gains and market swings, heir takes a 1.25 inheritance multiplier and a larger legacy payout in exchange for a tenth of quarter income.
- **Card feel (G7).** A short reveal, signed delta chips for every changed stat, outcome tones, a live 24-sample portfolio pulse and reduced-motion snapping. Presentation never enters the saved model.

## Design pass

Palette #14181D / #2E4057 / #3E5C76 / #C9A227 / #F1EEE7 / #7FB069 / #C4614F; Unbounded 600/700 display and Onest 400/500 body type; repository-authored 1.75px vector icons for market, business, grant, dynasty and settings; displayed strings omit emoji. See [ART_DIRECTION.md](ART_DIRECTION.md).

## Compatibility

All 2.1 save fields are optional. 1.4.0 and 2.0.x profiles load with neutral ambition, empty threads, no milestones and no legacy records. Canonical Russian copy and legacy user-data folders are unchanged. The complete persistent model is hashed across pause/background, live locale changes and authenticated save/restart by the profile contract.

## Verification scope

The mechanics matrix maps 18 mechanics and 144 executable cells, including [chains](../tests/test_chains.gd), [dynasty progression](../tests/test_dynasty_progression.gd) and [card feel](../tests/test_card_feel.gd). The publication gate ran every step to exit 0 at `807ba09` on 2026-10-30 in 5,685 seconds on a clean tree:

| Gate step | Result |
|---|---|
| Trust anchor | PASS — 5 critical data files verified against `data/critical-manifest.json`. |
| Localization compile | PASS — 1084 keys, `ru.csv` and `en.csv` rows identical, generated catalogue matches the committed JSON. |
| Strict compile | PASS — 34 shipping scripts, all 49 warning categories treated as errors. |
| Source suites | PASS — 49 headless and 50 rendered cases in RU and in EN, 0 failures. |
| Exports | PASS — public EXE 94,037,672 B `000b0eda79d7fa463a1e0e9ff64ebcfd976ad11b7fddd07dcccc01319e0fead9`, public PCK 22,790,300 B `35ed80d81ef2b22712115af74ca0b99702c037536812f809020242f453652ca1`, plus the private QA EXE/PCK pair built from the same template `a82cbeedcf7edb62d974ae6875b3dddb956ad2a0d0b430cf9b772fa39d670905`. |
| Exported native runs | PASS — 9 runs: three victory routes, three defeat routes and three guards that must refuse the verifier (each refused with exit 64). |
| Seeded cycles | PASS — 100 of 100 requested cycles completed, seeds 101–200, 100 distinct final states. |
| Legacy profiles | PASS — 1.4.0 and 2.0.x profiles round-trip with stable payload hashes and tamper rejection. |
| Soak | PASS — 1,817.032 s rendered at normal speed, 84 complete cycles, 1,333 checkpoints, 0 failures. Engine counts stayed flat (20 nodes, 1,991 objects, 42 resources, zero orphans). Final six-minute window: net −696,320 B, band 700,416 B; post-warm-up quarter growth 2,140,160 B against a 5,224,980 B allowance. |

Balance sweep on the same source: 112 lives across two scripted policies in 1,214.5 s with no dominance finding. Under the conservative policy every ambition wins (steady and heir at a median age 59 and 60.5, meteor at 56 but with a measured stress cost), and under the aggressive policy none of the three reaches victory, so no ambition is a free improvement over its siblings.

Performance on this host, measured against a 2.0.2 worktree in interleaved attempts with isolated save profiles: median frame 16.665 ms versus 16.675 ms, p95 frame 17.272 ms versus 17.263 ms, dashboard ready 528 ms versus 545.5 ms (the baseline's own attempt spread was 159 ms). Nothing in 2.1.0 is slower than the accepted baseline beyond the measurement noise.

Presentation was reviewed from re-rendered frames at `e9b0256`: 66 gallery frames in four contact sheets plus 12 ambition-row frames with each ambition selected in both locales and both resolutions. Finite automated tests do not replace owner play/listening checks and do not prove the absence of every possible defect.

## Archive

`HeirsOfFortune-Windows-2.1.0.zip` — 85,736,652 bytes, SHA256 `c7199222573d17c8996d8774ffdd6238feef240753eaf803b137eba38b456226` — with `HeirsOfFortune-SHA256SUMS-2.1.0.txt` (SHA256 `e0ec84e1ce0a84715151e86f740b72a768c317242b3952bcb07be14dc5bfd782`) naming that exact filename. The archive holds the public EXE and PCK above plus the documentation tree; the private QA pair is not inside it, and the outside re-audit of the delivered entries passes with 238 entries, intact inherited licence bytes and no key material in any loose file.

## Limits

Windows x64 only; Android artifacts are omitted. The executable is not Authenticode signed. Offline tamper evidence makes modification harder but is not DRM. No AAA-scale or "no bugs" claim is made.

## Русский

Версия 2.1.0 «Наследие и нити»: **публикационный гейт пройден 30 октября 2026 года на коммите `807ba09c551134c76f23b4167ab7b5783dd7199e`**; это заметка о переносимой сборке для Windows x64, собранной из этого коммита. Тег `v2.1.0` стоит на экспортированном коммите, все более поздние коммиты в `main` затрагивают только документацию. Ручные проверки владельцем не выполнены и не объявлены пройденными.

Восемь «нитей судьбы» из панели династии живут в двух звеньях: выбор запоминается флагом, возвращается через пять кварталов с точной цитатой и получает вариантную развязку; завершённая нить даёт импульс и записывается один раз. Панель династии содержит журнал, восемь постоянных перков за 4–15 очков, нити, зал славы на двенадцать жизней и восхождение на пять уровней NG+, которое усиливает инфляцию, волатильность и сложность. Вехи в 18, 25, 35, 50 и 65 лет показывают ретроспективу и импульс, не останавливая мир. Три амбиции — размеренная, метеор и наследник — меняют реальные экономические условия: наследник берёт множитель 1,25 к наследству и бóльшую долю капитала (25 % вместо 20 %) в обмен на десятую часть квартального дохода, и эта цена записана в его описании на обоих языках. Карточки получили короткое раскрытие, чипы изменений со знаком, тональность исхода и живой пульс портфеля; уменьшенная анимация всё мгновенно снимает.

Поля сохранений 2.1 необязательны: профили 1.4.0 и 2.0.x загружаются с нейтральными значениями. Канонический русский текст и каталоги пользовательских данных не переименованы. В матрице механик 18 строк и 144 исполняемых ячеек. Гейт прошёл без единого прохода с ненулевым кодом за 5685 секунд: якорь доверия (5 файлов), компиляция локализации (1084 ключа, совпадающие строки ru/en), строгий компилятор (34 скрипта, 49 категорий), 49 headless и 50 рендерных кейсов на русском и английском, четыре экспорта, девять нативных прогонов (три победы, три поражения, три отказа публичной сборки от верификатора), 100 из 100 сеяных циклов со 100 различными финалами, совместимость профилей 1.4.0/2.0.x и соук 1817,032 с с 84 циклами, 1333 контрольными точками, плоскими счётчиками объектов и ростом памяти 2 140 160 Б при допуске 5 224 980 Б. Балансный свод (112 жизней, 1214,5 с) не выявил доминирующей стратегии. Производительность против базы 2.0.2 на этом хосте: медиана кадра 16,665 мс против 16,675 мс, p95 17,272 мс против 17,263 мс, готовность панели 528 мс против 545,5 мс при разбросе самой базы в 159 мс. Визуальная приёмка переснята на `e9b0256`: 66 кадров галереи и 12 кадров ряда амбиций в обеих локалях и при обоих разрешениях. Тесты не заменяют ручное прохождение и прослушивание и не доказывают отсутствие всех возможных дефектов.

Windows x64; Android-артефакты опущены; EXE без Authenticode; офлайн-защита не является DRM.
