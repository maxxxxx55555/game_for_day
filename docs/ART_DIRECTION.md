# Heirs of Fortune — art direction

A quiet private office at the end of a rainy day. Keep the operator-selected city folio, authored victory/defeat illustrations. Their cool blue daylight and warm brass lamps are the visual anchor; dark ledger cards and warm, high-contrast type carry the decisions. The signature is a living ledger: capital settles gently while quotes show honest units and history, with simulation values already final.

## Palette and typography
- Smoked ink #14181D: page background; slate #2E4057: ledger surfaces.
- Raised slate #3E5C76: rules and focus edges; deep slate #1B2531: wells.
- Ivory #F1EEE7: primary foreground; muted #B8C2C4: secondary labels.
- Brass #C9A227: capital and legacy value; deep brass #A9871F: passive marks.
- Quiet green #7FB069: positive outcome; clay #C4614F: alert and harm.

### Skins after 2.1.0

The published 2.1.0 build paints the single palette above. Main now paints two skins from the same drawing code, resolved through `scripts/ui/Palette.gd` and documented token by token in [APPEARANCE.md](APPEARANCE.md): the dark skin keeps brass #C9A227, deep brass #A9871F, quiet green #7FB069 and clay #C4614F on ink #0A0F16 with panels at #111A25, and the light skin puts bronze #8A6A2F and #A8443C on warm paper #F3EEE2 with white popups. Meaning does not move with the theme: gold marks value, green marks gain, clay marks harm, and the switch changes presentation only — it is never written into a save.

Unbounded 600/700: display 24–32px and section headings only. Onest 400/500: body 19px, command 20px, compact meter/caption 13–15px, chart label 16px; capital 34px is the largest dashboard number, available cash 26px. These are the 644px ledger design units; dashboard scales to the 540×960 minimum window. Body line height 1.25 and display 1.1. A choice has a short 24px title, 20px detail and at least 92px height, recomputed from actual available width. Long canonical copy remains available in tooltips/accessibility and original Russian save text remains unchanged. Displayed strings omit emoji; legacy canonical Russian content keeps its historical marks but the presentation layer strips them before rendering.

Currency plots show USD per one named foreign unit, real high/low quotes to four decimals, the current sample and the number of preceding recorded samples. A sample is not labelled a quarter: extra actions and speed settings make that claim inaccurate. A one-sample or flat series remains honestly labelled. 180ms capital interpolation is presentation-only, interruptible and exact at settlement; reduced motion also snaps a currently running tween. Decision/panel arrival uses the same restrained timing; delta chips echo only the applied model delta, and the dashboard pulse plots the last 24 saved market samples. No bouncing coins, simulated profit sparkles or always-running ambient UI animation.

Face/portrait generations share the same restrained palette; no added text is baked into narrative illustrations. Do not tint a rainy ending to match a sunlit victory: their deliberate mood difference is retained while material, grain and lighting quality stay coherent. The icon's H monogram must remain distinguishable at 16×16; remove ornament only if that fails inspection.

## Controls, layout and motion
Use an eight-point layout grid: 8/16/24/32/48/64px; one-pixel optical dividers and two-pixel focus rings are deliberate exceptions. Panels use 8px radii; the authored button nine-slice uses 12px corners. Buttons have distinct normal/hover/pressed/disabled textures, 24px horizontal padding, 12px vertical padding and a minimum 48px pointer/touch target. Disabled text stays readable and its tooltip explains the unmet condition. Focus is a two-pixel bright outline, never color alone; Tab follows screen order, Escape/Back returns to the previous screen. Icon strokes use 1.75px at 24px with round caps and joins; all seven glyphs in assets/ui/icons — market, business, grant, dynasty, settings, globe and theme — are repository-authored vectors that differ by shape; the audit samples every one of them, so a new icon has to meet the same rule rather than be exempted from it.

Transitions last 120–240ms: 180ms card reveal and value settlement, 220ms chip fade, 120ms ease-in for dismissal where a delayed exit is appropriate. Reduced motion snaps. Presentation tweens never change simulation, RNG, cooldowns or saved balances. Avoid perpetual UI shimmer. Existing instant close/back remains instant for predictable navigation. Do not resize interactive targets during hover.

Text uses sentence case, short action verbs and plain cost/consequence details. Keep fuller directions in an accessible tooltip/help surface. No decorative implementation prose. Line height: body 1.25, captions 1.2, display 1.1; avoid forced multi-line display titles. Check longest English and Russian strings on the minimum viewport before accepting a changed screen.

## Asset curation and provenance
Keep source provenance visible in credits and asset metadata. Review every raster/vector for faces/hands/teeth, stray text, perspective, lighting, palette, clipping and UI legibility. Technical normal/roughness/UV maps are reviewed for their intended material role, not as displayed paintings. Generated art is curated; it is never relabelled as photographed or hand-painted by a human. Existing inherited license bytes are immutable. See ASSET_REVIEW.json for individual file decisions and the external release evidence for contact sheets and integrated gallery acceptance. Inventory acceptance does not replace final rendered-screen acceptance.

## Sound style
Interface feedback stays below the music and action effects. Focus is a brief dry cue at −24dB, rate-limited to 80ms; it never follows passive pointer hover. Normal actions get one short click only when their handler has not already emitted purchase/sale/upgrade/crafting/error feedback. Unavailable actions use a subdued 220ms two-tone cue at−10dB; disabled controls stay quiet and explain their condition in text. Repeated short effects vary pitch 0.97–1.03 with a separate cosmetic RNG. UI gain remains independent, and forced QA mute always wins. Closing a control retains its accepted-action acknowledgment without retaining the destroyed node.

The existing four distinct mood compositions and two 20-second musical finales retain their recorded Gemini/Lyria provenance and original mastered files. The new 80ms focus and 220ms unavailable cues are repository-authored synthesis, CC0; no third-party recording or music-generation claim is attached. assets/audio/interface-provenance.json records exact WAV and generator hashes. See AUDIO_FEEDBACK.md for action coverage and regression evidence.

## Country birth refinement

The dashboard identifies the actual country without an unrelated portrait or duplicated region line. The dedicated birth card carries country, region, population share, life expectancy and starting capital. Country names translate before casing; long names fit the measured line, and rules never cross statistic glyphs. Country income influence converges by age 52; this is a game balance rule.
