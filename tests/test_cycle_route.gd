extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 await process_frame
 var ui:Control=load("res://scenes/Main.tscn").instantiate()
 root.add_child(ui)
 current_scene=ui
 await process_frame
 var route:Node=load("res://scripts/ReleaseVerification.gd").new()
 root.add_child(route)
 await route.run(ui)
