**REVALIDATION REQUIRED:** the new birth-lottery/UI commit `c90d385ea965c8b01886ae03ea155afdccce6159` was merged after the earlier candidate QA. Receipts below describe the prior runtime until the new gate replaces them. No patch release is authorized yet.

# Heirs of Fortune 2.0.1 — acceptance certificate

Date: 2026-10-28 (Europe/Moscow). Automated Windows runtime checks accepted within the recorded scope. Final publication requires the external `release-gate.json` to report 100%; remote download verification is recorded after publication. Owner play/listening acceptance remains outstanding.

Runtime/export source: `2ca971ba27d78a931d792912d45bdb8bf4245537`. Full-suite source: `2ca971ba27d78a931d792912d45bdb8bf4245537`. Later documentation or test-only changes must retain byte-identical shipping source/assets; the final gate records this comparison. This certificate supersedes the earlier negative certificate for this patch only; old tags, assets and failure records remain unchanged.

| Phase | Result and evidence |
|---|---|
| F1 Content | PASS: complete campaign/life route, victory and defeat; promise/mechanics matrices and contracts. |
| F2 EN/RU | PASS: 53 Godot cases per locale, canonical copy and localization checks; `acceptance-2.0.1/suites.json`. |
| F3 Art/UI | PASS within retained stylized presentation: 40 actual frames inspected; `acceptance-2.0.1/visual-review.json`, new press set. |
| F4 Audio | PASS: exact provenance hashes, four distinct moods, finale cues, channels, durations, loops and independent controls. Silent QA is not human listening approval. |
| F5 Integrity | PASS: signed bounded saves, atomic backup/recovery, critical data anchoring, encrypted public pack and physically excluded private verifier; pack/native/source contracts. |
| F6 Mechanics | PASS: 50 distinct completed seeded routes; matrix assertions; no unexplained errors or integrity warnings. |
| F7 Acceptance | PASS: bilingual suites, 3 consecutive native victories plus defeat, legacy read/write round-trips and tamper rejection, 1850.625s measured normal soak with 69 complete loops. |
| F8 Distribution | Required external gate: clean synchronized main, shipping-byte parity, CI, licenses/secrets, exact ZIP+sums, immutable prior releases; fresh remote `sha256sum -c` after publication. |

## Exact public binaries

EXE SHA256: `6603b8264254ad943e5a5c9b81ffde5d6d044f079e8cdeb598b86f9b87dde395`. PCK SHA256: `08c295cff1e6eba128cd7f1bde805eb81ccf61cc8804b45df359a432d4f6d2d7`. The final ZIP checksum is stored beside its exact filename in the release sums file; a ZIP cannot embed its own final checksum.

## Scope and limitations

The normal soak has flat unloaded-cycle engine object/resource/node counts and zero orphans. Operating-system allocator variation is measured, not described as literal zero-byte growth. Old failed attempts remain evidence; they are not counted as passes. Public Exit/window-close/save-retry paths have actual-engine regressions. A desktop-control attempt produced an incorrect capture, and a later attempt showed a locked desktop. Both were stopped without blind input and are not counted as passes. Scripted gallery endings are explicitly labelled. Automated checks are finite and do not replace a human playtest or listening review.

Portable EXEs are not Authenticode signed. Android/emulator and store certification are outside this Windows release. Offline integrity resists ordinary corruption/editing but cannot prevent an owner from patching a local binary. The custom native template necessarily contains the pack-decryption key; encryption is not invulnerable DRM. No secrets or private profiles are distributed as loose files.

After the gated release and the five owner checks in [HANDOFF](HANDOFF.md), this edition may be announced and distributed within these limits.
