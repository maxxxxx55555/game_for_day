extends RefCounted
## Two complete skins. Every surface, rule and text colour in the game resolves
## through here, so switching the theme is one redraw instead of a second
## stylesheet. Dark is ink and champagne; light is warm paper and bronze.

const DARK:String= "dark"
const LIGHT:String= "light"

## Resolved through the tree, not by identifier: this module is compiled from
## FortuneTheme during autoload setup, before GameManager exists as a name.
static func theme_mode() -> String:
	var loop:MainLoop= Engine.get_main_loop()
	if loop is SceneTree:
		var root_window:Window= (loop as SceneTree).root
		if root_window != null:
			var manager:Node= root_window.get_node_or_null("GameManager")
			if manager != null:
				return str(manager.get("theme_mode"))
	return DARK

static func is_dark() -> bool:
	return theme_mode() != LIGHT

static func mode() -> String:
	return LIGHT if theme_mode() == LIGHT else DARK

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
	return Color("c9a227") if is_dark() else Color("8a6a2f")

static func accent_deep() -> Color:
	return Color("a9871f") if is_dark() else Color("6d5324")

## Positive movement and completed chains.
static func green() -> Color:
	return Color("7fb069") if is_dark() else Color("4f7a3a")

## Warnings and failure states.
static func alert() -> Color:
	return Color("c4614f") if is_dark() else Color("a8443c")

## Unfilled portion of a meter.
static func track() -> Color:
	return Color("1e2a38") if is_dark() else Color("ddd4c1")

## Drop shadow under elevated surfaces.
static func shadow() -> Color:
	return Color(0.0,0.0,0.0,0.45) if is_dark() else Color(0.16,0.12,0.06,0.14)

## Atmospheric backdrop: the tint that lifts the top of the page.
static func backdrop_top() -> Color:
	return Color(0.18,0.28,0.40,0.85) if is_dark() else Color(1.0,0.97,0.90,0.85)

## Atmospheric backdrop: the mid falloff between the lifted top and the page ink.
static func backdrop_mid() -> Color:
	return Color(0.10,0.15,0.24,0.28) if is_dark() else Color(0.99,0.95,0.86,0.30)

## Atmospheric backdrop: the transparent foot that lets the page ink show through.
static func backdrop_base() -> Color:
	return Color(0.04,0.06,0.09,0.0) if is_dark() else Color(0.95,0.93,0.89,0.0)

## Atmospheric backdrop: the darkest edge of the vignette that settles the corners.
static func vignette_edge() -> Color:
	return Color(0.0,0.0,0.0,0.38) if is_dark() else Color(0.12,0.10,0.06,0.16)

## Button surface suffix: the SVG set that matches the current skin.
static func button_variant() -> String:
	return "" if is_dark() else "-light"

## Blend helper for tinted bands over the current surface.
static func mix(base: Color, tint: Color, amount: float) -> Color:
	return base.lerp(tint, clampf(amount, 0.0, 1.0))

const TOKEN_META:String= "palette_token"
## Only these tokens are readable as text on either skin. Painting a surface, rule or
## track colour onto a label is a mistake that reads as invisible text, so paint() refuses it.
const TEXT_TOKENS:Array[String]= ["text", "muted", "accent", "accent_deep", "green", "alert"]

## Colour for one documented token in the active skin.
static func color_for(token: String) -> Color:
	match token:
		"ink": return ink()
		"surface": return surface()
		"raised": return raised()
		"deep": return deep()
		"rule": return rule()
		"rule_soft": return rule_soft()
		"text": return text()
		"muted": return muted()
		"accent": return accent()
		"accent_deep": return accent_deep()
		"green": return green()
		"alert": return alert()
		"track": return track()
		"shadow": return shadow()
		"backdrop_top": return backdrop_top()
		"backdrop_mid": return backdrop_mid()
		"backdrop_base": return backdrop_base()
		"vignette_edge": return vignette_edge()
		_:
			push_error("Unknown palette token: " + token)
			return text()

## Paints a control and remembers which token owns the colour, so a skin switch
## repaints it instead of leaving the previous skin's value on screen forever.
static func paint(target: Control, token: String) -> void:
	if not TEXT_TOKENS.has(token):
		push_error("Token %s is not a text colour; use color_for() for surfaces." % token)
		return
	target.set_meta(TOKEN_META, token)
	target.add_theme_color_override("font_color", color_for(token))

## Re-applies every marked colour in the subtree. Controls built after a switch
## paint themselves through paint(); this covers the ones built before it.
static func repaint(root: Node) -> void:
	for node: Node in root.find_children("*", "Control", true, false):
		if not node.has_meta(TOKEN_META): continue
		(node as Control).add_theme_color_override("font_color", color_for(str(node.get_meta(TOKEN_META))))
