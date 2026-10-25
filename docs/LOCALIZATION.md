# Bilingual presentation

585 nonempty keys in identical editable `key,ru,en` CSV catalogs compile to export-safe JSON. The runtime owns its own language signal and first-run system suggestion; the intro and settings expose a real selector. A confirmed selection persists independently of game progress.

Canonical Russian event titles, business/origin identifiers and choice callbacks remain stable for existing authenticated saves. Extra bilingual fields in event data are presentation metadata. Native controls keep canonical source copy; a scripted Godot Translation translates the rendered message, including formatted templates and compact choice fragments, without rerolling any event or mutating balances/RNG. Custom dashboard drawing uses the same resolver. Russian display formats decimal/grouping separators without touching serialized numbers. Source UI copy references catalog keys.

Full English and Russian rendered suites pass, including all93 native choice layouts, parity, live-state/RNG invariance, persistent language and Cyrillic glyphs. The English visible-string audit covers every event and major menu. TranslationServer outlives autoload Nodes: registered resources are explicitly detached in `_exit_tree`; a reproduced shutdown access violation is fixed and fresh-profile coverage exits normally.

Master/Music/SFX/UI are independent real buses with bounded persistent controls. Legacy authenticated dynasty settings default the two new levels; no save schema or user-data directory is renamed.
