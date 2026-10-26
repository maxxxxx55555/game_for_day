extends Translation
var manager:Node
func _get_message(src_message:StringName,_context:StringName) -> StringName:
	if not is_instance_valid(manager):return &""
	# The lookup owns this resource and clears manager before TranslationServer teardown.
	@warning_ignore("unsafe_method_access")
	var translated:String=manager.display(str(src_message))
	return StringName(translated)
