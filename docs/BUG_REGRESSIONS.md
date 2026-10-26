# F6 regression work

The source runner passes41 Godot cases in each of English and Russian after these fixes. This is an intermediate source checkpoint; the full v2 release gate remains open.

| Defect | Trigger and correction | Regression |
|---|---|---|
| Reentrant event choice | A persistence listener could activate another choice before the first transaction finished. A guarded synchronous choice transaction accepts one event; later independent clicks still work. | `tests/test_choice_reentry.gd` |
| Destroyed settings listener | A locale lambda retained a freed picker and left live row labels stale. The node-bound callback disconnects with its owner and updates the current labels. | `tests/test_settings_lifetime.gd` |

`tests/test_navigation_matrix.gd` walks intro/birth/perk plus10 live EN/RU menu states, keyboard focus, Back and resize. `tests/test_qa_seed.gd` validates private/source fuzz seeds. The complete-life and soak drivers vary real choices/markets and remain excluded from public exports.

`tests/fixtures/protected-v1.4.0-current_life.cfg` is the byte-identical original1.4 protected profile with provenance. Its installation key is private and never included in source or release assets. Legacy fractional dollar amounts migrate to the documented nearest cent; progression and protected input bytes are preserved.

Preliminary live soak:84 complete lives,1309UI/save/locale checkpoints,1804.043seconds of gameplay; no script errors. Raw process CPU/memory data are retained in the release evidence. Allocation variation is measured, not described as exactly zero. Final frozen-source fuzz, strict compiler checks, mechanics matrix and F7 acceptance remain pending.

- `tests/test_chart_path_regression.gd`: rendered quote history must contain its gold price path, not only axis labels. A typing change mistakenly treated the packed-array append error flag as a success flag; the regression recorded0 accent pixels before the correction and passes after it. The source suite includes this rendered case. Final frozen suites and soak remain required.

## Exact floating-point profile restoration

The native decimal parser can round a valid double by a few ULPs. `test_profile_contract.gd` exposed this during complete-state restoration; `test_config_float_precision.gd` use byte-constructed doubles and full-precision hashes. Current authenticated envelopes add bounded exact float patches inside the signed body. Restoration is atomic, accepts only existing numeric leaves and parser-sized differences, and uses no object deserialization. Schema4 and previous protected profiles remain supported. `test_exact_float_limits.gd` rejects malformed, duplicate, nonfinite and oversized patches without mutation.

The full source runner now imports first, then compiles every shipping GDScript with all49 warning categories promoted to errors before gameplay tests. It restores project.godot bytes even on failure. External QA drivers are checked separately by the gameplay suite.

## Pending-event test identity

The complete-profile test compares narrative fields and exact RNG across scene recreation, then requires live callbacks owned by the new screen. Lambdas capture their owning scene and their object identities are deliberately different after reload; comparing those identities was an invalid test oracle, not lost player progress. EN/RU narrative and RNG behavior remain checked.

`test_mechanics_inputs.gd` adds real rapid-input and boundary coverage for the edition systems; it does not grant resources in the full-cycle release verifier. Large boundary fixtures in this isolated test intentionally exercise caps and rejection.

## Native verifier deleted with the completed life screen

`tests/test_native_verifier_lifetime.py` runs the actual private Windows verifier and requires victory plus a timely clean exit. RED reached rank1 after154 turns but timed out after45seconds: QARouter parented the verifier to Main, then the route queued Main for deletion before its cleanup and exit calls. The private verifier now belongs to the scene-tree root and survives its UI cleanup. Source standalone drivers already used that root owner; normal gameplay, money, saved state and event routing are unchanged. Fresh complete source suites and exact native exports are rerun after this ownership fix.

## Portable promise and inherited-license byte contracts

A fresh Git checkout normalized the promise documents while their inventory recorded Windows line endings. Explicit LF rules and unchanged verbatim lines now make those digests portable. The pre-release README inventory is retained in its own immutable snapshot where needed. Protected profile fixtures, creator licenses and provenance use opaque Git attributes. The inherited-license test derives its expected bytes from the original published1.4.0 Windows archive. RED identified six line-ending-only changes in inherited font/engine notices; their original published bytes are restored. No license wording or game behavior changed. Fresh source and native acceptance follows the packaging correction.
