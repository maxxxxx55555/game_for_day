# Heirs of Fortune 2.0.1

## English

Normal Exit, window close and guarded QA rejection now wait for actual audio playback disposal before terminating. Save failures retain Retry/Stay/Discard, repeated accepted dialog callbacks cannot write twice, and private verifier cleanup remains reusable. Source test drivers drain audio explicitly and the runner rejects resource-leak warnings.

This patch repairs source-build reproducibility. Critical JSON and the compiled integrity manifest now agree with the committed LF files, and interface sound provenance records the canonical generator bytes. Ordinary Git checkout tests cover both autocrlf settings without metadata overrides, and run in CI and the full source suite. Existing trust, tamper, replacement-manifest, protected-save and license checks remain enforced.

Explicit LF rules for both localization CSVs preserve multiline canonical Russian copy on Windows.

The latest country-of-birth update is included: a weighted draw across 192 countries, country-specific initial capital, health, intellect, living costs and lifespan, with the income opportunity effect converging at age 52. The dark ledger interface shows the result in live English/Russian. Optional validated country/opportunity/lifespan save fields use neutral defaults for older profiles. Remaining content includes 31 events/93 choices, business progression, investments, EUR/GBP/JPY trading with a disclosed 0.35% spread each way, inflation, inheritance and illustrated victory/defeat. Live RU/EN presentation with 816 catalog keys, four mood compositions and two musical finales, independent audio levels, reduced motion, credits and protected 1.4.0 profiles remain available. No previous public tag or asset was replaced.

Extract all of `HeirsofFortune-Windows-2.0.1.zip` and run `HeirsOfFortune.exe`, keeping its PCK, notices and licenses beside it. Check the exact ZIP against `HeirsofFortune-SHA256SUMS-2.0.1.txt` with `sha256sum -c`. Back up the whole closed-game user-data directory, including its installation key, before upgrading. Private QA binaries and keys are not distributed.

Publication requires full rendered RU/EN source suites, real checkout/tamper/audio/license checks, 50 seeded complete routes, measured normal soak, three native verifier victories plus defeat, original protected-save compatibility, encrypted public/QA pack audit, reviewed galleries and exact-head CI. The release gate and acceptance report record actual results; historical results are not substituted for this patch's mandatory fresh checks.

Limits: Windows x64 offline edition, unsigned portable EXE, no Authenticode or store certification. Android artifacts are omitted under the documented unavailable-emulator fallback. Rendering remains stylized indie art. Finite testing does not guarantee zero possible bugs or prevent a device owner from modifying an offline game. Five owner play/listening/download checks remain a final human sign-off.

## Русский

Выход через меню и закрытие окна теперь дожидаются освобождения аудио. Повторные сигналы подтверждения не дублируют сохранения; Retry/Stay/Discard и коды отказа QA сохранены. Проверки больше не пропускают предупреждения об утечках ресурсов.

Исправлена воспроизводимая сборка из обычного Git-checkout: манифест данных, происхождение интерфейсных звуков и переносы строк локализации согласованы с исходными LF-байтами. Канонический русский текст и музыкальные записи сохранены. Включено обновление места рождения: взвешенный выбор среди 192 стран, стартовые условия и влияние на доход до 52 лет. Интерфейс переработан в тёмном оформлении; локализация RU/EN содержит 816 ключей. Новые поля сохранения строго проверяются, старые профили получают нейтральные значения.

Новый регрессионный тест проверяет обычную материализацию Git при обоих значениях autocrlf, без локальных обходных правил; он включён в CI и полный набор тестов. Проверки подмены данных, манифеста и сохранений сохранены. Старые опубликованные теги и файлы не заменяются.

Распакуйте весь `HeirsofFortune-Windows-2.0.1.zip` и запустите `HeirsOfFortune.exe`. Сверьте архив с `HeirsofFortune-SHA256SUMS-2.0.1.txt` командой `sha256sum -c`; перед обновлением скопируйте всю папку профиля с ключом установки. QA-сборки и ключи не распространяются.

Релиз публикуется только после полного гейта: RU/EN, маршруты победы/поражения, старые профили, 50 полных посевов, измеренная нагрузка, аудит зашифрованных пакетов, галереи и CI. Фактические результаты находятся в отчёте приёмки. Windows x64, офлайн; EXE без Authenticode. Android не выпускается, масштаб AAA и отсутствие любых возможных ошибок не заявляются. Ручные проверки владельца остаются обязательными.

## Verified Windows scope / Проверенный Windows-релиз

EN/RU: 55/55 Godot cases per locale; 50 completed distinct seed routes; 3 consecutive native victories and defeat; legacy save compatibility; measured normal soak 1823.906s. Full acceptance and owner checklist are in docs/ACCEPTANCE_CERTIFICATE.md and docs/HANDOFF.md.

Проверки EN/RU, 50 прохождений, три последовательные нативные победы, поражение и совместимость сохранений пройдены. Android и магазины не входят в релиз. EXE без Authenticode; ручное прослушивание и пять проверок владельца остаются обязательными перед анонсом.
