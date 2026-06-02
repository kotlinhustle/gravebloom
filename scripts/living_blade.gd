class_name LivingBlade
extends Node2D

var owner_player: Node2D
var fx_layer: Node2D
var damage := 1
var level_damage_bonus := 0.0
var grave_king_damage_multiplier := 1.65
var blood_evolved := false
var cooldown := 0.72
var attack_range := 230.0
var dash_speed := 820.0
var return_speed := 620.0
var timer := 0.0
var visual_angle := 0.0
var target_enemy: Node2D
var state := "orbit"
var has_hit_target := false

@onready var blade_sprite := $Blade
@onready var base_blade_scale: Vector2 = blade_sprite.scale

func setup(player: Node2D, effects_parent: Node2D) -> void:
	owner_player = player
	fx_layer = effects_parent

func _process(delta: float) -> void:
	if owner_player == null or owner_player.get("is_dead"):
		return
	match state:
		"orbit":
			_update_orbit(delta)
		"dash":
			_update_dash(delta)
		"return":
			_update_return(delta)

func tick(delta: float, enemies: Array) -> void:
	if owner_player == null or owner_player.get("is_dead"):
		return
	if state != "orbit":
		return
	timer -= delta
	if timer > 0.0:
		return
	var target := _nearest_enemy(enemies)
	if target == null:
		return
	target_enemy = target
	has_hit_target = false
	state = "dash"

func increase_damage() -> void:
	damage += 1

func set_level_damage_bonus(bonus: float) -> void:
	level_damage_bonus = bonus

func evolve_blood_blade() -> void:
	if blood_evolved:
		return
	blood_evolved = true
	damage += 2
	cooldown = max(0.22, cooldown - 0.12)
	dash_speed += 120.0
	return_speed += 90.0
	blade_sprite.modulate = Color(1.0, 0.48, 0.56)

func quicken() -> void:
	cooldown = max(0.22, cooldown - 0.08)

func widen_reach() -> void:
	attack_range += 45.0
	dash_speed += 95.0
	return_speed += 70.0
	cooldown = max(0.28, cooldown - 0.03)

func _update_orbit(delta: float) -> void:
	visual_angle += delta * 3.2
	var orbit_offset := Vector2.RIGHT.rotated(visual_angle) * 34.0
	global_position = owner_player.global_position + orbit_offset
	rotation = visual_angle + PI / 2.0
	var pulse := 1.0 + sin(visual_angle * 2.0) * 0.08
	blade_sprite.scale = blade_sprite.scale.move_toward(base_blade_scale * Vector2(pulse, 1.0 / pulse), delta * 8.0)

func _update_dash(delta: float) -> void:
	if not is_instance_valid(target_enemy):
		_begin_return()
		return
	var target_position := target_enemy.global_position
	_face_position(target_position)
	_leave_trail()
	global_position = global_position.move_toward(target_position, dash_speed * delta)
	if global_position.distance_to(target_position) <= 18.0:
		_hit_target()
		_begin_return()

func _update_return(delta: float) -> void:
	var return_position := owner_player.global_position + Vector2.RIGHT.rotated(visual_angle) * 34.0
	_face_position(return_position)
	global_position = global_position.move_toward(return_position, return_speed * delta)
	if global_position.distance_to(return_position) <= 8.0:
		state = "orbit"
		target_enemy = null
		timer = cooldown

func _hit_target() -> void:
	if has_hit_target or not is_instance_valid(target_enemy):
		return
	has_hit_target = true
	var hit_damage: int = max(1, int(ceil(float(damage) * (1.0 + level_damage_bonus))))
	if "enemy_kind" in target_enemy and target_enemy.enemy_kind == "grave_king":
		hit_damage = int(ceil(float(hit_damage) * grave_king_damage_multiplier))
	target_enemy.take_damage(hit_damage, owner_player.global_position, 260.0)
	if blood_evolved and owner_player.has_method("heal"):
		owner_player.heal(0.75)
	_show_impact(target_enemy.global_position)
	blade_sprite.scale = base_blade_scale * Vector2(1.55, 0.7)

func _begin_return() -> void:
	state = "return"

func _face_position(target_position: Vector2) -> void:
	var direction := global_position.direction_to(target_position)
	if direction.length() > 0.0:
		rotation = direction.angle() + PI / 2.0

func _nearest_enemy(enemies: Array) -> Node2D:
	var best: Node2D = null
	var best_distance := attack_range
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var distance := owner_player.global_position.distance_to(enemy.global_position)
		if distance < best_distance:
			best_distance = distance
			best = enemy
	return best

func _leave_trail() -> void:
	if fx_layer == null:
		return
	if randf() > 0.45:
		return
	var trail := Line2D.new()
	trail.width = 3.0
	trail.default_color = Color(1.0, 0.34, 0.48, 0.55) if blood_evolved else Color(0.72, 1.0, 0.84, 0.45)
	var back := Vector2.UP.rotated(rotation) * 26.0
	trail.points = PackedVector2Array([global_position - back, global_position])
	fx_layer.add_child(trail)
	var tween := create_tween()
	tween.tween_property(trail, "modulate:a", 0.0, 0.16)
	tween.tween_callback(trail.queue_free)

func _show_impact(target_position: Vector2) -> void:
	if fx_layer == null:
		return
	var slash := Line2D.new()
	slash.width = 10.0 if blood_evolved else 8.0
	slash.default_color = Color(1.0, 0.3, 0.42, 0.95) if blood_evolved else Color(0.72, 1.0, 0.83, 0.95)
	var slash_direction := Vector2.RIGHT.rotated(rotation)
	slash.points = PackedVector2Array([
		target_position - slash_direction * 34.0,
		target_position,
		target_position + slash_direction * 34.0
	])
	fx_layer.add_child(slash)
	var tween := create_tween()
	tween.tween_property(slash, "modulate:a", 0.0, 0.18)
	tween.tween_callback(slash.queue_free)
