extends Node

var catalog: Array = []

func _ready() -> void:
	catalog = BuildIntegrity.read_json("res://data/events.json")

func events_for(stage: String) -> Array:
	var result: Array = []
	for entry:Variant in catalog:
		if entry.stage != stage: continue
		var event:Dictionary= {"title": entry.title}
		for index:int in 3:
			var choice: Dictionary = entry.choices[index]
			event["o" + str(index + 1)] = choice.label
			event["r" + str(index + 1)] = execute.bind(choice)
		result.append(event)
	return result

func execute(choice: Dictionary) -> String:
	var delta:Array=choice.delta
	var cash_delta:float=delta[0]
	var health_delta:int=delta[1]
	var intellect_delta:int=delta[2]
	var stress_delta:int=delta[3]
	var happiness_delta:int=delta[4]
	var energy_delta:int=delta[5]
	GameManager.apply_delta(cash_delta,health_delta,intellect_delta,stress_delta,happiness_delta,energy_delta)
	return choice.result
