class_name CombatFx
extends RefCounted

static func damage_number(parent: Node, position: Vector2, amount: int, color: Color = Color(0.9, 1.0, 0.76), font_size: int = 18) -> void:
	var label := Label.new()
	label.text = str(amount)
	label.global_position = position + Vector2(randf_range(-10.0, 10.0), -28.0)
	label.z_index = 100
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
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
		var particle_shape := PackedVector2Array()
		particle_shape.append(Vector2(0, -3))
		particle_shape.append(Vector2(3, 0))
		particle_shape.append(Vector2(0, 3))
		particle_shape.append(Vector2(-3, 0))
		particle.polygon = particle_shape
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

static func gore_burst(parent: Node, position: Vector2, execution: bool = false) -> void:
	var count := 16 if execution else 6
	for i in range(count):
		var shard := Polygon2D.new()
		var long_side := randf_range(7.0, 18.0) if execution else randf_range(5.0, 12.0)
		var short_side := randf_range(3.0, 8.0)
		var palette_roll := randf()
		if palette_roll < 0.52:
			shard.color = Color(0.58, 1.0, 0.46, randf_range(0.74, 0.98))
		elif palette_roll < 0.82:
			shard.color = Color(0.98, 0.74, 0.22, randf_range(0.68, 0.92))
		else:
			shard.color = Color(0.42, 0.16, 0.58, randf_range(0.62, 0.86))
		shard.polygon = PackedVector2Array([
			Vector2(0.0, -short_side),
			Vector2(long_side, 0.0),
			Vector2(0.0, short_side),
			Vector2(-short_side, 0.0),
		])
		shard.global_position = position
		shard.rotation = randf() * TAU
		shard.z_index = 90
		parent.add_child(shard)
		var direction := Vector2.RIGHT.rotated(randf() * TAU)
		var distance := randf_range(52.0, 132.0) if execution else randf_range(28.0, 82.0)
		var tween := parent.create_tween()
		tween.set_parallel(true)
		tween.tween_property(shard, "global_position", position + direction * distance, 0.42 if execution else 0.3)
		tween.tween_property(shard, "rotation", shard.rotation + randf_range(-2.4, 2.4), 0.42 if execution else 0.3)
		tween.tween_property(shard, "scale", Vector2.ZERO, 0.42 if execution else 0.3)
		tween.tween_property(shard, "modulate:a", 0.0, 0.42 if execution else 0.3)
		tween.chain().tween_callback(shard.queue_free)

static func directional_shards(parent: Node, position: Vector2, direction: Vector2, color: Color, heavy: bool = false) -> void:
	if direction.length() <= 0.0:
		direction = Vector2.RIGHT.rotated(randf() * TAU)
	direction = direction.normalized()
	var count := 18 if heavy else 11
	for i in range(count):
		var shard := Polygon2D.new()
		var length := randf_range(24.0, 46.0) if heavy else randf_range(14.0, 30.0)
		var width := randf_range(4.0, 9.0)
		shard.color = Color(color.r, color.g, color.b, randf_range(0.72, 0.96))
		shard.polygon = PackedVector2Array([
			Vector2(length, 0.0),
			Vector2(-length * 0.35, -width),
			Vector2(-length * 0.12, 0.0),
			Vector2(-length * 0.35, width),
		])
		var spread := randf_range(-0.72, 0.72)
		var fly_direction := direction.rotated(spread)
		shard.global_position = position + fly_direction * randf_range(4.0, 16.0)
		shard.rotation = fly_direction.angle()
		shard.z_index = 95
		parent.add_child(shard)
		var distance := randf_range(108.0, 210.0) if heavy else randf_range(64.0, 132.0)
		var duration := randf_range(0.36, 0.52) if heavy else randf_range(0.26, 0.4)
		var tween := parent.create_tween()
		tween.set_parallel(true)
		tween.tween_property(shard, "global_position", position + fly_direction * distance, duration)
		tween.tween_property(shard, "rotation", shard.rotation + randf_range(-0.65, 0.65), duration)
		tween.tween_property(shard, "scale", Vector2.ZERO, duration)
		tween.tween_property(shard, "modulate:a", 0.0, duration)
		tween.chain().tween_callback(shard.queue_free)

static func impact_flash(parent: Node, position: Vector2, direction: Vector2, color: Color, heavy: bool = false) -> void:
	if direction.length() <= 0.0:
		direction = Vector2.RIGHT
	direction = direction.normalized()
	var side := direction.orthogonal()
	var length := 118.0 if heavy else 76.0
	var width := 32.0 if heavy else 20.0
	var flash := Polygon2D.new()
	flash.color = color
	flash.polygon = PackedVector2Array([
		direction * length,
		side * width,
		-direction * length * 0.42,
		-side * width,
	])
	flash.global_position = position
	flash.rotation = randf_range(-0.08, 0.08)
	flash.z_index = 105
	parent.add_child(flash)
	var tween := parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(flash, "scale", Vector2.ONE * (1.34 if heavy else 1.2), 0.1)
	tween.tween_property(flash, "modulate:a", 0.0, 0.28 if heavy else 0.22)
	tween.chain().tween_callback(flash.queue_free)

static func splat(parent: Node, position: Vector2, color: Color, heavy: bool = false) -> void:
	var stain := Polygon2D.new()
	var radius := 38.0 if heavy else 24.0
	var points := PackedVector2Array()
	for i in range(12):
		var angle := TAU * float(i) / 12.0
		var local_radius := radius * randf_range(0.55, 1.12)
		points.append(Vector2.RIGHT.rotated(angle) * local_radius)
	stain.polygon = points
	stain.color = Color(color.r * 0.72, color.g * 0.72, color.b * 0.72, 0.34 if heavy else 0.24)
	stain.global_position = position + Vector2(randf_range(-3.0, 3.0), randf_range(-2.0, 5.0))
	stain.rotation = randf() * TAU
	stain.z_index = 4
	parent.add_child(stain)
	var tween := parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(stain, "scale", Vector2.ONE * (1.18 if heavy else 1.08), 0.18)
	tween.tween_property(stain, "modulate:a", 0.0, 1.05 if heavy else 0.72)
	tween.chain().tween_callback(stain.queue_free)

static func combat_text(parent: Node, position: Vector2, text: String, color: Color = Color(1.0, 0.92, 0.72), font_size: int = 28) -> void:
	var label := Label.new()
	label.text = text
	label.global_position = position + Vector2(randf_range(-20.0, 20.0), -58.0)
	label.z_index = 120
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.02, 0.0, 0.0, 0.95))
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)
	parent.add_child(label)
	var tween := parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position", label.global_position + Vector2(0.0, -46.0), 0.58)
	tween.tween_property(label, "scale", Vector2.ONE * 1.12, 0.18)
	tween.tween_property(label, "modulate:a", 0.0, 0.58)
	tween.chain().tween_callback(label.queue_free)

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

static func sparkle(parent: Node, position: Vector2, color: Color, duration: float = 0.22) -> void:
	var dot := Polygon2D.new()
	dot.color = color
	var shape := PackedVector2Array()
	shape.append(Vector2(0, -2))
	shape.append(Vector2(2, 0))
	shape.append(Vector2(0, 2))
	shape.append(Vector2(-2, 0))
	dot.polygon = shape
	dot.global_position = position
	parent.add_child(dot)
	var tween := parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(dot, "scale", Vector2.ZERO, duration)
	tween.tween_property(dot, "modulate:a", 0.0, duration)
	tween.chain().tween_callback(dot.queue_free)
