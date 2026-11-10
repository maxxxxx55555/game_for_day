extends SceneTree
## Regression test for the 2.1.2 audio fix: purchase.wav and grant.wav used
## to be byte-for-byte the same file, and every short effect was a 0.38 s
## sine beep. The eight short effects are now synthesized at runtime with
## distinct designs, so this test proves they differ, are audible, and have
## clean attack/release edges.
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		print("FAIL: ", message)
func run() -> void:
	await process_frame
	var synth: RefCounted = load("res://scripts/audio/ProceduralSfx.gd").new()
	var checksums: Dictionary = {}
	var catalog: Dictionary = (root.get_node("SoundManager") as Node).catalog
	check(catalog.has("synth_sfx"), "Catalog documents the runtime-synthesized effects")
	for sound_name: String in ProceduralSfx.sound_names():
		var wav: AudioStreamWAV = synth.stream(sound_name)
		check(wav != null, "Procedural effect exists: " + sound_name)
		if wav == null:
			continue
		check(wav.mix_rate == 32000, "Procedural effect is 32 kHz: " + sound_name)
		check(not wav.stereo, "Procedural effect is mono: " + sound_name)
		check(is_equal_approx(wav.get_length(), ProceduralSfx.design_duration(sound_name)), "Procedural effect length matches its design: " + sound_name)
		var data: PackedByteArray = wav.data
		var frame_count: int = data.size() / 2
		var peak: int = 0
		var sum_sq: float = 0.0
		var checksum: int = 0
		for i: int in range(frame_count):
			var sample: int = data.decode_s16(i * 2)
			peak = maxi(peak, absi(sample))
			sum_sq += float(sample * sample)
			checksum = (checksum * 31 + sample) % 1000000007
		var rms: float = sqrt(sum_sq / float(maxi(frame_count, 1))) / 32768.0
		check(peak > 8000 and peak < 26000, "Procedural effect has a real, non-clipping peak: " + sound_name)
		check(rms > 0.05 and rms < 0.45, "Procedural effect is audible without being hot: " + sound_name)
		check(absi(data.decode_s16(0)) < 64, "Procedural effect starts cleanly: " + sound_name)
		check(absi(data.decode_s16(data.size() - 2)) < 64, "Procedural effect ends cleanly: " + sound_name)
		check(not checksums.values().has(checksum), "Procedural effect is distinct from the others: " + sound_name)
		checksums[sound_name] = checksum
		check((catalog.get("synth_sfx", {}) as Dictionary).has(sound_name), "Catalog lists the procedural effect: " + sound_name)
	check(checksums.get("grant", 0) != checksums.get("purchase", 1), "Grant and purchase are different sounds, not one shared file")
	var director: Node = root.get_node("SoundManager")
	var voice: AudioStreamPlayer = director.play_sfx("purchase")
	check(is_instance_valid(voice) and voice.stream is AudioStreamWAV, "A purchase has its own synthesized effect")
	var grant_voice: AudioStreamPlayer = director.play_sfx("grant")
	check(is_instance_valid(grant_voice) and grant_voice.stream is AudioStreamWAV, "A grant has its own synthesized effect")
	print("PROCEDURAL SFX RESULT: ", "PASS" if failures == 0 else "FAIL")
	if not await root.get_node("SoundManager").shutdown():
		quit(1)
		return
	quit(0 if failures == 0 else 1)
