extends Control
var code: String
func _ready() -> void:
	custom_minimum_size.y = 58
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
func _draw() -> void:
	var points: Array = GameManager.fx.history.get(code, [])
	if points.is_empty(): return
	var lo: float = points.min()
	var hi: float = points.max()
	var range_value := maxf(hi - lo, hi * 0.01)
	var line := PackedVector2Array()
	for i in points.size():
		line.append(Vector2(4 + (size.x - 8) * i / maxi(1, points.size()-1), size.y - 8 - (points[i] - lo) / range_value * (size.y - 16)))
	draw_line(Vector2(0, size.y - 4), Vector2(size.x, size.y - 4), Color("4a6066"), 1)
	if line.size() > 1: draw_polyline(line, Color("c8b482"), 2, true)
	else: draw_circle(Vector2(size.x * 0.5, size.y * 0.5), 3, Color("c8b482"))
