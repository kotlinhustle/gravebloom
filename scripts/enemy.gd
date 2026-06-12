class_name Enemy
extends CharacterBody2D

signal died(enemy_position: Vector2)
signal damaged(enemy_position: Vector2, amount: int)
signal spitting(enemy_position: Vector2, direction: Vector2)

var last_hit_source := ""
var target: Node2D
var speed := 70.0
var max_health := 2
var health := 2
var is_dead := false
var xp_value := 1
var is_miniboss := false
var knockback_velocity := Vector2.ZERO
var base_scale := Vector2.ONE
var anim_time := 0.0
var anim_offset := randf() * TAU
var attack_recoil := 0.0
var hit_reaction := 0.0
var uses_walk_frames := false
var animation_frame_count := 1
var facing_right := false
var enemy_kind := "crawler"
var contact_damage := 18.0
var spit_timer := 1.8
var spit_cooldown := 2.6
var preferred_range := 280.0
var separation_radius := 54.0
var separation_strength := 0.42
var flank_side := 1.0
var flank_distance := 150.0
var flank_ahead := 135.0
var obstacle_steer_timer := 0.0
var obstacle_steer_direction := Vector2.ZERO

@onready var art := $Art
@onready var shadow := $Shadow
@onready var base_art_position: Vector2 = art.position
@onready var base_art_scale: Vector2 = art.scale
@onready var base_shadow_position: Vector2 = shadow.position
@onready var base_shadow_scale: Vector2 = shadow.scale

func _physics_process(delta: float) -> void:
	if is_dead or target == null:
		velocity = Vector2.ZERO
		return
	var direction := global_position.direction_to(target.global_position)
	rotation = 0.0
	obstacle_steer_timer = maxf(0.0, obstacle_steer_timer - delta)
	velocity = _movement_direction(direction, delta) * speed + knockback_velocity
	var movement_ratio: float = clampf(velocity.length() / maxf(speed, 1.0), 0.0, 1.5)
	anim_time += delta * _animation_speed(movement_ratio)
	attack_recoil = maxf(0.0, attack_recoil - delta)
	hit_reaction = maxf(0.0, hit_reaction - delta)
	if absf(velocity.x) > 4.0:
		facing_right = velocity.x > 0.0
	art.flip_h = facing_right
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 900.0 * delta)
	move_and_slide()
	_update_obstacle_steering()
	_animate_art(delta, movement_ratio)

func _movement_direction(direction: Vector2, delta: float) -> Vector2:
	if obstacle_steer_timer > 0.0 and obstacle_steer_direction != Vector2.ZERO:
		return _with_separation(obstacle_steer_direction)
	if enemy_kind in ["flanker", "ash_ember"]:
		return _flanker_direction(direction)
	if enemy_kind not in ["spitter", "ash_bellringer"]:
		return _with_separation(direction)
	var distance := global_position.distance_to(target.global_position)
	spit_timer -= delta
	if spit_timer <= 0.0 and distance < 520.0:
		spit_timer = spit_cooldown
		attack_recoil = 0.3
		spitting.emit(global_position, _get_lead_direction(direction))
	if distance < preferred_range * 0.74:
		return _with_separation(-direction)
	if distance > preferred_range:
		return _with_separation(direction)
	return _with_separation(Vector2.ZERO)

func _update_obstacle_steering() -> void:
	if get_slide_collision_count() <= 0 or target == null:
		return
	var collision := get_slide_collision(0)
	var normal := collision.get_normal()
	var tangent_a := normal.rotated(PI * 0.5)
	var tangent_b := -tangent_a
	var target_direction := global_position.direction_to(target.global_position)
	obstacle_steer_direction = tangent_a if tangent_a.dot(target_direction) >= tangent_b.dot(target_direction) else tangent_b
	obstacle_steer_timer = 0.42

func _flanker_direction(direction: Vector2) -> Vector2:
	var target_velocity := Vector2.ZERO
	if target is CharacterBody2D:
		target_velocity = (target as CharacterBody2D).velocity
	var forward := target_velocity.normalized()
	if forward == Vector2.ZERO:
		forward = direction
	var flank_target := target.global_position + forward * flank_ahead + forward.rotated(PI / 2.0) * flank_side * flank_distance
	var flank_direction := global_position.direction_to(flank_target)
	return _with_separation(flank_direction)

func _get_lead_direction(fallback_direction: Vector2) -> Vector2:
	if target == null:
		return fallback_direction
	var target_velocity := Vector2.ZERO
	if target is CharacterBody2D:
		target_velocity = (target as CharacterBody2D).velocity
	var lead_time: float = clampf(global_position.distance_to(target.global_position) / 320.0, 0.35, 0.85)
	var predicted_position: Vector2 = target.global_position + target_velocity * lead_time
	return global_position.direction_to(predicted_position)

func _with_separation(base_direction: Vector2) -> Vector2:
	var separation := Vector2.ZERO
	for other in get_tree().get_nodes_in_group("enemies"):
		if other == self or not (other is Enemy):
			continue
		var other_enemy := other as Enemy
		var offset: Vector2 = global_position - other_enemy.global_position
		var distance: float = offset.length()
		if distance <= 0.0 or distance > separation_radius:
			continue
		separation += offset.normalized() * ((separation_radius - distance) / separation_radius)
	var combined := base_direction + separation * separation_strength
	if combined.length() > 1.0:
		return combined.normalized()
	return combined

func _animation_speed(movement_ratio: float) -> float:
	match enemy_kind:
		"runner", "flanker", "ash_ember":
			return lerpf(7.0, 14.0, minf(movement_ratio, 1.0))
		"brute", "ash_bellringer", "miniboss":
			return lerpf(2.2, 5.0, minf(movement_ratio, 1.0))
		"grave_king":
			return lerpf(1.8, 3.8, minf(movement_ratio, 1.0))
		"spitter":
			return lerpf(3.2, 6.2, minf(movement_ratio, 1.0))
		_:
			return lerpf(4.0, 8.0, minf(movement_ratio, 1.0))

func _animate_art(delta: float, movement_ratio: float) -> void:
	var phase: float = anim_time + anim_offset
	var step: float = sin(phase)
	var planted_step: float = absf(step)
	if uses_walk_frames:
		var frame_progress: float = fposmod(phase, TAU) / TAU
		art.frame = int(floor(frame_progress * float(animation_frame_count))) % animation_frame_count
		var frame_scale := base_art_scale
		if hit_reaction > 0.0:
			var hit_strength: float = hit_reaction / 0.14
			frame_scale *= Vector2(1.0 + hit_strength * 0.2, 1.0 - hit_strength * 0.16)
		art.position = art.position.lerp(base_art_position, minf(1.0, delta * 18.0))
		art.rotation = lerp_angle(art.rotation, 0.0, minf(1.0, delta * 18.0))
		art.scale = art.scale.lerp(frame_scale, minf(1.0, delta * 18.0))
		shadow.position = shadow.position.lerp(base_shadow_position, minf(1.0, delta * 12.0))
		shadow.scale = shadow.scale.lerp(base_shadow_scale, minf(1.0, delta * 12.0))
		shadow.modulate.a = lerpf(shadow.modulate.a, 0.6, minf(1.0, delta * 10.0))
		_animate_role_markers(delta)
		return
	var art_offset := Vector2.ZERO
	var art_rotation := 0.0
	var scale_target := base_art_scale
	var shadow_scale_target := base_shadow_scale
	var shadow_alpha := 0.65

	match enemy_kind:
		"runner", "flanker", "ash_ember":
			art_offset = Vector2(step * 3.8, -planted_step * 5.0)
			art_rotation = step * 0.11
			scale_target *= Vector2(0.92 + planted_step * 0.05, 1.08 - planted_step * 0.04)
			shadow_scale_target *= Vector2(1.18 - planted_step * 0.16, 0.82 + planted_step * 0.08)
			shadow_alpha = 0.5
		"brute", "ash_bellringer":
			var stomp := pow(planted_step, 3.0)
			art_offset = Vector2(step * 2.0, -stomp * 2.8)
			art_rotation = step * 0.035
			scale_target *= Vector2(1.0 + stomp * 0.045, 1.0 - stomp * 0.035)
			shadow_scale_target *= Vector2(1.0 + stomp * 0.1, 1.0 + stomp * 0.05)
			shadow_alpha = 0.78
		"spitter":
			var charge: float = clampf(1.0 - spit_timer / 0.7, 0.0, 1.0)
			var recoil: float = sin((attack_recoil / 0.3) * PI) if attack_recoil > 0.0 else 0.0
			art_offset = Vector2(step * 1.3, -charge * 3.5 + recoil * 7.0)
			art_rotation = step * 0.025
			scale_target *= Vector2(1.0 + charge * 0.14 + recoil * 0.08, 1.0 - charge * 0.08 - recoil * 0.12)
			shadow_scale_target *= Vector2(1.0 + charge * 0.18, 1.0 + charge * 0.08)
			shadow_alpha = 0.58 + charge * 0.18
		"exploder":
			var pulse := (sin(phase * 1.7) + 1.0) * 0.5
			art_offset = Vector2(step * 1.8, -pulse * 2.0)
			art_rotation = step * 0.05
			scale_target *= Vector2.ONE * (0.96 + pulse * 0.12)
			shadow_scale_target *= Vector2.ONE * (0.94 + pulse * 0.14)
			shadow_alpha = 0.55 + pulse * 0.22
		"ash_acolyte", "miniboss":
			art_offset = Vector2(step * 2.2, -4.0 - sin(phase * 0.7) * 2.5)
			art_rotation = step * 0.045
			scale_target *= Vector2(1.0 + step * 0.02, 1.0 - step * 0.02)
			shadow_scale_target *= Vector2(0.96 + planted_step * 0.08, 0.92 + planted_step * 0.05)
			shadow_alpha = 0.6
		"grave_king":
			var loom := (sin(phase * 0.72) + 1.0) * 0.5
			art_offset = Vector2(step * 1.5, -3.0 - loom * 4.0)
			art_rotation = step * 0.022
			scale_target *= Vector2(1.0 + loom * 0.025, 1.0 - loom * 0.015)
			shadow_scale_target *= Vector2(1.05 + loom * 0.12, 1.0 + loom * 0.06)
			shadow_alpha = 0.84
		_:
			art_offset = Vector2(step * 3.0, -planted_step * 3.2)
			art_rotation = step * 0.07
			scale_target *= Vector2(1.0 + planted_step * 0.035, 1.0 - planted_step * 0.03)
			shadow_scale_target *= Vector2(1.08 - planted_step * 0.1, 0.94 + planted_step * 0.05)

	art_offset *= lerpf(0.35, 1.0, minf(movement_ratio, 1.0))
	if hit_reaction > 0.0:
		var hit_strength: float = hit_reaction / 0.14
		scale_target *= Vector2(1.0 + hit_strength * 0.2, 1.0 - hit_strength * 0.16)
		art_offset.y += hit_strength * 4.0
	art.position = art.position.lerp(base_art_position + art_offset, minf(1.0, delta * 18.0))
	art.rotation = lerp_angle(art.rotation, art_rotation, minf(1.0, delta * 16.0))
	art.scale = art.scale.lerp(scale_target, minf(1.0, delta * 15.0))
	shadow.position = shadow.position.lerp(base_shadow_position + Vector2(0.0, planted_step * 1.5), minf(1.0, delta * 12.0))
	shadow.scale = shadow.scale.lerp(shadow_scale_target, minf(1.0, delta * 12.0))
	shadow.modulate.a = lerpf(shadow.modulate.a, shadow_alpha, minf(1.0, delta * 10.0))
	_animate_role_markers(delta)

func _animate_role_markers(delta: float) -> void:
	var ring := get_node_or_null("RoleRing") as CanvasItem
	if ring != null:
		ring.modulate.a = 0.62 + sin(anim_time * 1.8) * 0.22
		ring.rotation += delta * (2.0 if enemy_kind == "exploder" else 0.6)
	var mark := get_node_or_null("RoleMark") as CanvasItem
	if mark != null:
		mark.modulate.a = 0.72 + sin(anim_time * 2.5) * 0.2
		mark.position.y = -34.0 + sin(anim_time * 2.1) * 2.0
	var left_wing := get_node_or_null("RoleWingLeft") as CanvasItem
	var right_wing := get_node_or_null("RoleWingRight") as CanvasItem
	if left_wing != null and right_wing != null:
		var wing_alpha := 0.42 + sin(anim_time * 4.0) * 0.18
		left_wing.modulate.a = wing_alpha
		right_wing.modulate.a = wing_alpha

func take_damage(amount: int, hit_origin: Vector2 = Vector2.ZERO, knockback_force: float = 170.0, hit_source: String = "") -> void:
	if is_dead:
		return
	last_hit_source = hit_source
	health -= amount
	damaged.emit(global_position, amount)
	if hit_origin != Vector2.ZERO:
		knockback_velocity = hit_origin.direction_to(global_position) * knockback_force
	hit_reaction = 0.14
	scale = base_scale * Vector2(1.18, 0.82)
	modulate = Color(1.0, 0.95, 0.62)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	tween.tween_property(self, "scale", base_scale, 0.1)
	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	died.emit(global_position)
	queue_free()
