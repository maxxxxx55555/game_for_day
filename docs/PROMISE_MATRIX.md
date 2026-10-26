# Heirs of Fortune: promise-to-edition matrix

The older design documents contain a much larger roadmap. This matrix indexes every substantive non-code line, including duplicated/extended design-book sections. It distinguishes actual edition systems from excluded roadmap details. Mandatory v2 improvements are included work and must pass their separate phase gates. A historical partial promise is never silently described as fully implemented.

[Complete verbatim inventory](PROMISE_MATRIX.json). 38 paragraph/list/table entries. Sources and hashes are recorded; each group links to real engine tests. Final F7 logs determine test status.

| Original section | Status | Current edition / evidence | Explicit exclusions |
|---|---|---|---|
| 0 | implemented | Current edition: original event IDs/order,93 real decisions, four origins, quarterly business/markets/currencies/inflation, grants, dynasty, endings and settings. [Test](../tests/test_gameplay.gd) | No multiplayer/live markets/real-money ads or store-production signing |
| 1 | implemented | Keyed bilingual presentation preserves canonical Russian serialized text and action callables. [Test](../tests/test_localization.gd) | — |
| 2 | implemented | Concise real choice cards, costs/chances in details, native hitboxes/focus and responsive portrait layouts. [Test](../tests/test_choice_sweep.gd) | — |
| 3 | implemented | Authored theme, life-stage portraits, distinct finales, sound, compatibility and current release gate. [Test](../tests/test_premium_ui.gd) | — |

The same exclusions are visible from the README edition-scope section. These exclude additional roadmap features, not broken accessible controls. No button advertises an excluded feature. Both public-history and creator-license bytes are preserved.
