extends Control
## A hairline frame with corner ticks, drawn over the whole screen. It is the
## cheapest way to make a flat layout read as a printed certificate: one rule,
## four ticks, no ornament.
const Palette=preload("res://scripts/ui/Palette.gd")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 90
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	resized.connect(queue_redraw)
	# This signal is wired once per owning node; teardown and navigation tests cover its lifetime.
	@warning_ignore("return_value_discarded")
	GameManager.theme_changed.connect(func(_mode:String)->void:queue_redraw())

func _draw() -> void:
	if size.x < 80.0 or size.y < 80.0: return
	var inset:float = 9.0
	var frame:Rect2 = Rect2(Vector2(inset, inset), size - Vector2(inset * 2.0, inset * 2.0))
	var hair:Color = Palette.accent()
	hair.a = 0.14 if Palette.is_dark() else 0.18
	draw_rect(frame, hair, false, 1.0)
	var tick:float = 20.0
	var strong:Color = Palette.accent()
	strong.a = 0.55 if Palette.is_dark() else 0.6
	var corners:Array[Vector2] = [
		frame.position,
		Vector2(frame.end.x, frame.position.y),
		Vector2(frame.position.x, frame.end.y),
		frame.end
	]
	for i:int in 4:
		var corner:Vector2 = corners[i]
		var dx:float = -tick if i % 2 == 1 else tick
		var dy:float = -tick if i >= 2 else tick
		draw_line(corner, corner + Vector2(dx, 0.0), strong, 1.4)
		draw_line(corner, corner + Vector2(0.0, dy), strong, 1.4)
