class_name Enemy
extends CharacterBody2D

signal died(enemy_position: Vector2)
signal damaged(enemy_position: Vector2, amount: int)

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
	velocity = direction * speed + knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 900.0 * delta)
	move_and_slide()
	_animate_art(delta)

func _animate_art(delta: float) -> void:
	var crawl := sin(anim_time) * (2.6 if not is_miniboss else 1.6)
	art.position = base_art_position + Vector2(crawl, 0)
	var squash := 1.0 + sin(anim_time * 1.7) * (0.035 if not is_miniboss else 0.018)
	art.scale = art.scale.move_toward(base_art_scale * Vector2(squash, 1.0 / squash), delta * 12.0)

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
