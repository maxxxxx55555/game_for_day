extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		print("FAIL: ", message)

func run() -> void:
	await process_frame
	var audio: Node = root.get_node_or_null("SoundManager")
	check(is_instance_valid(audio), "Music and effects have a dedicated audio director")
	if audio:
		audio.play_music("study", 0.0)
		await process_frame
		check(audio.current_music == "study", "The requested life-stage music is selected")
		check(audio.music_players[0].stream is AudioStreamWAV, "Background music is a composed, cached audio asset")
		var voice = audio.play_sfx("purchase")
		check(is_instance_valid(voice) and voice.stream is AudioStreamWAV, "A purchase has its own recorded effect")
		seed(4242)
		var expected_random := randf()
		seed(4242)
		audio.play_sfx("ui_click")
		check(randf() == expected_random, "Cosmetic sound variation cannot alter gameplay randomness")
		audio.set_enabled(false)
		check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")), "Sound toggle really mutes playback")
		audio.set_enabled(true)
		if OS.get_environment("GAME_AUDIO_MUTED") == "1":
			check(AudioServer.is_bus_mute(0), "Silent QA stays muted when sound is enabled in settings")
		var game: Node = root.get_node("GameManager")
		game.music_volume = 0.25
		game.sfx_volume = 0.6
		audio.apply_gains()
		check(is_equal_approx(AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music")), 0.25), "Music slider controls actual music gain")
		check(is_equal_approx(AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("SFX")), 0.6), "Effects slider controls actual effect gain")
		game.save_dynasty()
		game.music_volume = 1.0
		game.load_dynasty()
		check(game.music_volume == 0.25, "Audio levels survive saving and loading")
	print("AUDIO RESULT: ", "PASS" if failures == 0 else "FAIL")
	quit(0 if failures == 0 else 1)
