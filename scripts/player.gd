class_name Player
extends CharacterBody2D

var speed := 225.0
var max_health := 100.0
var health := 100.0
var is_dead := false
var touch_start := Vector2.ZERO
var touch_direction := Vector2.ZERO
var touch_active := false
var mouse_drag_active := false
var mouse_drag_start := Vector2.ZERO
var key_left := false
var key_right := false
var key_up := false
var key_down := false

func _physics_process(_delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return
	_update_mouse_drag_direction()
	var keyboard_direction := _get_keyboard_direction()
	var direction := touch_direction
	if keyboard_direction.length() > 0.0:
		direction = keyboard_direction
	velocity = direction * speed
	move_and_slide()

func _get_keyboard_direction() -> Vector2:
	var direction := Vector2.ZERO
	if key_left:
		direction.x -= 1.0
	if key_right:
		direction.x += 1.0
	if key_up:
		direction.y -= 1.0
	if key_down:
		direction.y += 1.0
	if direction.length() > 1.0:
		return direction.normalized()
	if direction.length() > 0.0:
		return direction
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1.0
	if direction.length() > 1.0:
		direction = direction.normalized()
	return direction

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		_update_key_state(event)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		touch_active = event.pressed
		touch_start = event.position
		touch_direction = Vector2.ZERO
	elif event is InputEventScreenDrag and touch_active:
		_update_touch_direction(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_drag_active = event.pressed
		mouse_drag_start = event.position
		touch_start = event.position
		if not mouse_drag_active:
			touch_direction = Vector2.ZERO

func _update_mouse_drag_direction() -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouse_drag_active = false
		touch_direction = Vector2.ZERO
		return
	if not mouse_drag_active:
		mouse_drag_active = true
		mouse_drag_start = get_viewport().get_mouse_position()
		touch_start = mouse_drag_start
	_update_touch_direction(get_viewport().get_mouse_position())

func _update_touch_direction(pointer_position: Vector2) -> void:
	var drag_vector := pointer_position - touch_start
	if drag_vector.length() > 18.0:
		touch_direction = drag_vector.normalized()
	else:
		touch_direction = Vector2.ZERO

func _update_key_state(event: InputEventKey) -> void:
	var pressed_now := event.pressed and not event.echo
	var key := event.keycode
	var physical_key := event.physical_keycode
	if key == KEY_A or key == KEY_LEFT or physical_key == KEY_A or physical_key == KEY_LEFT:
		key_left = pressed_now
	elif key == KEY_D or key == KEY_RIGHT or physical_key == KEY_D or physical_key == KEY_RIGHT:
		key_right = pressed_now
	elif key == KEY_W or key == KEY_UP or physical_key == KEY_W or physical_key == KEY_UP:
		key_up = pressed_now
	elif key == KEY_S or key == KEY_DOWN or physical_key == KEY_S or physical_key == KEY_DOWN:
		key_down = pressed_now

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health = max(0.0, health - amount)
	modulate = Color(1.0, 0.55, 0.55)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.12)
	if health <= 0.0:
		is_dead = true
