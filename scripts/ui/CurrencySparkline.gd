extends Control
## Quote history uses real sample indices; actions do not always advance a quarter.
var code:String
var labels:Dictionary={}
func _ready() -> void:
	custom_minimum_size.y=104
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	for id in ["unit","high","low","past","now"]:
		var label:=Label.new()
		label.name=id.capitalize()+"AxisLabel"
		label.add_theme_font_size_override("font_size",16)
		label.add_theme_color_override("font_color",Color("a7b7bb"))
		label.mouse_filter=Control.MOUSE_FILTER_IGNORE
		add_child(label);labels[id]=label
	resized.connect(refresh_labels)
	LocalizationManager.language_changed.connect(func(_language):refresh_labels())
	refresh_labels()
func plot_rect() -> Rect2:
	return Rect2(72,28,maxf(1,size.x-80),maxf(1,size.y-56))
func refresh_labels() -> void:
	if labels.is_empty():return
	var points:Array=GameManager.fx.history.get(code,[])
	labels.unit.text=LocalizationManager.get_string("chart.unit") % code
	labels.high.text="%.4f" % float(points.max()) if not points.is_empty() else "—"
	labels.low.text="%.4f" % float(points.min()) if not points.is_empty() else "—"
	labels.past.text=LocalizationManager.get_string("chart.samples_ago") % maxi(0,points.size()-1)
	labels.now.text=LocalizationManager.get_string("chart.now")
	labels.unit.position=Vector2(0,0)
	labels.high.position=Vector2(0,24)
	labels.low.position=Vector2(0,size.y-48)
	labels.past.position=Vector2(72,size.y-labels.past.get_combined_minimum_size().y)
	labels.now.position=Vector2(size.x-labels.now.get_combined_minimum_size().x,size.y-labels.now.get_combined_minimum_size().y)
	queue_redraw()
func _draw() -> void:
	var points:Array=GameManager.fx.history.get(code,[])
	var plot:=plot_rect()
	draw_line(plot.position,Vector2(plot.position.x,plot.end.y),Color("4a6066"),1)
	draw_line(Vector2(plot.position.x,plot.end.y),plot.end,Color("4a6066"),1)
	if points.is_empty():return
	var lo:float=points.min()
	var hi:float=points.max()
	var range_value:float=hi-lo
	var line:=PackedVector2Array()
	for i in points.size():
		var height:float=(float(points[i])-lo)/range_value if range_value>0.000001 else 0.5
		line.append(Vector2(plot.position.x+plot.size.x*i/maxi(1,points.size()-1),plot.end.y-height*plot.size.y))
	if line.size()>1:draw_polyline(line,Color("c6ad7a"),2,true)
	else:draw_circle(Vector2(plot.end.x,plot.position.y+plot.size.y*0.5),3,Color("c6ad7a"))
