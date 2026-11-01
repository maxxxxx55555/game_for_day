# Static shipping audit

Orphan .uid/.import sidecars: 0. Unused literal assets after glTF dependency resolution: 0. Shipping TODO/FIXME/placeholder/lorem markers: 0. Non-engine function candidates without references: 0.

Native callbacks retained:
- `scripts/ExchangeMarket.gd::_init`: Godot RefCounted constructor: exchange-market seeded setup.
- `scripts/autoload/LocalizationManager.gd::_exit_tree`: Godot Node lifecycle override: locale signal/resource teardown.
- `scripts/localization/DisplayTranslation.gd::_get_message`: Godot Translation virtual: canonical display lookup.
- `scripts/security/BuildIntegrity.gd::_enter_tree`: Godot Node lifecycle override, first-autoload trust validation.

The graph includes scripts, scenes, resources, project autoloads, tests and relative glTF buffer/image dependencies. Identifiers found only once are reviewed explicitly above. Dynamic engine hooks are retained; unreferenced application helper methods were removed. This census complements strict compilation and runtime suites and does not establish proof of every possible execution.

CI: `.github/workflows/shipping-warnings.yml` imports the project and invokes the same 49-category strict audit on main pushes and pull requests, using a pinned checkout commit and SHA256-verified Godot 4.7 download. Local and hosted execution pass: 27 shipping scripts and 49 warning categories on the verified Godot 4.7 Ubuntu 24.04 runner at the time that audit was written (https://github.com/maxxxxx55555/game_for_day/actions/runs/40280278382 at `14a5f89f17bc559bbbff3088b864ddede572ffa4`). The same job has since been green on every commit of the 2.1.0 line, including the last code change `62c153b` (https://github.com/maxxxxx55555/game_for_day/actions/runs/41228424375), the gated export commit `b38e9df` with 38 shipping scripts (https://github.com/maxxxxx55555/game_for_day/actions/runs/41229903108) and the documentation-only HEAD published after the tag (https://github.com/maxxxxx55555/game_for_day/actions/runs/41287189896 at `7e83d42`). The final release HEAD receives its own hosted run.
