extends Control
const Palette=preload("res://scripts/ui/Palette.gd")
## Hero card for the birth lottery: the country, how rare that draw was, and what
## it means for the first years. Deliberately plain - one accent, thin rules.
const display_font:Font= preload("res://assets/fonts/Prata-Regular.ttf")
const CITY:Texture2D=preload("res://assets/art/city_folio.png")
const BirthLottery=preload("res://scripts/BirthLottery.gd")
var country:String=""
var region:String=""
var share_text:String=""
var life_text:String=""
var share_value:float=0.0
var life_years:int=0
var cash_text:String=""
var has_result:bool=false

func _ready() -> void:
	custom_minimum_size.y = 260
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	resized.connect(queue_redraw)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	GameManager.theme_changed.connect(func(_mode:String)->void:queue_redraw())
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	LocalizationManager.language_changed.connect(func(_language:Variant)->void:queue_redraw())

func present(info:Dictionary) -> void:
	country=str(info.get("title",""))
	region=str(info.get("region",GameManager.birth_origin))
	var percent:float=BirthLottery.value_number(info,"share")*100.0
	share_value=percent
	life_years=BirthLottery.value_int(info,"life")
	share_text=GameManager.origin_percent_text(percent)+"%"
	life_text=LocalizationManager.source("birth.life_years") % BirthLottery.value_int(info,"life")
	cash_text="$"+GameManager.format_num(GameManager.cash)
	has_result=true
	queue_redraw()

func clear() -> void:
	has_result=false
	queue_redraw()

## Rebuilds the card from saved run state after a session restore.
func present_from_state() -> void:
	var row:Array= BirthLottery.by_code(GameManager.birth_country_code)
	if row.is_empty():
		clear()
		return
	var code:String=GameManager.birth_country_code
	present({
		"title": BirthLottery.country_name(code),
		"region": BirthLottery.region_name(str(row[1])),
		"share": BirthLottery.share(row),
		"life": BirthLottery.row_int(row,3)
	})

func tracked(text:String) -> String:
	var letters:String=""
	for i:int in text.length():
		if i > 0:
			letters += " "
		letters += text.substr(i,1)
	return letters

func caption(at: Vector2, text: String, font_size: int, color: Color) -> void:
	draw_string(get_theme_default_font(), at, LocalizationManager.display(text), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func country_label()->String:
	return LocalizationManager.display(country)

func country_font_size()->int:
	var width:float=display_font.get_string_size(country_label(),HORIZONTAL_ALIGNMENT_LEFT,-1,42).x
	return maxi(20,mini(42,floori(42.0*620.0/maxf(1.0,width))))

func stat(x: float, value: String, label: String) -> void:
	draw_string(get_theme_default_font(), Vector2(x,154), LocalizationManager.display(value), HORIZONTAL_ALIGNMENT_LEFT, 190, 30, Palette.text())
	draw_string(get_theme_default_font(), Vector2(x,177), LocalizationManager.display(label), HORIZONTAL_ALIGNMENT_LEFT, 190, 11, Palette.muted())

func _draw() -> void:
	if not has_result: return
	var s:float= size.x / 620.0
	# Sit the card in the optical middle of whatever height the panel grants.
	var spare:float= maxf(0.0, size.y - 260.0 * s)
	# Use the existing city artwork as a quiet illustration, never under the data.
	var art_height:float=minf(spare * 0.34, 160.0 * s)
	if art_height >= 32.0 and size.x > 0.0:
		var source_width:float=float(CITY.get_width())
		var source_height:float=source_width * art_height / size.x
		var source_top:float=clampf(float(CITY.get_height()) * 0.39 - source_height * 0.5, 0.0, float(CITY.get_height()) - source_height)
		draw_texture_rect_region(CITY,Rect2(0,0,size.x,art_height),Rect2(0,source_top,source_width,source_height),Color(0.75,0.80,0.87,0.52))
	draw_set_transform(Vector2(0, spare * 0.42), 0, Vector2(s,s))
	draw_string(get_theme_default_font(), Vector2(0,12), tracked(LocalizationManager.get_string("birth.overline")), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Palette.accent())
	draw_line(Vector2(0,24), Vector2(620,24), Palette.rule(), 1.0)
	draw_string(display_font, Vector2(0,74), country_label(), HORIZONTAL_ALIGNMENT_LEFT, 620, country_font_size(), Palette.text())
	draw_string(get_theme_default_font(), Vector2(0,100), LocalizationManager.display(region).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 620, 12, Palette.muted())
	draw_line(Vector2(0,116), Vector2(620,116), Palette.rule(), 1.0)
	share_text=GameManager.origin_percent_text(share_value)+"%"
	life_text=LocalizationManager.get_string("birth.life_years") % life_years
	cash_text="$"+GameManager.format_num(GameManager.cash)
	stat(0.0,share_text,LocalizationManager.source("birth.share"))
	stat(215.0,life_text,LocalizationManager.source("birth.life"))
	stat(430.0,cash_text,LocalizationManager.source("birth.capital"))
	draw_line(Vector2(0,198), Vector2(620,198), Palette.rule(), 1.0)
	caption(Vector2(0,222), LocalizationManager.source("birth.note.one"), 13, Palette.text())
	caption(Vector2(0,242), LocalizationManager.source("birth.note.two"), 13, Palette.accent_deep())
