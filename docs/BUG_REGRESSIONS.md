# F6 regression work

The source runner passes41 Godot cases in each of English and Russian after these fixes. This is an intermediate source checkpoint; the full v2 release gate remains open.

| Defect | Trigger and correction | Regression |
|---|---|---|
| Reentrant event choice | A persistence listener could activate another choice before the first transaction finished. A guarded synchronous choice transaction accepts one event; later independent clicks still work. | `tests/test_choice_reentry.gd` |
| Destroyed settings listener | A locale lambda retained a freed picker and left live row labels stale. The node-bound callback disconnects with its owner and updates the current labels. | `tests/test_settings_lifetime.gd` |

`tests/test_navigation_matrix.gd` walks intro/birth/perk plus10 live EN/RU menu states, keyboard focus, Back and resize. `tests/test_qa_seed.gd` validates private/source fuzz seeds. The complete-life and soak drivers vary real choices/markets and remain excluded from public exports.

`tests/fixtures/protected-v1.4.0-current_life.cfg` is the byte-identical original1.4 protected profile with provenance. Its installation key is private and never included in source or release assets. Legacy fractional dollar amounts migrate to the documented nearest cent; progression and protected input bytes are preserved.

Preliminary live soak:84 complete lives,1309UI/save/locale checkpoints,1804.043seconds of gameplay; no script errors. Raw process CPU/memory data are retained in the release evidence. Allocation variation is measured, not described as exactly zero. Final frozen-source fuzz, strict compiler checks, mechanics matrix and F7 acceptance remain pending.
