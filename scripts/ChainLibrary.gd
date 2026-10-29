extends Node
## Delayed two-link life threads. Copy lives in the catalog; flags live in the run.

var catalog: Array = []

func _ready() -> void:
	var loaded: Variant = BuildIntegrity.read_json("res://data/chains.json")
	if loaded is Array:
		var entries: Array = loaded
		catalog = entries

func definition(id: String) -> Dictionary:
	for value: Variant in catalog:
		if not value is Dictionary:
			continue
		var entry: Dictionary = value
		if str(entry.get("id", "")) == id:
			return entry
	return {}

func ids_for(stage: String) -> Array[String]:
	var result: Array[String] = []
	for value: Variant in catalog:
		if not value is Dictionary:
			continue
		var entry: Dictionary = value
		if str(entry.get("stage", "")) == stage:
			result.append(str(entry.get("id", "")))
	return result

func codex(id: String) -> String:
	return LocalizationManager.source("chain." + id + ".codex")

func choice_rows(entry: Dictionary, section: String) -> Array:
	var block_value: Variant = entry.get(section, {})
	if not block_value is Dictionary:
		return []
	var block: Dictionary = block_value
	var rows_value: Variant = block.get("choices", [])
	if not rows_value is Array:
		return []
	var rows: Array = rows_value
	return rows

func start_event(id: String) -> Dictionary:
	var entry: Dictionary = definition(id)
	if entry.is_empty():
		return {}
	var choices: Array = choice_rows(entry, "start")
	if choices.size() != 3:
		return {}
	var event: Dictionary = {
		"title": LocalizationManager.source("chain." + id + ".start.title"),
		"chain_id": id,
		"chain_kind": "start",
		"overline": LocalizationManager.source("chain.thread.overline")
	}
	for index: int in choices.size():
		var value: Variant = choices[index]
		if not value is Dictionary:
			return {}
		var step: String = str(index + 1)
		event["o" + step] = LocalizationManager.source("chain." + id + ".start.c" + step + ".label")
		event["r" + step] = start_choice.bind(id, index)
	return event

func followup_event(record: Dictionary) -> Dictionary:
	var id: String = str(record.get("id", ""))
	var entry: Dictionary = definition(id)
	if entry.is_empty():
		return {}
	var choices: Array = choice_rows(entry, "followup")
	if choices.size() != 3:
		return {}
	var recall: String = LocalizationManager.source("chain." + id + ".follow.recall")
	var event: Dictionary = {
		"title": LocalizationManager.source("chain." + id + ".follow.title"),
		"chain_id": id,
		"chain_kind": "follow",
		"overline": LocalizationManager.source("chain.follow.overline"),
		"note": recall % str(record.get("label", ""))
	}
	for index: int in choices.size():
		var value: Variant = choices[index]
		if not value is Dictionary:
			return {}
		var step: String = str(index + 1)
		event["o" + step] = LocalizationManager.source("chain." + id + ".follow.c" + step + ".label")
		event["r" + step] = follow_choice.bind(id, index)
	return event

func restore_events() -> Array:
	var events: Array = []
	for value: Variant in catalog:
		if not value is Dictionary:
			continue
		var entry: Dictionary = value
		var id: String = str(entry.get("id", ""))
		var start: Dictionary = start_event(id)
		if not start.is_empty():
			events.append(start)
		var record: Dictionary = GameManager.chain_record_for(id)
		if not record.is_empty():
			var follow: Dictionary = followup_event(record)
			if not follow.is_empty():
				events.append(follow)
	return events

func start_choice(id: String, index: int) -> String:
	var entry: Dictionary = definition(id)
	var choices: Array = choice_rows(entry, "start")
	if index < 0 or index >= choices.size():
		return ""
	var value: Variant = choices[index]
	if not value is Dictionary:
		return ""
	var choice: Dictionary = value
	apply_choice(choice)
	var step: String = str(index + 1)
	var label: String = LocalizationManager.source("chain." + id + ".start.c" + step + ".label")
	var delay: int = entry.get("delay", 5)
	GameManager.begin_chain(
		id,
		str(entry.get("stage", "survival")),
		str(choice.get("flag", "")),
		label,
		delay
	)
	return LocalizationManager.source("chain." + id + ".start.c" + step + ".result")

func follow_choice(id: String, index: int) -> String:
	var entry: Dictionary = definition(id)
	var choices: Array = choice_rows(entry, "followup")
	if index < 0 or index >= choices.size():
		return ""
	var value: Variant = choices[index]
	if not value is Dictionary:
		return ""
	var choice: Dictionary = value
	var flag: String = GameManager.chain_flag(id)
	var chosen: Dictionary = choice
	var suffix: String = ".result"
	var variants_value: Variant = choice.get("variants", [])
	if variants_value is Array:
		var variants: Array = variants_value
		for variant_value: Variant in variants:
			if not variant_value is Dictionary:
				continue
			var variant: Dictionary = variant_value
			if str(variant.get("flag", "")) == flag:
				chosen = variant
				suffix = ".v." + flag + ".result"
				break
	var applied: Dictionary = choice.duplicate(true)
	for field: String in ["delta", "cash_pct"]:
		if chosen.has(field):
			applied[field] = chosen[field]
	apply_choice(applied)
	GameManager.complete_chain(id)
	return LocalizationManager.source("chain." + id + ".follow.c" + str(index + 1) + suffix)

func apply_choice(choice: Dictionary) -> void:
	var raw: Variant = choice.get("delta", [])
	if not raw is Array:
		return
	var values: Array = raw
	if values.size() != 6:
		return
	var cash: float = values[0]
	if choice.has("cash_pct"):
		var cash_pct: float = choice["cash_pct"]
		cash += GameManager.cash * cash_pct
	var health: int = values[1]
	var intellect: int = values[2]
	var stress: int = values[3]
	var happiness: int = values[4]
	var energy: int = values[5]
	GameManager.apply_delta(cash, health, intellect, stress, happiness, energy)
