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

@onready var art := $Art
@onready var base_art_position: Vector2 = art.position
@onready var base_art_scale: Vector2 = art.scale

func _physics_process(delta: float) -> void:
	if is_dead or target == null:
		velocity = Vector2.ZERO
		return
	anim_time += delta * (7.0 if not is_miniboss else 3.5)
	var direction := global_position.direction_to(target.global_position)
	rotation = direction.angle() + PI / 2.0
	velocity = _movement_direction(direction, delta) * speed + knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 900.0 * delta)
	move_and_slide()
	_animate_art(delta)

func _movement_direction(direction: Vector2, delta: float) -> Vector2:
	if enemy_kind in ["flanker", "ash_ember"]:
		return _flanker_direction(direction)
	if enemy_kind not in ["spitter", "ash_bellringer"]:
		return _with_separation(direction)
	var distance := global_position.distance_to(target.global_position)
	spit_timer -= delta
	if spit_timer <= 0.0 and distance < 520.0:
		spit_timer = spit_cooldown
		spitting.emit(global_position, _get_lead_direction(direction))
	if distance < preferred_range * 0.74:
		return _with_separation(-direction)
	if distance > preferred_range:
		return _with_separation(direction)
	return _with_separation(Vector2.ZERO)

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

func _animate_art(delta: float) -> void:
	var crawl := sin(anim_time) * (2.6 if not is_miniboss else 1.6)
	art.position = base_art_position + Vector2(crawl, 0)
	var squash := 1.0 + sin(anim_time * 1.7) * (0.035 if not is_miniboss else 0.018)
	art.scale = art.scale.move_toward(base_art_scale * Vector2(squash, 1.0 / squash), delta * 12.0)
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
	scale = base_scale * Vector2(1.18, 0.82)
	modulate = Color(1.0, 0.95, 0.62)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	tween.tween_property(self, "scale", base_scale, 0.1)
	tween.tween_property(art, "scale", base_art_scale * Vector2(1.26, 0.76), 0.06)
	tween.chain().tween_property(art, "scale", base_art_scale, 0.1)
	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	died.emit(global_position)
	queue_free()
