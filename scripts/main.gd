extends Node2D

const PlayerScene := preload("res://scenes/player.tscn")
const EnemyScene := preload("res://scenes/enemy.tscn")
const XPShardScene := preload("res://scenes/xp_shard.tscn")
const LivingBladeScene := preload("res://scenes/living_blade.tscn")

var player: Player
var living_blade: Node2D
var enemies: Array[Enemy] = []
var shards: Array[XPShard] = []
var elapsed := 0.0
var spawn_timer := 0.0
var level := 1
var xp := 0
var xp_to_next := 8
var shard_pull_range := 95.0
var paused_for_upgrade := false

@onready var world := Node2D.new()
@onready var fx_layer := Node2D.new()
@onready var ui_layer := CanvasLayer.new()
@onready var hud := Label.new()
@onready var upgrade_panel := PanelContainer.new()
@onready var upgrade_list := VBoxContainer.new()

func _ready() -> void:
	randomize()
	add_child(world)
	add_child(fx_layer)
	_build_arena()
	_spawn_player()
	_build_ui()

func _process(delta: float) -> void:
	if player == null or player.is_dead:
		return
	if paused_for_upgrade:
		return
	elapsed += delta
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		_spawn_enemy_wave()
		spawn_timer = max(0.25, 1.25 - elapsed * 0.01)
	living_blade.tick(delta, enemies)
	_update_shards(delta)
	_check_enemy_contact(delta)
	_update_hud()

func _build_arena() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.045, 0.04, 0.056)
	bg.size = Vector2(4000, 4000)
	bg.position = Vector2(-2000, -2000)
	world.add_child(bg)
	for i in range(36):
		var stone := ColorRect.new()
		stone.color = Color(0.095, 0.09, 0.115, randf_range(0.18, 0.38))
		stone.size = Vector2(randf_range(38, 130), randf_range(8, 22))
		stone.position = Vector2(randf_range(-1500, 1500), randf_range(-850, 850))
		stone.rotation = randf_range(-0.7, 0.7)
		world.add_child(stone)

func _spawn_player() -> void:
	player = PlayerScene.instantiate()
	player.position = Vector2.ZERO
	world.add_child(player)
	living_blade = LivingBladeScene.instantiate()
	living_blade.setup(player, fx_layer)
	world.add_child(living_blade)

func _build_ui() -> void:
	add_child(ui_layer)
	ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	hud.position = Vector2(18, 14)
	hud.add_theme_font_size_override("font_size", 18)
	hud.add_theme_color_override("font_color", Color(0.88, 0.84, 0.73))
	ui_layer.add_child(hud)
	upgrade_panel.visible = false
	upgrade_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	upgrade_panel.position = Vector2(320, 118)
	upgrade_panel.custom_minimum_size = Vector2(320, 260)
	ui_layer.add_child(upgrade_panel)
	upgrade_panel.add_child(upgrade_list)
	_update_hud()

func _spawn_enemy_wave() -> void:
	var count := 1 + int(elapsed / 25.0)
	for i in range(count):
		var enemy: Enemy = EnemyScene.instantiate()
		enemy.max_health = 2 + int(elapsed / 45.0)
		enemy.health = enemy.max_health
		enemy.speed = randf_range(56.0, 86.0) + elapsed * 0.15
		enemy.position = player.position + Vector2.RIGHT.rotated(randf() * TAU) * randf_range(360.0, 520.0)
		enemy.target = player
		enemy.died.connect(_on_enemy_died)
		enemies.append(enemy)
		world.add_child(enemy)

func _on_enemy_died(enemy_position: Vector2) -> void:
	var shard: XPShard = XPShardScene.instantiate()
	shard.position = enemy_position
	shards.append(shard)
	world.add_child(shard)
	_compact_enemies()

func _update_shards(delta: float) -> void:
	for shard in shards:
		if not is_instance_valid(shard):
			continue
		var distance := shard.global_position.distance_to(player.global_position)
		if distance < shard_pull_range:
			shard.global_position = shard.global_position.move_toward(player.global_position, 320.0 * delta)
		if distance < 22.0:
			xp += shard.value
			shard.queue_free()
			if xp >= xp_to_next:
				_level_up()
	_compact_shards()

func _compact_enemies() -> void:
	var alive_enemies: Array[Enemy] = []
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.is_dead:
			alive_enemies.append(enemy)
	enemies = alive_enemies

func _compact_shards() -> void:
	var alive_shards: Array[XPShard] = []
	for shard in shards:
		if is_instance_valid(shard):
			alive_shards.append(shard)
	shards = alive_shards

func _check_enemy_contact(delta: float) -> void:
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(player.global_position) < 30.0:
			player.take_damage(18.0 * delta)
			if player.is_dead:
				_show_game_over()

func _level_up() -> void:
	level += 1
	xp -= xp_to_next
	xp_to_next = int(xp_to_next * 1.35) + 4
	paused_for_upgrade = true
	get_tree().paused = true
	_show_upgrades()

func _show_upgrades() -> void:
	for child in upgrade_list.get_children():
		child.queue_free()
	var title := Label.new()
	title.text = "Choose a relic"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	upgrade_list.add_child(title)
	_add_upgrade_button("Sharpen Living Blade", "_upgrade_damage")
	_add_upgrade_button("Quicken the Curse", "_upgrade_cooldown")
	_add_upgrade_button("Widen Pale Reach", "_upgrade_range")
	upgrade_panel.visible = true

func _add_upgrade_button(text: String, method_name: StringName) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(280, 48)
	button.set_meta("upgrade_method", String(method_name))
	button.pressed.connect(_on_upgrade_button_pressed.bind(button))
	upgrade_list.add_child(button)

func _on_upgrade_button_pressed(button: Button) -> void:
	var method_name := String(button.get_meta("upgrade_method", ""))
	if method_name != "":
		call(method_name)
	upgrade_panel.visible = false
	paused_for_upgrade = false
	get_tree().paused = false

func _upgrade_damage() -> void:
	living_blade.increase_damage()

func _upgrade_cooldown() -> void:
	living_blade.quicken()

func _upgrade_range() -> void:
	living_blade.widen_reach()

func _show_game_over() -> void:
	get_tree().paused = true
	hud.text = "Gravebloom\nThe Masked Wanderer fell\nTime: %.1f" % elapsed

func _update_hud() -> void:
	hud.text = "Gravebloom\nHP: %d  Level: %d  XP: %d/%d  Time: %.1f" % [
		int(ceil(player.health)),
		level,
		xp,
		xp_to_next,
		elapsed
	]
