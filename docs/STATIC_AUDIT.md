# Static shipping audit

Orphan .uid/.import sidecars: 0. Unused literal assets after glTF dependency resolution: 0. Shipping TODO/FIXME/placeholder/lorem markers: 0. Non-engine function candidates without references: 0.

Native callbacks retained:
- `scripts/ExchangeMarket.gd::_init`: Godot RefCounted constructor: exchange-market seeded setup.
- `scripts/autoload/LocalizationManager.gd::_exit_tree`: Godot Node lifecycle override: locale signal/resource teardown.
- `scripts/localization/DisplayTranslation.gd::_get_message`: Godot Translation virtual: canonical display lookup.
- `scripts/security/BuildIntegrity.gd::_enter_tree`: Godot Node lifecycle override, first-autoload trust validation.

The graph includes scripts, scenes, resources, project autoloads, tests and relative glTF buffer/image dependencies. Identifiers found only once are reviewed explicitly above. Dynamic engine hooks are retained; unreferenced application helper methods were removed. This census complements strict compilation and runtime suites and does not establish proof of every possible execution.

CI: `.github/workflows/shipping-warnings.yml` imports the project and invokes the same 49-category strict audit on main pushes and pull requests, using a pinned checkout commit and a SHA256-verified Godot 4.7 download. The historical 2.0-era run recorded below covered 27 shipping scripts; the current tree carries 38 shipping scripts and the same job is green on the gated commit `466a8c1` and on every documentation-only commit after it.
