extends Node2D
## Self-playing showcase for Saltmire Juice. Auto-fires impacts on a loop (great
## for a preview GIF), and also reacts to mouse clicks. Read it as usage example.
##
## [FIX 1.1.0] This file used to call `Juice.flash(...)` directly. `Juice` is an
## autoload that only exists after the plugin is enabled — but Godot parses every
## .gd file the moment the zip is extracted into a project, which is BEFORE anyone
## has had a chance to enable anything. Reproduced with
## `godot --headless --check-only --script demo/demo.gd` in a clean project:
## six "Identifier Juice not declared in the current scope" errors, then
## "Failed to load script". Same defect was found and fixed in Saltmire Save.
## Resolving the singleton at runtime keeps the parser out of it.

@onready var cam: Camera2D = $Camera2D
@onready var target: Polygon2D = $Target

## Resolved at runtime, never seen by the parser. Null if the plugin is disabled.
var _juice: Node = null

var _t: float = 1.0

func _ready() -> void:
	_juice = get_node_or_null("/root/Juice")
	if _juice == null:
		push_warning("Saltmire Juice: enable the plugin in Project Settings -> Plugins, "
			+ "then run this scene again.")
		set_process(false)

func _process(delta: float) -> void:
	_t -= delta
	if _t <= 0.0:
		_t = randf_range(0.35, 0.6)
		_hit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_hit()

func _hit() -> void:
	if _juice == null:
		return
	var dmg: int = randi_range(5, 130)
	var big: bool = dmg > 95
	# In your own code this is just: Juice.flash(target, ...)
	_juice.flash(target, Color(5, 2, 2) if big else Color(4, 4, 4))
	_juice.pop(target, 1.18 if big else 1.1)
	_juice.damage_number(self, target.global_position + Vector2(randf_range(-24, 24), -46), dmg, {
		"color": Color(1, 0.85, 0.3) if big else Color(1, 1, 1),
		"scale": 1.5 if big else 1.0,
	})
	_juice.shake(cam, 0.6 if big else 0.22)
	if big:
		_juice.hitstop(0.09)
