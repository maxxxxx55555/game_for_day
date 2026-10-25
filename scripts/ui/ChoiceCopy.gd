extends RefCounted
## Presentation aliases only. The event's original text and callable remain intact.
static func parts(raw:String) -> Dictionary:
	var split:=raw.find(" (")
	var action:=raw.substr(0,split).strip_edges() if split>=0 else raw.strip_edges()
	var detail:=raw.substr(split+2).trim_suffix(")") if split>=0 else ""
	var title:String=(Engine.get_main_loop() as SceneTree).root.get_node("LocalizationManager").aliases.get(action,action)
	# Cost written before the parentheses still has to be visible after an alias.
	if title!=action:
		var money:=RegEx.new()
		money.compile("\\$[0-9][0-9,.]*")
		for match in money.search_all(action):
			var value:=match.get_string()
			if not value in detail: detail=value+(" · "+detail if not detail.is_empty() else "")
	return {"title":title,"detail":detail}
