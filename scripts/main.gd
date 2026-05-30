extends Node2D

const PlayerScene := preload("res://scenes/player.tscn")
const EnemyScene := preload("res://scenes/enemy.tscn")
const XPShardScene := preload("res://scenes/xp_shard.tscn")
const LivingBladeScene := preload("res://scenes/living_blade.tscn")
const CombatFxScript := preload("res://scripts/combat_fx.gd")
const EnemyCrawlerTexture := preload("res://assets/sprites/enemy_crawler.png")
const EnemyBruteTexture := preload("res://assets/sprites/enemy_brute.png")
const GraveWardenTexture := preload("res://assets/sprites/grave_warden.png")

const RUN_DURATION := 180.0
const MINIBOSS_TIME := 150.0
const ARENA_LIMIT_X := 2060.0
const ARENA_LIMIT_Y := 1360.0
const MAX_ENEMIES := 55
const ULTIMATE_COOLDOWN := 30.0
const ULTIMATE_RADIUS := 380.0
const ULTIMATE_DAMAGE := 7

var player: Player
var living_blade: Node2D
var enemies: Array[Enemy] = []
var shards: Array[XPShard] = []
var elapsed := 0.0
var spawn_timer := 0.0
var level := 1
var xp := 0
var xp_to_next := 14
var shard_pull_range := 95.0
var paused_for_upgrade := false
var game_state := "start"
var miniboss_spawned := false
var last_run_result := ""
var shadow_spirit_unlocked := false
var shadow_spirit_timer := 3.0
var shadow_spirit_cooldown := 5.5
var shadow_spirit_damage := 2
var shake_time := 0.0
var shake_intensity := 0.0
var joystick_active := false
var joystick_direction := Vector2.ZERO
var joystick_radius := 56.0
var ambient_glows: Array[CanvasItem] = []
var fog_wisps: Array[CanvasItem] = []
var ambience_time := 0.0
var ultimate_charge := 0.0
var ultimate_ready := false

@onready var world := Node2D.new()
@onready var fx_layer := Node2D.new()
@onready var ui_layer := CanvasLayer.new()
@onready var hud := Label.new()
@onready var hp_bar := ProgressBar.new()
@onready var xp_bar := ProgressBar.new()
@onready var ultimate_bar := ProgressBar.new()
@onready var ultimate_button := Button.new()
@onready var joystick_base := Panel.new()
@onready var joystick_knob := Panel.new()
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
	_update_screen_shake(delta)
	_update_joystick_mouse()
	_update_arena_ambience(delta)
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
		spawn_timer = max(0.32, 1.18 - elapsed * 0.006)
	living_blade.tick(delta, enemies)
	_update_ultimate(delta)
	_update_shadow_spirit(delta)
	_update_shards(delta)
	_check_enemy_contact(delta)
	_keep_player_inside_arena()
	_update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.physical_keycode == KEY_SPACE:
			_cast_ultimate()

func _build_arena() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.028, 0.031, 0.034)
	bg.size = Vector2(4600, 4600)
	bg.position = Vector2(-2300, -2300)
	world.add_child(bg)
	_build_floor_tiles()
	_build_cracks()
	_build_ruins()
	_build_graveblooms()
	_build_cursed_runes()
	_build_boundary_markers()
	_build_fog_wisps()
	_build_screen_vignette()

func _build_floor_tiles() -> void:
	var tile_size := 176.0
	for x in range(-11, 12):
		for y in range(-7, 8):
			var tile := ColorRect.new()
			var shade := randf_range(-0.012, 0.016)
			tile.color = Color(0.064 + shade, 0.065 + shade, 0.074 + shade, 0.92)
			tile.size = Vector2(tile_size - 7.0, tile_size - 7.0)
			tile.position = Vector2(x * tile_size, y * tile_size) + Vector2(randf_range(-3.0, 3.0), randf_range(-3.0, 3.0))
			tile.rotation = randf_range(-0.012, 0.012)
			world.add_child(tile)
	for i in range(90):
		var stain := _make_ellipse(randf_range(10.0, 34.0), randf_range(5.0, 18.0), Color(0.02, 0.025, 0.026, randf_range(0.16, 0.34)), 12)
		stain.position = Vector2(randf_range(-1850.0, 1850.0), randf_range(-1200.0, 1200.0))
		stain.rotation = randf() * TAU
		world.add_child(stain)

func _build_cracks() -> void:
	for i in range(34):
		var crack := Line2D.new()
		crack.width = randf_range(2.0, 5.0)
		crack.default_color = Color(0.012, 0.014, 0.018, randf_range(0.5, 0.82))
		crack.points = _make_crack_points(randf_range(80.0, 250.0), randi_range(4, 8))
		crack.position = Vector2(randf_range(-1750.0, 1750.0), randf_range(-1050.0, 1050.0))
		crack.rotation = randf() * TAU
		world.add_child(crack)

func _make_crack_points(length: float, point_count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	var current := Vector2.ZERO
	points.append(current)
	for i in range(1, point_count):
		current += Vector2(length / float(point_count - 1), randf_range(-18.0, 18.0))
		points.append(current)
	return points

func _build_ruins() -> void:
	for i in range(22):
		var base_position := Vector2(randf_range(-1750.0, 1750.0), randf_range(-1050.0, 1050.0))
		if base_position.length() < 280.0:
			base_position += base_position.normalized() * 320.0
		if randf() < 0.48:
			_add_broken_column(base_position)
		else:
			_add_gravestone(base_position, randf_range(0.8, 1.35))
	for i in range(48):
		var rubble := ColorRect.new()
		rubble.color = Color(0.12, 0.12, 0.135, randf_range(0.35, 0.7))
		rubble.size = Vector2(randf_range(12.0, 42.0), randf_range(7.0, 18.0))
		rubble.position = Vector2(randf_range(-1900.0, 1900.0), randf_range(-1250.0, 1250.0))
		rubble.rotation = randf() * TAU
		world.add_child(rubble)

func _add_broken_column(base_position: Vector2) -> void:
	var shadow := _make_ellipse(58.0, 18.0, Color(0.0, 0.0, 0.0, 0.24), 16)
	shadow.position = base_position + Vector2(8.0, 22.0)
	world.add_child(shadow)
	for piece_index in range(randi_range(2, 4)):
		var piece := ColorRect.new()
		piece.color = Color(0.16, 0.155, 0.17, randf_range(0.74, 0.94))
		piece.size = Vector2(randf_range(34.0, 74.0), randf_range(18.0, 34.0))
		piece.position = base_position + Vector2(piece_index * randf_range(18.0, 36.0), piece_index * randf_range(-5.0, 9.0))
		piece.rotation = randf_range(-0.7, 0.7)
		world.add_child(piece)

func _add_gravestone(base_position: Vector2, scale_value: float) -> void:
	var shadow := _make_ellipse(34.0 * scale_value, 10.0 * scale_value, Color(0.0, 0.0, 0.0, 0.28), 14)
	shadow.position = base_position + Vector2(4.0, 26.0 * scale_value)
	world.add_child(shadow)
	var stone := Polygon2D.new()
	stone.color = Color(0.13, 0.14, 0.15, 0.9)
	var width := 34.0 * scale_value
	var height := 58.0 * scale_value
	var shape := PackedVector2Array()
	shape.append(Vector2(-width * 0.5, height * 0.45))
	shape.append(Vector2(-width * 0.5, -height * 0.12))
	shape.append(Vector2(-width * 0.25, -height * 0.46))
	shape.append(Vector2(0.0, -height * 0.58))
	shape.append(Vector2(width * 0.25, -height * 0.46))
	shape.append(Vector2(width * 0.5, -height * 0.12))
	shape.append(Vector2(width * 0.5, height * 0.45))
	stone.polygon = shape
	stone.position = base_position
	stone.rotation = randf_range(-0.18, 0.18)
	world.add_child(stone)
	var rune := ColorRect.new()
	rune.color = Color(0.55, 1.0, 0.72, randf_range(0.22, 0.36))
	rune.size = Vector2(4.0 * scale_value, 20.0 * scale_value)
	rune.position = base_position + Vector2(-2.0 * scale_value, -8.0 * scale_value)
	world.add_child(rune)
	ambient_glows.append(rune)

func _build_graveblooms() -> void:
	for i in range(70):
		var center := Vector2(randf_range(-1850.0, 1850.0), randf_range(-1200.0, 1200.0))
		var stem := ColorRect.new()
		stem.color = Color(0.16, 0.36, 0.24, randf_range(0.44, 0.72))
		stem.size = Vector2(3.0, randf_range(10.0, 20.0))
		stem.position = center + Vector2(-1.5, -2.0)
		world.add_child(stem)
		var bloom := _make_ellipse(randf_range(5.0, 9.0), randf_range(4.0, 7.0), Color(0.62, 1.0, 0.72, randf_range(0.48, 0.82)), 8)
		bloom.position = center + Vector2(0.0, -7.0)
		world.add_child(bloom)
		ambient_glows.append(bloom)

func _build_cursed_runes() -> void:
	for i in range(9):
		var rune := Line2D.new()
		rune.width = 3.0
		rune.closed = true
		rune.default_color = Color(0.48, 1.0, 0.75, randf_range(0.28, 0.48))
		var radius := randf_range(18.0, 42.0)
		var points := PackedVector2Array()
		for point_index in range(6):
			points.append(Vector2.RIGHT.rotated(TAU * float(point_index) / 6.0) * radius)
		rune.points = points
		rune.position = Vector2(randf_range(-1600.0, 1600.0), randf_range(-950.0, 950.0))
		rune.rotation = randf() * TAU
		world.add_child(rune)
		ambient_glows.append(rune)

func _build_boundary_markers() -> void:
	var border_color := Color(0.11, 0.105, 0.12, 0.86)
	var glow_color := Color(0.48, 1.0, 0.72, 0.28)
	for x in range(-10, 11):
		_add_boundary_stone(Vector2(x * 205.0, -ARENA_LIMIT_Y - 36.0), randf_range(-0.12, 0.12), border_color)
		_add_boundary_stone(Vector2(x * 205.0, ARENA_LIMIT_Y + 36.0), randf_range(-0.12, 0.12), border_color)
	for y in range(-6, 7):
		_add_boundary_stone(Vector2(-ARENA_LIMIT_X - 42.0, y * 205.0), randf_range(1.42, 1.72), border_color)
		_add_boundary_stone(Vector2(ARENA_LIMIT_X + 42.0, y * 205.0), randf_range(1.42, 1.72), border_color)
	for i in range(14):
		var marker := Line2D.new()
		marker.width = 4.0
		marker.default_color = glow_color
		marker.points = PackedVector2Array([Vector2(-18, 0), Vector2(18, 0)])
		var on_horizontal_edge := i < 8
		if on_horizontal_edge:
			marker.position = Vector2(randf_range(-1850.0, 1850.0), (-ARENA_LIMIT_Y if i % 2 == 0 else ARENA_LIMIT_Y) + randf_range(-8.0, 8.0))
		else:
			marker.position = Vector2((-ARENA_LIMIT_X if i % 2 == 0 else ARENA_LIMIT_X) + randf_range(-8.0, 8.0), randf_range(-1180.0, 1180.0))
			marker.rotation = PI * 0.5
		world.add_child(marker)
		ambient_glows.append(marker)

func _add_boundary_stone(position: Vector2, rotation: float, color: Color) -> void:
	var stone := ColorRect.new()
	stone.color = color
	stone.size = Vector2(randf_range(86.0, 150.0), randf_range(18.0, 34.0))
	stone.position = position
	stone.rotation = rotation
	world.add_child(stone)

func _build_fog_wisps() -> void:
	for i in range(18):
		var wisp := Line2D.new()
		wisp.width = randf_range(12.0, 24.0)
		wisp.default_color = Color(0.45, 0.56, 0.52, randf_range(0.06, 0.13))
		var points := PackedVector2Array()
		for point_index in range(6):
			points.append(Vector2(point_index * randf_range(36.0, 58.0), sin(point_index * 1.7) * randf_range(10.0, 22.0)))
		wisp.points = points
		wisp.position = Vector2(randf_range(-1800.0, 1500.0), randf_range(-1100.0, 1100.0))
		wisp.rotation = randf_range(-0.35, 0.35)
		world.add_child(wisp)
		fog_wisps.append(wisp)

func _build_screen_vignette() -> void:
	var vignette := Control.new()
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.process_mode = Node.PROCESS_MODE_ALWAYS
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(vignette)
	_add_vignette_rect(vignette, Vector2.ZERO, Vector2(540.0, 120.0), Color(0.0, 0.0, 0.0, 0.28))
	_add_vignette_rect(vignette, Vector2(0.0, 820.0), Vector2(540.0, 140.0), Color(0.0, 0.0, 0.0, 0.32))
	_add_vignette_rect(vignette, Vector2.ZERO, Vector2(54.0, 960.0), Color(0.0, 0.0, 0.0, 0.24))
	_add_vignette_rect(vignette, Vector2(486.0, 0.0), Vector2(54.0, 960.0), Color(0.0, 0.0, 0.0, 0.24))

func _add_vignette_rect(parent: Node, position: Vector2, size: Vector2, color: Color) -> void:
	var rect := ColorRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.position = position
	rect.size = size
	rect.color = color
	parent.add_child(rect)

func _make_ellipse(radius_x: float, radius_y: float, color: Color, point_count: int) -> Polygon2D:
	var polygon := Polygon2D.new()
	polygon.color = color
	var points := PackedVector2Array()
	for i in range(point_count):
		points.append(Vector2(cos(TAU * float(i) / float(point_count)) * radius_x, sin(TAU * float(i) / float(point_count)) * radius_y))
	polygon.polygon = points
	return polygon

func _update_arena_ambience(delta: float) -> void:
	ambience_time += delta
	for i in range(ambient_glows.size()):
		var item := ambient_glows[i]
		if not is_instance_valid(item):
			continue
		item.modulate.a = 0.7 + sin(ambience_time * 1.6 + float(i) * 0.73) * 0.25
	for i in range(fog_wisps.size()):
		var wisp := fog_wisps[i]
		if not is_instance_valid(wisp):
			continue
		wisp.position.x += delta * (10.0 + float(i % 4) * 3.0)
		wisp.modulate.a = 0.72 + sin(ambience_time * 0.8 + float(i)) * 0.18
		if wisp.position.x > 1900.0:
			wisp.position.x = -1900.0

func _spawn_player() -> void:
	player = PlayerScene.instantiate()
	player.position = Vector2.ZERO
	player.set_arena_limits(Vector2(ARENA_LIMIT_X, ARENA_LIMIT_Y))
	world.add_child(player)
	living_blade = LivingBladeScene.instantiate()
	living_blade.setup(player, fx_layer)
	world.add_child(living_blade)

func _build_ui() -> void:
	add_child(ui_layer)
	ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	hud.position = Vector2(18, 18)
	hud.add_theme_font_size_override("font_size", 24)
	hud.add_theme_color_override("font_color", Color(0.88, 0.84, 0.73))
	ui_layer.add_child(hud)
	hp_bar.position = Vector2(18, 96)
	hp_bar.size = Vector2(504, 32)
	hp_bar.max_value = 100.0
	hp_bar.value = 100.0
	hp_bar.show_percentage = false
	ui_layer.add_child(hp_bar)
	xp_bar.position = Vector2(18, 138)
	xp_bar.size = Vector2(504, 26)
	xp_bar.max_value = xp_to_next
	xp_bar.value = xp
	xp_bar.show_percentage = false
	ui_layer.add_child(xp_bar)
	_build_ultimate_ui()
	_build_joystick()
	upgrade_panel.visible = false
	upgrade_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	upgrade_panel.position = Vector2(28, 220)
	upgrade_panel.custom_minimum_size = Vector2(484, 460)
	ui_layer.add_child(upgrade_panel)
	upgrade_panel.add_child(upgrade_list)
	overlay_panel.visible = false
	overlay_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay_panel.position = Vector2(36, 250)
	overlay_panel.custom_minimum_size = Vector2(468, 350)
	ui_layer.add_child(overlay_panel)
	overlay_panel.add_child(overlay_list)
	_update_hud()

func _show_start_screen() -> void:
	game_state = "start"
	get_tree().paused = true
	joystick_base.visible = false
	ultimate_button.visible = false
	ultimate_bar.visible = false
	overlay_panel.visible = true
	_clear_container(overlay_list)
	_add_overlay_label("GRAVEBLOOM", 42)
	_add_overlay_label("Продержись 3:00 в проклятых руинах.", 22)
	_add_overlay_label("Живой Клинок охотится сам. Твоя задача - двигаться.", 17)
	_add_overlay_button("Начать забег", _start_run)

func _start_run() -> void:
	_reset_run()
	overlay_panel.visible = false
	joystick_base.visible = true
	ultimate_button.visible = true
	ultimate_bar.visible = true
	game_state = "running"
	get_tree().paused = false

func _reset_run() -> void:
	_clear_world_entities()
	elapsed = 0.0
	spawn_timer = 0.0
	level = 1
	xp = 0
	xp_to_next = 14
	paused_for_upgrade = false
	miniboss_spawned = false
	last_run_result = ""
	shadow_spirit_unlocked = false
	shadow_spirit_timer = 3.0
	shadow_spirit_cooldown = 5.5
	shadow_spirit_damage = 2
	ultimate_charge = 0.0
	ultimate_ready = false
	_update_ultimate_ui()
	_reset_joystick()
	_stop_screen_shake()
	_spawn_player()
	_update_hud()

func _spawn_enemy_wave() -> void:
	_compact_enemies()
	var available_slots: int = MAX_ENEMIES - enemies.size()
	if available_slots <= 0:
		return
	var count: int = 1 + int(elapsed / 24.0)
	count = min(count, available_slots)
	for i in range(count):
		var is_brute: bool = randf() < min(0.26, 0.04 + elapsed / 420.0)
		_spawn_enemy(is_brute, false)

func _spawn_enemy(is_brute: bool, is_miniboss: bool) -> void:
	var enemy: Enemy = EnemyScene.instantiate()
	enemy.max_health = 2 + int(elapsed / 52.0)
	enemy.speed = randf_range(56.0, 84.0) + elapsed * 0.14
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
	_set_enemy_art(enemy, is_brute, is_miniboss)
	enemy.base_scale = enemy.scale
	enemy.health = enemy.max_health
	enemy.position = _clamp_to_arena(player.position + Vector2.RIGHT.rotated(randf() * TAU) * randf_range(360.0, 520.0))
	enemy.target = player
	enemy.damaged.connect(_on_enemy_damaged)
	enemy.died.connect(_on_enemy_died.bind(enemy.xp_value, enemy.is_miniboss))
	enemies.append(enemy)
	world.add_child(enemy)

func _set_enemy_art(enemy: Enemy, is_brute: bool, is_miniboss: bool) -> void:
	var art := enemy.get_node_or_null("Art")
	if art == null:
		return
	if is_miniboss:
		art.texture = GraveWardenTexture
		art.scale = Vector2(0.2, 0.2)
	elif is_brute:
		art.texture = EnemyBruteTexture
		art.scale = Vector2(0.19, 0.19)
	else:
		art.texture = EnemyCrawlerTexture
		art.scale = Vector2(0.28, 0.28)

func _spawn_miniboss() -> void:
	miniboss_spawned = true
	_spawn_enemy(false, true)
	CombatFxScript.ring(fx_layer, player.global_position, Color(0.9, 0.55, 0.72, 0.9), 260.0, 0.7)
	_flash_overlay_text("Могильный Страж пробудился")
	_start_screen_shake(0.34, 8.0)

func _on_enemy_damaged(enemy_position: Vector2, amount: int) -> void:
	CombatFxScript.damage_number(fx_layer, enemy_position, amount)

func _on_enemy_died(enemy_position: Vector2, xp_value: int = 1, was_miniboss: bool = false) -> void:
	CombatFxScript.burst(fx_layer, enemy_position, Color(0.55, 1.0, 0.72, 0.9), 18 if was_miniboss else 12)
	_start_screen_shake(0.18 if was_miniboss else 0.06, 7.0 if was_miniboss else 2.5)
	var shard: XPShard = XPShardScene.instantiate()
	shard.position = enemy_position
	shard.value = xp_value
	if xp_value > 1:
		shard.scale = Vector2.ONE * min(2.0, 1.0 + float(xp_value) / 10.0)
	shards.append(shard)
	world.add_child(shard)
	if was_miniboss:
		_flash_overlay_text("Могильный Страж повержен")
	_compact_enemies()

func _update_shards(delta: float) -> void:
	for shard in shards:
		if not is_instance_valid(shard):
			continue
		var distance := shard.global_position.distance_to(player.global_position)
		if distance < shard_pull_range:
			shard.global_position = shard.global_position.move_toward(player.global_position, 320.0 * delta)
			if randf() < 0.28:
				CombatFxScript.sparkle(fx_layer, shard.global_position, Color(0.58, 1.0, 0.78, 0.72), 0.2)
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
		if enemy.global_position.distance_to(player.global_position) < 42.0:
			var damage := 32.0 if enemy.is_miniboss else 18.0
			player.take_damage(damage * delta)
			if player.is_dead:
				_show_game_over()

func _keep_player_inside_arena() -> void:
	if player == null:
		return
	player.global_position = _clamp_to_arena(player.global_position)

func _clamp_to_arena(position: Vector2) -> Vector2:
	return Vector2(
		clamp(position.x, -ARENA_LIMIT_X, ARENA_LIMIT_X),
		clamp(position.y, -ARENA_LIMIT_Y, ARENA_LIMIT_Y)
	)

func _level_up() -> void:
	level += 1
	xp -= xp_to_next
	xp_to_next = int(xp_to_next * 1.55) + 8
	CombatFxScript.ring(fx_layer, player.global_position, Color(0.7, 1.0, 0.84, 0.85), 170.0, 0.55)
	CombatFxScript.burst(fx_layer, player.global_position, Color(0.78, 1.0, 0.9, 0.9), 24)
	paused_for_upgrade = true
	game_state = "upgrade"
	joystick_base.visible = false
	ultimate_button.visible = false
	ultimate_bar.visible = false
	_reset_joystick()
	get_tree().paused = true
	_show_upgrades()

func _show_upgrades() -> void:
	_clear_container(upgrade_list)
	var title := _make_label("Выбери реликвию", 26)
	upgrade_list.add_child(title)
	_add_upgrade_button("Заточить Живой Клинок", "Больше урона клинком", "_upgrade_damage")
	_add_upgrade_button("Ускорить проклятие", "Клинок атакует чаще", "_upgrade_cooldown")
	_add_upgrade_button("Расширить бледный радиус", "Клинок ищет врагов дальше", "_upgrade_range")
	_add_upgrade_button("Призвать Тень", "Дух прорезает толпу лучом", "_upgrade_shadow_spirit")
	upgrade_panel.visible = true

func _add_upgrade_button(text: String, description: String, method_name: StringName) -> void:
	var button := Button.new()
	button.text = "%s\n%s" % [text, description]
	button.custom_minimum_size = Vector2(430, 70)
	button.set_meta("upgrade_method", String(method_name))
	button.pressed.connect(_on_upgrade_button_pressed.bind(button))
	upgrade_list.add_child(button)

func _on_upgrade_button_pressed(button: Button) -> void:
	var method_name := String(button.get_meta("upgrade_method", ""))
	if method_name != "":
		call(method_name)
	upgrade_panel.visible = false
	joystick_base.visible = true
	ultimate_button.visible = true
	ultimate_bar.visible = true
	paused_for_upgrade = false
	game_state = "running"
	get_tree().paused = false

func _upgrade_damage() -> void:
	living_blade.increase_damage()

func _upgrade_cooldown() -> void:
	living_blade.quicken()

func _upgrade_range() -> void:
	living_blade.widen_reach()

func _upgrade_shadow_spirit() -> void:
	if shadow_spirit_unlocked:
		shadow_spirit_damage += 1
		shadow_spirit_cooldown = max(2.5, shadow_spirit_cooldown - 0.45)
	else:
		shadow_spirit_unlocked = true
		shadow_spirit_timer = 0.35
	_flash_overlay_text("Тень пробудилась")

func _show_game_over() -> void:
	if game_state == "game_over":
		return
	game_state = "game_over"
	last_run_result = "Странник в Маске пал"
	joystick_base.visible = false
	ultimate_button.visible = false
	ultimate_bar.visible = false
	_reset_joystick()
	get_tree().paused = true
	_show_result_screen(false)

func _show_victory() -> void:
	game_state = "victory"
	last_run_result = "Проклятие отступает"
	joystick_base.visible = false
	ultimate_button.visible = false
	ultimate_bar.visible = false
	_reset_joystick()
	get_tree().paused = true
	_show_result_screen(true)

func _show_result_screen(victory: bool) -> void:
	overlay_panel.visible = true
	_clear_container(overlay_list)
	_add_overlay_label("Победа" if victory else "Забег окончен", 32)
	_add_overlay_label(last_run_result, 20)
	_add_overlay_label("Время: %s   Уровень: %d" % [_format_time(elapsed), level], 18)
	_add_overlay_button("Заново", _start_run)

func _update_hud() -> void:
	var remaining: float = max(0.0, RUN_DURATION - elapsed)
	var health_value := 0
	if player != null:
		health_value = int(ceil(player.health))
	hud.text = "GRAVEBLOOM\nУР %d   ВРЕМЯ %s   ОСТАЛОСЬ %s" % [
		level,
		_format_time(elapsed),
		_format_time(remaining)
	]
	hp_bar.value = health_value
	xp_bar.max_value = xp_to_next
	xp_bar.value = xp
	_update_ultimate_ui()

func _build_ultimate_ui() -> void:
	ultimate_bar.position = Vector2(348, 878)
	ultimate_bar.size = Vector2(160, 18)
	ultimate_bar.max_value = ULTIMATE_COOLDOWN
	ultimate_bar.value = 0.0
	ultimate_bar.show_percentage = false
	ultimate_bar.process_mode = Node.PROCESS_MODE_ALWAYS
	ui_layer.add_child(ultimate_bar)
	ultimate_button.position = Vector2(358, 786)
	ultimate_button.size = Vector2(140, 84)
	ultimate_button.text = "НОВА\n0%"
	ultimate_button.disabled = false
	ultimate_button.process_mode = Node.PROCESS_MODE_ALWAYS
	ultimate_button.add_theme_font_size_override("font_size", 22)
	ultimate_button.pressed.connect(_cast_ultimate)
	ui_layer.add_child(ultimate_button)

func _update_ultimate(delta: float) -> void:
	if ultimate_ready:
		return
	ultimate_charge = min(ULTIMATE_COOLDOWN, ultimate_charge + delta)
	if ultimate_charge >= ULTIMATE_COOLDOWN:
		ultimate_ready = true
		_flash_overlay_text("Нова готова")
		CombatFxScript.ring(fx_layer, player.global_position, Color(0.58, 1.0, 0.72, 0.65), 130.0, 0.42)
	_update_ultimate_ui()

func _update_ultimate_ui() -> void:
	if ultimate_bar == null or ultimate_button == null:
		return
	ultimate_bar.value = ultimate_charge
	var charge_percent := int(floor((ultimate_charge / ULTIMATE_COOLDOWN) * 100.0))
	ultimate_button.text = "НОВА\nГОТОВА" if ultimate_ready else "НОВА\n%d%%" % charge_percent
	ultimate_button.disabled = game_state != "running"
	ultimate_button.modulate = Color.WHITE if ultimate_ready else Color(0.78, 0.86, 0.78, 0.95)

func _cast_ultimate() -> void:
	if game_state != "running" or player == null:
		return
	if not ultimate_ready:
		_flash_overlay_text("Нова заряжается: %d%%" % int(floor((ultimate_charge / ULTIMATE_COOLDOWN) * 100.0)))
		return
	ultimate_ready = false
	ultimate_charge = 0.0
	var origin := player.global_position
	_flash_overlay_text("НОВА GRAVEBLOOM")
	_start_screen_shake(0.42, 13.0)
	CombatFxScript.ring(fx_layer, origin, Color(0.78, 1.0, 0.72, 0.95), ULTIMATE_RADIUS, 0.55)
	CombatFxScript.ring(fx_layer, origin, Color(0.95, 0.78, 1.0, 0.68), ULTIMATE_RADIUS * 0.62, 0.42)
	CombatFxScript.burst(fx_layer, origin, Color(0.72, 1.0, 0.78, 0.92), 42)
	_add_ultimate_lashes(origin)
	var targets := enemies.duplicate()
	for enemy in targets:
		if not is_instance_valid(enemy):
			continue
		var distance := origin.distance_to(enemy.global_position)
		if distance <= ULTIMATE_RADIUS:
			var damage := ULTIMATE_DAMAGE
			if enemy.is_miniboss:
				damage = int(ceil(float(ULTIMATE_DAMAGE) * 0.65))
			enemy.take_damage(damage, origin, 520.0)
	_update_ultimate_ui()

func _add_ultimate_lashes(origin: Vector2) -> void:
	for i in range(18):
		var lash := Line2D.new()
		lash.width = randf_range(3.0, 7.0)
		lash.default_color = Color(0.56, 1.0, 0.75, randf_range(0.5, 0.86))
		var angle := TAU * float(i) / 18.0 + randf_range(-0.08, 0.08)
		var start := Vector2.RIGHT.rotated(angle) * randf_range(26.0, 70.0)
		var end := Vector2.RIGHT.rotated(angle + randf_range(-0.18, 0.18)) * randf_range(210.0, ULTIMATE_RADIUS)
		lash.points = PackedVector2Array([origin + start, origin + (start + end) * 0.52, origin + end])
		fx_layer.add_child(lash)
		var tween := create_tween()
		tween.tween_property(lash, "modulate:a", 0.0, 0.36)
		tween.tween_callback(lash.queue_free)

func _build_joystick() -> void:
	joystick_base.position = Vector2(30, 770)
	joystick_base.custom_minimum_size = Vector2(142, 142)
	joystick_base.size = Vector2(142, 142)
	joystick_base.visible = false
	joystick_base.mouse_filter = Control.MOUSE_FILTER_STOP
	joystick_base.process_mode = Node.PROCESS_MODE_ALWAYS
	joystick_base.add_theme_stylebox_override("panel", _make_round_style(Color(0.18, 0.22, 0.2, 0.42), 70, Color(0.62, 1.0, 0.77, 0.42), 3))
	joystick_base.gui_input.connect(_on_joystick_input)
	ui_layer.add_child(joystick_base)

	joystick_knob.position = Vector2(43, 43)
	joystick_knob.custom_minimum_size = Vector2(56, 56)
	joystick_knob.size = Vector2(56, 56)
	joystick_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	joystick_knob.add_theme_stylebox_override("panel", _make_round_style(Color(0.58, 1.0, 0.72, 0.76), 28, Color(0.9, 1.0, 0.86, 0.55), 2))
	joystick_base.add_child(joystick_knob)

func _make_round_style(fill: Color, radius: int, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style

func _on_joystick_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		joystick_active = event.pressed
		if joystick_active:
			_update_joystick(event.position)
		else:
			_reset_joystick()
		joystick_base.accept_event()
	elif event is InputEventMouseMotion and joystick_active:
		_update_joystick(event.position)
		joystick_base.accept_event()
	elif event is InputEventScreenTouch:
		joystick_active = event.pressed
		if joystick_active:
			_update_joystick(event.position)
		else:
			_reset_joystick()
		joystick_base.accept_event()
	elif event is InputEventScreenDrag and joystick_active:
		_update_joystick(event.position)
		joystick_base.accept_event()

func _update_joystick_mouse() -> void:
	if not joystick_active:
		return
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_reset_joystick()
		return
	var local_position := joystick_base.get_local_mouse_position()
	_update_joystick(local_position)

func _update_joystick(local_position: Vector2) -> void:
	var center := joystick_base.size * 0.5
	var offset := local_position - center
	if offset.length() > joystick_radius:
		offset = offset.normalized() * joystick_radius
	joystick_direction = offset / joystick_radius
	joystick_knob.position = center + offset - joystick_knob.size * 0.5
	if player != null:
		player.set_virtual_direction(joystick_direction)

func _reset_joystick() -> void:
	joystick_active = false
	joystick_direction = Vector2.ZERO
	if joystick_base != null and joystick_knob != null:
		joystick_knob.position = joystick_base.size * 0.5 - joystick_knob.size * 0.5
	if player != null:
		player.set_virtual_direction(Vector2.ZERO)

func _update_shadow_spirit(delta: float) -> void:
	if not shadow_spirit_unlocked:
		return
	shadow_spirit_timer -= delta
	if shadow_spirit_timer > 0.0:
		return
	var target := _nearest_enemy_for_spirit()
	if target == null:
		shadow_spirit_timer = 0.4
		return
	_cast_shadow_spirit(target.global_position)
	shadow_spirit_timer = shadow_spirit_cooldown

func _nearest_enemy_for_spirit() -> Node2D:
	var best: Node2D = null
	var best_distance := 420.0
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var distance := player.global_position.distance_to(enemy.global_position)
		if distance < best_distance:
			best_distance = distance
			best = enemy
	return best

func _cast_shadow_spirit(target_position: Vector2) -> void:
	var start := player.global_position
	var direction := start.direction_to(target_position)
	if direction.length() <= 0.0:
		return
	var end := start + direction * 520.0
	var spirit := Line2D.new()
	spirit.width = 14.0
	spirit.default_color = Color(0.44, 1.0, 0.78, 0.72)
	spirit.points = PackedVector2Array([start, end])
	fx_layer.add_child(spirit)
	var tween := create_tween()
	tween.tween_property(spirit, "modulate:a", 0.0, 0.34)
	tween.tween_callback(spirit.queue_free)
	CombatFxScript.ring(fx_layer, start, Color(0.45, 1.0, 0.76, 0.55), 90.0, 0.28)
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var distance_to_beam := _distance_to_segment(enemy.global_position, start, end)
		if distance_to_beam <= 34.0:
			enemy.take_damage(shadow_spirit_damage, start, 180.0)
	_start_screen_shake(0.1, 3.5)

func _distance_to_segment(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment := end - start
	var length_squared := segment.length_squared()
	if length_squared <= 0.0:
		return point.distance_to(start)
	var t: float = clamp((point - start).dot(segment) / length_squared, 0.0, 1.0)
	var projection := start + segment * t
	return point.distance_to(projection)

func _start_screen_shake(duration: float, intensity: float) -> void:
	shake_time = max(shake_time, duration)
	shake_intensity = max(shake_intensity, intensity)

func _stop_screen_shake() -> void:
	shake_time = 0.0
	shake_intensity = 0.0
	world.position = Vector2.ZERO
	fx_layer.position = Vector2.ZERO

func _update_screen_shake(delta: float) -> void:
	if shake_time <= 0.0:
		if world.position != Vector2.ZERO:
			world.position = Vector2.ZERO
			fx_layer.position = Vector2.ZERO
		return
	shake_time -= delta
	var offset := Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
	world.position = offset
	fx_layer.position = offset
	shake_intensity = max(0.0, shake_intensity - delta * 18.0)

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
	button.custom_minimum_size = Vector2(360, 62)
	button.pressed.connect(callback)
	overlay_list.add_child(button)

func _flash_overlay_text(text: String) -> void:
	var label := _make_label(text, 26)
	label.global_position = Vector2(80, 164)
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
