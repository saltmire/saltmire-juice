extends Node2D
## Pooled floating damage number used by Juice.damage_number(). Rises, fades,
## then calls its recycle callback so it can be reused. Built in code — no scene
## dependency. You can restyle it via the `options` dictionary.

var _label: Label

func _ensure_label() -> void:
	if _label != null:
		return
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 20)
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	_label.add_theme_constant_override("outline_size", 4)
	add_child(_label)

func play(value: Variant, options: Dictionary, on_done: Callable) -> void:
	_ensure_label()
	_label.text = str(value)
	var color: Color = options.get("color", Color(1, 1, 1))
	var rise: float = options.get("rise", 36.0)
	var duration: float = options.get("duration", 0.65)
	var spread: float = options.get("spread", 10.0)
	var start_scale: float = options.get("scale", 1.0)

	_label.modulate = color
	modulate.a = 1.0
	scale = Vector2.ONE * start_scale
	# center the label on our origin (approximate; size resolves after set)
	_label.reset_size()
	_label.position = -_label.size * 0.5

	var start := position
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(self, "position",
		start + Vector2(randf_range(-spread, spread), -rise), duration) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
	# little pop at the start
	scale = Vector2.ONE * start_scale * 1.3
	t.tween_property(self, "scale", Vector2.ONE * start_scale, 0.18) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.chain().tween_callback(on_done)
