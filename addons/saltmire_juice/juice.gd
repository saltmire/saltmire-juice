extends Node
## Saltmire Juice — a tiny, free game-feel kit for Godot 4.
## Trauma-based screen shake, hit-stop, flash, pooled damage numbers, scale punch.
## Autoloaded as `Juice`. MIT licensed. https://saltmire.itch.io
##
## Quick use:
##   Juice.shake($Camera2D, 0.6)
##   await Juice.hitstop(0.08)
##   Juice.flash($Sprite2D, Color.RED)
##   Juice.damage_number(self, global_position, 25)
##   Juice.pop($Icon)

const DamageNumber := preload("res://addons/saltmire_juice/damage_number.gd")

# ---------------------------------------------------------------------------
# Screen shake (trauma-based — Nolla/Squirrel Eiserloh style)
# ---------------------------------------------------------------------------
# trauma builds additively and decays over time; actual shake = trauma^2 so
# small hits are subtle and big ones punch. Multiple cameras supported.
var _shakes: Dictionary = {}

func shake(camera: Camera2D, amount: float = 0.5, decay: float = 1.4,
		max_offset: Vector2 = Vector2(22, 14), max_roll: float = 0.08) -> void:
	if camera == null:
		return
	var s: Dictionary = _shakes.get(camera, {"trauma": 0.0})
	s.trauma = minf(1.0, float(s.get("trauma", 0.0)) + amount)
	s.decay = decay
	s.max_offset = max_offset
	s.max_roll = max_roll
	_shakes[camera] = s
	set_process(true)

func _process(delta: float) -> void:
	if _shakes.is_empty():
		set_process(false)
		return
	for cam in _shakes.keys():
		if not is_instance_valid(cam):
			_shakes.erase(cam)
			continue
		var s: Dictionary = _shakes[cam]
		s.trauma = maxf(0.0, s.trauma - s.decay * delta)
		var amt: float = s.trauma * s.trauma
		if s.trauma <= 0.0:
			cam.offset = Vector2.ZERO
			cam.rotation = 0.0
			_shakes.erase(cam)
		else:
			cam.offset = Vector2(randf_range(-1.0, 1.0) * s.max_offset.x,
								 randf_range(-1.0, 1.0) * s.max_offset.y) * amt
			cam.rotation = randf_range(-1.0, 1.0) * s.max_roll * amt

# ---------------------------------------------------------------------------
# Hit-stop / freeze-frame
# ---------------------------------------------------------------------------
# Briefly drops Engine.time_scale for impact. Uses a real-time timer so it
# still resumes while the game is frozen. Nested calls are safe (last wins).
var _hitstop_token: int = 0

func hitstop(duration: float = 0.08, time_scale: float = 0.0) -> void:
	_hitstop_token += 1
	var token: int = _hitstop_token
	Engine.time_scale = time_scale
	# ignore_time_scale = true so the timer fires while frozen.
	await get_tree().create_timer(duration, true, false, true).timeout
	if token == _hitstop_token:
		Engine.time_scale = 1.0

# ---------------------------------------------------------------------------
# Flash (tint a CanvasItem then fade back)
# ---------------------------------------------------------------------------
func flash(target: CanvasItem, color: Color = Color(4, 4, 4, 1),
		duration: float = 0.15, back_to: Color = Color(1, 1, 1, 1)) -> void:
	if target == null:
		return
	target.modulate = color
	var t := target.create_tween()
	t.tween_property(target, "modulate", back_to, duration)

# ---------------------------------------------------------------------------
# Scale punch (juicy pop)
# ---------------------------------------------------------------------------
func pop(node: Node, scale_mult: float = 1.25, duration: float = 0.18) -> void:
	if node == null or not ("scale" in node):
		return
	var base: Vector2 = node.scale
	node.scale = base * scale_mult
	var t := node.create_tween()
	t.tween_property(node, "scale", base, duration) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

# ---------------------------------------------------------------------------
# Damage numbers (pooled floating labels)
# ---------------------------------------------------------------------------
var _pool: Array[Node] = []

func damage_number(parent: Node, world_pos: Vector2, value: Variant,
		options: Dictionary = {}) -> void:
	if parent == null:
		return
	var n: Node = _pool.pop_back() if not _pool.is_empty() else DamageNumber.new()
	if n.get_parent() != parent:
		if n.get_parent() != null:
			n.get_parent().remove_child(n)
		parent.add_child(n)
	n.global_position = world_pos
	n.play(value, options, Callable(self, "_recycle").bind(n))

func _recycle(n: Node) -> void:
	if is_instance_valid(n):
		if n.get_parent() != null:
			n.get_parent().remove_child(n)
		_pool.append(n)
