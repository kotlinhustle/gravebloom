extends Node2D

const PlayerScene := preload("res://scenes/player.tscn")
const EnemyScene := preload("res://scenes/enemy.tscn")
const XPShardScene := preload("res://scenes/xp_shard.tscn")
const LivingBladeScene := preload("res://scenes/living_blade.tscn")
const CombatFxScript := preload("res://scripts/combat_fx.gd")

const RUN_DURATION := 180.0
const MINIBOSS_TIME := 150.0

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
var game_state := "start"
var miniboss_spawned := false
var last_run_result := ""

@onready var world := Node2D.new()
@onready var fx_layer := Node2D.new()
@onready var ui_layer := CanvasLayer.new()
@onready var hud := Label.new()
@onready var xp_bar := ProgressBar.new()
@onready var upgrade_panel := PanelContainer.new()
@onready var upgrade_list := VBoxContainer.new()
@onready var overlay_panel := PanelContainer.new()
@onready var overlay_list := VBoxContainer.new()

func _ready() -> void:
	randomize()
	add_child(world)
	add_child(fx_layer)
	_build_arena()
	_build_ui()
	_show_start_screen()

func _process(delta: float) -> void:
	if game_state != "running":
		return
	elapsed += delta
	if elapsed >= RUN_DURATION:
		_show_victory()
		return
	if not miniboss_spawned and elapsed >= MINIBOSS_TIME:
		_spawn_miniboss()
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		_spawn_enemy_wave()
		spawn_timer = max(0.18, 1.0 - elapsed * 0.008)
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
	xp_bar.position = Vector2(18, 86)
	xp_bar.size = Vector2(280, 18)
	xp_bar.max_value = xp_to_next
	xp_bar.value = xp
	xp_bar.show_percentage = false
	ui_layer.add_child(xp_bar)
	upgrade_panel.visible = false
	upgrade_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	upgrade_panel.position = Vector2(260, 104)
	upgrade_panel.custom_minimum_size = Vector2(440, 300)
	ui_layer.add_child(upgrade_panel)
	upgrade_panel.add_child(upgrade_list)
	overlay_panel.visible = false
	overlay_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay_panel.position = Vector2(280, 96)
	overlay_panel.custom_minimum_size = Vector2(400, 310)
	ui_layer.add_child(overlay_panel)
	overlay_panel.add_child(overlay_list)
	_update_hud()

func _show_start_screen() -> void:
	game_state = "start"
	get_tree().paused = true
	overlay_panel.visible = true
	_clear_container(overlay_list)
	_add_overlay_label("Gravebloom", 34)
	_add_overlay_label("Survive 3:00 in the cursed ruins.", 18)
	_add_overlay_label("Move with WASD, arrows, or mouse drag. The Living Blade hunts by itself.", 14)
	_add_overlay_button("Start Run", _start_run)

func _start_run() -> void:
	_reset_run()
	overlay_panel.visible = false
	game_state = "running"
	get_tree().paused = false

func _reset_run() -> void:
	_clear_world_entities()
	elapsed = 0.0
	spawn_timer = 0.0
	level = 1
	xp = 0
	xp_to_next = 8
	paused_for_upgrade = false
	miniboss_spawned = false
	last_run_result = ""
	_spawn_player()
	_update_hud()

func _spawn_enemy_wave() -> void:
	var count := 2 + int(elapsed / 20.0)
	for i in range(count):
		var is_brute: bool = randf() < min(0.28, 0.04 + elapsed / 360.0)
		_spawn_enemy(is_brute, false)

func _spawn_enemy(is_brute: bool, is_miniboss: bool) -> void:
	var enemy: Enemy = EnemyScene.instantiate()
	enemy.max_health = 2 + int(elapsed / 45.0)
	enemy.speed = randf_range(56.0, 86.0) + elapsed * 0.15
	enemy.xp_value = 1
	if is_brute:
		enemy.max_health += 4
		enemy.speed *= 0.68
		enemy.scale = Vector2.ONE * 1.45
		enemy.xp_value = 2
	if is_miniboss:
		enemy.is_miniboss = true
		enemy.max_health = 34 + int(elapsed / 10.0)
		enemy.speed = 46.0
		enemy.scale = Vector2.ONE * 2.25
		enemy.xp_value = 12
	enemy.health = enemy.max_health
	enemy.position = player.position + Vector2.RIGHT.rotated(randf() * TAU) * randf_range(360.0, 520.0)
	enemy.target = player
	enemy.damaged.connect(_on_enemy_damaged)
	enemy.died.connect(_on_enemy_died.bind(enemy.xp_value, enemy.is_miniboss))
	enemies.append(enemy)
	world.add_child(enemy)

func _spawn_miniboss() -> void:
	miniboss_spawned = true
	_spawn_enemy(false, true)
	CombatFxScript.ring(fx_layer, player.global_position, Color(0.9, 0.55, 0.72, 0.9), 260.0, 0.7)
	_flash_overlay_text("A Grave Warden wakes")

func _on_enemy_damaged(enemy_position: Vector2, amount: int) -> void:
	CombatFxScript.damage_number(fx_layer, enemy_position, amount)

func _on_enemy_died(enemy_position: Vector2, xp_value: int = 1, was_miniboss: bool = false) -> void:
	CombatFxScript.burst(fx_layer, enemy_position, Color(0.55, 1.0, 0.72, 0.9), 18 if was_miniboss else 12)
	var shard: XPShard = XPShardScene.instantiate()
	shard.position = enemy_position
	shard.value = xp_value
	if xp_value > 1:
		shard.scale = Vector2.ONE * min(2.0, 1.0 + float(xp_value) / 10.0)
	shards.append(shard)
	world.add_child(shard)
	if was_miniboss:
		_flash_overlay_text("Grave Warden broken")
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
			var damage := 32.0 if enemy.is_miniboss else 18.0
			player.take_damage(damage * delta)
			if player.is_dead:
				_show_game_over()

func _level_up() -> void:
	level += 1
	xp -= xp_to_next
	xp_to_next = int(xp_to_next * 1.35) + 4
	CombatFxScript.ring(fx_layer, player.global_position, Color(0.7, 1.0, 0.84, 0.85), 170.0, 0.55)
	CombatFxScript.burst(fx_layer, player.global_position, Color(0.78, 1.0, 0.9, 0.9), 24)
	paused_for_upgrade = true
	game_state = "upgrade"
	get_tree().paused = true
	_show_upgrades()

func _show_upgrades() -> void:
	_clear_container(upgrade_list)
	var title := _make_label("Choose a relic", 26)
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
	game_state = "running"
	get_tree().paused = false

func _upgrade_damage() -> void:
	living_blade.increase_damage()

func _upgrade_cooldown() -> void:
	living_blade.quicken()

func _upgrade_range() -> void:
	living_blade.widen_reach()

func _show_game_over() -> void:
	if game_state == "game_over":
		return
	game_state = "game_over"
	last_run_result = "The Masked Wanderer fell"
	get_tree().paused = true
	_show_result_screen(false)

func _show_victory() -> void:
	game_state = "victory"
	last_run_result = "The curse recedes"
	get_tree().paused = true
	_show_result_screen(true)

func _show_result_screen(victory: bool) -> void:
	overlay_panel.visible = true
	_clear_container(overlay_list)
	_add_overlay_label("Victory" if victory else "Run Ended", 32)
	_add_overlay_label(last_run_result, 20)
	_add_overlay_label("Time: %s   Level: %d" % [_format_time(elapsed), level], 18)
	_add_overlay_button("Restart", _start_run)

func _update_hud() -> void:
	var remaining: float = max(0.0, RUN_DURATION - elapsed)
	var health_value := 0
	if player != null:
		health_value = int(ceil(player.health))
	hud.text = "Gravebloom\nHP: %d  Level: %d  Time: %s\nSurvive: %s" % [
		health_value,
		level,
		_format_time(elapsed),
		_format_time(remaining)
	]
	xp_bar.max_value = xp_to_next
	xp_bar.value = xp

func _format_time(time_value: float) -> String:
	var total_seconds: int = int(max(0.0, floor(time_value)))
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]

func _clear_container(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()

func _make_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.88, 0.84, 0.73))
	return label

func _add_overlay_label(text: String, font_size: int) -> void:
	overlay_list.add_child(_make_label(text, font_size))

func _add_overlay_button(text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(320, 52)
	button.pressed.connect(callback)
	overlay_list.add_child(button)

func _flash_overlay_text(text: String) -> void:
	var label := _make_label(text, 26)
	label.global_position = Vector2(325, 56)
	ui_layer.add_child(label)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position", label.global_position + Vector2(0, -32), 1.1)
	tween.tween_property(label, "modulate:a", 0.0, 1.1)
	tween.chain().tween_callback(label.queue_free)

func _clear_world_entities() -> void:
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	for shard in shards:
		if is_instance_valid(shard):
			shard.queue_free()
	if is_instance_valid(player):
		player.queue_free()
	if is_instance_valid(living_blade):
		living_blade.queue_free()
	enemies.clear()
	shards.clear()
	player = null
	living_blade = null
