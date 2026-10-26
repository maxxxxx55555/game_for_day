# Localization source audit — v2 F2

Catalog: 598 keys in each of RU and EN. Both editable CSV files contain identical keyed rows. Compilation validates nonempty values and placeholder parity. The source audit rejects missing literal keys, unkeyed Cyrillic model/UI copy and nonempty hardcoded scene labels. Blank scene controls are populated by localized _ready handlers before display. Native language names remain readable regardless of the active language. English product brands and standard input symbols are deliberate identifiers.

First launch suggests the system language, offers an explicit selector and persists confirmation. Live switching preserves the existing scene and gameplay state. Body/heading fonts are checked for Cyrillic, ё, punctuation and currency symbols. Decorative legacy emoji are preserved in canonical Russian content but omitted by the concise presentation layer; this avoids relying on an OS color-emoji font.

All remaining model copy uses existing catalog keys; no saved event IDs, event ordering or schema changes are part of this extraction. QA route title matching is nonvisible diagnostic code; its public-build exclusion is an independent F5 requirement.

The F1 suite inventory was corrected from an inherited estimate: actual executed case logs are authoritative. Current default source case count: 27. Final v2 protocol evidence is generated after all later phases.

The immutable v1.4.0 fixture records255 unique Russian literals from original Main/GameManager/ChoiceCopy source and16 ordered external events, with tag commit/source hashes. test_copy_contract.py requires exact original Russian values and the same ordered event data/deltas after removing added translation metadata. test_canonical_model.gd checks all four original birth identities and the existing business-name read API in both languages. test_choice_sweep.gd verifies title/detail translation for every real decision. The former ACTIONS table remains removed.
