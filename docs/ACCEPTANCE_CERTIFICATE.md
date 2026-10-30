# Heirs of Fortune 2.1.0 — acceptance certificate

Date: 2026-10-30 (Europe/Moscow). Automated Windows runtime checks accepted within the recorded scope. The publication gate ran on a clean tree at the export commit and reported PASS for every step; remote download verification is recorded after publication. Owner play/listening acceptance remains outstanding.

Runtime/export source: `807ba09c551134c76f23b4167ab7b5783dd7199e`. Engine `4.7.stable.official.5b4e0cb0f`, GL Compatibility, portrait 720x1280. Documentation-only commits may follow the tagged commit; anything that ships in the PCK is frozen at the source above and the packager refuses a mismatch. This certificate covers the 2.1.0 edition; older tags, releases and failure records remain unchanged.

| Phase | Result and evidence |
|---|---|
| F1 Content | PASS: complete campaign/life route, victory and defeat; 40 promise-matrix entries with explicit edition scope; 18-mechanic matrix with 144 executable cells. |
| F2 EN/RU | PASS: 49 headless and 50 rendered Godot cases per locale with zero failures; 1084 localization keys; `ru.csv` and `en.csv` rows identical and the committed catalogue is their compiled form. |
| F3 Art/UI | PASS within the recorded presentation scope: 66 gallery frames in four labelled contact sheets plus 12 ambition-row frames re-rendered at `e9b0256` in both locales and both acceptance resolutions; `acceptance-2.1.0/visual-review.json`; press set in `press/v2.1.0`. |
| F4 Audio | PASS: exact provenance hashes, four distinct moods, two finale cues, channels, durations, loops and independent controls; nine exported-binary audio lifetimes inside the native runs. Silent QA is not human listening approval. |
| F5 Integrity | PASS: signed bounded saves, atomic backup/recovery, critical-data anchoring over 5 files verified before the run, encrypted public pack and physically excluded private verifier; three exported guards refuse the verifier with exit 64. |
| F6 Mechanics | PASS: 100 of 100 seeded complete cycles, seeds 101–200, 100 distinct final states; matrix assertions executed in both locales; no unexplained errors or integrity warnings. |
| F7 Acceptance | PASS: bilingual suites, three consecutive exported victories plus three exported defeats, 1.4.0 and 2.0.x legacy read/write round-trips and tamper rejection, and a 1,817.032 s rendered soak with 84 complete cycles, 1,333 checkpoints, zero failures, flat engine counts and memory growth 2,140,160 B against a 5,224,980 B allowance. |
| F8 Distribution | Clean synchronized `main`, shipping-byte parity between the export commit and the packaged sources, hosted CI, license/secret scans, exact ZIP plus versioned sums, immutable prior releases; fresh remote `sha256sum -c` recorded after publication. |

## Exact public binaries

EXE SHA256: `000b0eda79d7fa463a1e0e9ff64ebcfd976ad11b7fddd07dcccc01319e0fead9` (94,037,672 bytes). PCK SHA256: `35ed80d81ef2b22712115af74ca0b99702c037536812f809020242f453652ca1` (22,790,300 bytes). Both were produced from the same custom release template `a82cbeedcf7edb62d974ae6875b3dddb956ad2a0d0b430cf9b772fa39d670905`. The private QA pair (`881cc5b198fd5bdf63431ce48a5be9a4c1007abb5687412d25db1e7356515c43` EXE, `876e142edf86972cb29a7ea40157e2cb4433cfa006ea5b8acbc2de4ab653064c` PCK) exists only on the build host and is excluded from the public archive. Archive `HeirsOfFortune-Windows-2.1.0.zip` (85,736,652 bytes) SHA256: `c7199222573d17c8996d8774ffdd6238feef240753eaf803b137eba38b456226`; its sums file `HeirsOfFortune-SHA256SUMS-2.1.0.txt` (99 bytes, SHA256 `e0ec84e1ce0a84715151e86f740b72a768c317242b3952bcb07be14dc5bfd782`) names that exact filename. A ZIP cannot embed its own final checksum, so the archive carries the acceptance receipts as committed at packaging time and the receipts that describe the archive itself land in the repository immediately after it.

## Scope and limitations

The soak is a finite stability review at a ~350 MB plateau: engine node/resource/object counts are exactly flat with zero orphans, and operating-system allocation variation is measured against a scaled allowance rather than described as literal zero-byte growth. The balance sweep runs two scripted policies over four birth origins and three seeds per variant, so it measures the shipped knobs and not every possible player policy. Old failed attempts remain evidence and are not counted as passes. Gallery endings and dynasty rows are explicitly labelled as driver-seeded. QA harnesses share the real user-data profile with the game, so save-writing harnesses and suites are never run concurrently. Finite automated checks do not replace a human playtest or listening review.

Portable EXEs are not Authenticode signed. Android/emulator and store certification are outside this Windows release. Offline integrity resists ordinary corruption and editing but cannot prevent an owner from patching a local binary. The custom native template necessarily contains the pack-decryption key; encryption is not invulnerable DRM. No secrets or private profiles are distributed as loose files.

After the gated release and the five owner checks in [HANDOFF](HANDOFF.md), this edition may be announced and distributed within these limits.
