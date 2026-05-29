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

func _physics_process(delta: float) -> void:
	if is_dead or target == null:
		velocity = Vector2.ZERO
		return
	var direction := global_position.direction_to(target.global_position)
	rotation = direction.angle() + PI / 2.0
	velocity = direction * speed + knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 900.0 * delta)
	move_and_slide()

func take_damage(amount: int, hit_origin: Vector2 = Vector2.ZERO, knockback_force: float = 170.0) -> void:
	if is_dead:
		return
	health -= amount
	damaged.emit(global_position, amount)
	if hit_origin != Vector2.ZERO:
		knockback_velocity = hit_origin.direction_to(global_position) * knockback_force
	scale = Vector2(1.18, 0.82)
	modulate = Color(1.0, 0.95, 0.62)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	died.emit(global_position)
	queue_free()
