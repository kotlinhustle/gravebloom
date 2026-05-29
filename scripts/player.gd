class_name Player
extends CharacterBody2D

var speed := 225.0
var max_health := 100.0
var health := 100.0
var is_dead := false
var touch_start := Vector2.ZERO
var touch_direction := Vector2.ZERO
var touch_active := false

func _physics_process(_delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return
	var keyboard_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := touch_direction
	if keyboard_direction.length() > 0.0:
		direction = keyboard_direction
	velocity = direction * speed
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		touch_active = event.pressed
		touch_start = event.position
		touch_direction = Vector2.ZERO
	elif event is InputEventScreenDrag and touch_active:
		_update_touch_direction(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		touch_active = event.pressed
		touch_start = event.position
		touch_direction = Vector2.ZERO
	elif event is InputEventMouseMotion and touch_active and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_update_touch_direction(event.position)

func _update_touch_direction(pointer_position: Vector2) -> void:
	var drag_vector := pointer_position - touch_start
	if drag_vector.length() > 18.0:
		touch_direction = drag_vector.normalized()
	else:
		touch_direction = Vector2.ZERO

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health = max(0.0, health - amount)
	modulate = Color(1.0, 0.55, 0.55)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.12)
	if health <= 0.0:
		is_dead = true
