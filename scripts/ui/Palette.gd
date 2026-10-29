extends RefCounted
## Two complete skins. Every surface, rule and text colour in the game resolves
## through here, so switching the theme is one redraw instead of a second
## stylesheet. Dark is ink and champagne; light is warm paper and bronze.

const DARK:String= "dark"
const LIGHT:String= "light"

static func is_dark() -> bool:
	return GameManager.theme_mode != LIGHT

static func mode() -> String:
	return LIGHT if GameManager.theme_mode == LIGHT else DARK

## Page background behind every panel.
static func ink() -> Color:
	return Color("0a0f16") if is_dark() else Color("f3eee2")

## Standard panel surface.
static func surface() -> Color:
	return Color("111a25") if is_dark() else Color("fbf7ee")

## Slightly lifted surface for popups and nested cards.
static func raised() -> Color:
	return Color("16212e") if is_dark() else Color("ffffff")

## Recessed surface for the event panel and progress tracks.
static func deep() -> Color:
	return Color("0d151f") if is_dark() else Color("ebe4d4")

## Hairline borders.
static func rule() -> Color:
	return Color("26313f") if is_dark() else Color("d8cdb6")

static func rule_soft() -> Color:
	return Color("1d2733") if is_dark() else Color("e4dbc8")

## Primary reading colour.
static func text() -> Color:
	return Color("ede7da") if is_dark() else Color("1b2027")

## Secondary labels and captions.
static func muted() -> Color:
	return Color("8a97a6") if is_dark() else Color("6f6a5e")

## The single accent. Champagne on ink, bronze on paper.
static func accent() -> Color:
	return Color("c8a96a") if is_dark() else Color("8a6a2f")

static func accent_deep() -> Color:
	return Color("8c7442") if is_dark() else Color("6d5324")

## Warnings and failure states.
static func alert() -> Color:
	return Color("c9736a") if is_dark() else Color("a8443c")

## Unfilled portion of a meter.
static func track() -> Color:
	return Color("1e2a38") if is_dark() else Color("ddd4c1")

## Drop shadow under elevated surfaces.
static func shadow() -> Color:
	return Color(0.0,0.0,0.0,0.45) if is_dark() else Color(0.16,0.12,0.06,0.14)

## Button surface suffix: the SVG set that matches the current skin.
static func button_variant() -> String:
	return "" if is_dark() else "-light"

## Blend helper for tinted bands over the current surface.
static func mix(base: Color, tint: Color, amount: float) -> Color:
	return base.lerp(tint, clampf(amount, 0.0, 1.0))
