extends Node

var catalog: Array = []

func _ready() -> void:
	catalog = JSON.parse_string(FileAccess.get_file_as_string("res://data/events.json"))

func events_for(stage: String) -> Array:
	var result: Array = []
	for entry in catalog:
		if entry.stage != stage: continue
		var event := {"title": entry.title}
		for index in 3:
			var choice: Dictionary = entry.choices[index]
			event["o" + str(index + 1)] = choice.label
			event["r" + str(index + 1)] = execute.bind(choice)
		result.append(event)
	return result

func execute(choice: Dictionary) -> String:
	var delta: Array = choice.delta
	GameManager.apply_delta(delta[0], delta[1], delta[2], delta[3], delta[4], delta[5])
	return choice.result
