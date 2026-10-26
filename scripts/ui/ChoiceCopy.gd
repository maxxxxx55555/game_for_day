extends RefCounted
## Presentation aliases only. The event's original text and callable remain intact.
static func parts(raw:String) -> Dictionary:
	var split:int=raw.find(" (")
	var action:String=raw.substr(0,split).strip_edges() if split>=0 else raw.strip_edges()
	var detail:String=raw.substr(split+2).trim_suffix(")") if split>=0 else ""
	var title:String=LocalizationManager.aliases.get(action,action)
	# Cost written before the parentheses still has to be visible after an alias.
	if title!=action:
		var money:RegEx=RegEx.new()
		if money.compile("\\$[0-9][0-9,.]*")!=OK:
			push_error("Invalid built-in regular expression")
		for match:RegExMatch in money.search_all(action):
			var value:String=match.get_string()
			if not value in detail: detail=value+(" · "+detail if not detail.is_empty() else "")
	return {"title":title,"detail":detail}
