# Art and audio credits — cumulative, current edition 2.1.0

Original in-game illustrations: OpenAI image generation, created for this edition. Generation records and SHA-256 digests are in assets/art/*provenance.json.

Fonts: Manrope, Prata and Alegreya from Google Fonts, SIL Open Font License 1.1. Full notices are in assets/fonts/*-OFL.txt. Original download URLs and digests are in asset-sources.json.

Music: “Last Call at Three”, generated in Google Gemini / Lyria on 2026-10-24. Full prompt, original and mastered-file digests, terms and quiet-loop processing are recorded in assets/audio/music-provenance.json and LICENSE.md. Sound effects have separate CC0 provenance.

## 1.3 interface
Original scalable satin control surfaces. New OFL type families: Onest and Unbounded. Font notices and exact source digests accompany the assets.

## 2.0.0 soundtrack

Four mood recordings and two musical finale cues, generated using Google Lyria RealTime. Track names, prompts, original/mastered hashes and generated-output terms: assets/audio/music-provenance.json and SOUNDTRACK.md. Synthesized interface/game effects retain separate CC0 provenance.

## 2.0.0 application icons

Original project artwork authored for this release, without third-party image sources. The scalable `icon.svg` and raster `assets/ui/app-icon.png` form the application icon family.

- `icon.svg`: SHA256 `89b5a964e141d7ae66e6a7fbd13ce924cbe31f30fea27100f39bc948a89e5e49`.
- `assets/ui/app-icon.png`: SHA256 `c698dfd30aad44067387088eb00e4b1d2d7b9a48f7a723a41224c9dc6600015f`.

V2 art curation: docs/ART_DIRECTION.md and docs/ASSET_REVIEW.json. Narrative illustrations and their original generation provenance are retained. Prata display headings and Onest controls use the bundled licensed font files; currency plots and capital motion are repository UI code. Inherited third-party license files are retained unchanged.

Interface focus/unavailable cues: original profile-specific synthesis using tools/generate_audio.py, CC0-1.0; exact provenance is in audio/interface-provenance.json.

## 2.1.0 interface vectors

The 2.1.0 dynasty release adds no new generated imagery: no new bitmap illustration, photograph, texture or third-party icon set, and no audio. Everything new on screen is repository-authored vector geometry drawn in this repository and editable as text, with 1.75px strokes at 24px, round caps and joins per [art direction](../docs/ART_DIRECTION.md). The five section glyphs differ by shape, not by colour alone.

New icons in `assets/ui/icons/`:

- `market.svg`: SHA256 `f799d278cdef1f8e9be9521f4b3568b58a6c3f9ad98a25023681d8ec4f12545f`.
- `business.svg`: SHA256 `5135d4cc7bf9d4f66f915da85a7058a47892f8704246369a27f9ab1464a689cb`.
- `grant.svg`: SHA256 `9cd5f09c3fdba7a54dde29a16071798713976eaecadd4cbd3ce16e170c597004`.
- `dynasty.svg`: SHA256 `cde3ccff36e28c76247a6155bd40fbac60ff362ef17326c65be3306840ed03d9`.
- `settings.svg`: SHA256 `4722efcddb997ab1eaac22d3b31eb7b3c8a52d35782f2aab9c205910b4491a8e`.

Re-authored nine-slice control surfaces in `assets/ui/`:

- `button-normal.svg`: SHA256 `025ae522be6d0e8c582d5b700f339c61ad296088f2f28ec3797508b46b46a6bf`.
- `button-hover.svg`: SHA256 `117eab4276c2121e1fc6139628e41de2615e16f9f3a05f95fe7bca01e72ecf01`.
- `button-pressed.svg`: SHA256 `bfcc8dbace9afff113721ae23e9434121d0ee018749284f6c6cf52731cff952f`.
- `button-disabled.svg`: SHA256 `dd39654fe8cf2a96cc1fec2a352a2772bd49d72e0d6dc13b2697e0804d803a7d`.

The 2.1.0 press set is rendered from the shipping source at 720x1280 and is listed with per-file digests in [docs/press/v2.1.0/CAPTIONS.md](../docs/press/v2.1.0/CAPTIONS.md); those frames are engine captures, not retouched artwork, and the frames whose ledger rows are seeded by the capture driver are labelled as such. Narrative illustrations, the application icon family, the four mood recordings, the two finale cues and all inherited third-party license bytes are unchanged from the editions above.
