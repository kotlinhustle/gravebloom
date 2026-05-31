class_name Enemy
extends CharacterBody2D

signal died(enemy_position: Vector2)
signal damaged(enemy_position: Vector2, amount: int)
signal spitting(enemy_position: Vector2, direction: Vector2)

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
	if enemy_kind != "spitter":
		return direction
	var distance := global_position.distance_to(target.global_position)
	spit_timer -= delta
	if spit_timer <= 0.0 and distance < 520.0:
		spit_timer = spit_cooldown
		spitting.emit(global_position, direction)
	if distance < preferred_range * 0.74:
		return -direction
	if distance > preferred_range:
		return direction
	return Vector2.ZERO

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

func take_damage(amount: int, hit_origin: Vector2 = Vector2.ZERO, knockback_force: float = 170.0) -> void:
	if is_dead:
		return
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
