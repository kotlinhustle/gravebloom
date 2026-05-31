class_name Player
extends CharacterBody2D

const SPRITE_FRAME_SIZE := Vector2i(257, 258)
const SPRITE_FRAME_COUNT := 6
const IDLE_ROW := 0
const RUN_ROW := 1

var speed := 225.0
var max_health := 100.0
var health := 100.0
var is_dead := false
var touch_start := Vector2.ZERO
var touch_direction := Vector2.ZERO
var touch_active := false
var mouse_drag_active := false
var mouse_drag_start := Vector2.ZERO
var virtual_direction := Vector2.ZERO
var anim_time := 0.0
var sprite_frame := 0
var sprite_frame_timer := 0.0
var facing_left := false
var arena_limits := Vector2.ZERO

@onready var art := $Art
@onready var shadow := $Shadow
@onready var base_art_position: Vector2 = art.position
@onready var base_art_scale: Vector2 = art.scale
@onready var base_shadow_scale: Vector2 = shadow.scale

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return
	_update_mouse_drag_direction()
	var keyboard_direction := _get_keyboard_direction()
	var direction := touch_direction
	if virtual_direction.length() > 0.0:
		direction = virtual_direction
	if keyboard_direction.length() > 0.0:
		direction = keyboard_direction
	velocity = direction * speed
	move_and_slide()
	_clamp_to_arena()
	_animate_art(delta, direction)

func _animate_art(delta: float, direction: Vector2) -> void:
	var moving: bool = direction.length() > 0.0
	_update_sprite_frame(delta, direction, moving)
	anim_time += delta * (9.0 if moving else 3.0)
	var bob := sin(anim_time) * (2.4 if moving else 1.2)
	art.position = base_art_position + Vector2(0, bob)
	var lean: float = clamp(direction.x, -1.0, 1.0) * (0.055 if moving else 0.025)
	art.rotation = lerp(art.rotation, lean, delta * 10.0)
	var pulse := 1.0 + sin(anim_time * 0.75) * (0.012 if moving else 0.01)
	art.scale = base_art_scale * Vector2(pulse, 1.0 / pulse)
	shadow.scale = base_shadow_scale * Vector2(1.0 + abs(bob) * 0.012, 1.0 - abs(bob) * 0.006)

func _update_sprite_frame(delta: float, direction: Vector2, moving: bool) -> void:
	if abs(direction.x) > 0.05:
		facing_left = direction.x < 0.0
	art.flip_h = facing_left
	var row: int = RUN_ROW if moving else IDLE_ROW
	var fps: float = 12.0 if moving else 6.0
	sprite_frame_timer += delta
	if sprite_frame_timer >= 1.0 / fps:
		sprite_frame_timer = 0.0
		sprite_frame = (sprite_frame + 1) % SPRITE_FRAME_COUNT
	var rect_position := Vector2(SPRITE_FRAME_SIZE.x * sprite_frame, SPRITE_FRAME_SIZE.y * row)
	art.region_rect = Rect2(rect_position, Vector2(SPRITE_FRAME_SIZE))

func _get_keyboard_direction() -> Vector2:
	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP) or Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN) or Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		direction.y += 1.0
	if direction.length() > 1.0:
		direction = direction.normalized()
	return direction

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		clear_pointer_input()

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
		return
	_update_touch_direction(get_viewport().get_mouse_position())

func _update_touch_direction(pointer_position: Vector2) -> void:
	var drag_vector := pointer_position - touch_start
	if drag_vector.length() > 18.0:
		touch_direction = drag_vector.normalized()
	else:
		touch_direction = Vector2.ZERO

func set_virtual_direction(direction: Vector2) -> void:
	if direction.length() > 1.0:
		virtual_direction = direction.normalized()
	else:
		virtual_direction = direction

func clear_pointer_input() -> void:
	touch_active = false
	mouse_drag_active = false
	touch_direction = Vector2.ZERO

func set_arena_limits(limits: Vector2) -> void:
	arena_limits = limits

func _clamp_to_arena() -> void:
	if arena_limits == Vector2.ZERO:
		return
	global_position = Vector2(
		clamp(global_position.x, -arena_limits.x, arena_limits.x),
		clamp(global_position.y, -arena_limits.y, arena_limits.y)
	)

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health = max(0.0, health - amount)
	modulate = Color(1.0, 0.55, 0.55)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color.WHITE, 0.12)
	tween.tween_property(art, "scale", base_art_scale * Vector2(1.15, 0.86), 0.06)
	tween.chain().tween_property(art, "scale", base_art_scale, 0.1)
	if health <= 0.0:
		is_dead = true

func heal(amount: float) -> void:
	if is_dead:
		return
	health = min(max_health, health + amount)
	modulate = Color(0.72, 1.0, 0.76)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.16)
