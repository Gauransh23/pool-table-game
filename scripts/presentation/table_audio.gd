extends Node
class_name TableAudio

var enabled := true
var _players: Array[AudioStreamPlayer] = []
var _cursor := 0
var _sounds := {}

func _ready() -> void:
	for kind in ["ball", "rail", "cue", "pocket"]:
		_sounds[kind] = load("res://assets/audio/%s.wav" % kind)
	for index in range(12):
		var player := AudioStreamPlayer.new()
		player.bus = &"Contacts"
		add_child(player)
		_players.append(player)

func play_contact(kind: String, speed: float = 1.0) -> void:
	if not enabled or _players.is_empty() or not is_finite(speed) or speed < 0.005:
		return
	# Distinct physics contacts can arrive together in one rendered frame. Do not
	# discard unrelated impacts based on CPU wall time; the voice pool bounds work.
	var player := _players[_cursor % _players.size()]
	_cursor += 1
	player.stream = _sounds.get(kind, _sounds["ball"])
	player.volume_db = clampf(-19.0 + 9.0 * log(maxf(0.1, speed)), -32.0, -7.0)
	player.pitch_scale = clampf(0.88 + speed * 0.045, 0.88, 1.3)
	player.play()
