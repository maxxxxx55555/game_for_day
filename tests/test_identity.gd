extends SceneTree

func _initialize() -> void:
	var valid: bool = ProjectSettings.get_setting("application/config/name") == "Heirs of Fortune"
	valid = valid and OS.get_user_data_dir().get_file() == "Forbes Ladder- Dynasty & Markets v2"
	valid = valid and ProjectSettings.get_setting("rendering/renderer/rendering_method.mobile", "") == "gl_compatibility"
	print("IDENTITY RESULT: ", "PASS" if valid else "FAIL", " path=", OS.get_user_data_dir())
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if valid else 1)
