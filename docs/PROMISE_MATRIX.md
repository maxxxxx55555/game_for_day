# Heirs of Fortune: promise-to-edition matrix

The older design documents contain a much larger roadmap. This matrix indexes every substantive non-code line, including duplicated/extended design-book sections. It distinguishes actual edition systems from excluded roadmap details. Mandatory v2 improvements are included work and must pass their separate phase gates. A historical partial promise is never silently described as fully implemented.

[Complete verbatim inventory](PROMISE_MATRIX.json). 40 paragraph/list/table entries. Sources and hashes are recorded; each group links to real engine tests. Final F7 logs determine test status.

| Original section | Status | Current edition / evidence | Explicit exclusions |
|---|---|---|---|
| 0 | implemented | Current edition: original event IDs/order, 93 real decisions, 192 weighted country birthplaces, quarterly business/markets/currencies/inflation, grants, dynasty, endings and settings. [Test](../tests/test_gameplay.gd) | No multiplayer/live markets/real-money ads or store-production signing |
| 1 | implemented | Keyed bilingual presentation preserves canonical Russian serialized text and action callables. [Test](../tests/test_localization.gd) | — |
| 2 | implemented | Concise real choice cards, costs/chances in details, native hitboxes/focus and responsive portrait layouts. [Test](../tests/test_choice_sweep.gd) | — |
| 3 | implemented | Dark ledger theme, country card/dashboard, illustrated finales, sound, compatibility and current release gate. [Test](../tests/test_premium_ui.gd) | — |

The same exclusions are visible from the README edition-scope section. These exclude additional roadmap features, not broken accessible controls. No button advertises an excluded feature. Both public-history and creator-license bytes are preserved.

## Current 2.0.1 country update

The preserved upstream country update replaces four legacy origins with 192 weighted birthplaces. The dashboard now uses a country card and a dark ledger layout; the four former portrait files remain archived assets rather than active dashboard presentation. Historical quoted promises remain unchanged; the JSON edition-scope entries identify these superseding behaviors. Legacy profiles preserve their progress and receive neutral defaults for the optional birth fields.
