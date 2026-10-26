extends Node

const CATALOG_PATH := "res://assets/audio/catalog.json"
var catalog: Dictionary = {}
var streams: Dictionary = {}
var music_players: Array[AudioStreamPlayer] = []
var effect_players: Array[AudioStreamPlayer] = []
var current_music: String = ""
var finale_player:AudioStreamPlayer
var current_finale:=""
var music_index: int = -1
var crossfade: Tween
var effect_cursor: int = 0
var feedback_serial:int=0
var audio_rng := RandomNumberGenerator.new()
var force_mute: bool = OS.get_environment("GAME_AUDIO_MUTED") == "1"

func _ready() -> void:
	AudioServer.set_bus_mute(0, force_mute)
	audio_rng.randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if not file:
		push_error("Audio catalog missing: " + CATALOG_PATH)
		return
	catalog = JSON.parse_string(file.get_as_text())
	var routes := {"Music": "Master", "SFX": "Master", "UI": "Master"}
	for bus_name in routes:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
		AudioServer.set_bus_send(AudioServer.get_bus_index(bus_name), routes[bus_name])
	for i in range(2):
		var player := AudioStreamPlayer.new()
		player.bus = "Music"
		add_child(player)
		music_players.append(player)
	for i in range(8):
		var player := AudioStreamPlayer.new()
		add_child(player)
		effect_players.append(player)
	apply_gains()
	var feedback:=preload("res://scripts/audio/UIFeedback.gd").new()
	add_child(feedback)
	feedback.start(self)

func _stream(name: String, music: bool = false) -> AudioStreamWAV:
	var key := ("music/" if music else "sfx/") + name
	if streams.has(key):
		return streams[key]
	var group: Dictionary = catalog.get("music" if music else "sfx", {})
	if not group.has(name):
		return null
	var entry: Dictionary = group[name]
	var source = load("res://assets/audio/" + entry.path)
	if not source is AudioStreamWAV:
		push_error("Invalid audio asset: " + entry.path)
		return null
	var sound: AudioStreamWAV = source.duplicate()
	if entry.get("loop", false):
		sound.loop_mode = AudioStreamWAV.LOOP_FORWARD
		sound.loop_begin = 0
		sound.loop_end = int(sound.get_length() * sound.mix_rate)
	streams[key] = sound
	return sound

func play_music(mood: String, fade_seconds: float = 1.2) -> void:
	if is_instance_valid(finale_player):finale_player.stop()
	current_finale=""
	if mood == current_music:
		return
	# Retain continuity if an explicitly shared source is ever configured.
	if catalog.get("music", {}).get(mood, {}).get("path", "") == catalog.get("music", {}).get(current_music, {}).get("path", "missing"):
		current_music = mood
		return
	var sound := _stream(mood, true)
	if not sound:
		return
	if is_instance_valid(crossfade):
		crossfade.kill()
	var previous := music_index
	music_index = 0 if music_index < 0 else 1 - music_index
	var next: AudioStreamPlayer = music_players[music_index]
	next.stream = sound
	next.volume_db = -60 if fade_seconds > 0 else 0
	next.play()
	current_music = mood
	if fade_seconds <= 0:
		if previous >= 0:
			music_players[previous].stop()
		return
	crossfade = create_tween().set_parallel(true)
	crossfade.tween_property(next, "volume_db", 0.0, fade_seconds).set_trans(Tween.TRANS_SINE)
	if previous >= 0:
		var old: AudioStreamPlayer = music_players[previous]
		crossfade.tween_property(old, "volume_db", -60.0, fade_seconds).set_trans(Tween.TRANS_SINE)
		crossfade.tween_callback(old.stop).set_delay(fade_seconds)

func play_sfx(sound_name: String, bus_name: String = "") -> AudioStreamPlayer:
	var sound := _stream(sound_name)
	if not sound:
		return null
	feedback_serial+=1
	var player: AudioStreamPlayer
	for candidate in effect_players:
		if not candidate.playing:
			player = candidate
			break
	if not player:
		player = effect_players[effect_cursor % effect_players.size()]
		effect_cursor += 1
	player.stream = sound
	player.bus = bus_name if not bus_name.is_empty() else ("UI" if sound_name in ["ui_click","ui_focus","ui_error"] else "SFX")
	player.volume_db = -24 if sound_name=="ui_focus" else -10 if sound_name=="ui_error" else -5
	player.pitch_scale = audio_rng.randf_range(0.97, 1.03) if not catalog.sfx[sound_name].get("loop",false) and sound_name not in ["victory","defeat"] else 1.0
	player.play()
	return player

func play_sound(sound_name: String, bus_name: String = "") -> void:
	play_sfx(sound_name, bus_name)

func set_bus_volume(bus_name: String, value: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index >= 0:
		AudioServer.set_bus_mute(index, value <= 0 or (bus_name == "Master" and force_mute))
		AudioServer.set_bus_volume_linear(index, clampf(value, 0.0001, 1))

func set_enabled(enabled: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), force_mute or not enabled or (is_instance_valid(get_node_or_null("/root/GameManager")) and get_node("/root/GameManager").master_volume<=0))

func apply_gains() -> void:
	var settings := get_node_or_null("/root/GameManager")
	if settings:
		set_bus_volume("Master", settings.master_volume)
		set_bus_volume("UI", settings.ui_volume)
		set_bus_volume("Music", settings.music_volume)
		set_bus_volume("SFX", settings.sfx_volume)
		set_enabled(settings.audio_enabled)

func play_finale(victorious:bool) -> void:
	var cue:="victory" if victorious else "defeat"
	if is_instance_valid(finale_player) and finale_player.playing and current_finale==cue:return
	if is_instance_valid(crossfade):crossfade.kill()
	current_music=""
	current_finale=cue
	crossfade=create_tween().set_parallel(true)
	for player in music_players:
		crossfade.tween_property(player,"volume_db",-60.0,0.7).set_trans(Tween.TRANS_SINE)
		crossfade.tween_callback(player.stop).set_delay(0.7)
	if not is_instance_valid(finale_player):
		finale_player=AudioStreamPlayer.new()
		finale_player.bus="Music"
		add_child(finale_player)
	finale_player.stream=_stream(cue)
	finale_player.volume_db=0
	finale_player.play()
