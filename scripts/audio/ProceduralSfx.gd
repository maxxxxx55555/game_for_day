class_name ProceduralSfx
extends RefCounted
## Runtime-synthesized interface effects, CC0-1.0.
##
## Why this exists: the shipped WAV effects were thin 0.38 s sine beeps, and
## purchase.wav and grant.wav were byte-for-byte the same file even though
## they answer different player actions. Replacing them with new WAV binaries
## would also re-open the provenance/hash contracts in tests. These effects
## are therefore synthesized deterministically at runtime, from authored note
## designs below, as 32 kHz mono 16-bit AudioStreamWAV data. No global RNG
## is touched, so gameplay randomness is unaffected, and every effect has a
## distinct pitch contour, duration and timbre by construction.
##
## Music and the victory/defeat finales stay as recorded WAV assets in
## assets/audio/catalog.json; only the eight short interface effects live here.

const MIX_RATE: int = 32000
const PEAK_TARGET: float = 0.60

## name -> [duration_seconds, [ [freq_hz, start_s, dur_s, amp, bright], ... ]]
const DESIGNS: Dictionary = {
	"ui_click": [0.09, [[880.0, 0.0, 0.09, 0.50, true]]],
	"ui_focus": [0.06, [[660.0, 0.0, 0.06, 0.35, false]]],
	"ui_error": [0.30, [[196.0, 0.0, 0.30, 0.45, false], [185.0, 0.0, 0.30, 0.30, false]]],
	"coin": [0.45, [[1318.0, 0.0, 0.28, 0.50, true], [1976.0, 0.12, 0.33, 0.45, true]]],
	"purchase": [0.65, [[130.0, 0.0, 0.20, 0.40, false], [523.0, 0.0, 0.40, 0.40, true], [659.0, 0.09, 0.40, 0.40, true], [784.0, 0.18, 0.42, 0.40, true]]],
	"sale": [0.55, [[784.0, 0.0, 0.25, 0.45, true], [659.0, 0.14, 0.25, 0.45, true], [523.0, 0.28, 0.27, 0.40, true]]],
	"grant": [0.95, [[130.0, 0.0, 0.90, 0.25, false], [523.0, 0.0, 0.30, 0.35, true], [587.0, 0.07, 0.30, 0.35, true], [659.0, 0.14, 0.30, 0.35, true], [784.0, 0.21, 0.30, 0.35, true], [880.0, 0.28, 0.30, 0.35, true], [1047.0, 0.35, 0.55, 0.40, true]]],
	"upgrade": [1.05, [[523.0, 0.0, 0.35, 0.40, true], [659.0, 0.12, 0.35, 0.40, true], [784.0, 0.24, 0.35, 0.40, true], [1047.0, 0.36, 0.60, 0.45, true]]],
}

static func has_sound(sound_name: String) -> bool:
	return DESIGNS.has(sound_name)

static func sound_names() -> Array:
	return DESIGNS.keys()

static func design_duration(sound_name: String) -> float:
	if not DESIGNS.has(sound_name):
		return 0.0
	@warning_ignore("unsafe_cast")
	var design: Array = DESIGNS[sound_name]
	var duration: float = design[0]
	return duration

var _cache: Dictionary = {}

func cached_streams() -> Array:
	return _cache.values()

func clear_cache() -> void:
	_cache.clear()

func stream(sound_name: String) -> AudioStreamWAV:
	if _cache.has(sound_name):
		@warning_ignore("unsafe_cast")
		var cached: AudioStreamWAV = _cache[sound_name]
		return cached
	if not DESIGNS.has(sound_name):
		return null
	@warning_ignore("unsafe_cast")
	var design: Array = DESIGNS[sound_name]
	var duration: float = design[0]
	@warning_ignore("unsafe_cast")
	var notes: Array = design[1]
	var frame_count: int = int(duration * float(MIX_RATE))
	var buffer: PackedFloat32Array = PackedFloat32Array()
	@warning_ignore("return_value_discarded")
	buffer.resize(frame_count)
	for note_variant: Variant in notes:
		@warning_ignore("unsafe_cast")
		var note: Array = note_variant
		var freq: float = note[0]
		var start_s: float = note[1]
		var dur_s: float = note[2]
		var amp: float = note[3]
		var bright: bool = note[4]
		_add_note(buffer, freq, start_s, dur_s, amp, bright)
	var peak: float = 0.0
	for value: float in buffer:
		peak = maxf(peak, absf(value))
	var gain: float = PEAK_TARGET / peak if peak > 0.001 else 1.0
	var bytes: PackedByteArray = PackedByteArray()
	@warning_ignore("return_value_discarded")
	bytes.resize(frame_count * 2)
	for i: int in range(frame_count):
		var sample: int = int(clampf(buffer[i] * gain, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, sample)
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.stereo = false
	wav.data = bytes
	_cache[sound_name] = wav
	return wav

func _add_note(buffer: PackedFloat32Array, freq: float, start_s: float, dur_s: float, amp: float, bright: bool) -> void:
	var start: int = int(start_s * float(MIX_RATE))
	var length: int = int(dur_s * float(MIX_RATE))
	var harmonics: Array = [[1.0, 1.0], [2.0, 0.40], [3.0, 0.15]] if bright else [[1.0, 1.0], [2.0, 0.50]]
	var attack: int = int(0.005 * float(MIX_RATE))
	var release: int = int(0.04 * float(MIX_RATE))
	for i: int in range(length):
		var index: int = start + i
		if index < 0 or index >= buffer.size():
			continue
		var t: float = float(i) / float(MIX_RATE)
		var envelope: float = 1.0
		if i < attack:
			envelope = float(i) / float(maxi(attack, 1))
		elif i >= length - release:
			var remaining: int = length - i
			envelope = 0.5 + 0.5 * cos(PI * float(remaining) / float(maxi(release, 1)) - PI)
			envelope = clampf(envelope, 0.0, 1.0)
		envelope *= exp(-t * 2.2)
		var value: float = 0.0
		for harmonic_variant: Variant in harmonics:
			@warning_ignore("unsafe_cast")
			var harmonic: Array = harmonic_variant
			var multiple: float = harmonic[0]
			var weight: float = harmonic[1]
			value += sin(TAU * freq * multiple * t) * weight / multiple
		buffer[index] += value * amp * envelope
