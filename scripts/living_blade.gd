class_name LivingBlade
extends Node2D

var owner_player: Node2D
var fx_layer: Node2D
var damage := 1
var cooldown := 0.62
var attack_range := 145.0
var timer := 0.0

func setup(player: Node2D, effects_parent: Node2D) -> void:
	owner_player = player
	fx_layer = effects_parent

func _process(delta: float) -> void:
	if owner_player == null or owner_player.get("is_dead"):
		return
	global_position = owner_player.global_position
	rotation += delta * 5.5

func tick(delta: float, enemies: Array) -> void:
	if owner_player == null or owner_player.get("is_dead"):
		return
	timer -= delta
	if timer > 0.0:
		return
	var target := _nearest_enemy(enemies)
	if target == null:
		return
	_show_slash(target.global_position)
	target.take_damage(damage)
	timer = cooldown

func increase_damage() -> void:
	damage += 1

func quicken() -> void:
	cooldown = max(0.22, cooldown - 0.08)

func widen_reach() -> void:
	attack_range += 35.0

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

func _show_slash(target_position: Vector2) -> void:
	if fx_layer == null:
		return
	var slash := Line2D.new()
	slash.width = 5.0
	slash.default_color = Color(0.72, 1.0, 0.83, 0.95)
	slash.points = PackedVector2Array([
		owner_player.global_position,
		owner_player.global_position.lerp(target_position, 0.45) + Vector2(0, -24),
		target_position
	])
	fx_layer.add_child(slash)
	var tween := create_tween()
	tween.tween_property(slash, "modulate:a", 0.0, 0.16)
	tween.tween_callback(slash.queue_free)
