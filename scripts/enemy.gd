class_name Enemy
extends CharacterBody2D

signal died(enemy_position: Vector2)

var target: Node2D
var speed := 70.0
var max_health := 2
var health := 2
var is_dead := false

func _physics_process(_delta: float) -> void:
	if is_dead or target == null:
		velocity = Vector2.ZERO
		return
	var direction := global_position.direction_to(target.global_position)
	rotation = direction.angle() + PI / 2.0
	velocity = direction * speed
	move_and_slide()

func take_damage(amount: int) -> void:
	if is_dead:
		return
	health -= amount
	modulate = Color(1.0, 0.85, 0.85)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.08)
	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	died.emit(global_position)
	queue_free()
