class_name CombatFx
extends RefCounted

static func damage_number(parent: Node, position: Vector2, amount: int) -> void:
	var label := Label.new()
	label.text = str(amount)
	label.global_position = position + Vector2(randf_range(-10.0, 10.0), -28.0)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.9, 1.0, 0.76))
	label.add_theme_color_override("font_shadow_color", Color(0.02, 0.015, 0.02, 0.9))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(label)
	var tween := parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position", label.global_position + Vector2(0, -34), 0.42)
	tween.tween_property(label, "modulate:a", 0.0, 0.42)
	tween.chain().tween_callback(label.queue_free)

static func burst(parent: Node, position: Vector2, color: Color, count: int = 10) -> void:
	for i in range(count):
		var particle := Polygon2D.new()
		particle.color = color
		particle.polygon = PackedVector2Array([
			Vector2(0, -3),
			Vector2(3, 0),
			Vector2(0, 3),
			Vector2(-3, 0)
		])
		particle.global_position = position
		particle.rotation = randf() * TAU
		parent.add_child(particle)
		var direction := Vector2.RIGHT.rotated(randf() * TAU)
		var distance := randf_range(26.0, 72.0)
		var tween := parent.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", position + direction * distance, 0.32)
		tween.tween_property(particle, "scale", Vector2.ZERO, 0.32)
		tween.tween_property(particle, "modulate:a", 0.0, 0.32)
		tween.chain().tween_callback(particle.queue_free)

static func ring(parent: Node, position: Vector2, color: Color, radius: float, duration: float = 0.42) -> void:
	var ring_line := Line2D.new()
	ring_line.width = 4.0
	ring_line.default_color = color
	ring_line.closed = true
	var points := PackedVector2Array()
	for i in range(32):
		points.append(Vector2.RIGHT.rotated(TAU * float(i) / 32.0) * 8.0)
	ring_line.points = points
	ring_line.global_position = position
	parent.add_child(ring_line)
	var tween := parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring_line, "scale", Vector2.ONE * (radius / 8.0), duration)
	tween.tween_property(ring_line, "modulate:a", 0.0, duration)
	tween.chain().tween_callback(ring_line.queue_free)
