# Heirs of Fortune clear play implementation archive

Historical 1.4.0 plan; superseded by the current release.

## Action cards and concise events

Files: scripts/ui/ChoiceCopy.gd, ChoiceCard.gd; scripts/Main.gd; tests/test_clear_play.gd.
- [ ] Add a real-scene test that selects known event labels, asserts compact title/separate cost+chance, focuses/clicks the original Button and checks exactly one ordinary turn.
- [ ] Run `work/run_godot.py game_for_day clarity-red --headless --script res://tests/test_clear_play.gd`; observe missing card labels/notice.
- [ ] Implement `ChoiceCopy.parts(raw:String)->Dictionary` and native Button view, preserving raw full text and callbacks. Separate outcome notice from current event; shorten intro/market/business labels.
- [ ] Run focused test with real GPU at 540x960 and 360x800; inspect bounds, all effects, save restoration and captures. Commit with real evidence.


## Presentation and validation
Rounded satin control surfaces retain native hitboxes, focus and callbacks. Validate all 93 decisions, native victory/loss, protected saves and Android touch/lifecycle. Prior immutable release evidence remains available.
