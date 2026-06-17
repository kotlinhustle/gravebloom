class_name LivingBlade
extends Node2D

var owner_player: Node2D
var fx_layer: Node2D
var damage := 1
var level_damage_bonus := 0.0
var grave_king_damage_multiplier := 1.65
var blood_evolved := false
var king_heart_awakened := false
var cooldown := 0.72
var attack_range := 230.0
var dash_speed := 820.0
var return_speed := 620.0
var timer := 0.0
var visual_angle := 0.0
var target_enemy: Node2D
var state := "orbit"
var has_hit_target := false
var nearby_enemies: Array = []

@onready var blade_sprite := $Blade
@onready var base_blade_scale: Vector2 = blade_sprite.scale

func setup(player: Node2D, effects_parent: Node2D) -> void:
	owner_player = player
	fx_layer = effects_parent
	z_index = 20

func reset_to_owner() -> void:
	if owner_player == null:
		return
	z_index = 20
	target_enemy = null
	has_hit_target = false
	state = "orbit"
	timer = 0.0
	global_position = owner_player.global_position + Vector2.RIGHT * 34.0

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

func tick(delta: float, enemies: Array, priority_target: Node2D = null) -> void:
	if owner_player == null or owner_player.get("is_dead"):
		return
	nearby_enemies = enemies
	if state != "orbit":
		return
	timer -= delta
	if timer > 0.0:
		return
	var target := _choose_target(enemies, priority_target)
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

func awaken_king_heart() -> void:
	if king_heart_awakened:
		return
	king_heart_awakened = true
	damage += 2
	attack_range += 35.0
	base_blade_scale *= 1.22
	blade_sprite.scale = base_blade_scale
	blade_sprite.modulate = Color(1.0, 0.76, 0.36)

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
	var is_journey_objective := bool(target_enemy.get_meta("journey_objective", false))
	var target_kind := "" if is_journey_objective else String(target_enemy.get("enemy_kind"))
	if target_kind == "grave_king":
		hit_damage = int(ceil(float(hit_damage) * grave_king_damage_multiplier))
	var is_execution := false
	var target_health: Variant = target_enemy.get("health")
	var target_miniboss := false if is_journey_objective else bool(target_enemy.get("is_miniboss"))
	if target_health != null and not target_kind.is_empty():
		is_execution = int(target_health) <= hit_damage and not target_miniboss and target_kind != "grave_king"
	if is_execution:
		target_enemy.set_meta("execution_death", true)
		target_enemy.set_meta("execution_source", "blade")
	target_enemy.take_damage(hit_damage, owner_player.global_position, 360.0 if is_execution else 260.0, "blade")
	if king_heart_awakened:
		_cleave_near_target(target_enemy.global_position, hit_damage)
	if blood_evolved and owner_player.has_method("heal"):
		owner_player.heal(0.75)
	_show_impact(target_enemy.global_position, is_execution)
	blade_sprite.scale = base_blade_scale * (Vector2(1.95, 0.55) if is_execution else Vector2(1.55, 0.7))

func _cleave_near_target(hit_position: Vector2, hit_damage: int) -> void:
	for enemy in nearby_enemies:
		if not is_instance_valid(enemy) or enemy == target_enemy:
			continue
		if hit_position.distance_to(enemy.global_position) <= 82.0:
			enemy.take_damage(max(1, int(ceil(float(hit_damage) * 0.55))), hit_position, 220.0, "blade")

func _begin_return() -> void:
	state = "return"

func _face_position(target_position: Vector2) -> void:
	var direction := global_position.direction_to(target_position)
	if direction.length() > 0.0:
		rotation = direction.angle() + PI / 2.0

func _choose_target(enemies: Array, priority_target: Node2D) -> Node2D:
	# Approaching a chapter objective is an intentional attack command.
	if is_instance_valid(priority_target):
		var objective_range := maxf(440.0, attack_range * 1.65)
		if owner_player.global_position.distance_to(priority_target.global_position) <= objective_range:
			return priority_target
	return _nearest_enemy(enemies)

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
	if randf() > 0.18:
		return
	var trail := Line2D.new()
	trail.width = 3.0
	trail.default_color = Color(0.98, 0.72, 0.24, 0.58) if blood_evolved else Color(0.72, 1.0, 0.84, 0.45)
	var back := Vector2.UP.rotated(rotation) * 26.0
	trail.points = PackedVector2Array([global_position - back, global_position])
	fx_layer.add_child(trail)
	var tween := create_tween()
	tween.tween_property(trail, "modulate:a", 0.0, 0.16)
	tween.tween_callback(trail.queue_free)

func _show_impact(target_position: Vector2, is_execution: bool = false) -> void:
	if fx_layer == null:
		return
	var slash_direction := Vector2.RIGHT.rotated(rotation)
	var flash_color := Color(1.0, 0.74, 0.28, 0.94) if blood_evolved else Color(0.72, 1.0, 0.86, 0.92)
	CombatFx.impact_flash(fx_layer, target_position, slash_direction, flash_color, is_execution)
