extends Node
class_name TableAudio

var enabled := true
var _players: Array[AudioStreamPlayer] = []
var _cursor := 0
var _last_contact_ms := 0
var _sounds := {}

func _ready() -> void:
	for kind in ["ball", "rail", "cue", "pocket"]:
		_sounds[kind] = load("res://assets/audio/%s.wav" % kind)
	for index in range(12):
		var player := AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)

func play_contact(kind: String, speed: float = 1.0) -> void:
	if not enabled or _players.is_empty() or speed < 0.08:
		return
	var now := Time.get_ticks_msec()
	if kind == "ball" and now - _last_contact_ms < 16:
		return
	if kind == "ball":
		_last_contact_ms = now
	var player := _players[_cursor % _players.size()]
	_cursor += 1
	player.stream = _sounds.get(kind, _sounds["ball"])
	player.volume_db = clampf(-19.0 + 9.0 * log(maxf(0.1, speed)), -32.0, -7.0)
	player.pitch_scale = clampf(0.88 + speed * 0.045, 0.88, 1.3)
	player.play()
