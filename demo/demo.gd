extends Node2D
## Self-playing showcase for Saltmire Juice. Auto-fires impacts on a loop (great
## for a preview GIF), and also reacts to mouse clicks. Read it as usage example.

@onready var cam: Camera2D = $Camera2D
@onready var target: Polygon2D = $Target

var _t: float = 1.0

func _process(delta: float) -> void:
	_t -= delta
	if _t <= 0.0:
		_t = randf_range(0.35, 0.6)
		_hit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_hit()

func _hit() -> void:
	var dmg: int = randi_range(5, 130)
	var big: bool = dmg > 95
	Juice.flash(target, Color(5, 2, 2) if big else Color(4, 4, 4))
	Juice.pop(target, 1.18 if big else 1.1)
	Juice.damage_number(self, target.global_position + Vector2(randf_range(-24, 24), -46), dmg, {
		"color": Color(1, 0.85, 0.3) if big else Color(1, 1, 1),
		"scale": 1.5 if big else 1.0,
	})
	Juice.shake(cam, 0.6 if big else 0.22)
	if big:
		Juice.hitstop(0.09)
