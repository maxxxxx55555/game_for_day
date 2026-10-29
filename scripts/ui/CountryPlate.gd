extends Control
## Editorial banner for the country the run belongs to. Instead of one shared
## painting, every country gets its own plate: a wash built from the three
## dominant flag colours, the name in Prata, and an abstract emblem of bands.
## Reads as a dossier cover in both skins.
const Palette=preload("res://scripts/ui/Palette.gd")
const BirthLottery=preload("res://scripts/BirthLottery.gd")
const display_font:Font= preload("res://assets/fonts/Prata-Regular.ttf")
var code:String=""
var scrim:GradientTexture2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size.y = 190
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var gradient:Gradient= Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0,0.42,0.72,1.0])
	gradient.colors = PackedColorArray([
		Color(1,1,1,0.0),
		Color(1,1,1,0.0),
		Color(1,1,1,0.72),
		Color(1,1,1,0.96)])
	scrim = GradientTexture2D.new()
	scrim.gradient = gradient
	scrim.width = 8
	scrim.height = 256
	scrim.fill_from = Vector2(0.0,0.0)
	scrim.fill_to = Vector2(0.0,1.0)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	resized.connect(queue_redraw)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	GameManager.theme_changed.connect(func(_mode:String)->void:queue_redraw())
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	LocalizationManager.language_changed.connect(func(_language:Variant)->void:queue_redraw())

func present(country_code:String) -> void:
	code = country_code
	queue_redraw()

func tracked(text:String) -> String:
	var letters:String=""
	for i:int in text.length():
		if i > 0:
			letters += " "
		letters += text.substr(i,1)
	return letters

func _draw() -> void:
	if code.is_empty(): return
	var row:Array= BirthLottery.by_code(code)
	if row.is_empty(): return
	var colors:Array[Color]= BirthLottery.flag_colors(code)
	var w:float= size.x
	var h:float= size.y
	var base:Color= Palette.deep()
	draw_rect(Rect2(0,0,w,h),base)
	# Colour wash: three soft vertical bands, heavier at the left edge.
	var strength:float= 0.24 if Palette.is_dark() else 0.30
	for i:int in 3:
		var tint:Color= colors[i]
		var x:float= w*(0.02+float(i)*0.11)
		draw_rect(Rect2(x,0,w*0.10,h),Palette.mix(base,tint,strength-float(i)*0.045))
	draw_rect(Rect2(0,0,w,h*0.5),Palette.mix(base,colors[0],0.05))
	# Scrim so the typography reads over any flag colour.
	draw_texture_rect(scrim,Rect2(0.0,0.0,w,h),false,base)
	# Content sits in a fixed optical block, anchored to the bottom so it reads as a
	# caption for the event text underneath.
	var block:float= minf(h-16.0,200.0)
	var top:float= maxf(0.0,h-block-10.0)
	var left:float= maxf(20.0,w*0.055)
	# Oversized monogram watermark fills the upper field without adding noise.
	if top > 90.0:
		var mark:Color= Palette.accent()
		mark.a = 0.07 if Palette.is_dark() else 0.10
		draw_string(display_font,Vector2(left-4.0,top-14.0),code,HORIZONTAL_ALIGNMENT_LEFT,-1,clampi(roundi(top*0.72),36,132),mark)
	# Emblem: three stacked bars on the right, the flag reduced to rhythm.
	var bar_w:float= maxf(46.0,w*0.13)
	var bar_h:float= maxf(9.0,block*0.052)
	var right:float= w - maxf(22.0,w*0.055)
	var bar_top:float= top + block*0.5 - bar_h*1.6
	for i:int in 3:
		draw_rect(Rect2(right-bar_w,bar_top+float(i)*(bar_h+bar_h*0.55),bar_w,bar_h),colors[i])
	draw_rect(Rect2(right-bar_w,bar_top,bar_w,bar_h*3.0+bar_h*1.1),Palette.rule(),false,1.0)
	# Typography block.
	var name_text:String= BirthLottery.country_name(code)
	draw_string(display_font,Vector2(left,top+block*0.52),name_text,HORIZONTAL_ALIGNMENT_LEFT,w*0.62,clampi(roundi(block*0.19),22,44),Palette.text())
	draw_string(get_theme_default_font(),Vector2(left,top+block*0.64),tracked(BirthLottery.region_name(str(row[1])).to_upper()),HORIZONTAL_ALIGNMENT_LEFT,w*0.62,10,Palette.accent())
	draw_line(Vector2(left,top+block*0.72),Vector2(w*0.46,top+block*0.72),Palette.rule(),1.0)
	var share:float= BirthLottery.share(row)*100.0
	draw_string(get_theme_default_font(),Vector2(left,top+block*0.85),GameManager.origin_percent_text(share)+"% "+LocalizationManager.source("birth.share"),HORIZONTAL_ALIGNMENT_LEFT,w*0.62,12,Palette.muted())
	draw_rect(Rect2(0,0,w,h),Palette.rule(),false,1.0)
