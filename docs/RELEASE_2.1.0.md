# Heirs of Fortune 2.1.0 — Legacy & Chains

Status: **release candidate, not yet published.** This note records the intended 2.1.0 scope. No 2.1.0 ZIP, tag or GitHub Release is published until the publication gate, fresh bilingual/native evidence and the owner checks pass.

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

The mechanics matrix now maps 18 mechanics and 144 executable cells, including [chains](../tests/test_chains.gd), [dynasty progression](../tests/test_dynasty_progression.gd) and [card feel](../tests/test_card_feel.gd). On 2026-10-29 the 49-case headless suite and the 50-case rendered suite passed in both RU and EN in this workspace, including the strict compiler, deterministic playthrough, balance routes, save compatibility and the three new suites. Export and native artifacts, the seeded soak and the owner checks remain open until the gate run reports PASS; their exact logs and artifact hashes belong to the publication gate. Finite automated tests do not replace owner play/listening checks and do not prove the absence of every possible defect.

## Limits

Windows x64 only; Android artifacts are omitted. The executable is not Authenticode signed. Offline tamper evidence makes modification harder but is not DRM. No AAA-scale or "no bugs" claim is made. Publication requires the 100% gate; until then the latest published release, 2.0.1, remains current.

## Русский

Версия 2.1.0 «Наследие и нити» — **кандидат, а не публикация**. ZIP, тег и GitHub Release появятся только после публикационного гейта, свежих двуязычных и нативных проверок и пяти проверок владельца; до этого актуальным остаётся опубликованный релиз 2.0.1 (кандидат 2.0.2 проверен в исходниках, но не был помечен тегом и не публиковался).

Восемь «нитей судьбы» из панели династии живут в двух звеньях: выбор запоминается флагом, возвращается через пять кварталов с точной цитатой и получает вариантную развязку; завершённая нить даёт импульс и записывается один раз. Панель династии содержит журнал, восемь постоянных перков за 4–15 очков, нити, зал славы на двенадцать жизней и восхождение на пять уровней NG+, которое усиливает инфляцию, волатильность и сложность. Вехи в 18, 25, 35, 50 и 65 лет показывают ретроспективу и импульс, не останавливая мир. Три амбиции — размеренная, метеор и наследник — меняют реальные экономические условия. Карточки получили короткое появление, чипы изменений, тональность исхода и живой пульс портфеля; уменьшенная анимация всё мгновенно снимает.

Поля сохранений 2.1 необязательны: профили 1.4.0 и 2.0.x загружаются с нейтральными значениями. Канонический русский текст и каталоги пользовательских данных не переименованы. В матрице механик 18 строк и 144 исполняемых ячейки. 29 октября 2026 года headless-набор из 49 кейсов и рендерный набор из 50 кейсов прошли на русском и английском, включая строгий компилятор, детерминированное прохождение, баланс, совместимость сохранений и три новых набора. Экспортные и нативные артефакты, сеяный прогон и проверки владельца остаются открытыми до PASS публикационного гейта; их точные логи и хеши принадлежат гейту. Тесты не заменяют ручное прохождение и прослушивание и не доказывают отсутствие всех возможных дефектов.

Windows x64; Android-артефакты опущены; EXE без Authenticode; офлайн-защита не является DRM. Публикация возможна только при 100% гейта.
