extends Node
class_name TableAudio

const VOICE_BUDGET := 32
const FADE_SECONDS := 0.006
const VARIANT_COUNTS := {"ball": 5, "cue": 5, "rail": 1, "pocket": 5}

var enabled := true:
	set(value):
		enabled = value
		if not value:
			_generation += 1
			_reserved.clear()
			for player in _players:
				if player.playing:
					_fade_out(player)
var _players: Array[AudioStreamPlayer] = []
var _cursor := 0
var _sounds := {}
var _variants := {}
var _last_variant := {}
# This private stream never consumes global/simulation random state.
var _cosmetic_rng := RandomNumberGenerator.new()
var _fades := {}
var _reserved := {}
var _voice_kinds := {}
var _generation := 0
var voice_steals := 0
var voice_drops := 0
var voice_starts := 0

func _ready() -> void:
	_cosmetic_rng.randomize()
	for kind in VARIANT_COUNTS:
		_sounds[kind] = load("res://assets/audio/%s.wav" % kind)
		_variants[kind] = []
		for index in range(VARIANT_COUNTS[kind]):
			_variants[kind].append(load("res://assets/audio/%s_%02d.wav" % [kind, index + 1]))
	for index in range(VOICE_BUDGET):
		var player := AudioStreamPlayer.new()
		player.bus = &"Contacts"
		add_child(player)
		_players.append(player)

# speed is the existing normal approach-speed/strike-speed proxy. For fixed
# material/mass, impulse is proportional to speed and energy to speed squared.
# Keep gain monotonic; ball size/material do not change with shot strength.
static func contact_gain_db(speed: float) -> float:
	return clampf(-18.0 + 12.0 * log(maxf(0.005, speed)) / log(10.0), -46.0, -7.0)

func _next_variant(kind: String) -> AudioStream:
	# Keep the compatibility _sounds override used by event-only tests.
	if _sounds[kind] == null:
		return null
	var variants: Array = _variants[kind]
	var count := variants.size()
	var index := 0
	if count > 1:
		var previous: int = _last_variant.get(kind, -1)
		index = _cosmetic_rng.randi_range(0, count - 1 if previous < 0 else count - 2)
		if index >= previous and previous >= 0:
			index += 1
	_last_variant[kind] = index
	return variants[index]

func _fade_out(player: AudioStreamPlayer) -> Tween:
	if _fades.has(player):
		_fades[player].kill()
	var fade := create_tween()
	_fades[player] = fade
	fade.tween_property(player, "volume_linear", 0.0, FADE_SECONDS)
	fade.tween_callback(func():
		player.stop()
		_fades.erase(player))
	return fade

func _start_voice(player: AudioStreamPlayer, stream: AudioStream, kind: String, gain: float) -> void:
	# A naturally finished tail may be reused before an old mute tween ends.
	if _fades.has(player):
		_fades[player].kill()
		_fades.erase(player)
	player.stream = stream
	player.volume_db = gain
	player.pitch_scale = 1.0
	_voice_kinds[player] = kind
	player.play()
	voice_starts += 1

func play_contact(kind: String, speed: float = 1.0) -> void:
	if not enabled or _players.is_empty() or not is_finite(speed) or speed < 0.005:
		return
	if not _sounds.has(kind):
		kind = "ball"
	_cursor += 1
	var stream := _next_variant(kind)
	var gain := contact_gain_db(speed)
	if kind == "cue": gain -= 2.0
	if kind == "rail": gain -= 1.0
	if kind == "pocket": gain -= 1.0
	for player in _players:
		if not player.playing and not _reserved.has(player):
			_start_voice(player, stream, kind, gain)
			return
	# Preserve cue/pocket tails where possible. Retire the quietest ball tail;
	# reserve its slot during the 6ms ramp so another event cannot cut the fade.
	var victim: AudioStreamPlayer = null
	for player in _players:
		if _reserved.has(player): continue
		if victim == null or (_voice_kinds.get(player, "ball") == "ball" and _voice_kinds.get(victim, "ball") != "ball") or (_voice_kinds.get(player, "ball") == _voice_kinds.get(victim, "ball") and player.volume_db < victim.volume_db):
			victim = player
	if victim == null:
		voice_drops += 1
		return
	voice_steals += 1
	_reserved[victim] = true
	var generation := _generation
	var fade := _fade_out(victim)
	fade.tween_callback(func():
		_reserved.erase(victim)
		if enabled and generation == _generation:
			_start_voice(victim, stream, kind, gain))

func _exit_tree() -> void:
	_generation += 1
	for fade in _fades.values(): fade.kill()
	_fades.clear()
	_reserved.clear()
	_voice_kinds.clear()
