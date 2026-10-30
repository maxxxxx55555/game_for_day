extends Control
## Quote history uses real sample indices; actions do not always advance a quarter.
const Palette=preload("res://scripts/ui/Palette.gd")
var code:String
var labels:Dictionary[String,Label]={}
func _ready() -> void:
	custom_minimum_size.y=104
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	for id:String in ["unit","high","low","past","now"]:
		var label:Label=Label.new()
		label.name=id.capitalize()+"AxisLabel"
		label.add_theme_font_size_override("font_size",16)
		label.add_theme_color_override("font_color",Palette.muted())
		label.mouse_filter=Control.MOUSE_FILTER_IGNORE
		add_child(label);labels[id]=label
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	resized.connect(refresh_labels)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	LocalizationManager.language_changed.connect(func(_language:Variant)->void:refresh_labels())
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	GameManager.theme_changed.connect(func(_mode:String)->void:apply_skin())
	refresh_labels()

func apply_skin() -> void:
	for id:String in labels:
		labels[id].add_theme_color_override("font_color",Palette.muted())
	queue_redraw()
	refresh_labels()
func plot_rect() -> Rect2:
	return Rect2(72,28,maxf(1,size.x-80),maxf(1,size.y-56))
func refresh_labels() -> void:
	if labels.is_empty():return
	var raw_points:Array=GameManager.fx.history.get(code,[])
	var points:Array[float]=Array(raw_points,TYPE_FLOAT,"",null)
	labels.unit.text=LocalizationManager.get_string("chart.unit") % code
	var high:float=points.max() if not points.is_empty() else 0.0
	var low:float=points.min() if not points.is_empty() else 0.0
	labels.high.text="%.4f" % high if not points.is_empty() else "—"
	labels.low.text="%.4f" % low if not points.is_empty() else "—"
	labels.past.text=LocalizationManager.get_string("chart.samples_ago") % maxi(0,points.size()-1)
	labels.now.text=LocalizationManager.get_string("chart.now")
	labels.unit.position=Vector2(0,0)
	labels.high.position=Vector2(0,24)
	labels.low.position=Vector2(0,size.y-48)
	labels.past.position=Vector2(72,size.y-labels.past.get_combined_minimum_size().y)
	labels.now.position=Vector2(size.x-labels.now.get_combined_minimum_size().x,size.y-labels.now.get_combined_minimum_size().y)
	queue_redraw()
func _draw() -> void:
	var raw_points:Array=GameManager.fx.history.get(code,[])
	var points:Array[float]=Array(raw_points,TYPE_FLOAT,"",null)
	var plot:Rect2=plot_rect()
	draw_line(plot.position,Vector2(plot.position.x,plot.end.y),Palette.rule(),1)
	draw_line(Vector2(plot.position.x,plot.end.y),plot.end,Palette.rule(),1)
	if points.is_empty():return
	var lo:float=points.min()
	var hi:float=points.max()
	var range_value:float=hi-lo
	var line:PackedVector2Array=PackedVector2Array()
	for i:int in points.size():
		var height:float=(float(points[i])-lo)/range_value if range_value>0.000001 else 0.5
		if line.append(Vector2(plot.position.x+plot.size.x*i/maxi(1,points.size()-1),plot.end.y-height*plot.size.y)):return
	if line.size()>1:draw_polyline(line,Palette.accent(),2,true)
	else:draw_circle(Vector2(plot.end.x,plot.position.y+plot.size.y*0.5),3,Palette.accent())
