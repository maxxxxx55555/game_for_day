# Heirs of Fortune 2.0.1 — acceptance certificate

Date: 2026-10-28 (Europe/Moscow). Automated Windows runtime checks accepted within the recorded scope. Final publication requires the external `release-gate.json` to report 100%; remote download verification is recorded after publication. Owner play/listening acceptance remains outstanding.

Runtime/export source: `bd25752d9b4c6948bb1f9fa18f04779da10acdd9`. Full-suite source: `bd25752d9b4c6948bb1f9fa18f04779da10acdd9`. Later documentation or test-only changes must retain byte-identical shipping source/assets; the final gate records this comparison. This certificate supersedes the earlier negative certificate for this patch only; old tags, assets and failure records remain unchanged.

| Phase | Result and evidence |
|---|---|
| F1 Content | PASS: complete campaign/life route, victory and defeat; promise/mechanics matrices and contracts. |
| F2 EN/RU | PASS: 55 Godot cases per locale, canonical copy and localization checks; `acceptance-2.0.1-birth/suites.json`. |
| F3 Art/UI | PASS within retained stylized presentation: 44 actual frames inspected; `acceptance-2.0.1-birth/visual-review.json`, new press set. |
| F4 Audio | PASS: exact provenance hashes, four distinct moods, finale cues, channels, durations, loops and independent controls. Silent QA is not human listening approval. |
| F5 Integrity | PASS: signed bounded saves, atomic backup/recovery, critical data anchoring, encrypted public pack and physically excluded private verifier; pack/native/source contracts. |
| F6 Mechanics | PASS: 50 distinct completed seeded routes; matrix assertions; no unexplained errors or integrity warnings. |
| F7 Acceptance | PASS: bilingual suites, 3 consecutive native victories plus defeat, legacy read/write round-trips and tamper rejection, 1823.906s measured normal soak with 76 complete loops. |
| F8 Distribution | Required external gate: clean synchronized main, shipping-byte parity, CI, licenses/secrets, exact ZIP+sums, immutable prior releases; fresh remote `sha256sum -c` after publication. |

## Exact public binaries

EXE SHA256: `b57ba5c47522a95c1d197b26be9a4ac1bfc777a96612106b81c6b95f9eba5f78`. PCK SHA256: `87df971a2c885e223034e53eb657a8a352f333339344383447f0c1153d6a457e`. The final ZIP checksum is stored beside its exact filename in the release sums file; a ZIP cannot embed its own final checksum.

## Scope and limitations

The normal soak has flat unloaded-cycle engine object/resource/node counts and zero orphans. Operating-system allocation variation is measured, not described as literal zero-byte growth. For the finance run, a1.76MiB quarter-median private-memory increase was separately reviewed: the final six-minute median net was4096bytes across at least10 completed cycles, with flat engine counts. The original trend flag and explicit review/negative controls are preserved in the evidence. Old failed attempts remain evidence; they are not counted as passes. Public Exit/window-close/save-retry paths have actual-engine regressions. A desktop-control attempt produced an incorrect capture, and a later attempt showed a locked desktop. Both were stopped without blind input and are not counted as passes. Scripted gallery endings are explicitly labelled. Automated checks are finite and do not replace a human playtest or listening review.

Portable EXEs are not Authenticode signed. Android/emulator and store certification are outside this Windows release. Offline integrity resists ordinary corruption/editing but cannot prevent an owner from patching a local binary. The custom native template necessarily contains the pack-decryption key; encryption is not invulnerable DRM. No secrets or private profiles are distributed as loose files.

After the gated release and the five owner checks in [HANDOFF](HANDOFF.md), this edition may be announced and distributed within these limits.
