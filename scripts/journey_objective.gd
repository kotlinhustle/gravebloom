class_name JourneyObjective
extends Node2D

const GraveHeartTexturePath := "res://assets/sprites/grave_heart_objective.png"
const CursedBellTexturePath := "res://assets/sprites/cursed_bell_objective.png"

signal destroyed(objective_position: Vector2)
signal damaged(objective_position: Vector2, amount: int)

var objective_kind := "grave_heart"
var max_health := 24
var health := 24
var is_dead := false
var anim_time := 0.0

var body_root: Node2D
var health_fill: ColorRect
var objective_texture: Texture2D

func setup(kind: String, objective_health: int) -> void:
	objective_kind = kind
	max_health = objective_health
	health = objective_health
	z_index = 14
	set_meta("journey_objective", true)
	objective_texture = _load_image_texture(CursedBellTexturePath if objective_kind == "cursed_bell" else GraveHeartTexturePath)
	_build_visual()

func _process(delta: float) -> void:
	if is_dead or body_root == null:
		return
	anim_time += delta
	var pulse := 1.0 + sin(anim_time * 2.4) * 0.035
	body_root.scale = Vector2.ONE * pulse
	if objective_kind == "cursed_bell":
		body_root.rotation = sin(anim_time * 2.1) * 0.035

func take_damage(amount: int, _hit_origin: Vector2 = Vector2.ZERO, _knockback_force: float = 0.0, _hit_source: String = "") -> void:
	if is_dead:
		return
	health -= amount
	damaged.emit(global_position, amount)
	_update_health_bar()
	modulate = Color(1.0, 0.88, 0.62)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.12)
	if health <= 0:
		is_dead = true
		destroyed.emit(global_position)
		queue_free()

func _build_visual() -> void:
	body_root = Node2D.new()
	add_child(body_root)

	var shadow := _ellipse(78.0, 31.0, Color(0.0, 0.0, 0.0, 0.62), 24)
	shadow.position = Vector2(10.0, 42.0)
	body_root.add_child(shadow)

	if objective_kind == "cursed_bell":
		_build_bell()
	else:
		_build_heart()

	var bar_back := ColorRect.new()
	bar_back.color = Color(0.025, 0.025, 0.03, 0.92)
	bar_back.position = Vector2(-76.0, -112.0)
	bar_back.size = Vector2(152.0, 12.0)
	add_child(bar_back)
	health_fill = ColorRect.new()
	health_fill.color = Color(1.0, 0.62, 0.24) if objective_kind == "cursed_bell" else Color(0.48, 1.0, 0.62)
	health_fill.position = Vector2(3.0, 3.0)
	health_fill.size = Vector2(146.0, 6.0)
	bar_back.add_child(health_fill)

func _build_heart() -> void:
	var sprite := Sprite2D.new()
	sprite.texture = objective_texture
	sprite.centered = true
	sprite.position = Vector2(0.0, -8.0)
	sprite.scale = _fit_scale(objective_texture, 184.0)
	body_root.add_child(sprite)
	var glow := _ellipse(42.0, 54.0, Color(0.44, 1.0, 0.56, 0.18), 18)
	glow.position = Vector2(0.0, -10.0)
	body_root.add_child(glow)

func _build_bell() -> void:
	var sprite := Sprite2D.new()
	sprite.texture = objective_texture
	sprite.centered = true
	sprite.position = Vector2(0.0, -4.0)
	sprite.scale = _fit_scale(objective_texture, 194.0)
	body_root.add_child(sprite)
	var glow := _ellipse(46.0, 58.0, Color(1.0, 0.62, 0.26, 0.16), 18)
	glow.position = Vector2(0.0, 2.0)
	body_root.add_child(glow)

func _update_health_bar() -> void:
	if health_fill == null:
		return
	health_fill.size.x = 146.0 * clampf(float(health) / float(max_health), 0.0, 1.0)

func _ellipse(radius_x: float, radius_y: float, color: Color, segments: int) -> Polygon2D:
	var polygon := Polygon2D.new()
	var points := PackedVector2Array()
	for i in range(segments):
		var angle := TAU * float(i) / float(segments)
		points.append(Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	polygon.polygon = points
	polygon.color = color
	return polygon

func _fit_scale(texture: Texture2D, max_size: float) -> Vector2:
	if texture == null:
		return Vector2.ONE
	var size := texture.get_size()
	var scale_value := max_size / maxf(size.x, size.y)
	return Vector2.ONE * scale_value

func _load_image_texture(resource_path: String) -> Texture2D:
	var texture := load(resource_path) as Texture2D
	if texture != null:
		return texture
	var image := Image.load_from_file(resource_path)
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)
