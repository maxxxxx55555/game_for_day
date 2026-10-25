extends Translation
var manager:Node
func _get_message(src_message:StringName,_context:StringName) -> StringName:
	if not is_instance_valid(manager):return &""
	return StringName(manager.display(str(src_message)))
