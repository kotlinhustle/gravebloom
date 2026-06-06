extends Node2D

const PlayerScene := preload("res://scenes/player.tscn")
const EnemyScene := preload("res://scenes/enemy.tscn")
const XPShardScene := preload("res://scenes/xp_shard.tscn")
const LivingBladeScene := preload("res://scenes/living_blade.tscn")
const CombatFxScript := preload("res://scripts/combat_fx.gd")
const EnemyCrawlerTexture := preload("res://assets/sprites/enemy_crawler.png")
const EnemyBruteTexture := preload("res://assets/sprites/enemy_brute.png")
const GraveWardenTexture := preload("res://assets/sprites/grave_warden.png")
const GraveKingTexture := preload("res://assets/sprites/grave_king.png")
const AshAbbotTexture := preload("res://assets/sprites/ash_abbot.png")

const RUN_DURATION := 180.0
const DREAD_BOSS_TIME := 120.0
const MINIBOSS_TIME := 150.0
const ARENA_LIMIT_X := 2060.0
const ARENA_LIMIT_Y := 1360.0
const MAX_ENEMIES := 55
const ULTIMATE_COOLDOWN := 30.0
const ULTIMATE_RADIUS := 380.0
const ULTIMATE_DAMAGE := 7
const ULTIMATE_AUTO_CAST := true
const NOVA_CUE_WAKE := 0.85
const NOVA_CUE_WARN := 0.90
const NOVA_CUE_STRIKE := 0.97
const ENEMY_SPAWN_OFFSCREEN_MARGIN := 180.0
const ENEMY_SPAWN_SCREEN_PADDING := 64.0
const MAX_RELIC_CHOICES := 3
const HEALTH_PACK_DROP_CHANCE := 0.07
const EXECUTION_HEALTH_PACK_CHANCE := 0.34
const KILL_STREAK_WINDOW := 3.2
const SCREEN_SHAKE_SCALE := 0.62
const SCREEN_SHAKE_DURATION_SCALE := 0.74
const SCREEN_SHAKE_MIN_INTENSITY := 2.8
const SCREEN_SHAKE_MAX_INTENSITY := 8.0
const PROFILE_DIFFICULTY_HEALTH_STEP := 0.18
const PROFILE_DIFFICULTY_DAMAGE_STEP := 0.007
const PROFILE_DIFFICULTY_SPEED_STEP := 0.003
const HEALTH_PACK_HEAL := 16.0
const PLAYER_LEVEL_HEALTH_GAIN := 6.0
const PLAYER_LEVEL_HEAL := 18.0
const PLAYER_LEVEL_DAMAGE_STEP := 0.07
const SPITTER_PROJECTILE_DAMAGE := 8.0
const PLAYER_DAMAGE_NUMBER_INTERVAL := 0.48
const ANTI_KITE_START_TIME := 58.0
const ANTI_KITE_INTERVAL := 12.0
const PRESSURE_DIRECTOR_START_TIME := 38.0
const PRESSURE_DIRECTOR_INTERVAL := 2.1
const PRESSURE_NEAR_RADIUS := 760.0
const PRESSURE_VISIBLE_PADDING := 120.0
const PRESSURE_FAR_RADIUS := 1120.0
const HAZARD_START_TIME := 62.0
const HAZARD_INTERVAL := 5.0
const HAZARD_ARM_TIME := 1.55
const HAZARD_ACTIVE_TIME := 2.6
const HAZARD_RADIUS := 112.0
const HAZARD_DAMAGE := 18.0
const HAZARD_SAFE_DISTANCE := 190.0
const NOVA_VAMPIRISM_HEAL_CAP := 15.0
const CLUSTER_BLOOM_START_TIME := 72.0
const CLUSTER_BLOOM_INTERVAL := 7.0
const CLUSTER_BLOOM_MIN_ENEMIES := 12
const DREAD_BOSS_HAZARD_INTERVAL := 4.8
const DREAD_BOSS_SUMMON_INTERVAL := 7.4
const DREAD_BOSS_BELL_INTERVAL := 8.2
const DREAD_BOSS_JUDGMENT_INTERVAL := 6.4
const DREAD_BOSS_CROSS_INTERVAL := 10.5
const BOSS_ATTACK_ARM_TIME := 1.0
const BOSS_ATTACK_ACTIVE_TIME := 0.45
const SAVE_PATH := "user://save.json"
const HISTORY_LIMIT := 8
const PROFILE_HISTORY_VISIBLE := 3
const CODEX_VISIBLE_ENTRIES := 4
const META_UPGRADES := {
	"mask": {"name": "Крепче Маска", "description": "+5 стартового HP", "base_cost": 24, "cost_step": 18, "max": 8},
	"blade": {"name": "Острее Клинок", "description": "+1 стартовый урон клинка", "base_cost": 38, "cost_step": 28, "max": 4},
	"magnet": {"name": "Старый Магнит", "description": "Опыт ближе к Маске", "base_cost": 22, "cost_step": 16, "max": 8},
	"nova": {"name": "Быстрее Нова", "description": "Нова заряжается быстрее", "base_cost": 32, "cost_step": 24, "max": 5},
}
const LORE_EVENTS := [
	{"time": 12.0, "text": "Руины проснулись"},
	{"time": 45.0, "text": "Gravebloom тянется к крови"},
	{"time": 90.0, "text": "Маска шепчет: не останавливайся"},
	{"time": 130.0, "text": "Клинок вспоминает старую клятву"},
]
const DEATH_LORE_LINES := [
	"Цветы сомкнулись над следами Маски.",
	"Руины не отпускают тех, кто вспомнил их имя.",
	"Клинок вернулся один.",
	"Gravebloom выпил еще одну клятву.",
]
const VICTORY_LORE_LINES := [
	"Рассвет не исцелил королевство, но заставил его замолчать.",
	"Маска вынесла из руин еще один вдох.",
	"Корни отступили. Ненадолго.",
	"Клинок уснул, насытившись мертвыми.",
]
const CHAPTERS := [
	{
		"id": "dead_garden",
		"name": "Мертвый Сад",
		"subtitle": "Руины первого двора, где Gravebloom пустил корни.",
		"goal": "Продержись до рассвета.",
		"palette": {
			"bg": Color(0.028, 0.031, 0.034),
			"floor": Color(0.064, 0.065, 0.074, 0.92),
			"stain": Color(0.02, 0.025, 0.026, 0.25),
			"stone": Color(0.13, 0.14, 0.15, 0.9),
			"rubble": Color(0.12, 0.12, 0.135, 0.55),
			"glow": Color(0.55, 1.0, 0.72, 0.34),
			"flower": Color(0.62, 1.0, 0.72, 0.68),
			"fog": Color(0.45, 0.56, 0.52, 0.1),
		},
		"lore_events": [
			{"time": 12.0, "text": "Руины проснулись"},
			{"time": 45.0, "text": "Gravebloom тянется к крови"},
			{"time": 90.0, "text": "Маска шепчет: не останавливайся"},
			{"time": 130.0, "text": "Клинок вспоминает старую клятву"},
		],
		"death_lines": [
			"Цветы сомкнулись над следами Маски.",
			"Руины не отпускают тех, кто вспомнил их имя.",
			"Клинок вернулся один.",
			"Gravebloom выпил еще одну клятву.",
		],
		"victory_lines": [
			"Рассвет не исцелил королевство, но заставил его замолчать.",
			"Маска вынесла из руин еще один вдох.",
			"Корни отступили. Ненадолго.",
			"Клинок уснул, насытившись мертвыми.",
		],
		"boss_name": "КОРОЛЬ-МОГИЛА",
		"boss_enter": "Король-Могила встал",
		"boss_lore": "За ним не осталось живых подданных",
		"boss_dead": "Король-Могила пал",
		"enemy_speed": 1.0,
		"enemy_health": 0,
		"spitter_bonus": 0.0,
		"runner_bonus": 0.0,
	},
	{
		"id": "ashen_chapel",
		"name": "Пепельная Часовня",
		"subtitle": "Сгоревший храм, где колокол звенит без руки.",
		"goal": "Выживи под пеплом и не дай звону сомкнуться.",
		"palette": {
			"bg": Color(0.036, 0.032, 0.038),
			"floor": Color(0.078, 0.071, 0.077, 0.92),
			"stain": Color(0.035, 0.028, 0.033, 0.3),
			"stone": Color(0.16, 0.145, 0.15, 0.92),
			"rubble": Color(0.17, 0.135, 0.13, 0.58),
			"glow": Color(1.0, 0.68, 0.42, 0.36),
			"flower": Color(0.98, 0.72, 0.42, 0.68),
			"fog": Color(0.62, 0.52, 0.45, 0.11),
		},
		"lore_events": [
			{"time": 10.0, "text": "Пепел лег на Маску"},
			{"time": 42.0, "text": "Часовня считает каждый шаг"},
			{"time": 82.0, "text": "Колокол звенит из-под пола"},
			{"time": 128.0, "text": "Огонь здесь умер последним"},
		],
		"death_lines": [
			"Пепел заполнил трещину в Маске.",
			"Часовня закрыла двери без звука.",
			"Клинок потускнел в сером алтаре.",
			"Звон нашел еще одно имя.",
		],
		"victory_lines": [
			"Колокол смолк, но пепел не осел.",
			"Маска вышла из часовни теплее смерти.",
			"Алтарь треснул, и корни отступили.",
			"Пепел запомнил форму клинка.",
		],
		"boss_name": "ИГУМЕН ПЕПЛА",
		"boss_enter": "Игумен Пепла поднялся",
		"boss_lore": "Он молился, пока храм не сгорел",
		"boss_dead": "Игумен Пепла рассыпался",
		"enemy_speed": 1.08,
		"enemy_health": 1,
		"spitter_bonus": 0.04,
		"runner_bonus": 0.05,
	},
]
const RUN_GOAL_COUNT := 3
const RUN_GOALS := [
	{"id": "kill_45", "title": "Сорвать 45 мертвых", "description": "Убей 45 врагов", "reward": 12, "type": "kills", "target": 45},
	{"id": "kill_80", "title": "Очистить двор", "description": "Убей 80 врагов", "reward": 20, "type": "kills", "target": 80},
	{"id": "level_5", "title": "Маска крепнет", "description": "Достигни 5 уровня", "reward": 14, "type": "level", "target": 5},
	{"id": "level_7", "title": "Клятва глубже", "description": "Достигни 7 уровня", "reward": 22, "type": "level", "target": 7},
	{"id": "meet_king", "title": "Увидеть пустой трон", "description": "Доживи до Короля-Могилы", "reward": 18, "type": "boss_spawned", "target": 1},
	{"id": "kill_king", "title": "Сломать корону", "description": "Убей Короля-Могилу", "reward": 45, "type": "boss_killed", "target": 1},
	{"id": "blood_blade", "title": "Разбудить кровь", "description": "Собери Кровавый Клинок", "reward": 24, "type": "blood_blade", "target": 1},
	{"id": "bone_spears", "title": "Поднять старую стражу", "description": "Возьми Костяные Копья", "reward": 12, "type": "bone_spears", "target": 1},
	{"id": "bell", "title": "Позвонить мертвым", "description": "Возьми Колокол Забвения", "reward": 10, "type": "bell", "target": 1},
	{"id": "nova_3", "title": "Трижды раскрыть цветок", "description": "Нова сработает 3 раза", "reward": 18, "type": "nova_casts", "target": 3},
	{"id": "health_3", "title": "Не отдать тепло", "description": "Собери 3 аптечки", "reward": 12, "type": "health_packs", "target": 3},
]
const CODEX_ENTRIES := [
	{"id": "first_death", "title": "Первая трещина", "text": "Маска треснула. Руины запомнили звук.", "reward": 8},
	{"id": "first_victory", "title": "Первый рассвет", "text": "Gravebloom отступил, но корни не умерли.", "reward": 18},
	{"id": "king_seen", "title": "Пустой трон", "text": "Король-Могила встал без подданных и без лица.", "reward": 12},
	{"id": "king_killed", "title": "Сломанная корона", "text": "Корона упала, а земля все еще ждала приказа.", "reward": 30},
	{"id": "blood_blade", "title": "Клинок пьет", "text": "Живой Клинок вспомнил кровь и стал голоднее Маски.", "reward": 18},
	{"id": "bone_spears", "title": "Старая стража", "text": "Кости поднялись не ради жизни, а ради последнего приказа.", "reward": 12},
	{"id": "bell", "title": "Звон забвения", "text": "Колокол прозвучал там, где больше некому было скорбеть.", "reward": 12},
	{"id": "three_runs", "title": "Третья клятва", "text": "Трижды Маска входила в руины. На четвертый раз руины ждали.", "reward": 10},
	{"id": "hundred_kills", "title": "Сад мертвых", "text": "Сто тел легли в землю. Цветы стали выше.", "reward": 16},
	{"id": "nova_ten", "title": "Сердце цветка", "text": "Нова раскрывалась снова и снова, как зеленая звезда под кожей.", "reward": 14},
]
const BUILD_PATH_DESCRIPTIONS := {
	"Кровавый Клинок": "ближний урон, вампиризм и охота на босса",
	"Костяная Стража": "Копья и Колокол держат толпу на расстоянии",
	"Сердце Gravebloom": "Нова и Цветок превращают толпу во взрыв",
	"Тень Маски": "луч, магнит и позиционирование вокруг толпы",
	"Живой Клинок": "базовый путь Маски и охотящегося клинка",
}

var player: Player
var living_blade: Node2D
var enemies: Array[Enemy] = []
var shards: Array[XPShard] = []
var enemy_projectiles: Array[Node2D] = []
var health_packs: Array[Node2D] = []
var hazard_zones: Array[Node2D] = []
var boss_attacks: Array[Node2D] = []
var elapsed := 0.0
var spawn_timer := 0.0
var level := 1
var player_damage_bonus := 0.0
var xp := 0
var xp_to_next := 14
var shard_pull_range := 95.0
var paused_for_upgrade := false
var game_state := "start"
var dread_boss_spawned := false
var miniboss_spawned := false
var last_run_result := ""
var last_run_lore := ""
var last_run_ash := 0
var last_run_goal_ash := 0
var last_run_codex_ash := 0
var last_run_codex_unlocks: Array[String] = []
var run_reward_recorded := false
var profile_ash := 0
var profile_upgrades: Dictionary = {}
var profile_stats: Dictionary = {}
var codex_unlocked: Dictionary = {}
var run_history: Array = []
var relic_pick_counts: Dictionary = {}
var relic_pick_order: Array[String] = []
var active_run_goals: Array = []
var completed_goal_ids: Dictionary = {}
var current_chapter_index := 0
var shadow_spirit_unlocked := false
var shadow_spirit_timer := 3.0
var shadow_spirit_cooldown := 5.5
var shadow_spirit_damage := 2
var bone_spears_unlocked := false
var bone_spear_timer := 2.8
var bone_spear_cooldown := 3.4
var bone_spear_damage := 2
var bone_spear_count := 1
var oblivion_bell_unlocked := false
var oblivion_bell_timer := 4.0
var oblivion_bell_cooldown := 5.8
var oblivion_bell_damage := 1
var oblivion_bell_radius := 138.0
var blood_blade_evolved := false
var shake_time := 0.0
var shake_intensity := 0.0
var joystick_active := false
var joystick_direction := Vector2.ZERO
var joystick_radius := 67.0
var ambient_glows: Array[CanvasItem] = []
var fog_wisps: Array[CanvasItem] = []
var ambience_time := 0.0
var ultimate_charge := 0.0
var ultimate_ready := false
var ultimate_cooldown := ULTIMATE_COOLDOWN
var ultimate_radius := ULTIMATE_RADIUS
var ultimate_damage := ULTIMATE_DAMAGE
var thorn_bloom_unlocked := false
var thorn_bloom_cooldown := 0.0
var vampirism_unlocked := false
var vampirism_level := 0
var vampirism_heal_amount := 5.0
var vampirism_kills_required := 9
var kill_count := 0
var kill_streak := 0
var best_kill_streak := 0
var kill_streak_timer := 0.0
var nova_cast_count := 0
var health_pack_count := 0
var grave_king_killed := false
var nova_damage_active := false
var nova_vampirism_healed := 0.0
var nova_charge_stage := 0
var nova_pulse_time := 0.0
var player_damage_number_cooldown := 0.0
var player_damage_number_accumulator := 0.0
var lore_event_index := 0
var anti_kite_timer := ANTI_KITE_INTERVAL
var pressure_director_timer := PRESSURE_DIRECTOR_INTERVAL
var hazard_timer := HAZARD_INTERVAL
var cluster_bloom_timer := CLUSTER_BLOOM_INTERVAL
var dread_boss_hazard_timer := DREAD_BOSS_HAZARD_INTERVAL
var dread_boss_summon_timer := DREAD_BOSS_SUMMON_INTERVAL
var dread_boss_bell_timer := DREAD_BOSS_BELL_INTERVAL
var dread_boss_judgment_timer := DREAD_BOSS_JUDGMENT_INTERVAL
var dread_boss_cross_timer := DREAD_BOSS_CROSS_INTERVAL
var dread_boss_phase_two := false

@onready var world := Node2D.new()
@onready var fx_layer := Node2D.new()
@onready var ui_layer := CanvasLayer.new()
@onready var hud := Label.new()
@onready var build_label := Label.new()
@onready var hp_bar := ProgressBar.new()
@onready var xp_bar := ProgressBar.new()
@onready var boss_name_label := Label.new()
@onready var boss_hp_bar := ProgressBar.new()
@onready var ultimate_bar := ProgressBar.new()
@onready var ultimate_button := Button.new()
@onready var joystick_base := Panel.new()
@onready var joystick_knob := Panel.new()
@onready var upgrade_panel := PanelContainer.new()
@onready var upgrade_list := VBoxContainer.new()
@onready var overlay_panel := PanelContainer.new()
@onready var overlay_list := VBoxContainer.new()
@onready var nova_charge_fx := Node2D.new()
@onready var nova_wake_player := AudioStreamPlayer.new()
@onready var nova_warn_player := AudioStreamPlayer.new()
@onready var nova_burst_player := AudioStreamPlayer.new()

func _ready() -> void:
	randomize()
	add_child(world)
	add_child(fx_layer)
	_load_profile()
	_build_arena()
	_build_ui()
	_build_nova_charge_fx()
	_build_nova_audio()
	_show_start_screen()

func _current_chapter() -> Dictionary:
	var index: int = clampi(current_chapter_index, 0, CHAPTERS.size() - 1)
	var chapter: Dictionary = CHAPTERS[index]
	return chapter

func _chapter_palette() -> Dictionary:
	var palette: Variant = _current_chapter().get("palette", {})
	if typeof(palette) == TYPE_DICTIONARY:
		return palette
	return {}

func _chapter_color(color_id: String, fallback: Color) -> Color:
	var palette := _chapter_palette()
	var color: Variant = palette.get(color_id, fallback)
	if typeof(color) == TYPE_COLOR:
		return color
	return fallback

func _chapter_lore_events() -> Array:
	var events: Variant = _current_chapter().get("lore_events", LORE_EVENTS)
	if typeof(events) == TYPE_ARRAY:
		return events
	return LORE_EVENTS

func _chapter_death_lines() -> Array:
	var lines: Variant = _current_chapter().get("death_lines", DEATH_LORE_LINES)
	if typeof(lines) == TYPE_ARRAY:
		return lines
	return DEATH_LORE_LINES

func _chapter_victory_lines() -> Array:
	var lines: Variant = _current_chapter().get("victory_lines", VICTORY_LORE_LINES)
	if typeof(lines) == TYPE_ARRAY:
		return lines
	return VICTORY_LORE_LINES

func _chapter_enemy_speed_multiplier() -> float:
	return float(_current_chapter().get("enemy_speed", 1.0))

func _chapter_enemy_health_bonus() -> int:
	return int(_current_chapter().get("enemy_health", 0))

func _chapter_chance_bonus(bonus_id: String) -> float:
	return float(_current_chapter().get(bonus_id, 0.0))

func _is_ashen_chapel() -> bool:
	return String(_current_chapter().get("id", "")) == "ashen_chapel"

func _rebuild_arena() -> void:
	for child in world.get_children():
		if child != player and child != living_blade:
			child.queue_free()
	ambient_glows.clear()
	fog_wisps.clear()
	_build_arena()

func _process(delta: float) -> void:
	_update_screen_shake(delta)
	_update_joystick_mouse()
	_update_arena_ambience(delta)
	_update_nova_charge_fx(delta)
	if game_state != "running":
		return
	elapsed += delta
	thorn_bloom_cooldown = max(0.0, thorn_bloom_cooldown - delta)
	player_damage_number_cooldown = max(0.0, player_damage_number_cooldown - delta)
	_update_kill_streak(delta)
	if elapsed >= RUN_DURATION:
		_show_victory()
		return
	if not dread_boss_spawned and elapsed >= DREAD_BOSS_TIME:
		_spawn_dread_boss()
	if not miniboss_spawned and elapsed >= MINIBOSS_TIME:
		_spawn_miniboss()
	_update_lore_events()
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		_spawn_enemy_wave()
		spawn_timer = max(0.28, 1.18 - elapsed * 0.006 - float(_profile_pressure_tier()) * 0.018)
	_update_pressure_director(delta)
	_update_anti_kite_pressure(delta)
	living_blade.tick(delta, enemies)
	_update_ultimate(delta)
	_update_shadow_spirit(delta)
	_update_bone_spears(delta)
	_update_enemy_projectiles(delta)
	_update_hazard_zones(delta)
	_update_boss_attacks(delta)
	_update_cluster_bloom(delta)
	_update_dread_boss_pressure(delta)
	_update_shards(delta)
	_update_health_packs(delta)
	_check_enemy_contact(delta)
	_keep_player_inside_arena()
	_update_oblivion_bell(delta)
	_update_run_goals()
	_update_hud()

func _build_arena() -> void:
	var bg := ColorRect.new()
	bg.color = _chapter_color("bg", Color(0.028, 0.031, 0.034))
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

func _build_floor_tiles() -> void:
	var tile_size := 176.0
	var base_floor := _chapter_color("floor", Color(0.064, 0.065, 0.074, 0.92))
	var stain_color := _chapter_color("stain", Color(0.02, 0.025, 0.026, 0.25))
	for x in range(-11, 12):
		for y in range(-7, 8):
			var tile := ColorRect.new()
			var shade := randf_range(-0.012, 0.016)
			tile.color = Color(base_floor.r + shade, base_floor.g + shade, base_floor.b + shade, base_floor.a)
			tile.size = Vector2(tile_size - 7.0, tile_size - 7.0)
			tile.position = Vector2(x * tile_size, y * tile_size) + Vector2(randf_range(-3.0, 3.0), randf_range(-3.0, 3.0))
			tile.rotation = randf_range(-0.012, 0.012)
			world.add_child(tile)
	for i in range(90):
		var stain := _make_ellipse(randf_range(10.0, 34.0), randf_range(5.0, 18.0), Color(stain_color.r, stain_color.g, stain_color.b, randf_range(0.16, 0.34)), 12)
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
		var rubble_color := _chapter_color("rubble", Color(0.12, 0.12, 0.135, 0.55))
		rubble.color = Color(rubble_color.r, rubble_color.g, rubble_color.b, randf_range(0.35, 0.7))
		rubble.size = Vector2(randf_range(12.0, 42.0), randf_range(7.0, 18.0))
		rubble.position = Vector2(randf_range(-1900.0, 1900.0), randf_range(-1250.0, 1250.0))
		rubble.rotation = randf() * TAU
		world.add_child(rubble)
	if _is_ashen_chapel():
		_build_chapel_debris()

func _build_chapel_debris() -> void:
	for aisle_index in range(-2, 3):
		var aisle := Line2D.new()
		aisle.width = 58.0 if aisle_index == 0 else 34.0
		aisle.default_color = Color(0.12, 0.095, 0.1, 0.72)
		aisle.points = PackedVector2Array([
			Vector2(-1820.0, float(aisle_index) * 390.0),
			Vector2(1820.0, float(aisle_index) * 390.0),
		])
		world.add_child(aisle)
	for row in [-1, 1]:
		for column_index in range(-8, 9):
			var column_position := Vector2(float(column_index) * 220.0, float(row) * 410.0)
			var shadow := _make_ellipse(54.0, 18.0, Color(0.0, 0.0, 0.0, 0.34), 16)
			shadow.position = column_position + Vector2(10.0, 22.0)
			world.add_child(shadow)
			var column := Polygon2D.new()
			column.color = Color(0.22, 0.18, 0.18, 0.92)
			column.polygon = PackedVector2Array([
				Vector2(-28.0, 34.0),
				Vector2(-22.0, -42.0),
				Vector2(-12.0, -62.0),
				Vector2(12.0, -62.0),
				Vector2(22.0, -42.0),
				Vector2(28.0, 34.0),
			])
			column.position = column_position
			world.add_child(column)
			var column_glow := _make_ellipse(9.0, 5.0, Color(1.0, 0.55, 0.24, 0.5), 10)
			column_glow.position = column_position + Vector2(0.0, -48.0)
			world.add_child(column_glow)
			ambient_glows.append(column_glow)
	for i in range(14):
		var arch := Line2D.new()
		arch.width = randf_range(6.0, 10.0)
		arch.default_color = Color(0.24, 0.19, 0.18, randf_range(0.42, 0.68))
		arch.points = PackedVector2Array([
			Vector2(-42.0, 34.0),
			Vector2(-32.0, -18.0),
			Vector2(0.0, -48.0),
			Vector2(32.0, -18.0),
			Vector2(42.0, 34.0),
		])
		arch.position = Vector2(randf_range(-1720.0, 1720.0), randf_range(-1040.0, 1040.0))
		if arch.position.length() < 300.0:
			arch.position += arch.position.normalized() * 360.0
		arch.rotation = randf_range(-0.35, 0.35)
		world.add_child(arch)
	for i in range(26):
		var ember := _make_ellipse(randf_range(5.0, 12.0), randf_range(2.0, 5.0), Color(1.0, 0.56, 0.24, randf_range(0.28, 0.5)), 8)
		ember.position = Vector2(randf_range(-1860.0, 1860.0), randf_range(-1180.0, 1180.0))
		ember.rotation = randf() * TAU
		world.add_child(ember)
		ambient_glows.append(ember)

func _add_broken_column(base_position: Vector2) -> void:
	var shadow := _make_ellipse(58.0, 18.0, Color(0.0, 0.0, 0.0, 0.24), 16)
	shadow.position = base_position + Vector2(8.0, 22.0)
	world.add_child(shadow)
	var stone_color := _chapter_color("stone", Color(0.16, 0.155, 0.17, 0.88))
	for piece_index in range(randi_range(2, 4)):
		var piece := ColorRect.new()
		piece.color = Color(stone_color.r + 0.03, stone_color.g + 0.015, stone_color.b + 0.02, randf_range(0.74, 0.94))
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
	stone.color = _chapter_color("stone", Color(0.13, 0.14, 0.15, 0.9))
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
	var glow_color := _chapter_color("glow", Color(0.55, 1.0, 0.72, 0.34))
	rune.color = Color(glow_color.r, glow_color.g, glow_color.b, randf_range(0.22, 0.36))
	rune.size = Vector2(4.0 * scale_value, 20.0 * scale_value)
	rune.position = base_position + Vector2(-2.0 * scale_value, -8.0 * scale_value)
	world.add_child(rune)
	ambient_glows.append(rune)

func _build_graveblooms() -> void:
	var flower_color := _chapter_color("flower", Color(0.62, 1.0, 0.72, 0.68))
	for i in range(70):
		var center := Vector2(randf_range(-1850.0, 1850.0), randf_range(-1200.0, 1200.0))
		var stem := ColorRect.new()
		stem.color = Color(0.16, 0.36, 0.24, randf_range(0.44, 0.72))
		stem.size = Vector2(3.0, randf_range(10.0, 20.0))
		stem.position = center + Vector2(-1.5, -2.0)
		world.add_child(stem)
		var bloom := _make_ellipse(randf_range(5.0, 9.0), randf_range(4.0, 7.0), Color(flower_color.r, flower_color.g, flower_color.b, randf_range(0.48, 0.82)), 8)
		bloom.position = center + Vector2(0.0, -7.0)
		world.add_child(bloom)
		ambient_glows.append(bloom)

func _build_cursed_runes() -> void:
	for i in range(9):
		var rune := Line2D.new()
		rune.width = 3.0
		rune.closed = true
		var glow_color := _chapter_color("glow", Color(0.48, 1.0, 0.75, 0.42))
		rune.default_color = Color(glow_color.r, glow_color.g, glow_color.b, randf_range(0.28, 0.48))
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
	var base_glow := _chapter_color("glow", Color(0.48, 1.0, 0.72, 0.28))
	var glow_color := Color(base_glow.r, base_glow.g, base_glow.b, 0.28)
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
	var fog_color := _chapter_color("fog", Color(0.45, 0.56, 0.52, 0.1))
	for i in range(18):
		var wisp := Line2D.new()
		wisp.width = randf_range(12.0, 24.0)
		wisp.default_color = Color(fog_color.r, fog_color.g, fog_color.b, randf_range(0.06, 0.13))
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

func _make_ring_points(radius: float, point_count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(point_count):
		points.append(Vector2.RIGHT.rotated(TAU * float(i) / float(point_count)) * radius)
	return points

func _build_nova_charge_fx() -> void:
	nova_charge_fx.visible = false
	nova_charge_fx.z_index = 40
	fx_layer.add_child(nova_charge_fx)

	var aura := _make_ellipse(62.0, 42.0, Color(0.42, 1.0, 0.66, 0.16), 32)
	aura.name = "Aura"
	nova_charge_fx.add_child(aura)

	var outer_ring := Line2D.new()
	outer_ring.name = "OuterRing"
	outer_ring.width = 4.0
	outer_ring.closed = true
	outer_ring.default_color = Color(0.62, 1.0, 0.74, 0.72)
	outer_ring.points = _make_ring_points(72.0, 44)
	nova_charge_fx.add_child(outer_ring)

	var inner_ring := Line2D.new()
	inner_ring.name = "InnerRing"
	inner_ring.width = 2.0
	inner_ring.closed = true
	inner_ring.default_color = Color(0.9, 0.78, 1.0, 0.58)
	inner_ring.points = _make_ring_points(46.0, 32)
	nova_charge_fx.add_child(inner_ring)

	var petal_root := Node2D.new()
	petal_root.name = "Petals"
	nova_charge_fx.add_child(petal_root)
	for i in range(10):
		var petal := _make_ellipse(7.0, 19.0, Color(0.76, 1.0, 0.72, 0.62), 12)
		var angle := TAU * float(i) / 10.0
		petal.position = Vector2.RIGHT.rotated(angle) * 72.0
		petal.rotation = angle + PI * 0.5
		petal_root.add_child(petal)

func _build_nova_audio() -> void:
	nova_wake_player.stream = _make_nova_tone([210.0, 315.0], 0.22, 0.28)
	nova_warn_player.stream = _make_nova_tone([280.0, 420.0, 630.0], 0.32, 0.36)
	nova_burst_player.stream = _make_nova_tone([130.0, 260.0, 520.0], 0.48, 0.52)
	for player_node in [nova_wake_player, nova_warn_player, nova_burst_player]:
		player_node.volume_db = -8.0
		add_child(player_node)

func _make_nova_tone(frequencies: Array, duration: float, volume: float) -> AudioStreamWAV:
	var mix_rate := 22050
	var sample_count := int(duration * float(mix_rate))
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for i in range(sample_count):
		var t := float(i) / float(mix_rate)
		var fade_in: float = clamp(t / 0.025, 0.0, 1.0)
		var fade_out: float = clamp((duration - t) / 0.16, 0.0, 1.0)
		var envelope := fade_in * fade_out
		var sample := 0.0
		for frequency in frequencies:
			var sweep := 1.0 + t * 0.42
			sample += sin(TAU * float(frequency) * sweep * t)
		sample /= max(1.0, float(frequencies.size()))
		sample += sin(TAU * 42.0 * t) * 0.22
		var value := int(clamp(sample * envelope * volume, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, value)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = data
	return stream

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
	_apply_profile_start_bonuses()

func _apply_profile_start_bonuses() -> void:
	if player != null:
		var mask_bonus := float(_profile_upgrade_level("mask")) * 5.0
		player.max_health += mask_bonus
		player.health = player.max_health
	if is_instance_valid(living_blade):
		for i in range(_profile_upgrade_level("blade")):
			living_blade.increase_damage()

func _build_ui() -> void:
	add_child(ui_layer)
	ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	_build_screen_vignette()
	hud.position = Vector2(18, 18)
	hud.add_theme_font_size_override("font_size", 24)
	hud.add_theme_color_override("font_color", Color(0.88, 0.84, 0.73))
	ui_layer.add_child(hud)
	build_label.position = Vector2(18, 230)
	build_label.size = Vector2(504, 118)
	build_label.add_theme_font_size_override("font_size", 16)
	build_label.add_theme_color_override("font_color", Color(0.74, 0.88, 0.78, 0.92))
	build_label.add_theme_color_override("font_shadow_color", Color(0.02, 0.015, 0.02, 0.9))
	build_label.add_theme_constant_override("shadow_offset_x", 2)
	build_label.add_theme_constant_override("shadow_offset_y", 2)
	ui_layer.add_child(build_label)
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
	_build_boss_ui()
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

func _build_boss_ui() -> void:
	boss_name_label.position = Vector2(18, 174)
	boss_name_label.size = Vector2(504, 26)
	boss_name_label.text = "КОРОЛЬ-МОГИЛА"
	boss_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_name_label.add_theme_font_size_override("font_size", 20)
	boss_name_label.add_theme_color_override("font_color", Color(0.9, 0.82, 0.72))
	boss_name_label.add_theme_color_override("font_shadow_color", Color(0.02, 0.015, 0.02, 0.9))
	boss_name_label.add_theme_constant_override("shadow_offset_x", 2)
	boss_name_label.add_theme_constant_override("shadow_offset_y", 2)
	boss_name_label.visible = false
	ui_layer.add_child(boss_name_label)

	boss_hp_bar.position = Vector2(46, 204)
	boss_hp_bar.size = Vector2(448, 22)
	boss_hp_bar.max_value = 100.0
	boss_hp_bar.value = 100.0
	boss_hp_bar.show_percentage = false
	boss_hp_bar.visible = false
	boss_hp_bar.add_theme_stylebox_override("background", _make_bar_style(Color(0.055, 0.035, 0.045, 0.92), Color(0.32, 0.22, 0.26, 0.9)))
	boss_hp_bar.add_theme_stylebox_override("fill", _make_bar_style(Color(0.62, 0.12, 0.18, 0.96), Color(0.9, 0.62, 0.42, 0.9)))
	ui_layer.add_child(boss_hp_bar)

func _make_bar_style(fill: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style

func _show_start_screen() -> void:
	_clear_world_entities()
	_prepare_run_goals()
	game_state = "start"
	get_tree().paused = true
	build_label.visible = false
	hp_bar.visible = false
	xp_bar.visible = false
	_hide_boss_ui()
	upgrade_panel.visible = false
	joystick_base.visible = false
	ultimate_button.visible = false
	ultimate_bar.visible = false
	_configure_overlay(Vector2(24, 72), Vector2(492, 820))
	overlay_panel.visible = true
	_clear_container(overlay_list)
	var chapter := _current_chapter()
	_add_overlay_label("GRAVEBLOOM", 42)
	_add_overlay_label("Глава: %s" % String(chapter["name"]), 23)
	_add_overlay_label(String(chapter["subtitle"]), 15)
	_add_overlay_label("Цели забега", 22)
	_add_overlay_label("Выполни их во время забега, чтобы получить больше Пепла.", 15)
	for goal in active_run_goals:
		var goal_data: Dictionary = goal
		_add_overlay_label("%s: %s  +%d" % [String(goal_data["title"]), String(goal_data["description"]), int(goal_data["reward"])], 16)
	_add_overlay_label("Королевство умерло, но его цветы продолжают расти.", 19)
	_add_overlay_label(String(chapter["goal"]), 20)
	_add_overlay_label("Пепел профиля: %d" % profile_ash, 18)
	if _profile_pressure_tier() > 0:
		_add_overlay_label("Руины чувствуют силу Маски и отвечают более опасными волнами.", 14)
	_add_overlay_button("Начать забег", _start_run)
	_add_overlay_button("Выбрать главу", _show_chapter_screen)
	_add_overlay_button("Справка", _show_help_screen)
	_add_overlay_button("Профиль", _show_profile_screen)
	_add_overlay_button("Летопись", _show_codex_screen)

func _show_chapter_screen() -> void:
	_clear_world_entities()
	game_state = "chapter_select"
	get_tree().paused = true
	build_label.visible = false
	hp_bar.visible = false
	xp_bar.visible = false
	_hide_boss_ui()
	upgrade_panel.visible = false
	joystick_base.visible = false
	ultimate_button.visible = false
	ultimate_bar.visible = false
	_configure_overlay(Vector2(24, 76), Vector2(492, 812))
	overlay_panel.visible = true
	_clear_container(overlay_list)
	_add_overlay_label("Выбор главы", 32)
	_add_overlay_label("Каждая глава меняет арену, темп врагов и голос руин.", 16)
	for i in range(CHAPTERS.size()):
		var chapter: Dictionary = CHAPTERS[i]
		var marker := ">> " if i == current_chapter_index else ""
		_add_overlay_button("%s%s\n%s" % [marker, String(chapter["name"]), String(chapter["subtitle"])], _select_chapter.bind(i))
	_add_overlay_button("Назад", _show_start_screen)

func _select_chapter(chapter_index: int) -> void:
	current_chapter_index = clampi(chapter_index, 0, CHAPTERS.size() - 1)
	_save_profile()
	_rebuild_arena()
	_prepare_run_goals()
	_show_start_screen()

func _start_run() -> void:
	if game_state != "start":
		_prepare_run_goals()
	_reset_run()
	overlay_panel.visible = false
	hp_bar.visible = true
	xp_bar.visible = true
	joystick_base.visible = true
	ultimate_button.visible = true
	ultimate_bar.visible = true
	game_state = "running"
	get_tree().paused = false

func _show_profile_screen() -> void:
	_clear_world_entities()
	game_state = "profile"
	get_tree().paused = true
	build_label.visible = false
	hp_bar.visible = false
	xp_bar.visible = false
	_hide_boss_ui()
	upgrade_panel.visible = false
	joystick_base.visible = false
	ultimate_button.visible = false
	ultimate_bar.visible = false
	_configure_overlay(Vector2(24, 72), Vector2(492, 820))
	overlay_panel.visible = true
	_clear_container(overlay_list)
	_add_overlay_label("Профиль Маски", 32)
	_add_overlay_label("Пепел: %d" % profile_ash, 22)
	_add_overlay_label("Пепел сохраняется между забегами. Трать его здесь на постоянные усиления.", 15)
	_add_overlay_label("Постоянные дары", 20)
	for upgrade_id in ["mask", "blade", "magnet", "nova"]:
		_add_profile_upgrade_button(upgrade_id)
	_add_overlay_label("История забегов", 20)
	if run_history.is_empty():
		_add_overlay_label("Пока руины молчат.", 16)
	else:
		var history_count: int = min(PROFILE_HISTORY_VISIBLE, run_history.size())
		for entry in run_history.slice(0, history_count):
			_add_overlay_label(_format_history_entry(entry), 15)
		if run_history.size() > history_count:
			_add_overlay_label("Еще забегов в памяти: %d" % (run_history.size() - history_count), 14)
	_add_overlay_button("Справка", _show_help_screen)
	_add_overlay_button("Летопись", _show_codex_screen)
	_add_overlay_button("Назад", _show_start_screen)

func _show_help_screen() -> void:
	_clear_world_entities()
	game_state = "help"
	get_tree().paused = true
	build_label.visible = false
	hp_bar.visible = false
	xp_bar.visible = false
	_hide_boss_ui()
	upgrade_panel.visible = false
	joystick_base.visible = false
	ultimate_button.visible = false
	ultimate_bar.visible = false
	_configure_overlay(Vector2(24, 76), Vector2(492, 812))
	overlay_panel.visible = true
	_clear_container(overlay_list)
	_add_overlay_label("Справка Маски", 32)
	_add_overlay_label("Как играть\nДвигайся и выживай 3 минуты. Атаки срабатывают сами, ты управляешь только позицией.", 16)
	_add_overlay_label("Пепел\nВалюта профиля. Получаешь после забега, тратишь на постоянные усиления.", 16)
	_add_overlay_label("Реликвии\nВременные улучшения одного забега. Выбираются при новом уровне и сбрасываются после смерти.", 16)
	_add_overlay_label("Летопись\nДостижения, статистика и короткие записи мира. Новые записи дают разовый Пепел.", 16)
	_add_overlay_label("Счетчики сверху\nУровень, время забега и сколько осталось до конца. Полоски: здоровье и опыт.", 16)
	_add_overlay_button("Назад", _show_start_screen)

func _show_codex_screen() -> void:
	_clear_world_entities()
	game_state = "codex"
	get_tree().paused = true
	build_label.visible = false
	hp_bar.visible = false
	xp_bar.visible = false
	_hide_boss_ui()
	upgrade_panel.visible = false
	joystick_base.visible = false
	ultimate_button.visible = false
	ultimate_bar.visible = false
	_configure_overlay(Vector2(24, 72), Vector2(492, 820))
	overlay_panel.visible = true
	_clear_container(overlay_list)
	_add_overlay_label("Летопись Маски", 32)
	_add_overlay_label("Здесь хранятся достижения, статистика и открытые записи мира.", 15)
	_add_overlay_label(_format_codex_stats(), 16)
	_add_overlay_label("Последние открытые записи", 20)
	var opened := 0
	var shown := 0
	for entry in CODEX_ENTRIES:
		var entry_data: Dictionary = entry
		if codex_unlocked.has(String(entry_data["id"])):
			opened += 1
			if shown < CODEX_VISIBLE_ENTRIES:
				shown += 1
				_add_overlay_label("%s\n%s" % [String(entry_data["title"]), String(entry_data["text"])], 15)
	if opened <= 0:
		_add_overlay_label("Руины пока молчат. Вернись после забега.", 16)
	elif opened > shown:
		_add_overlay_label("Еще записей открыто: %d" % (opened - shown), 14)
	_add_overlay_label("Открыто: %d/%d" % [opened, CODEX_ENTRIES.size()], 16)
	_add_overlay_button("Профиль", _show_profile_screen)
	_add_overlay_button("Назад", _show_start_screen)

func _reset_run() -> void:
	_clear_world_entities()
	elapsed = 0.0
	spawn_timer = 0.0
	level = 1
	player_damage_bonus = 0.0
	xp = 0
	xp_to_next = 14
	shard_pull_range = 95.0 + float(_profile_upgrade_level("magnet")) * 16.0
	paused_for_upgrade = false
	dread_boss_spawned = false
	miniboss_spawned = false
	_hide_boss_ui()
	last_run_result = ""
	last_run_lore = ""
	last_run_ash = 0
	last_run_goal_ash = 0
	last_run_codex_ash = 0
	last_run_codex_unlocks.clear()
	run_reward_recorded = false
	completed_goal_ids.clear()
	relic_pick_counts.clear()
	relic_pick_order.clear()
	shadow_spirit_unlocked = false
	shadow_spirit_timer = 3.0
	shadow_spirit_cooldown = 5.5
	shadow_spirit_damage = 2
	bone_spears_unlocked = false
	bone_spear_timer = 2.8
	bone_spear_cooldown = 3.4
	bone_spear_damage = 2
	bone_spear_count = 1
	oblivion_bell_unlocked = false
	oblivion_bell_timer = 4.0
	oblivion_bell_cooldown = 5.8
	oblivion_bell_damage = 1
	oblivion_bell_radius = 138.0
	blood_blade_evolved = false
	ultimate_charge = 0.0
	ultimate_ready = false
	ultimate_cooldown = maxf(20.0, ULTIMATE_COOLDOWN - float(_profile_upgrade_level("nova")) * 1.4)
	ultimate_radius = ULTIMATE_RADIUS
	ultimate_damage = ULTIMATE_DAMAGE
	nova_charge_stage = 0
	nova_pulse_time = 0.0
	nova_charge_fx.visible = false
	thorn_bloom_unlocked = false
	thorn_bloom_cooldown = 0.0
	vampirism_unlocked = false
	vampirism_level = 0
	vampirism_heal_amount = 5.0
	vampirism_kills_required = 9
	kill_count = 0
	kill_streak = 0
	best_kill_streak = 0
	kill_streak_timer = 0.0
	nova_cast_count = 0
	health_pack_count = 0
	grave_king_killed = false
	nova_damage_active = false
	nova_vampirism_healed = 0.0
	player_damage_number_cooldown = 0.0
	player_damage_number_accumulator = 0.0
	lore_event_index = 0
	anti_kite_timer = ANTI_KITE_INTERVAL
	pressure_director_timer = PRESSURE_DIRECTOR_INTERVAL
	hazard_timer = HAZARD_INTERVAL
	cluster_bloom_timer = CLUSTER_BLOOM_INTERVAL
	dread_boss_hazard_timer = DREAD_BOSS_HAZARD_INTERVAL
	dread_boss_summon_timer = DREAD_BOSS_SUMMON_INTERVAL
	dread_boss_bell_timer = DREAD_BOSS_BELL_INTERVAL
	dread_boss_judgment_timer = DREAD_BOSS_JUDGMENT_INTERVAL
	dread_boss_cross_timer = DREAD_BOSS_CROSS_INTERVAL
	dread_boss_phase_two = false
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
	if _profile_pressure_tier() >= 4 and elapsed >= 55.0:
		count += 1
	count = min(count, available_slots)
	for i in range(count):
		_spawn_enemy(_pick_enemy_kind(), false)

func _update_anti_kite_pressure(delta: float) -> void:
	if elapsed < ANTI_KITE_START_TIME or player == null:
		return
	anti_kite_timer -= delta
	if anti_kite_timer > 0.0:
		return
	anti_kite_timer = max(7.5, ANTI_KITE_INTERVAL - elapsed * 0.018)
	var available_slots: int = MAX_ENEMIES - enemies.size()
	if available_slots <= 0:
		return
	var interceptors: int = 1
	if elapsed > 120.0 and available_slots > 1:
		interceptors = 2
	for i in range(min(interceptors, available_slots)):
		var roll := randf()
		var kind := "ash_ember" if _is_ashen_chapel() else "flanker"
		if not _is_ashen_chapel():
			if roll < 0.24:
				kind = "exploder"
			elif roll < 0.58:
				kind = "runner"
		_spawn_enemy(kind, false, _get_interceptor_position(i))

func _update_pressure_director(delta: float) -> void:
	if elapsed < PRESSURE_DIRECTOR_START_TIME or player == null:
		return
	pressure_director_timer -= delta
	if pressure_director_timer > 0.0:
		return
	pressure_director_timer = max(1.25, PRESSURE_DIRECTOR_INTERVAL - elapsed * 0.004)
	_compact_enemies()
	var near_threats := _count_active_threats_near_player()
	var target_threats := _target_active_threats()
	if near_threats >= target_threats:
		return
	var missing := target_threats - near_threats
	_recycle_far_pressure_enemies(missing)
	var available_slots: int = MAX_ENEMIES - enemies.size()
	var spawn_count: int = min(missing, max(0, available_slots))
	if elapsed >= DREAD_BOSS_TIME:
		spawn_count = min(spawn_count + 1, max(0, available_slots))
	for i in range(spawn_count):
		_spawn_enemy(_pick_pressure_enemy_kind(i), false, _get_pressure_spawn_position(i))

func _count_active_threats_near_player() -> int:
	var count := 0
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.is_dead:
			continue
		if enemy.is_miniboss:
			count += 1
			continue
		var distance := enemy.global_position.distance_to(player.global_position)
		if distance <= PRESSURE_NEAR_RADIUS or _is_position_on_screen(enemy.global_position, PRESSURE_VISIBLE_PADDING):
			count += 1
	return count

func _target_active_threats() -> int:
	var profile_pressure: int = mini(4, int(_profile_pressure_tier() / 2))
	if elapsed >= DREAD_BOSS_TIME:
		return 14 + profile_pressure
	if elapsed >= 90.0:
		return 10 + profile_pressure
	if elapsed >= 58.0:
		return 7 + profile_pressure
	return 5 + mini(2, profile_pressure)

func _recycle_far_pressure_enemies(needed_slots: int) -> int:
	if needed_slots <= 0:
		return 0
	var recycled := 0
	var far_enemies := _get_far_recyclable_enemies()
	for enemy in far_enemies:
		if recycled >= needed_slots:
			break
		if not is_instance_valid(enemy):
			continue
		enemy.queue_free()
		recycled += 1
	if recycled > 0:
		_compact_enemies()
	return recycled

func _get_far_recyclable_enemies() -> Array[Enemy]:
	var far_enemies: Array[Enemy] = []
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.is_dead or enemy.is_miniboss:
			continue
		if enemy.enemy_kind == "grave_king":
			continue
		if enemy.global_position.distance_to(player.global_position) >= PRESSURE_FAR_RADIUS and not _is_position_on_screen(enemy.global_position, PRESSURE_VISIBLE_PADDING):
			far_enemies.append(enemy)
	far_enemies.sort_custom(func(a: Enemy, b: Enemy) -> bool:
		return a.global_position.distance_to(player.global_position) > b.global_position.distance_to(player.global_position)
	)
	return far_enemies

func _pick_pressure_enemy_kind(index: int) -> String:
	if _is_ashen_chapel():
		if elapsed >= DREAD_BOSS_TIME:
			return "ash_ember" if index == 0 else ("ash_bellringer" if randf() < 0.52 else "ash_acolyte")
		if elapsed >= 75.0 and randf() < 0.5:
			return "ash_ember" if index % 2 == 0 else "ash_bellringer"
		return _pick_enemy_kind()
	if elapsed >= DREAD_BOSS_TIME:
		if index == 0:
			return "flanker"
		if randf() < 0.32:
			return "spitter"
		if randf() < 0.56:
			return "runner"
		return "crawler"
	if elapsed >= 75.0:
		if randf() < 0.36:
			return "runner"
		if randf() < 0.58:
			return "flanker"
	return _pick_enemy_kind()

func _get_pressure_spawn_position(index: int) -> Vector2:
	var direction := _get_player_motion_direction(Vector2.RIGHT.rotated(randf() * TAU))
	if index % 3 == 1:
		direction = direction.rotated(PI * 0.5)
	elif index % 3 == 2:
		direction = direction.rotated(-PI * 0.5)
	return _get_offscreen_spawn_position(ENEMY_SPAWN_OFFSCREEN_MARGIN * 0.58, direction)

func _pick_enemy_kind() -> String:
	if _is_ashen_chapel():
		var chapel_roll := randf()
		if elapsed > 64.0 and chapel_roll < min(0.2, 0.07 + elapsed / 900.0):
			return "ash_ember"
		if elapsed > 38.0 and chapel_roll < min(0.42, 0.15 + elapsed / 650.0):
			return "ash_bellringer"
		if chapel_roll < 0.76:
			return "ash_acolyte"
		return "brute"
	if elapsed > 58.0 and randf() < min(0.18, 0.05 + elapsed / 760.0):
		return "flanker"
	if elapsed > 70.0 and randf() < 0.08:
		return "exploder"
	if elapsed > 46.0 and randf() < min(0.22, 0.04 + elapsed / 650.0 + _chapter_chance_bonus("spitter_bonus")):
		return "spitter"
	if elapsed > 28.0 and randf() < min(0.24, 0.05 + elapsed / 620.0 + _chapter_chance_bonus("runner_bonus")):
		return "runner"
	if randf() < min(0.26, 0.04 + elapsed / 420.0):
		return "brute"
	return "crawler"

func _spawn_enemy(enemy_kind: String, is_miniboss: bool, spawn_position := Vector2.INF) -> void:
	var enemy: Enemy = EnemyScene.instantiate()
	enemy.enemy_kind = enemy_kind
	enemy.max_health = 2 + int(elapsed / 52.0) + _chapter_enemy_health_bonus()
	enemy.speed = (randf_range(56.0, 84.0) + elapsed * 0.14) * _chapter_enemy_speed_multiplier()
	enemy.xp_value = 1
	enemy.contact_damage = 18.0
	if enemy_kind == "brute":
		enemy.max_health += 4
		enemy.speed *= 0.68
		enemy.scale = Vector2.ONE * 1.45
		enemy.xp_value = 2
		enemy.contact_damage = 22.0
	elif enemy_kind == "runner":
		enemy.max_health += 1
		enemy.speed *= 1.48
		enemy.scale = Vector2.ONE * 0.82
		enemy.contact_damage = 14.0
	elif enemy_kind == "flanker":
		enemy.max_health += 2
		enemy.speed *= 1.34
		enemy.scale = Vector2.ONE * 0.9
		enemy.contact_damage = 16.0
		enemy.flank_side = -1.0 if randf() < 0.5 else 1.0
		enemy.flank_distance = randf_range(125.0, 190.0)
		enemy.flank_ahead = randf_range(105.0, 180.0)
	elif enemy_kind == "spitter":
		enemy.max_health += 2
		enemy.speed *= 0.82
		enemy.xp_value = 2
		enemy.contact_damage = 10.0
		enemy.spit_cooldown = randf_range(2.2, 3.0)
		enemy.spit_timer = randf_range(0.8, 1.7)
	elif enemy_kind == "exploder":
		enemy.max_health += 1
		enemy.speed *= 1.18
		enemy.scale = Vector2.ONE * 1.05
		enemy.contact_damage = 30.0
		enemy.xp_value = 2
	elif enemy_kind == "ash_acolyte":
		enemy.max_health += 2
		enemy.speed *= 0.92
		enemy.scale = Vector2.ONE * 1.08
		enemy.contact_damage = 21.0
	elif enemy_kind == "ash_bellringer":
		enemy.max_health += 4
		enemy.speed *= 0.7
		enemy.scale = Vector2.ONE * 1.28
		enemy.xp_value = 2
		enemy.contact_damage = 13.0
		enemy.preferred_range = 340.0
		enemy.spit_cooldown = randf_range(2.6, 3.4)
		enemy.spit_timer = randf_range(0.9, 1.8)
	elif enemy_kind == "ash_ember":
		enemy.max_health += 1
		enemy.speed *= 1.72
		enemy.scale = Vector2.ONE * 0.72
		enemy.contact_damage = 34.0
		enemy.xp_value = 2
		enemy.flank_side = -1.0 if randf() < 0.5 else 1.0
		enemy.flank_distance = randf_range(70.0, 120.0)
		enemy.flank_ahead = randf_range(155.0, 240.0)
	elif enemy_kind == "grave_king":
		enemy.max_health = 78 + int(elapsed / 6.0) + _chapter_enemy_health_bonus() * 8
		enemy.speed = 142.0 * _chapter_enemy_speed_multiplier()
		enemy.scale = Vector2.ONE * 1.0
		enemy.contact_damage = 52.0
		enemy.xp_value = 24
	if is_miniboss:
		enemy.is_miniboss = true
		if enemy_kind != "grave_king":
			enemy.enemy_kind = "miniboss"
			enemy.max_health = 34 + int(elapsed / 10.0)
			enemy.speed = 46.0
			enemy.scale = Vector2.ONE * 2.25
			enemy.xp_value = 12
			enemy.contact_damage = 32.0
	var profile_power := _profile_power_level()
	enemy.max_health += int(floor(float(profile_power) * PROFILE_DIFFICULTY_HEALTH_STEP))
	enemy.speed *= 1.0 + float(profile_power) * PROFILE_DIFFICULTY_SPEED_STEP
	enemy.contact_damage *= 1.0 + float(profile_power) * PROFILE_DIFFICULTY_DAMAGE_STEP
	if enemy.enemy_kind == "grave_king":
		enemy.max_health += profile_power * 2
	_set_enemy_art(enemy, enemy.enemy_kind, is_miniboss)
	enemy.base_scale = enemy.scale
	enemy.health = enemy.max_health
	if spawn_position == Vector2.INF:
		enemy.position = _get_offscreen_spawn_position(ENEMY_SPAWN_OFFSCREEN_MARGIN)
	else:
		enemy.position = _clamp_to_arena(spawn_position)
	enemy.target = player
	enemy.add_to_group("enemies")
	enemy.damaged.connect(_on_enemy_damaged)
	enemy.spitting.connect(_on_enemy_spitting)
	enemy.died.connect(_on_enemy_died.bind(enemy, enemy.xp_value, enemy.is_miniboss))
	enemies.append(enemy)
	world.add_child(enemy)

func _get_interceptor_position(index: int) -> Vector2:
	var forward := player.velocity.normalized()
	if forward == Vector2.ZERO:
		forward = Vector2.RIGHT.rotated(randf() * TAU)
	if not _is_position_on_screen(player.global_position + forward * 380.0, 0.0):
		return _clamp_to_arena(player.position + forward * randf_range(320.0, 460.0))
	var side := forward.rotated(PI / 2.0)
	var side_sign := -1.0 if index % 2 == 0 else 1.0
	var preferred := (forward + side * side_sign * randf_range(0.15, 0.36)).normalized()
	return _get_offscreen_spawn_position(ENEMY_SPAWN_OFFSCREEN_MARGIN * 0.72, preferred)

func _get_offscreen_spawn_position(margin: float = ENEMY_SPAWN_OFFSCREEN_MARGIN, preferred_direction: Vector2 = Vector2.ZERO) -> Vector2:
	if player == null:
		return Vector2.ZERO
	var edges: Array[String] = _spawn_edges_for_direction(preferred_direction)
	for attempt in range(28):
		var edge: String = String(edges[attempt % edges.size()])
		if attempt >= edges.size():
			edge = String(edges[randi() % edges.size()])
		var candidate := _position_on_screen_edge(edge, margin)
		if not _is_position_on_screen(candidate, ENEMY_SPAWN_SCREEN_PADDING) and candidate.distance_to(player.global_position) > 300.0:
			return candidate
	return _clamp_to_arena(player.global_position + Vector2.RIGHT.rotated(randf() * TAU) * 760.0)

func _spawn_edges_for_direction(direction: Vector2) -> Array[String]:
	if direction == Vector2.ZERO:
		var edges: Array[String] = ["left", "right", "top", "bottom"]
		edges.shuffle()
		return edges
	var primary := ""
	var secondary_a := ""
	var secondary_b := ""
	var opposite := ""
	if abs(direction.x) >= abs(direction.y):
		primary = "right" if direction.x >= 0.0 else "left"
		opposite = "left" if direction.x >= 0.0 else "right"
		secondary_a = "bottom" if direction.y >= 0.0 else "top"
		secondary_b = "top" if direction.y >= 0.0 else "bottom"
	else:
		primary = "bottom" if direction.y >= 0.0 else "top"
		opposite = "top" if direction.y >= 0.0 else "bottom"
		secondary_a = "right" if direction.x >= 0.0 else "left"
		secondary_b = "left" if direction.x >= 0.0 else "right"
	var ordered_edges: Array[String] = [primary, secondary_a, secondary_b, opposite]
	return ordered_edges

func _position_on_screen_edge(edge: String, margin: float) -> Vector2:
	var center := _camera_world_center()
	var half_extents := _camera_world_half_extents() + Vector2(margin, margin)
	var position := center
	match edge:
		"left":
			position.x = center.x - half_extents.x
			position.y = randf_range(center.y - half_extents.y, center.y + half_extents.y)
		"right":
			position.x = center.x + half_extents.x
			position.y = randf_range(center.y - half_extents.y, center.y + half_extents.y)
		"top":
			position.x = randf_range(center.x - half_extents.x, center.x + half_extents.x)
			position.y = center.y - half_extents.y
		"bottom":
			position.x = randf_range(center.x - half_extents.x, center.x + half_extents.x)
			position.y = center.y + half_extents.y
	return _clamp_to_arena(position)

func _is_position_on_screen(position: Vector2, padding: float) -> bool:
	var center := _camera_world_center()
	var half_extents := _camera_world_half_extents() + Vector2(padding, padding)
	var offset := position - center
	return abs(offset.x) <= half_extents.x and abs(offset.y) <= half_extents.y

func _camera_world_center() -> Vector2:
	if player == null:
		return Vector2.ZERO
	return player.global_position

func _camera_world_half_extents() -> Vector2:
	var viewport_size := get_viewport_rect().size
	var zoom := Vector2.ONE
	if player != null:
		var camera := player.get_node_or_null("Camera2D") as Camera2D
		if camera != null:
			zoom = camera.zoom
	return Vector2(
		(viewport_size.x / maxf(zoom.x, 0.01)) * 0.5,
		(viewport_size.y / maxf(zoom.y, 0.01)) * 0.5
	)

func _set_enemy_art(enemy: Enemy, enemy_kind: String, is_miniboss: bool) -> void:
	var art := enemy.get_node_or_null("Art")
	if art == null:
		return
	if enemy_kind == "grave_king":
		art.texture = AshAbbotTexture if _is_ashen_chapel() else GraveKingTexture
		art.scale = Vector2(0.235, 0.235) if _is_ashen_chapel() else Vector2(0.24, 0.24)
		art.modulate = Color.WHITE if _is_ashen_chapel() else Color(0.82, 0.92, 0.86)
	elif is_miniboss:
		art.texture = GraveWardenTexture
		art.scale = Vector2(0.2, 0.2)
		if _is_ashen_chapel():
			art.modulate = Color(0.88, 0.58, 0.38)
	elif enemy_kind == "ash_acolyte":
		art.texture = GraveWardenTexture
		art.scale = Vector2(0.105, 0.105)
		art.modulate = Color(0.68, 0.55, 0.5)
	elif enemy_kind == "ash_bellringer":
		art.texture = EnemyBruteTexture
		art.scale = Vector2(0.17, 0.17)
		art.modulate = Color(0.94, 0.62, 0.32)
	elif enemy_kind == "ash_ember":
		art.texture = EnemyCrawlerTexture
		art.scale = Vector2(0.18, 0.18)
		art.modulate = Color(1.0, 0.42, 0.18)
	elif enemy_kind == "brute":
		art.texture = EnemyBruteTexture
		art.scale = Vector2(0.19, 0.19)
	elif enemy_kind == "runner":
		art.texture = EnemyCrawlerTexture
		art.scale = Vector2(0.23, 0.23)
		art.modulate = Color(0.78, 1.0, 0.88)
	elif enemy_kind == "flanker":
		art.texture = EnemyCrawlerTexture
		art.scale = Vector2(0.24, 0.24)
		art.modulate = Color(1.0, 0.92, 0.62)
	elif enemy_kind == "spitter":
		art.texture = EnemyCrawlerTexture
		art.scale = Vector2(0.27, 0.27)
		art.modulate = Color(0.86, 0.72, 1.0)
	elif enemy_kind == "exploder":
		art.texture = EnemyBruteTexture
		art.scale = Vector2(0.15, 0.15)
		art.modulate = Color(1.0, 0.78, 0.58)
	else:
		art.texture = EnemyCrawlerTexture
		art.scale = Vector2(0.28, 0.28)
	_add_enemy_role_markers(enemy, enemy_kind)

func _add_enemy_role_markers(enemy: Enemy, enemy_kind: String) -> void:
	match enemy_kind:
		"spitter":
			_add_enemy_mark(enemy, Color(0.86, 0.62, 1.0, 0.72), PackedVector2Array([
				Vector2(0, -43),
				Vector2(8, -33),
				Vector2(0, -29),
				Vector2(-8, -33),
			]))
		"exploder":
			_add_enemy_ring(enemy, Color(1.0, 0.58, 0.28, 0.48), 34.0, 4.0)
		"ash_bellringer":
			pass
		"ash_ember":
			_add_enemy_mark(enemy, Color(1.0, 0.58, 0.2, 0.78), PackedVector2Array([
				Vector2(0, -48),
				Vector2(8, -34),
				Vector2(2, -36),
				Vector2(8, -24),
				Vector2(-7, -33),
			]))
		"miniboss":
			_add_enemy_ring(enemy, Color(0.9, 0.48, 0.72, 0.48), 45.0, 4.0)
		"grave_king":
			var boss_primary := Color(1.0, 0.55, 0.24, 0.88) if _is_ashen_chapel() else Color(0.62, 1.0, 0.58, 0.82)
			var boss_secondary := Color(0.5, 0.16, 0.08, 0.72) if _is_ashen_chapel() else Color(0.95, 0.52, 0.86, 0.58)
			_add_enemy_ring(enemy, Color(boss_primary.r, boss_primary.g, boss_primary.b, 0.56), 62.0, 5.0)
			_add_enemy_ring(enemy, Color(boss_secondary.r, boss_secondary.g, boss_secondary.b, 0.38), 78.0, 3.0)
			_add_enemy_mark(enemy, boss_primary, PackedVector2Array([
				Vector2(0, -76),
				Vector2(18, -48),
				Vector2(9, -52),
				Vector2(22, -24),
				Vector2(0, -38),
				Vector2(-22, -24),
				Vector2(-9, -52),
				Vector2(-18, -48),
			]))

func _add_enemy_ring(enemy: Enemy, color: Color, radius: float, width: float) -> void:
	var ring := Line2D.new()
	ring.name = "RoleRing"
	ring.z_index = -1
	ring.closed = true
	ring.width = width
	ring.default_color = color
	var points := PackedVector2Array()
	for i in range(18):
		points.append(Vector2.RIGHT.rotated(TAU * float(i) / 18.0) * radius)
	ring.points = points
	enemy.add_child(ring)

func _add_enemy_mark(enemy: Enemy, color: Color, shape: PackedVector2Array) -> void:
	var mark := Polygon2D.new()
	mark.name = "RoleMark"
	mark.z_index = 5
	mark.color = color
	mark.polygon = shape
	enemy.add_child(mark)

func _add_enemy_speed_wings(enemy: Enemy, color: Color) -> void:
	var left_wing := Line2D.new()
	left_wing.name = "RoleWingLeft"
	left_wing.z_index = 4
	left_wing.width = 3.0
	left_wing.default_color = color
	left_wing.points = PackedVector2Array([
		Vector2(-18, -8),
		Vector2(-30, 0),
		Vector2(-18, 8),
	])
	enemy.add_child(left_wing)

	var right_wing := Line2D.new()
	right_wing.name = "RoleWingRight"
	right_wing.z_index = 4
	right_wing.width = 3.0
	right_wing.default_color = color
	right_wing.points = PackedVector2Array([
		Vector2(18, -8),
		Vector2(30, 0),
		Vector2(18, 8),
	])
	enemy.add_child(right_wing)

func _spawn_miniboss() -> void:
	miniboss_spawned = true
	_spawn_enemy("miniboss", true)
	CombatFxScript.ring(fx_layer, player.global_position, Color(1.0, 0.62, 0.28, 0.9) if _is_ashen_chapel() else Color(0.9, 0.55, 0.72, 0.9), 260.0, 0.7)
	_flash_overlay_text("Пепельный Дьякон поднялся" if _is_ashen_chapel() else "Могильный Страж пробудился")
	_flash_overlay_text("Он несет последний уголь" if _is_ashen_chapel() else "Он все еще охраняет пустой трон")
	_start_screen_shake(0.34, 8.0)

func _spawn_dread_boss() -> void:
	dread_boss_spawned = true
	var spawn_direction := _get_player_motion_direction(Vector2.RIGHT.rotated(randf() * TAU))
	var spawn_position := _get_offscreen_spawn_position(ENEMY_SPAWN_OFFSCREEN_MARGIN * 1.25, spawn_direction)
	_spawn_enemy("grave_king", true, spawn_position)
	_show_boss_ui(_get_dread_boss())
	CombatFxScript.ring(fx_layer, player.global_position, Color(1.0, 0.55, 0.22, 0.94) if _is_ashen_chapel() else Color(0.64, 1.0, 0.56, 0.92), 360.0, 0.9)
	CombatFxScript.ring(fx_layer, player.global_position, Color(0.48, 0.12, 0.06, 0.8) if _is_ashen_chapel() else Color(0.95, 0.5, 0.8, 0.72), 220.0, 0.7)
	_flash_overlay_text(String(_current_chapter().get("boss_enter", "Король-Могила встал")))
	_flash_overlay_text(String(_current_chapter().get("boss_lore", "За ним не осталось живых подданных")))
	_start_screen_shake(0.64, 12.0)
	for i in range(3):
		_spawn_hazard_zone(player.position + Vector2.RIGHT.rotated(TAU * float(i) / 3.0 + randf_range(-0.35, 0.35)) * randf_range(170.0, 310.0))
	if _is_ashen_chapel():
		_spawn_abbot_ash_wave(_get_dread_boss())

func _on_enemy_damaged(enemy_position: Vector2, amount: int) -> void:
	CombatFxScript.damage_number(fx_layer, enemy_position, amount)

func _on_enemy_spitting(enemy_position: Vector2, direction: Vector2) -> void:
	var projectile := _make_spitter_projectile(direction)
	projectile.position = enemy_position + direction * 32.0
	projectile.set_meta("velocity", direction * 270.0)
	projectile.set_meta("damage", SPITTER_PROJECTILE_DAMAGE)
	projectile.set_meta("ttl", 2.2)
	projectile.z_index = 6
	enemy_projectiles.append(projectile)
	world.add_child(projectile)
	CombatFxScript.sparkle(fx_layer, enemy_position, Color(1.0, 0.62, 0.28, 0.8) if _is_ashen_chapel() else Color(0.82, 0.55, 1.0, 0.72), 0.22)

func _make_spitter_projectile(direction: Vector2) -> Node2D:
	var projectile := Node2D.new()
	projectile.rotation = direction.angle()
	var ash_projectile := _is_ashen_chapel()
	projectile.set_meta("ash_projectile", ash_projectile)

	var tail := Line2D.new()
	tail.name = "Tail"
	tail.width = 7.0
	tail.default_color = Color(1.0, 0.5, 0.18, 0.58) if ash_projectile else Color(0.46, 0.95, 0.86, 0.5)
	tail.points = PackedVector2Array([Vector2(-34.0, 0.0), Vector2(-10.0, 0.0)])
	projectile.add_child(tail)

	var halo := _make_ellipse(15.0, 11.0, Color(1.0, 0.42, 0.16, 0.34) if ash_projectile else Color(0.48, 1.0, 0.86, 0.28), 16)
	halo.name = "Halo"
	projectile.add_child(halo)

	var ring := Line2D.new()
	ring.name = "Ring"
	ring.width = 3.0
	ring.closed = true
	ring.default_color = Color(1.0, 0.78, 0.38, 0.88) if ash_projectile else Color(0.88, 0.52, 1.0, 0.78)
	ring.points = _make_ring_points(12.0, 18)
	projectile.add_child(ring)

	var core := _make_ellipse(7.0, 7.0, Color(1.0, 0.42, 0.12, 0.98) if ash_projectile else Color(0.95, 0.74, 1.0, 0.96), 12)
	core.name = "Core"
	projectile.add_child(core)

	var seed := _make_ellipse(3.0, 3.0, Color(0.18, 0.08, 0.22, 0.9), 8)
	seed.name = "Seed"
	projectile.add_child(seed)
	return projectile

func _on_enemy_died(enemy_position: Vector2, enemy_ref: Enemy = null, xp_value: int = 1, was_miniboss: bool = false) -> void:
	kill_count += 1
	var was_execution := _enemy_died_by_execution(enemy_ref)
	var enemy_kind := enemy_ref.enemy_kind if enemy_ref != null else ""
	_register_kill_streak(enemy_position, was_execution, was_miniboss)
	_add_enemy_death_fx(enemy_position, enemy_kind, was_execution, was_miniboss)
	_start_screen_shake(0.26 if was_execution else (0.18 if was_miniboss else 0.07), 11.0 if was_execution else (7.0 if was_miniboss else 3.0))
	if was_execution and player != null:
		player.heal(2.0)
		ultimate_charge = min(ultimate_cooldown, ultimate_charge + 1.1)
	if vampirism_unlocked and player != null and kill_count % vampirism_kills_required == 0:
		var heal_amount: float = vampirism_heal_amount
		if nova_damage_active:
			var remaining_nova_heal: float = maxf(0.0, NOVA_VAMPIRISM_HEAL_CAP - nova_vampirism_healed)
			heal_amount = minf(heal_amount, remaining_nova_heal)
			nova_vampirism_healed += heal_amount
		if heal_amount > 0.0:
			player.health = min(player.max_health, player.health + heal_amount)
			CombatFxScript.sparkle(fx_layer, player.global_position, Color(1.0, 0.45, 0.62, 0.9), 0.36)
	var pack_chance := EXECUTION_HEALTH_PACK_CHANCE if was_execution else HEALTH_PACK_DROP_CHANCE
	if not was_miniboss and randf() < pack_chance:
		_spawn_health_pack(enemy_position)
	var shard: XPShard = XPShardScene.instantiate()
	shard.position = enemy_position
	shard.value = xp_value
	if xp_value > 1:
		shard.scale = Vector2.ONE * min(2.0, 1.0 + float(xp_value) / 10.0)
	shards.append(shard)
	world.add_child(shard)
	if was_miniboss:
		_flash_overlay_text(String(_current_chapter().get("boss_dead", "Король-Могила пал")) if xp_value >= 20 else "Могильный Страж повержен")
		if xp_value >= 20:
			grave_king_killed = true
			_hide_boss_ui()
	_compact_enemies()

func _spawn_health_pack(pack_position: Vector2) -> void:
	var pack := Node2D.new()
	pack.position = pack_position + Vector2(randf_range(-18.0, 18.0), randf_range(-18.0, 18.0))
	pack.z_index = 4
	var glow := _make_ellipse(20.0, 14.0, Color(0.95, 0.16, 0.24, 0.28), 14)
	glow.name = "Glow"
	pack.add_child(glow)
	var body := ColorRect.new()
	body.name = "Body"
	body.color = Color(0.16, 0.04, 0.06, 0.95)
	body.size = Vector2(28.0, 28.0)
	body.position = Vector2(-14.0, -14.0)
	pack.add_child(body)
	var cross_vertical := ColorRect.new()
	cross_vertical.color = Color(1.0, 0.24, 0.32, 1.0)
	cross_vertical.size = Vector2(8.0, 22.0)
	cross_vertical.position = Vector2(-4.0, -11.0)
	pack.add_child(cross_vertical)
	var cross_horizontal := ColorRect.new()
	cross_horizontal.color = Color(1.0, 0.24, 0.32, 1.0)
	cross_horizontal.size = Vector2(22.0, 8.0)
	cross_horizontal.position = Vector2(-11.0, -4.0)
	pack.add_child(cross_horizontal)
	pack.set_meta("age", 0.0)
	health_packs.append(pack)
	world.add_child(pack)

func _enemy_died_by_execution(enemy_ref: Enemy) -> bool:
	if enemy_ref == null:
		return false
	if enemy_ref.is_miniboss or enemy_ref.enemy_kind == "grave_king":
		return false
	return bool(enemy_ref.get_meta("execution_death", false)) or enemy_ref.last_hit_source == "blade"

func _register_kill_streak(enemy_position: Vector2, was_execution: bool, was_miniboss: bool) -> void:
	kill_streak += 1
	kill_streak_timer = KILL_STREAK_WINDOW
	best_kill_streak = max(best_kill_streak, kill_streak)
	if kill_streak in [10, 25, 50, 75, 100] or (kill_streak > 0 and kill_streak % 50 == 0):
		CombatFxScript.combat_text(fx_layer, enemy_position + Vector2(0.0, -34.0), "СЕРИЯ x%d" % kill_streak, Color(1.0, 0.88, 0.46), 30)
		ultimate_charge = min(ultimate_cooldown, ultimate_charge + (2.0 if was_miniboss else 1.2))
		_start_screen_shake(0.14, 5.8)

func _update_kill_streak(delta: float) -> void:
	if kill_streak <= 0:
		return
	kill_streak_timer -= delta
	if kill_streak_timer <= 0.0:
		kill_streak = 0

func _break_kill_streak() -> void:
	if kill_streak < 10:
		kill_streak = 0
		kill_streak_timer = 0.0
		return
	CombatFxScript.combat_text(fx_layer, player.global_position, "СЕРИЯ СБИТА", Color(1.0, 0.36, 0.42), 22)
	kill_streak = 0
	kill_streak_timer = 0.0

func _add_enemy_death_fx(enemy_position: Vector2, enemy_kind: String, was_execution: bool, was_miniboss: bool) -> void:
	var color := Color(0.55, 1.0, 0.72, 0.9)
	match enemy_kind:
		"spitter":
			color = Color(0.78, 0.48, 1.0, 0.92)
		"exploder":
			color = Color(1.0, 0.5, 0.24, 0.94)
		"brute":
			color = Color(0.9, 0.88, 0.68, 0.92)
		"ash_acolyte":
			color = Color(0.72, 0.58, 0.5, 0.94)
		"ash_bellringer":
			color = Color(1.0, 0.7, 0.3, 0.96)
		"ash_ember":
			color = Color(1.0, 0.36, 0.12, 0.98)
		"grave_king":
			color = Color(1.0, 0.42, 0.14, 0.98) if _is_ashen_chapel() else Color(0.9, 0.1, 0.2, 0.95)
	CombatFxScript.burst(fx_layer, enemy_position, color, 28 if was_miniboss else (24 if was_execution else 14))
	CombatFxScript.gore_burst(fx_layer, enemy_position, was_execution or was_miniboss)
	if was_execution:
		CombatFxScript.ring(fx_layer, enemy_position, Color(0.68, 1.0, 0.34, 0.72), 96.0, 0.24)
	elif was_miniboss:
		CombatFxScript.ring(fx_layer, enemy_position, Color(0.9, 0.55, 0.72, 0.78), 150.0, 0.38)
	if enemy_kind == "spitter":
		CombatFxScript.ring(fx_layer, enemy_position, Color(0.72, 0.42, 1.0, 0.46), 82.0, 0.32)
	elif enemy_kind == "exploder":
		CombatFxScript.ring(fx_layer, enemy_position, Color(1.0, 0.48, 0.18, 0.64), 118.0, 0.28)
	elif enemy_kind == "ash_bellringer":
		CombatFxScript.ring(fx_layer, enemy_position, Color(1.0, 0.74, 0.34, 0.66), 108.0, 0.3)
	elif enemy_kind == "ash_ember":
		CombatFxScript.ring(fx_layer, enemy_position, Color(1.0, 0.4, 0.12, 0.72), 124.0, 0.26)

func _update_health_packs(delta: float) -> void:
	var alive_packs: Array[Node2D] = []
	for pack in health_packs:
		if not is_instance_valid(pack):
			continue
		var age := float(pack.get_meta("age", 0.0)) + delta
		pack.set_meta("age", age)
		pack.rotation = sin(age * 2.5) * 0.08
		pack.scale = Vector2.ONE * (1.0 + sin(age * 4.0) * 0.05)
		if player != null and pack.global_position.distance_to(player.global_position) < 34.0:
			player.heal(HEALTH_PACK_HEAL)
			health_pack_count += 1
			CombatFxScript.ring(fx_layer, pack.global_position, Color(1.0, 0.26, 0.34, 0.72), 70.0, 0.26)
			_flash_overlay_text("+%d здоровье" % int(HEALTH_PACK_HEAL))
			pack.queue_free()
			continue
		if age > 26.0:
			pack.queue_free()
			continue
		alive_packs.append(pack)
	health_packs = alive_packs

func _update_enemy_projectiles(delta: float) -> void:
	var alive_projectiles: Array[Node2D] = []
	for projectile in enemy_projectiles:
		if not is_instance_valid(projectile):
			continue
		var ttl := float(projectile.get_meta("ttl", 0.0)) - delta
		if ttl <= 0.0:
			projectile.queue_free()
			continue
		projectile.set_meta("ttl", ttl)
		var velocity := projectile.get_meta("velocity", Vector2.ZERO) as Vector2
		projectile.position += velocity * delta
		_update_spitter_projectile_visual(projectile, delta)
		if player != null and projectile.global_position.distance_to(player.global_position) < 28.0:
			var damage: float = float(projectile.get_meta("damage", SPITTER_PROJECTILE_DAMAGE))
			_damage_player(damage, damage, true)
			var impact_color := Color(1.0, 0.5, 0.18, 0.9) if bool(projectile.get_meta("ash_projectile", false)) else Color(0.85, 0.48, 1.0, 0.84)
			CombatFxScript.burst(fx_layer, projectile.global_position, impact_color, 8)
			projectile.queue_free()
			if player.is_dead:
				_show_game_over()
			continue
		if abs(projectile.position.x) > ARENA_LIMIT_X + 180.0 or abs(projectile.position.y) > ARENA_LIMIT_Y + 180.0:
			projectile.queue_free()
			continue
		alive_projectiles.append(projectile)
	enemy_projectiles = alive_projectiles

func _update_spitter_projectile_visual(projectile: Node2D, delta: float) -> void:
	var age := float(projectile.get_meta("age", 0.0)) + delta
	projectile.set_meta("age", age)
	var ring := projectile.get_node_or_null("Ring") as Line2D
	var halo := projectile.get_node_or_null("Halo") as CanvasItem
	var tail := projectile.get_node_or_null("Tail") as Line2D
	var core := projectile.get_node_or_null("Core") as CanvasItem
	if ring != null:
		ring.rotation += delta * 9.0
		ring.width = 2.0 + sin(age * 12.0) * 0.9
	if halo != null:
		halo.scale = Vector2.ONE * (1.0 + sin(age * 10.0) * 0.12)
		halo.modulate.a = 0.78 + sin(age * 8.0) * 0.18
	if tail != null:
		tail.modulate.a = 0.55 + sin(age * 14.0) * 0.16
	if core != null:
		core.scale = Vector2.ONE * (1.0 + sin(age * 16.0) * 0.08)

func _update_hazard_zones(delta: float) -> void:
	if elapsed >= HAZARD_START_TIME and player != null:
		hazard_timer -= delta
		if hazard_timer <= 0.0:
			hazard_timer = max(3.8, HAZARD_INTERVAL - elapsed * 0.018)
			_spawn_hazard_zone(_get_hazard_position())
	var alive_hazards: Array[Node2D] = []
	for zone in hazard_zones:
		if not is_instance_valid(zone):
			continue
		var age := float(zone.get_meta("age", 0.0)) + delta
		zone.set_meta("age", age)
		var radius := float(zone.get_meta("radius", HAZARD_RADIUS))
		var zone_damage := float(zone.get_meta("damage", HAZARD_DAMAGE))
		var active := age >= HAZARD_ARM_TIME
		var total_time := HAZARD_ARM_TIME + HAZARD_ACTIVE_TIME
		var core := zone.get_node_or_null("Core") as CanvasItem
		var ring := zone.get_node_or_null("Ring") as CanvasItem
		var petals := zone.get_node_or_null("Petals") as CanvasItem
		var runes := zone.get_node_or_null("Runes") as CanvasItem
		var bloom := zone.get_node_or_null("Bloom") as CanvasItem
		var label := zone.get_node_or_null("Label") as Label
		if ring != null:
			ring.scale = Vector2.ONE * (0.62 + min(1.0, age / HAZARD_ARM_TIME) * 0.45)
			ring.rotation += delta * (1.2 if active else 0.45)
			ring.modulate.a = 0.46 + sin(age * 11.0) * 0.18
		if core != null:
			core.scale = Vector2.ONE * (0.84 + sin(age * 4.5) * 0.045)
			core.modulate.a = 0.1 if not active else 0.34 + sin(age * 7.0) * 0.08
		if petals != null:
			petals.rotation -= delta * (0.45 if active else 0.18)
			petals.scale = Vector2.ONE * (0.82 + min(1.0, age / HAZARD_ARM_TIME) * 0.22 + sin(age * 5.0) * 0.025)
			petals.modulate.a = 0.36 if not active else 0.72
		if runes != null:
			runes.rotation += delta * 0.72
			runes.modulate.a = 0.3 + sin(age * 8.0) * 0.14
		if bloom != null:
			bloom.rotation += delta * 1.8
			bloom.scale = Vector2.ONE * (0.8 + min(1.0, age / HAZARD_ARM_TIME) * 0.45 + sin(age * 7.0) * 0.08)
		if label != null:
			label.modulate.a = max(0.0, min(1.0, total_time - age)) * (0.72 if not active else 1.0)
			label.position.y = -radius - 56.0 + sin(age * 5.0) * 2.0
		if active and player != null and zone.global_position.distance_to(player.global_position) < radius:
			_damage_player(zone_damage * delta)
			if randf() < 0.22:
				var spark_color := Color(1.0, 0.62, 0.3, 0.86) if bool(zone.get_meta("bell_zone", false)) else Color(0.7, 1.0, 0.58, 0.82)
				CombatFxScript.sparkle(fx_layer, player.global_position, spark_color, 0.12)
			if player.is_dead:
				_show_game_over()
		if age >= total_time:
			CombatFxScript.sparkle(fx_layer, zone.global_position, Color(0.62, 1.0, 0.5, 0.55), 0.18)
			zone.queue_free()
			continue
		alive_hazards.append(zone)
	hazard_zones = alive_hazards

func _spawn_hazard_zone(zone_position: Vector2) -> void:
	var zone := Node2D.new()
	var bell_zone := _is_ashen_chapel()
	zone.position = _clamp_to_arena(_keep_hazard_away_from_player(zone_position))
	zone.z_index = 2
	zone.set_meta("age", 0.0)
	zone.set_meta("radius", HAZARD_RADIUS)
	zone.set_meta("damage", 21.0 if bell_zone else HAZARD_DAMAGE)
	zone.set_meta("bell_zone", bell_zone)
	var shadow_color := Color(0.16, 0.07, 0.035, 0.52) if bell_zone else Color(0.04, 0.12, 0.06, 0.48)
	var core_color := Color(0.92, 0.42, 0.16, 0.14) if bell_zone else Color(0.38, 0.92, 0.34, 0.12)
	var petal_color := Color(1.0, 0.56, 0.22, 0.46) if bell_zone else Color(0.52, 1.0, 0.34, 0.42)
	var ring_color := Color(1.0, 0.7, 0.32, 0.76) if bell_zone else Color(0.72, 1.0, 0.48, 0.66)
	var rune_color := Color(1.0, 0.84, 0.48, 0.78) if bell_zone else Color(0.9, 1.0, 0.5, 0.72)
	var shadow := _make_ellipse(HAZARD_RADIUS * 1.16, HAZARD_RADIUS * 0.84, shadow_color, 32)
	shadow.name = "Shadow"
	zone.add_child(shadow)
	var core := _make_ellipse(HAZARD_RADIUS, HAZARD_RADIUS * 0.72, core_color, 34)
	core.name = "Core"
	zone.add_child(core)
	var petals := Node2D.new()
	petals.name = "Petals"
	for i in range(12):
		var petal := _make_ellipse(16.0, 42.0, petal_color, 12)
		petal.position = Vector2.RIGHT.rotated(TAU * float(i) / 12.0) * (HAZARD_RADIUS * 0.48)
		petal.rotation = TAU * float(i) / 12.0 + PI / 2.0
		petals.add_child(petal)
	zone.add_child(petals)
	var ring := Line2D.new()
	ring.name = "Ring"
	ring.closed = true
	ring.width = 6.0
	ring.default_color = ring_color
	var points := PackedVector2Array()
	for i in range(36):
		var wobble := 1.0 + sin(float(i) * 3.0) * 0.055
		points.append(Vector2(cos(TAU * float(i) / 36.0) * HAZARD_RADIUS * wobble, sin(TAU * float(i) / 36.0) * HAZARD_RADIUS * 0.72 * wobble))
	ring.points = points
	zone.add_child(ring)
	var runes := Node2D.new()
	runes.name = "Runes"
	for i in range(8):
		var rune := Line2D.new()
		rune.width = 3.0
		rune.default_color = rune_color
		rune.points = PackedVector2Array([
			Vector2(-7.0, -8.0),
			Vector2(0.0, 8.0),
			Vector2(8.0, -5.0),
		])
		rune.position = Vector2.RIGHT.rotated(TAU * float(i) / 8.0) * (HAZARD_RADIUS * 0.76)
		rune.rotation = TAU * float(i) / 8.0 + randf_range(-0.35, 0.35)
		runes.add_child(rune)
	zone.add_child(runes)
	var bloom := _make_ellipse(26.0, 16.0, Color(1.0, 0.66, 0.28, 0.88) if bell_zone else Color(0.8, 1.0, 0.45, 0.82), 11)
	bloom.name = "Bloom"
	bloom.rotation = randf() * TAU
	zone.add_child(bloom)
	if bell_zone:
		var bell := Polygon2D.new()
		bell.color = Color(0.25, 0.12, 0.06, 0.96)
		bell.polygon = PackedVector2Array([
			Vector2(-24.0, 12.0),
			Vector2(-17.0, -20.0),
			Vector2(-8.0, -32.0),
			Vector2(8.0, -32.0),
			Vector2(17.0, -20.0),
			Vector2(24.0, 12.0),
			Vector2(0.0, 24.0),
		])
		zone.add_child(bell)
	var label := Label.new()
	label.name = "Label"
	label.text = "КОЛОКОЛЬНЫЙ ЗВОН" if bell_zone else "ПРОКЛЯТЫЙ ЦВЕТОК"
	label.position = Vector2(-115.0, -HAZARD_RADIUS - 56.0)
	label.size = Vector2(230.0, 30.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.42, 0.98) if bell_zone else Color(0.86, 1.0, 0.54, 0.95))
	zone.add_child(label)
	hazard_zones.append(zone)
	world.add_child(zone)

func _get_hazard_position() -> Vector2:
	var forward := player.velocity.normalized()
	if forward == Vector2.ZERO:
		forward = Vector2.RIGHT.rotated(randf() * TAU)
	var side := forward.rotated(PI / 2.0)
	var side_sign := -1.0 if randf() < 0.5 else 1.0
	return _keep_hazard_away_from_player(player.position + forward * randf_range(230.0, 360.0) + side * side_sign * randf_range(60.0, 170.0))

func _keep_hazard_away_from_player(zone_position: Vector2) -> Vector2:
	if player == null:
		return zone_position
	var offset := zone_position - player.global_position
	if offset.length() >= HAZARD_SAFE_DISTANCE:
		return zone_position
	if offset == Vector2.ZERO:
		offset = _get_player_motion_direction(Vector2.RIGHT)
	return player.global_position + offset.normalized() * HAZARD_SAFE_DISTANCE

func _update_cluster_bloom(delta: float) -> void:
	if elapsed < CLUSTER_BLOOM_START_TIME:
		return
	cluster_bloom_timer -= delta
	if cluster_bloom_timer > 0.0:
		return
	cluster_bloom_timer = max(5.8, CLUSTER_BLOOM_INTERVAL - elapsed * 0.012)
	var cluster_center := _get_enemy_cluster_center()
	if cluster_center == Vector2.INF:
		return
	_spawn_hazard_zone(cluster_center)
	_flash_overlay_text("Толпа расцветает")

func _get_enemy_cluster_center() -> Vector2:
	_compact_enemies()
	if enemies.size() < CLUSTER_BLOOM_MIN_ENEMIES:
		return Vector2.INF
	var center := Vector2.ZERO
	for enemy in enemies:
		center += enemy.global_position
	center /= float(enemies.size())
	var clustered := 0
	for enemy in enemies:
		if enemy.global_position.distance_to(center) < 230.0:
			clustered += 1
	if clustered < CLUSTER_BLOOM_MIN_ENEMIES:
		return Vector2.INF
	return center

func _update_dread_boss_pressure(delta: float) -> void:
	if not dread_boss_spawned or player == null:
		return
	var boss := _get_dread_boss()
	if boss == null:
		return
	if not dread_boss_phase_two and boss.health <= int(ceil(float(boss.max_health) * 0.5)):
		dread_boss_phase_two = true
		boss.speed *= 1.34
		boss.contact_damage += 10.0
		boss.modulate = Color(1.0, 0.5, 0.28) if _is_ashen_chapel() else Color(1.0, 0.78, 0.88)
		_flash_overlay_text("Кадило раскололось" if _is_ashen_chapel() else "Корона раскрылась")
		_flash_boss_ui()
		_start_screen_shake(0.5, 11.0)
		if _is_ashen_chapel():
			_spawn_abbot_ash_wave(boss)
		else:
			_spawn_boss_cross_attack(boss)
	dread_boss_hazard_timer -= delta
	if dread_boss_hazard_timer <= 0.0:
		dread_boss_hazard_timer = max(2.8, DREAD_BOSS_HAZARD_INTERVAL - elapsed * 0.006) * (0.74 if dread_boss_phase_two else 1.0)
		_spawn_hazard_zone(_get_boss_hazard_position(boss))
		CombatFxScript.ring(fx_layer, boss.global_position, Color(0.62, 1.0, 0.5, 0.55), 150.0, 0.34)
	dread_boss_summon_timer -= delta
	if dread_boss_summon_timer <= 0.0:
		dread_boss_summon_timer = max(4.8, DREAD_BOSS_SUMMON_INTERVAL - elapsed * 0.006) * (0.82 if dread_boss_phase_two else 1.0)
		var available_slots: int = MAX_ENEMIES - enemies.size()
		if available_slots > 0:
			var summon_count: int = min(3 if dread_boss_phase_two else 2, available_slots)
			for i in range(summon_count):
				var kind := ("ash_ember" if i == 0 else "ash_bellringer") if _is_ashen_chapel() else ("flanker" if i == 0 else "spitter")
				_spawn_enemy(kind, false, _get_interceptor_position(i))
		_flash_overlay_text("Игумен созывает паству" if _is_ashen_chapel() else "Король зовет мертвых")
	dread_boss_bell_timer -= delta
	if dread_boss_bell_timer <= 0.0:
		dread_boss_bell_timer = DREAD_BOSS_BELL_INTERVAL * (0.76 if dread_boss_phase_two else 1.0)
		_spawn_boss_bell_attack(boss)
	dread_boss_judgment_timer -= delta
	if dread_boss_judgment_timer <= 0.0:
		dread_boss_judgment_timer = DREAD_BOSS_JUDGMENT_INTERVAL * (0.78 if dread_boss_phase_two else 1.0)
		if _is_ashen_chapel():
			_spawn_abbot_ash_wave(boss)
		else:
			_spawn_boss_judgment_attack(boss)
	dread_boss_cross_timer -= delta
	if dread_boss_phase_two and dread_boss_cross_timer <= 0.0:
		dread_boss_cross_timer = DREAD_BOSS_CROSS_INTERVAL
		if _is_ashen_chapel():
			_spawn_boss_bell_attack(boss)
			_spawn_hazard_zone(_get_boss_hazard_position(boss))
		else:
			_spawn_boss_cross_attack(boss)

func _get_dread_boss() -> Enemy:
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.enemy_kind == "grave_king":
			return enemy
	return null

func _get_boss_hazard_position(boss: Enemy) -> Vector2:
	var to_player := boss.global_position.direction_to(player.global_position)
	if to_player == Vector2.ZERO:
		to_player = Vector2.RIGHT.rotated(randf() * TAU)
	var side := to_player.rotated(PI / 2.0)
	var side_sign := -1.0 if randf() < 0.5 else 1.0
	return _keep_hazard_away_from_player(player.position + to_player * randf_range(180.0, 280.0) + side * side_sign * randf_range(70.0, 160.0))

func _spawn_boss_bell_attack(boss: Enemy) -> void:
	var attack := Node2D.new()
	attack.position = boss.global_position
	attack.z_index = 5
	attack.set_meta("kind", "bell")
	attack.set_meta("age", 0.0)
	attack.set_meta("arm_time", BOSS_ATTACK_ARM_TIME)
	attack.set_meta("active_time", BOSS_ATTACK_ACTIVE_TIME)
	attack.set_meta("radius", 245.0 if not dread_boss_phase_two else 300.0)
	attack.set_meta("width", 58.0)
	attack.set_meta("damage", 34.0 if not dread_boss_phase_two else 44.0)
	attack.set_meta("hit", false)
	var ring := Line2D.new()
	ring.name = "Telegraph"
	ring.closed = true
	ring.width = 8.0
	ring.default_color = Color(1.0, 0.64, 0.28, 0.86) if _is_ashen_chapel() else Color(0.9, 1.0, 0.56, 0.78)
	var points := PackedVector2Array()
	for i in range(48):
		points.append(Vector2.RIGHT.rotated(TAU * float(i) / 48.0) * float(attack.get_meta("radius", 245.0)))
	ring.points = points
	attack.add_child(ring)
	boss_attacks.append(attack)
	world.add_child(attack)
	_flash_overlay_text("Последний Колокол" if _is_ashen_chapel() else "Похоронный Колокол")

func _spawn_abbot_ash_wave(boss: Enemy) -> void:
	if boss == null or player == null:
		return
	var base_direction := boss.global_position.direction_to(player.global_position)
	if base_direction == Vector2.ZERO:
		base_direction = Vector2.RIGHT.rotated(randf() * TAU)
	var wave_count := 5 if dread_boss_phase_two else 3
	var spread := 0.24
	var start_angle := -spread * float(wave_count - 1) * 0.5
	for i in range(wave_count):
		var direction := base_direction.rotated(start_angle + spread * float(i))
		_spawn_boss_lane_attack(boss.global_position + direction * 330.0, direction, 760.0, 48.0, 28.0 if not dread_boss_phase_two else 36.0, "Пепельная волна" if i == 0 else "")
	CombatFxScript.burst(fx_layer, boss.global_position, Color(1.0, 0.48, 0.16, 0.9), 24)
	_start_screen_shake(0.24, 7.0)

func _spawn_boss_judgment_attack(boss: Enemy) -> void:
	var direction := _get_player_motion_direction(boss.global_position.direction_to(player.global_position))
	var center := player.global_position + direction * 165.0
	_spawn_boss_lane_attack(center, direction, 720.0, 76.0, 32.0 if not dread_boss_phase_two else 42.0, "Королевский Приговор")

func _spawn_boss_cross_attack(boss: Enemy) -> void:
	var base_direction := boss.global_position.direction_to(player.global_position)
	if base_direction == Vector2.ZERO:
		base_direction = Vector2.RIGHT.rotated(randf() * TAU)
	_spawn_boss_lane_attack(player.global_position, base_direction, 760.0, 68.0, 36.0, "Черная корона")
	_spawn_boss_lane_attack(player.global_position, base_direction.rotated(PI / 2.0), 760.0, 68.0, 36.0, "Черная корона")

func _spawn_boss_lane_attack(center: Vector2, direction: Vector2, length: float, width: float, damage: float, label_text: String) -> void:
	var attack := Node2D.new()
	attack.position = Vector2.ZERO
	attack.z_index = 5
	attack.set_meta("kind", "lane")
	attack.set_meta("age", 0.0)
	attack.set_meta("arm_time", BOSS_ATTACK_ARM_TIME)
	attack.set_meta("active_time", BOSS_ATTACK_ACTIVE_TIME)
	attack.set_meta("start", center - direction * (length * 0.5))
	attack.set_meta("end", center + direction * (length * 0.5))
	attack.set_meta("width", width)
	attack.set_meta("damage", damage)
	attack.set_meta("hit", false)
	var line := Line2D.new()
	line.name = "Telegraph"
	line.width = width
	line.default_color = Color(1.0, 0.46, 0.18, 0.54) if _is_ashen_chapel() else Color(0.95, 0.58, 0.9, 0.48)
	line.points = PackedVector2Array([
		center - direction * (length * 0.5),
		center + direction * (length * 0.5),
	])
	attack.add_child(line)
	var edge := Line2D.new()
	edge.name = "Edge"
	edge.width = 4.0
	edge.default_color = Color(1.0, 0.78, 0.38, 0.92) if _is_ashen_chapel() else Color(0.86, 1.0, 0.58, 0.88)
	edge.points = line.points
	attack.add_child(edge)
	boss_attacks.append(attack)
	world.add_child(attack)
	if not label_text.is_empty():
		_flash_overlay_text(label_text)

func _get_player_motion_direction(fallback: Vector2) -> Vector2:
	var direction := player.velocity.normalized()
	if direction == Vector2.ZERO:
		direction = fallback
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT.rotated(randf() * TAU)
	return direction

func _update_boss_attacks(delta: float) -> void:
	var alive_attacks: Array[Node2D] = []
	for attack in boss_attacks:
		if not is_instance_valid(attack):
			continue
		var age: float = float(attack.get_meta("age", 0.0)) + delta
		attack.set_meta("age", age)
		var arm_time: float = float(attack.get_meta("arm_time", BOSS_ATTACK_ARM_TIME))
		var active_time: float = float(attack.get_meta("active_time", BOSS_ATTACK_ACTIVE_TIME))
		var active := age >= arm_time
		_update_boss_attack_visual(attack, age, arm_time, active)
		if active and not bool(attack.get_meta("hit", false)):
			_damage_player_from_boss_attack(attack)
			attack.set_meta("hit", true)
		if age >= arm_time + active_time:
			attack.queue_free()
			continue
		alive_attacks.append(attack)
	boss_attacks = alive_attacks

func _update_boss_attack_visual(attack: Node2D, age: float, arm_time: float, active: bool) -> void:
	var telegraph := attack.get_node_or_null("Telegraph") as CanvasItem
	var edge := attack.get_node_or_null("Edge") as CanvasItem
	var pulse := 0.5 + sin(age * 14.0) * 0.22
	if telegraph != null:
		telegraph.modulate.a = 0.92 if active else pulse
		if attack.get_meta("kind", "") == "bell":
			telegraph.scale = Vector2.ONE * (0.35 + min(1.0, age / arm_time) * 0.75)
			telegraph.rotation += get_process_delta_time() * 0.9
	if edge != null:
		edge.modulate.a = 1.0 if active else 0.42 + sin(age * 18.0) * 0.22

func _damage_player_from_boss_attack(attack: Node2D) -> void:
	if player == null or player.is_dead:
		return
	var damage: float = float(attack.get_meta("damage", 30.0))
	var kind := String(attack.get_meta("kind", ""))
	var did_hit := false
	if kind == "bell":
		var radius: float = float(attack.get_meta("radius", 245.0))
		var width: float = float(attack.get_meta("width", 58.0))
		var distance := attack.global_position.distance_to(player.global_position)
		did_hit = abs(distance - radius) <= width or distance < radius * 0.38
	elif kind == "lane":
		var start := attack.get_meta("start", Vector2.ZERO) as Vector2
		var end := attack.get_meta("end", Vector2.ZERO) as Vector2
		var width: float = float(attack.get_meta("width", 70.0))
		did_hit = _distance_to_segment(player.global_position, start, end) <= width * 0.5
	if did_hit:
		_damage_player(damage, damage, true)
		_start_screen_shake(0.24, 9.0)
		CombatFxScript.burst(fx_layer, player.global_position, Color(1.0, 0.5, 0.18, 0.92) if _is_ashen_chapel() else Color(0.9, 1.0, 0.52, 0.9), 18)
		if player.is_dead:
			_show_game_over()

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

func _explode_enemy(enemy: Enemy) -> void:
	if not is_instance_valid(enemy) or enemy.is_dead:
		return
	var origin := enemy.global_position
	CombatFxScript.ring(fx_layer, origin, Color(1.0, 0.66, 0.42, 0.86), 115.0, 0.32)
	CombatFxScript.burst(fx_layer, origin, Color(1.0, 0.78, 0.5, 0.9), 18)
	_start_screen_shake(0.12, 5.0)
	for other in enemies:
		if not is_instance_valid(other) or other == enemy:
			continue
		if other.global_position.distance_to(origin) < 112.0:
			other.take_damage(2, origin, 240.0)
	enemy.die()

func _trigger_thorn_bloom(origin: Vector2) -> void:
	if thorn_bloom_cooldown > 0.0:
		return
	thorn_bloom_cooldown = 0.8
	CombatFxScript.ring(fx_layer, player.global_position, Color(0.65, 1.0, 0.72, 0.68), 92.0, 0.22)
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(player.global_position) < 96.0:
			enemy.take_damage(_scaled_player_damage(1), origin, 190.0)

func _check_enemy_contact(delta: float) -> void:
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var contact_radius := 42.0
		if enemy.enemy_kind == "grave_king":
			contact_radius = 76.0
		elif enemy.is_miniboss:
			contact_radius = 58.0
		if enemy.global_position.distance_to(player.global_position) < contact_radius:
			var damage := enemy.contact_damage
			_damage_player(damage * delta)
			if thorn_bloom_unlocked:
				_trigger_thorn_bloom(enemy.global_position)
			if enemy.enemy_kind in ["exploder", "ash_ember"]:
				_explode_enemy(enemy)
			if player.is_dead:
				_show_game_over()

func _damage_player(amount: float, display_amount: float = -1.0, force_number: bool = false) -> void:
	if player == null or player.is_dead:
		return
	if amount > 0.0:
		_break_kill_streak()
	player.take_damage(amount)
	if display_amount < 0.0:
		display_amount = amount
	if force_number:
		_show_player_damage_number(display_amount)
		player_damage_number_cooldown = PLAYER_DAMAGE_NUMBER_INTERVAL
		return
	player_damage_number_accumulator += display_amount
	if player_damage_number_cooldown <= 0.0:
		_show_player_damage_number(player_damage_number_accumulator)
		player_damage_number_accumulator = 0.0
		player_damage_number_cooldown = PLAYER_DAMAGE_NUMBER_INTERVAL

func _show_player_damage_number(amount: float) -> void:
	if player == null:
		return
	var shown_amount: int = max(1, int(ceil(amount)))
	CombatFxScript.damage_number(fx_layer, player.global_position + Vector2(0.0, -18.0), shown_amount, Color(1.0, 0.36, 0.42), 22)

func _keep_player_inside_arena() -> void:
	if player == null:
		return
	player.global_position = _clamp_to_arena(player.global_position)

func _clamp_to_arena(position: Vector2) -> Vector2:
	return Vector2(
		clamp(position.x, -ARENA_LIMIT_X, ARENA_LIMIT_X),
		clamp(position.y, -ARENA_LIMIT_Y, ARENA_LIMIT_Y)
	)

func _scaled_player_damage(base_damage: int) -> int:
	return max(1, int(ceil(float(base_damage) * (1.0 + player_damage_bonus))))

func _level_up() -> void:
	level += 1
	player_damage_bonus = float(level - 1) * PLAYER_LEVEL_DAMAGE_STEP
	if is_instance_valid(living_blade):
		living_blade.set_level_damage_bonus(player_damage_bonus)
	player.max_health += PLAYER_LEVEL_HEALTH_GAIN
	player.heal(PLAYER_LEVEL_HEAL + PLAYER_LEVEL_HEALTH_GAIN)
	xp -= xp_to_next
	xp_to_next = int(xp_to_next * 1.55) + 8
	CombatFxScript.ring(fx_layer, player.global_position, Color(0.7, 1.0, 0.84, 0.85), 170.0, 0.55)
	CombatFxScript.burst(fx_layer, player.global_position, Color(0.78, 1.0, 0.9, 0.9), 24)
	CombatFxScript.damage_number(fx_layer, player.global_position + Vector2(0.0, -42.0), int(PLAYER_LEVEL_HEAL + PLAYER_LEVEL_HEALTH_GAIN), Color(0.55, 1.0, 0.62), 22)
	paused_for_upgrade = true
	game_state = "upgrade"
	build_label.visible = false
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
	upgrade_list.add_child(_make_label("Реликвии работают только в этом забеге", 15))
	var relics := _roll_relics()
	for relic in relics:
		_add_upgrade_button(relic["name"], relic["description"], relic["method"])
	upgrade_panel.visible = true

func _roll_relics() -> Array:
	var bell_relic := {"name": "Колокол Забвения", "description": "Автооружие: волны вокруг Маски", "method": "_upgrade_oblivion_bell"}
	var blood_relic := {"name": "Кровавый Цветок", "description": "Вампиризм. Эволюция: Цветок+2 улучшения Клинка", "method": "_upgrade_vampirism"}
	var blade_relics := [
		{"name": "Заточить Живой Клинок", "description": "Урон клинка выше. Эволюция: Цветок+2 улучшения", "method": "_upgrade_damage"},
		{"name": "Ускорить проклятие", "description": "Клинок чаще. Эволюция: Цветок+2 улучшения", "method": "_upgrade_cooldown"},
		{"name": "Расширить бледный радиус", "description": "Клинок дальше. Эволюция: Цветок+2 улучшения", "method": "_upgrade_range"},
	]
	var relics := [
		{"name": "Призвать Тень", "description": "Автооружие: луч сквозь толпу", "method": "_upgrade_shadow_spirit"},
		{"name": "Костяные Копья", "description": "Автооружие: пронзают линию", "method": "_upgrade_bone_spears"},
		{"name": "Могильный Магнит", "description": "Опыт притягивается дальше", "method": "_upgrade_magnet"},
		{"name": "Сердце Новы", "description": "Нова быстрее, шире, сильнее", "method": "_upgrade_nova"},
		{"name": "Шипастый Венец", "description": "Ответный урон рядом", "method": "_upgrade_thorns"},
	]
	relics.append_array(blade_relics)
	relics.append(blood_relic)
	relics.shuffle()
	if not oblivion_bell_unlocked:
		var choices := [bell_relic]
		choices.append_array(relics.slice(0, MAX_RELIC_CHOICES - 1))
		return choices
	var forced_relic := _evolution_hint_relic(blade_relics, blood_relic)
	if not forced_relic.is_empty() and randf() < 0.72:
		relics = _without_relic_name(relics, String(forced_relic["name"]))
		relics.insert(0, forced_relic)
	relics.append(bell_relic)
	return relics.slice(0, MAX_RELIC_CHOICES)

func _evolution_hint_relic(blade_relics: Array, blood_relic: Dictionary) -> Dictionary:
	if blood_blade_evolved:
		return {}
	var blade_picks := _blade_upgrade_pick_count()
	if vampirism_unlocked and blade_picks < 2:
		var missing_blade_relics: Array = []
		for relic in blade_relics:
			if int(relic_pick_counts.get(String(relic["name"]), 0)) <= 0:
				missing_blade_relics.append(relic)
		if missing_blade_relics.is_empty():
			missing_blade_relics = blade_relics
		return missing_blade_relics[randi() % missing_blade_relics.size()]
	if blade_picks >= 2 and not vampirism_unlocked:
		return blood_relic
	return {}

func _without_relic_name(relics: Array, relic_name: String) -> Array:
	var filtered: Array = []
	for relic in relics:
		if String(relic["name"]) != relic_name:
			filtered.append(relic)
	return filtered

func _add_upgrade_button(text: String, description: String, method_name: String) -> void:
	var button := Button.new()
	button.text = "%s\n%s" % [text, description]
	button.custom_minimum_size = Vector2(430, 74)
	button.set_meta("upgrade_method", String(method_name))
	button.set_meta("relic_name", text)
	button.pressed.connect(_on_upgrade_button_pressed.bind(button))
	upgrade_list.add_child(button)

func _on_upgrade_button_pressed(button: Button) -> void:
	var method_name := String(button.get_meta("upgrade_method", ""))
	var relic_name := String(button.get_meta("relic_name", ""))
	if method_name != "":
		_record_relic_pick(relic_name)
		call(method_name)
		_flash_overlay_text(_relic_lore_echo(method_name))
		_check_relic_evolutions()
	upgrade_panel.visible = false
	joystick_base.visible = true
	ultimate_button.visible = true
	ultimate_bar.visible = true
	paused_for_upgrade = false
	game_state = "running"
	get_tree().paused = false

func _record_relic_pick(relic_name: String) -> void:
	if relic_name.is_empty():
		return
	if not relic_pick_counts.has(relic_name):
		relic_pick_counts[relic_name] = 0
		relic_pick_order.append(relic_name)
	relic_pick_counts[relic_name] = int(relic_pick_counts[relic_name]) + 1

func _relic_lore_echo(method_name: String) -> String:
	match method_name:
		"_upgrade_damage":
			return "Клинок вспомнил вкус королевской крови"
		"_upgrade_cooldown":
			return "Проклятие задышало чаще"
		"_upgrade_range":
			return "Бледный радиус коснулся дальних могил"
		"_upgrade_shadow_spirit":
			return "За Маской встал второй силуэт"
		"_upgrade_bone_spears":
			return "Кости старой стражи встали на приказ"
		"_upgrade_oblivion_bell":
			return "В руинах снова ударил похоронный звон"
		"_upgrade_magnet":
			return "Осколки сами ищут того, кто выжил"
		"_upgrade_vampirism":
			return "Цветок пьет смерть и возвращает тепло"
		"_upgrade_nova":
			return "В сердце цветка шевельнулась звезда"
		"_upgrade_thorns":
			return "Старая корона не умеет падать"
	return "Руины приняли новую клятву"

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

func _upgrade_bone_spears() -> void:
	if bone_spears_unlocked:
		bone_spear_damage += 1
		bone_spear_count = min(4, bone_spear_count + 1)
		bone_spear_cooldown = maxf(1.55, bone_spear_cooldown - 0.34)
	else:
		bone_spears_unlocked = true
		bone_spear_timer = 0.45
	_flash_overlay_text("Костяные копья поднялись")

func _upgrade_oblivion_bell() -> void:
	if oblivion_bell_unlocked:
		oblivion_bell_damage += 1
		oblivion_bell_radius += 22.0
		oblivion_bell_cooldown = maxf(3.4, oblivion_bell_cooldown - 0.45)
	else:
		oblivion_bell_unlocked = true
		oblivion_bell_timer = 0.8
	_flash_overlay_text("Колокол Забвения звучит")

func _upgrade_magnet() -> void:
	shard_pull_range += 70.0
	_flash_overlay_text("Магнит опыта усилен")

func _upgrade_vampirism() -> void:
	vampirism_level += 1
	if not vampirism_unlocked:
		vampirism_unlocked = true
	else:
		vampirism_heal_amount += 2.0
		vampirism_kills_required = max(5, vampirism_kills_required - 1)
	player.health = min(player.max_health, player.health + 10.0 + float(vampirism_level) * 2.0)
	_flash_overlay_text("Кровавый Цветок расцвел" if vampirism_level == 1 else "Кровавый Цветок пьет глубже")

func _upgrade_nova() -> void:
	ultimate_cooldown = max(20.0, ultimate_cooldown - 3.5)
	ultimate_radius += 28.0
	ultimate_damage += 1
	_update_ultimate_ui()
	_flash_overlay_text("Нова стала ярче")

func _upgrade_thorns() -> void:
	thorn_bloom_unlocked = true
	_flash_overlay_text("Шипастый Венец пробудился")

func _check_relic_evolutions() -> void:
	if blood_blade_evolved:
		return
	var blade_picks := _blade_upgrade_pick_count()
	if blade_picks >= 2 and vampirism_unlocked and is_instance_valid(living_blade):
		blood_blade_evolved = true
		living_blade.evolve_blood_blade()
		vampirism_heal_amount += 2.0
		vampirism_kills_required = max(5, vampirism_kills_required - 1)
		_flash_overlay_text("Эволюция: Кровавый Клинок")

func _blade_upgrade_pick_count() -> int:
	var blade_picks := int(relic_pick_counts.get("Заточить Живой Клинок", 0))
	blade_picks += int(relic_pick_counts.get("Ускорить проклятие", 0))
	blade_picks += int(relic_pick_counts.get("Расширить бледный радиус", 0))
	return blade_picks

func _update_lore_events() -> void:
	var events := _chapter_lore_events()
	if lore_event_index >= events.size():
		return
	var lore_event: Dictionary = events[lore_event_index]
	if elapsed >= float(lore_event["time"]):
		lore_event_index += 1
		_flash_overlay_text(String(lore_event["text"]))

func _show_game_over() -> void:
	if game_state == "game_over":
		return
	game_state = "game_over"
	last_run_result = "Маска треснула, но проклятие запомнило тебя"
	last_run_lore = _pick_lore_line(_chapter_death_lines())
	_finish_run(false)
	build_label.visible = false
	joystick_base.visible = false
	ultimate_button.visible = false
	ultimate_bar.visible = false
	_hide_boss_ui()
	_reset_joystick()
	get_tree().paused = true
	_show_result_screen(false)

func _show_victory() -> void:
	game_state = "victory"
	last_run_result = "На миг Gravebloom отступил от сердца руин"
	last_run_lore = _pick_lore_line(_chapter_victory_lines())
	_finish_run(true)
	build_label.visible = false
	joystick_base.visible = false
	ultimate_button.visible = false
	ultimate_bar.visible = false
	_reset_joystick()
	get_tree().paused = true
	_show_result_screen(true)

func _show_result_screen(victory: bool) -> void:
	_configure_overlay(Vector2(28, 104), Vector2(484, 744))
	overlay_panel.visible = true
	_clear_container(overlay_list)
	_add_overlay_label("Победа" if victory else "Забег окончен", 34)
	_add_overlay_label("Глава: %s" % String(_current_chapter()["name"]), 18)
	_add_overlay_label(last_run_result, 20)
	_add_overlay_label(last_run_lore, 18)
	_add_overlay_label("Время: %s   Уровень: %d   Убийства: %d   Серия: x%d" % [_format_time(elapsed), level, kill_count, best_kill_streak], 18)
	_add_overlay_label("Пепел: %d   Цели:+%d   Летопись:+%d" % [last_run_ash, last_run_goal_ash, last_run_codex_ash], 18)
	_add_overlay_label("Всего пепла: %d" % profile_ash, 18)
	_add_overlay_label("Осколки: %d/%d" % [xp, xp_to_next], 16)
	_add_overlay_label("Цели забега:\n%s" % _format_goal_summary(false), 15)
	if not last_run_codex_unlocks.is_empty():
		_add_overlay_label("Летопись открыла: %s" % ", ".join(last_run_codex_unlocks), 15)
	var build_summary := _format_relic_summary()
	if not build_summary.is_empty():
		_add_overlay_label("Реликвии: %s" % build_summary, 16)
	else:
		_add_overlay_label("Реликвии: Маска вошла в руины без даров", 16)
	_add_overlay_button("Заново", _start_run)
	_add_overlay_button("Профиль", _show_profile_screen)

func _finish_run(victory: bool) -> void:
	if run_reward_recorded:
		return
	run_reward_recorded = true
	_update_run_goals()
	last_run_goal_ash = _calculate_goal_reward()
	last_run_codex_ash = _update_codex_after_run(victory)
	last_run_ash = _calculate_ash_reward(victory) + last_run_goal_ash + last_run_codex_ash
	profile_ash += last_run_ash
	var history_entry := {
		"victory": victory,
		"time": elapsed,
		"level": level,
		"kills": kill_count,
		"best_streak": best_kill_streak,
		"ash": last_run_ash,
		"goal_ash": last_run_goal_ash,
		"codex_ash": last_run_codex_ash,
		"goals": _format_goal_summary(true),
		"codex": ", ".join(last_run_codex_unlocks),
		"build": _format_relic_summary(),
		"build_path": _current_build_path(true),
		"chapter": String(_current_chapter()["name"]),
		"date": Time.get_datetime_string_from_system(false, true),
	}
	run_history.insert(0, history_entry)
	run_history = run_history.slice(0, HISTORY_LIMIT)
	_save_profile()

func _calculate_ash_reward(victory: bool) -> int:
	var reward := 0
	reward += int(elapsed / 12.0)
	reward += level * 4
	reward += int(kill_count / 4)
	if dread_boss_spawned:
		reward += 10
	if victory:
		reward += 45
	return max(3, reward)

func _format_relic_summary() -> String:
	var parts: Array[String] = []
	if blood_blade_evolved:
		parts.append("Кровавый Клинок")
	for relic_name in relic_pick_order:
		var count := int(relic_pick_counts.get(relic_name, 0))
		if count <= 0:
			continue
		parts.append("%s x%d" % [relic_name, count] if count > 1 else relic_name)
	return ", ".join(parts)

func _current_build_path(include_default: bool = false) -> String:
	var blade_picks := _blade_upgrade_pick_count()
	var nova_picks := int(relic_pick_counts.get("Сердце Новы", 0))
	var magnet_picks := int(relic_pick_counts.get("Могильный Магнит", 0))
	if blood_blade_evolved or (vampirism_unlocked and blade_picks > 0) or blade_picks >= 2:
		return "Кровавый Клинок"
	if bone_spears_unlocked and (oblivion_bell_unlocked or thorn_bloom_unlocked):
		return "Костяная Стража"
	if nova_picks > 0 and vampirism_unlocked:
		return "Сердце Gravebloom"
	if shadow_spirit_unlocked and magnet_picks > 0:
		return "Тень Маски"
	if bone_spears_unlocked or oblivion_bell_unlocked or thorn_bloom_unlocked:
		return "Костяная Стража"
	if nova_picks > 0:
		return "Сердце Gravebloom"
	if shadow_spirit_unlocked or magnet_picks > 0:
		return "Тень Маски"
	return "Живой Клинок" if include_default else ""

func _format_build_path_summary() -> String:
	var path_name := _current_build_path(true)
	var description := String(BUILD_PATH_DESCRIPTIONS.get(path_name, ""))
	return "%s: %s" % [path_name, description] if not description.is_empty() else path_name

func _prepare_run_goals() -> void:
	active_run_goals.clear()
	completed_goal_ids.clear()
	var pool: Array = RUN_GOALS.duplicate()
	pool.shuffle()
	for goal in pool.slice(0, RUN_GOAL_COUNT):
		var goal_data: Dictionary = goal
		active_run_goals.append(goal_data)

func _update_run_goals() -> void:
	for goal in active_run_goals:
		var goal_data: Dictionary = goal
		var goal_id := String(goal_data["id"])
		if completed_goal_ids.has(goal_id):
			continue
		var progress := _run_goal_progress(goal_data)
		if progress >= int(goal_data["target"]):
			completed_goal_ids[goal_id] = true
			_flash_overlay_text("Цель выполнена: %s" % String(goal_data["title"]))

func _run_goal_progress(goal: Dictionary) -> int:
	match String(goal["type"]):
		"kills":
			return kill_count
		"level":
			return level
		"boss_spawned":
			return 1 if dread_boss_spawned else 0
		"boss_killed":
			return 1 if grave_king_killed else 0
		"blood_blade":
			return 1 if blood_blade_evolved else 0
		"bone_spears":
			return 1 if bone_spears_unlocked else 0
		"bell":
			return 1 if oblivion_bell_unlocked else 0
		"nova_casts":
			return nova_cast_count
		"health_packs":
			return health_pack_count
	return 0

func _calculate_goal_reward() -> int:
	var reward := 0
	for goal in active_run_goals:
		var goal_data: Dictionary = goal
		if completed_goal_ids.has(String(goal_data["id"])):
			reward += int(goal_data["reward"])
	return reward

func _format_goal_summary(completed_only: bool = false) -> String:
	var parts: Array[String] = []
	for goal in active_run_goals:
		var goal_data: Dictionary = goal
		var is_completed := completed_goal_ids.has(String(goal_data["id"]))
		if completed_only and not is_completed:
			continue
		var progress: int = min(_run_goal_progress(goal_data), int(goal_data["target"]))
		var marker := "✓" if is_completed else "·"
		parts.append("%s %s %d/%d" % [marker, String(goal_data["title"]), progress, int(goal_data["target"])])
	if parts.is_empty():
		return "Нет выполненных целей"
	return "\n".join(parts)

func _update_codex_after_run(victory: bool) -> int:
	_increment_profile_stat("runs", 1)
	_increment_profile_stat("victories" if victory else "deaths", 1)
	_increment_profile_stat("kills_total", kill_count)
	_increment_profile_stat("nova_casts_total", nova_cast_count)
	_increment_profile_stat("health_packs_total", health_pack_count)
	_increment_profile_stat("objectives_completed", completed_goal_ids.size())
	if grave_king_killed:
		_increment_profile_stat("grave_king_kills", 1)
	if blood_blade_evolved:
		_increment_profile_stat("blood_blade_evolutions", 1)
	_set_profile_stat_max("best_level", level)
	_set_profile_stat_max("best_kills", kill_count)
	_set_profile_stat_max("best_streak", best_kill_streak)
	_set_profile_stat_max("best_time", int(floor(elapsed)))

	var reward := 0
	if not victory:
		reward += _unlock_codex_entry("first_death")
	if victory:
		reward += _unlock_codex_entry("first_victory")
	if dread_boss_spawned:
		reward += _unlock_codex_entry("king_seen")
	if grave_king_killed:
		reward += _unlock_codex_entry("king_killed")
	if blood_blade_evolved:
		reward += _unlock_codex_entry("blood_blade")
	if bone_spears_unlocked:
		reward += _unlock_codex_entry("bone_spears")
	if oblivion_bell_unlocked:
		reward += _unlock_codex_entry("bell")
	if int(profile_stats.get("runs", 0)) >= 3:
		reward += _unlock_codex_entry("three_runs")
	if int(profile_stats.get("kills_total", 0)) >= 100:
		reward += _unlock_codex_entry("hundred_kills")
	if int(profile_stats.get("nova_casts_total", 0)) >= 10:
		reward += _unlock_codex_entry("nova_ten")
	return reward

func _unlock_codex_entry(entry_id: String) -> int:
	if codex_unlocked.has(entry_id):
		return 0
	var entry := _codex_entry_by_id(entry_id)
	if entry.is_empty():
		return 0
	codex_unlocked[entry_id] = true
	last_run_codex_unlocks.append(String(entry["title"]))
	return int(entry["reward"])

func _codex_entry_by_id(entry_id: String) -> Dictionary:
	for entry in CODEX_ENTRIES:
		var entry_data: Dictionary = entry
		if String(entry_data["id"]) == entry_id:
			return entry_data
	return {}

func _increment_profile_stat(stat_id: String, amount: int) -> void:
	profile_stats[stat_id] = int(profile_stats.get(stat_id, 0)) + amount

func _set_profile_stat_max(stat_id: String, value: int) -> void:
	profile_stats[stat_id] = max(int(profile_stats.get(stat_id, 0)), value)

func _format_codex_stats() -> String:
	return "Забеги:%d  Победы:%d  Смерти:%d\nЛучший ур:%d  Убийств:%d  Серия:x%d  Король:%d\nВсего убийств:%d  Нова:%d  Цели:%d" % [
		int(profile_stats.get("runs", 0)),
		int(profile_stats.get("victories", 0)),
		int(profile_stats.get("deaths", 0)),
		int(profile_stats.get("best_level", 1)),
		int(profile_stats.get("best_kills", 0)),
		int(profile_stats.get("best_streak", 0)),
		int(profile_stats.get("grave_king_kills", 0)),
		int(profile_stats.get("kills_total", 0)),
		int(profile_stats.get("nova_casts_total", 0)),
		int(profile_stats.get("objectives_completed", 0)),
	]

func _pick_lore_line(lines: Array) -> String:
	if lines.is_empty():
		return ""
	return String(lines[randi() % lines.size()])

func _load_profile() -> void:
	_reset_profile_defaults()
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var data: Dictionary = parsed
	profile_ash = int(data.get("ash", 0))
	current_chapter_index = clampi(int(data.get("chapter_index", 0)), 0, CHAPTERS.size() - 1)
	var upgrades: Variant = data.get("upgrades", {})
	if typeof(upgrades) == TYPE_DICTIONARY:
		for upgrade_id in META_UPGRADES.keys():
			profile_upgrades[String(upgrade_id)] = int(upgrades.get(String(upgrade_id), 0))
	var stats: Variant = data.get("stats", {})
	if typeof(stats) == TYPE_DICTIONARY:
		var stats_data: Dictionary = stats
		for stat_id in stats_data.keys():
			profile_stats[String(stat_id)] = int(stats_data.get(stat_id, 0))
	var codex: Variant = data.get("codex", {})
	if typeof(codex) == TYPE_DICTIONARY:
		var codex_data: Dictionary = codex
		for entry_id in codex_data.keys():
			if bool(codex_data.get(entry_id, false)):
				codex_unlocked[String(entry_id)] = true
	var history: Variant = data.get("history", [])
	if typeof(history) == TYPE_ARRAY:
		run_history = history

func _save_profile() -> void:
	var data := {
		"version": 2,
		"ash": profile_ash,
		"chapter_index": current_chapter_index,
		"upgrades": profile_upgrades,
		"stats": profile_stats,
		"codex": codex_unlocked,
		"history": run_history.slice(0, HISTORY_LIMIT),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data))

func _reset_profile_defaults() -> void:
	profile_ash = 0
	profile_upgrades.clear()
	for upgrade_id in META_UPGRADES.keys():
		profile_upgrades[String(upgrade_id)] = 0
	profile_stats = {
		"runs": 0,
		"victories": 0,
		"deaths": 0,
		"kills_total": 0,
		"best_level": 1,
		"best_kills": 0,
		"best_streak": 0,
		"best_time": 0,
		"grave_king_kills": 0,
		"blood_blade_evolutions": 0,
		"nova_casts_total": 0,
		"health_packs_total": 0,
		"objectives_completed": 0,
	}
	codex_unlocked.clear()
	run_history.clear()
	current_chapter_index = 0

func _profile_upgrade_level(upgrade_id: String) -> int:
	return int(profile_upgrades.get(upgrade_id, 0))

func _profile_power_level() -> int:
	var total := 0
	for upgrade_id in META_UPGRADES.keys():
		total += _profile_upgrade_level(String(upgrade_id))
	return total

func _profile_pressure_tier() -> int:
	return int(_profile_power_level() / 3)

func _profile_upgrade_cost(upgrade_id: String) -> int:
	var upgrade: Dictionary = META_UPGRADES[upgrade_id]
	var level := _profile_upgrade_level(upgrade_id)
	return int(upgrade["base_cost"]) + level * int(upgrade["cost_step"])

func _add_profile_upgrade_button(upgrade_id: String) -> void:
	var upgrade: Dictionary = META_UPGRADES[upgrade_id]
	var level := _profile_upgrade_level(upgrade_id)
	var max_level := int(upgrade["max"])
	var cost := _profile_upgrade_cost(upgrade_id)
	var button := Button.new()
	button.custom_minimum_size = Vector2(430, 62)
	if level >= max_level:
		button.text = "%s %d/%d\n%s" % [String(upgrade["name"]), level, max_level, String(upgrade["description"])]
		button.disabled = true
	else:
		button.text = "%s %d/%d  %d пепла\n%s" % [String(upgrade["name"]), level, max_level, cost, String(upgrade["description"])]
		button.disabled = profile_ash < cost
	button.pressed.connect(_buy_profile_upgrade.bind(upgrade_id))
	overlay_list.add_child(button)

func _buy_profile_upgrade(upgrade_id: String) -> void:
	var upgrade: Dictionary = META_UPGRADES[upgrade_id]
	var level := _profile_upgrade_level(upgrade_id)
	if level >= int(upgrade["max"]):
		return
	var cost := _profile_upgrade_cost(upgrade_id)
	if profile_ash < cost:
		return
	profile_ash -= cost
	profile_upgrades[upgrade_id] = level + 1
	_save_profile()
	_show_profile_screen()

func _format_history_entry(entry: Variant) -> String:
	if typeof(entry) != TYPE_DICTIONARY:
		return ""
	var title := "Победа" if bool(entry.get("victory", false)) else "Смерть"
	var time_text := _format_time(float(entry.get("time", 0.0)))
	return "%s  %s  %s  ур.%d  убийств:%d  серия:x%d  +%d" % [
		title,
		String(entry.get("chapter", "Мертвый Сад")),
		time_text,
		int(entry.get("level", 1)),
		int(entry.get("kills", 0)),
		int(entry.get("best_streak", 0)),
		int(entry.get("ash", 0)),
	]

func _update_hud() -> void:
	var remaining: float = max(0.0, RUN_DURATION - elapsed)
	var health_value := 0
	if player != null:
		health_value = int(ceil(player.health))
	hud.text = "%s\nУровень %d   Забег %s   До конца %s" % [
		String(_current_chapter()["name"]),
		level,
		_format_time(elapsed),
		_format_time(remaining)
	]
	hp_bar.value = health_value
	xp_bar.max_value = xp_to_next
	xp_bar.value = xp
	build_label.text = _format_build_hud()
	build_label.visible = game_state == "running" and not build_label.text.is_empty()
	_update_boss_ui()
	_update_ultimate_ui()

func _format_build_hud() -> String:
	var lines: Array[String] = []
	var blade_picks := _blade_upgrade_pick_count()
	if blood_blade_evolved:
		lines.append("Кровавый Клинок")
	else:
		lines.append("Клинок: улучшений %d/2" % min(2, blade_picks))
	if oblivion_bell_unlocked:
		lines.append("Колокол x%d" % int(relic_pick_counts.get("Колокол Забвения", 1)))
	if bone_spears_unlocked:
		lines.append("Копья x%d" % int(relic_pick_counts.get("Костяные Копья", 1)))
	if shadow_spirit_unlocked:
		lines.append("Тень x%d" % int(relic_pick_counts.get("Призвать Тень", 1)))
	if vampirism_unlocked:
		lines.append("Цветок x%d" % vampirism_level)
	if kill_streak >= 5:
		lines.append("Серия x%d" % kill_streak)
	if not blood_blade_evolved:
		var needed_blade: int = max(0, 2 - blade_picks)
		if vampirism_unlocked and needed_blade > 0:
			lines.append("До Кровавого Клинка: %d" % needed_blade)
		elif not vampirism_unlocked and blade_picks >= 2:
			lines.append("До Кровавого Клинка: нужен Цветок")
		elif not vampirism_unlocked:
			lines.append("Кровавый Клинок: Цветок + 2 улучшения")
	return "\n".join(lines.slice(0, 5))

func _show_boss_ui(boss: Enemy) -> void:
	if boss == null:
		return
	boss_name_label.text = String(_current_chapter().get("boss_name", "КОРОЛЬ-МОГИЛА"))
	boss_name_label.visible = true
	boss_hp_bar.visible = true
	boss_hp_bar.max_value = max(1, boss.max_health)
	boss_hp_bar.value = max(0, boss.health)
	boss_hp_bar.modulate = Color.WHITE
	boss_name_label.modulate = Color.WHITE

func _hide_boss_ui() -> void:
	boss_name_label.visible = false
	boss_hp_bar.visible = false

func _update_boss_ui() -> void:
	if not boss_hp_bar.visible:
		return
	var boss := _get_dread_boss()
	if boss == null:
		_hide_boss_ui()
		return
	boss_hp_bar.max_value = max(1, boss.max_health)
	boss_hp_bar.value = clamp(boss.health, 0, boss.max_health)

func _flash_boss_ui() -> void:
	if not boss_hp_bar.visible:
		return
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(boss_hp_bar, "modulate", Color(1.0, 0.42, 0.62), 0.08)
	tween.tween_property(boss_name_label, "modulate", Color(1.0, 0.7, 0.82), 0.08)
	tween.chain().tween_property(boss_hp_bar, "modulate", Color.WHITE, 0.28)
	tween.parallel().tween_property(boss_name_label, "modulate", Color.WHITE, 0.28)

func _build_ultimate_ui() -> void:
	ultimate_bar.position = Vector2(22, 882)
	ultimate_bar.size = Vector2(188, 18)
	ultimate_bar.max_value = ULTIMATE_COOLDOWN
	ultimate_bar.value = 0.0
	ultimate_bar.show_percentage = false
	ultimate_bar.process_mode = Node.PROCESS_MODE_ALWAYS
	ui_layer.add_child(ultimate_bar)
	ultimate_button.position = Vector2(20, 760)
	ultimate_button.custom_minimum_size = Vector2(194, 114)
	ultimate_button.size = Vector2(194, 114)
	ultimate_button.text = "НОВА\n0%"
	ultimate_button.disabled = true
	ultimate_button.process_mode = Node.PROCESS_MODE_ALWAYS
	ultimate_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ultimate_button.focus_mode = Control.FOCUS_NONE
	ultimate_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	ultimate_button.add_theme_font_size_override("font_size", 24)
	ui_layer.add_child(ultimate_button)

func _update_ultimate(delta: float) -> void:
	if ultimate_ready:
		return
	ultimate_charge = min(ultimate_cooldown, ultimate_charge + delta)
	_update_nova_charge_cues()
	if ultimate_charge >= ultimate_cooldown:
		ultimate_ready = true
		if ULTIMATE_AUTO_CAST:
			_cast_ultimate()
			return
		else:
			_flash_overlay_text("Нова готова")
			CombatFxScript.ring(fx_layer, player.global_position, Color(0.58, 1.0, 0.72, 0.65), 130.0, 0.42)
	_update_ultimate_ui()

func _update_ultimate_ui() -> void:
	if ultimate_bar == null or ultimate_button == null:
		return
	ultimate_bar.max_value = ultimate_cooldown
	ultimate_bar.value = ultimate_charge
	var charge_percent := int(floor((ultimate_charge / ultimate_cooldown) * 100.0))
	ultimate_button.text = "НОВА\nАВТО" if ultimate_ready else "НОВА\n%d%%" % charge_percent
	ultimate_button.disabled = true
	ultimate_button.modulate = Color.WHITE if ultimate_ready else Color(0.78, 0.86, 0.78, 0.95)

func _update_nova_charge_cues() -> void:
	var ratio: float = _nova_charge_ratio()
	var next_stage := 0
	if ratio >= NOVA_CUE_STRIKE:
		next_stage = 3
	elif ratio >= NOVA_CUE_WARN:
		next_stage = 2
	elif ratio >= NOVA_CUE_WAKE:
		next_stage = 1
	if next_stage <= nova_charge_stage:
		return
	nova_charge_stage = next_stage
	match nova_charge_stage:
		1:
			_play_nova_cue(nova_wake_player)
			if player != null:
				CombatFxScript.ring(fx_layer, player.global_position, Color(0.58, 1.0, 0.72, 0.36), 96.0, 0.34)
		2:
			_play_nova_cue(nova_warn_player)
			if player != null:
				CombatFxScript.ring(fx_layer, player.global_position, Color(0.76, 1.0, 0.68, 0.54), 132.0, 0.38)
				_start_screen_shake(0.08, 2.5)
		3:
			_play_nova_cue(nova_burst_player)
			if player != null:
				CombatFxScript.ring(fx_layer, player.global_position, Color(0.96, 0.82, 1.0, 0.7), 172.0, 0.28)
				_start_screen_shake(0.16, 5.5)

func _play_nova_cue(audio_player: AudioStreamPlayer) -> void:
	if audio_player == null:
		return
	audio_player.stop()
	audio_player.play()

func _nova_charge_ratio() -> float:
	if ultimate_cooldown <= 0.0:
		return 0.0
	return clamp(ultimate_charge / ultimate_cooldown, 0.0, 1.0)

func _update_nova_charge_fx(delta: float) -> void:
	if game_state != "running" or player == null or nova_charge_fx == null:
		if nova_charge_fx != null:
			nova_charge_fx.visible = false
		return
	var ratio: float = _nova_charge_ratio()
	if ratio < NOVA_CUE_WAKE:
		nova_charge_fx.visible = false
		return
	nova_pulse_time += delta
	nova_charge_fx.visible = true
	nova_charge_fx.global_position = player.global_position + Vector2(0.0, -10.0)
	var stage_strength: float = clampf((ratio - NOVA_CUE_WAKE) / (1.0 - NOVA_CUE_WAKE), 0.0, 1.0)
	var pulse: float = 0.5 + sin(nova_pulse_time * lerpf(5.2, 10.5, stage_strength)) * 0.5
	nova_charge_fx.scale = Vector2.ONE * lerpf(0.82, 1.28, stage_strength) * (1.0 + pulse * lerpf(0.03, 0.1, stage_strength))

	var aura := nova_charge_fx.get_node_or_null("Aura") as CanvasItem
	var outer_ring := nova_charge_fx.get_node_or_null("OuterRing") as Line2D
	var inner_ring := nova_charge_fx.get_node_or_null("InnerRing") as Line2D
	var petals := nova_charge_fx.get_node_or_null("Petals") as Node2D
	if aura != null:
		aura.modulate.a = lerpf(0.45, 1.0, stage_strength) * (0.74 + pulse * 0.26)
	if outer_ring != null:
		outer_ring.rotation += delta * lerpf(1.6, 4.8, stage_strength)
		outer_ring.width = lerpf(3.0, 7.0, stage_strength)
		outer_ring.default_color = Color(0.58 + stage_strength * 0.3, 1.0, 0.72 + stage_strength * 0.2, 0.58 + pulse * 0.34)
	if inner_ring != null:
		inner_ring.rotation -= delta * lerpf(2.4, 6.2, stage_strength)
		inner_ring.width = lerpf(2.0, 4.0, stage_strength)
		inner_ring.default_color = Color(0.92, 0.76 + stage_strength * 0.18, 1.0, 0.42 + pulse * 0.36)
	if petals != null:
		petals.rotation += delta * lerpf(2.0, 7.0, stage_strength)
		petals.modulate.a = lerpf(0.5, 1.0, stage_strength)

func _cast_ultimate() -> void:
	if game_state != "running" or player == null:
		return
	if not ultimate_ready:
		_flash_overlay_text("Нова заряжается: %d%%" % int(floor((ultimate_charge / ultimate_cooldown) * 100.0)))
		return
	ultimate_ready = false
	ultimate_charge = 0.0
	nova_cast_count += 1
	nova_charge_stage = 0
	nova_charge_fx.visible = false
	var origin := player.global_position
	player.clear_pointer_input()
	_flash_overlay_text("НОВА GRAVEBLOOM")
	_play_nova_cue(nova_burst_player)
	_start_screen_shake(0.42, 13.0)
	CombatFxScript.ring(fx_layer, origin, Color(0.78, 1.0, 0.72, 0.95), ultimate_radius, 0.55)
	CombatFxScript.ring(fx_layer, origin, Color(0.95, 0.78, 1.0, 0.68), ultimate_radius * 0.62, 0.42)
	CombatFxScript.burst(fx_layer, origin, Color(0.72, 1.0, 0.78, 0.92), 42)
	_add_ultimate_lashes(origin)
	var targets := enemies.duplicate()
	nova_damage_active = true
	nova_vampirism_healed = 0.0
	for enemy in targets:
		if not is_instance_valid(enemy):
			continue
		var distance := origin.distance_to(enemy.global_position)
		if distance <= ultimate_radius:
			var damage := _scaled_player_damage(ultimate_damage)
			if enemy.enemy_kind == "grave_king":
				damage = int(ceil(float(damage) * 1.35))
			elif enemy.is_miniboss:
				damage = int(ceil(float(damage) * 0.65))
			enemy.take_damage(damage, origin, 520.0)
	nova_damage_active = false
	_update_ultimate_ui()

func _add_ultimate_lashes(origin: Vector2) -> void:
	for i in range(18):
		var lash := Line2D.new()
		lash.width = randf_range(3.0, 7.0)
		lash.default_color = Color(0.56, 1.0, 0.75, randf_range(0.5, 0.86))
		var angle := TAU * float(i) / 18.0 + randf_range(-0.08, 0.08)
		var start := Vector2.RIGHT.rotated(angle) * randf_range(26.0, 70.0)
		var end := Vector2.RIGHT.rotated(angle + randf_range(-0.18, 0.18)) * randf_range(210.0, ultimate_radius)
		lash.points = PackedVector2Array([origin + start, origin + (start + end) * 0.52, origin + end])
		fx_layer.add_child(lash)
		var tween := create_tween()
		tween.tween_property(lash, "modulate:a", 0.0, 0.36)
		tween.tween_callback(lash.queue_free)

func _build_joystick() -> void:
	joystick_base.position = Vector2(340, 760)
	joystick_base.custom_minimum_size = Vector2(170, 170)
	joystick_base.size = Vector2(170, 170)
	joystick_base.visible = false
	joystick_base.mouse_filter = Control.MOUSE_FILTER_STOP
	joystick_base.process_mode = Node.PROCESS_MODE_ALWAYS
	joystick_base.add_theme_stylebox_override("panel", _make_round_style(Color(0.18, 0.22, 0.2, 0.42), 85, Color(0.62, 1.0, 0.77, 0.42), 3))
	joystick_base.gui_input.connect(_on_joystick_input)
	ui_layer.add_child(joystick_base)

	joystick_knob.position = Vector2(51.5, 51.5)
	joystick_knob.custom_minimum_size = Vector2(67, 67)
	joystick_knob.size = Vector2(67, 67)
	joystick_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	joystick_knob.add_theme_stylebox_override("panel", _make_round_style(Color(0.58, 1.0, 0.72, 0.76), 34, Color(0.9, 1.0, 0.86, 0.55), 2))
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
			enemy.take_damage(_scaled_player_damage(shadow_spirit_damage), start, 180.0)
	_start_screen_shake(0.1, 3.5)

func _update_bone_spears(delta: float) -> void:
	if not bone_spears_unlocked or player == null:
		return
	bone_spear_timer -= delta
	if bone_spear_timer > 0.0:
		return
	_cast_bone_spears()
	bone_spear_timer = bone_spear_cooldown

func _cast_bone_spears() -> void:
	var target := _nearest_enemy_for_spirit()
	if target == null:
		bone_spear_timer = 0.35
		return
	_flash_overlay_text("Костяные копья!")
	var base_direction := player.global_position.direction_to(target.global_position)
	if base_direction.length() <= 0.0:
		base_direction = Vector2.RIGHT
	var spread_step := 0.22
	var start_offset := -float(bone_spear_count - 1) * spread_step * 0.5
	for i in range(bone_spear_count):
		var direction := base_direction.rotated(start_offset + float(i) * spread_step)
		_cast_single_bone_spear(player.global_position, direction)
	_start_screen_shake(0.08, 3.0)

func _cast_single_bone_spear(origin: Vector2, direction: Vector2) -> void:
	var length := 620.0
	var width := 42.0
	var start := origin + direction * 42.0
	var end := origin + direction * length
	var spear_root := Node2D.new()
	spear_root.z_index = 46
	fx_layer.add_child(spear_root)
	var shadow := Line2D.new()
	shadow.width = 22.0
	shadow.default_color = Color(0.03, 0.015, 0.02, 0.48)
	shadow.points = PackedVector2Array([start - direction * 10.0, end])
	spear_root.add_child(shadow)
	var spear := Line2D.new()
	spear.width = 15.0
	spear.default_color = Color(0.86, 0.88, 0.68, 0.95)
	spear.points = PackedVector2Array([start, end])
	spear_root.add_child(spear)
	var core := Line2D.new()
	core.width = 5.0
	core.default_color = Color(1.0, 0.98, 0.82, 1.0)
	core.points = PackedVector2Array([start + direction * 20.0, end])
	spear_root.add_child(core)
	var head := Polygon2D.new()
	var side := direction.orthogonal()
	head.color = Color(0.96, 0.94, 0.72, 0.98)
	head.polygon = PackedVector2Array([
		end + direction * 36.0,
		end - direction * 28.0 + side * 22.0,
		end - direction * 12.0,
		end - direction * 28.0 - side * 22.0,
	])
	spear_root.add_child(head)
	for j in range(4):
		var shard := Polygon2D.new()
		var shard_direction := direction.rotated(randf_range(-0.34, 0.34))
		var shard_side := shard_direction.orthogonal()
		var shard_center := start.lerp(end, randf_range(0.25, 0.92))
		shard.color = Color(0.78, 0.82, 0.64, 0.72)
		shard.polygon = PackedVector2Array([
			shard_center + shard_direction * 15.0,
			shard_center - shard_direction * 9.0 + shard_side * 5.0,
			shard_center - shard_direction * 9.0 - shard_side * 5.0,
		])
		spear_root.add_child(shard)
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var distance_to_spear := _distance_to_segment(enemy.global_position, start, end)
		if distance_to_spear <= width:
			enemy.take_damage(_scaled_player_damage(bone_spear_damage), origin, 230.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(spear_root, "modulate:a", 0.0, 0.42)
	tween.tween_property(spear_root, "scale", Vector2(1.03, 1.03), 0.42)
	tween.chain().tween_callback(spear_root.queue_free)

func _update_oblivion_bell(delta: float) -> void:
	if not oblivion_bell_unlocked or player == null:
		return
	oblivion_bell_timer -= delta
	if oblivion_bell_timer > 0.0:
		return
	_cast_oblivion_bell()
	oblivion_bell_timer = oblivion_bell_cooldown

func _cast_oblivion_bell() -> void:
	var origin := player.global_position
	CombatFxScript.ring(fx_layer, origin, Color(0.82, 1.0, 0.62, 0.82), oblivion_bell_radius, 0.38)
	CombatFxScript.ring(fx_layer, origin, Color(0.52, 1.0, 0.84, 0.48), oblivion_bell_radius * 0.62, 0.28)
	_add_bell_wave_lines(origin)
	var hit_count := 0
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(origin) <= oblivion_bell_radius:
			enemy.take_damage(_scaled_player_damage(oblivion_bell_damage), origin, 260.0)
			hit_count += 1
	if hit_count > 0:
		_start_screen_shake(0.08, 3.2)

func _add_bell_wave_lines(origin: Vector2) -> void:
	for i in range(12):
		var angle := TAU * float(i) / 12.0
		var line := Line2D.new()
		line.width = 3.0
		line.default_color = Color(0.84, 1.0, 0.58, 0.58)
		line.points = PackedVector2Array([
			origin + Vector2.RIGHT.rotated(angle) * 26.0,
			origin + Vector2.RIGHT.rotated(angle) * oblivion_bell_radius,
		])
		fx_layer.add_child(line)
		var tween := create_tween()
		tween.tween_property(line, "modulate:a", 0.0, 0.22)
		tween.tween_callback(line.queue_free)

func _distance_to_segment(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment := end - start
	var length_squared := segment.length_squared()
	if length_squared <= 0.0:
		return point.distance_to(start)
	var t: float = clamp((point - start).dot(segment) / length_squared, 0.0, 1.0)
	var projection := start + segment * t
	return point.distance_to(projection)

func _start_screen_shake(duration: float, intensity: float) -> void:
	if intensity < SCREEN_SHAKE_MIN_INTENSITY:
		return
	var reduced_duration := duration * SCREEN_SHAKE_DURATION_SCALE
	var reduced_intensity := minf(intensity * SCREEN_SHAKE_SCALE, SCREEN_SHAKE_MAX_INTENSITY)
	shake_time = max(shake_time, reduced_duration)
	shake_intensity = max(shake_intensity, reduced_intensity)

func _stop_screen_shake() -> void:
	shake_time = 0.0
	shake_intensity = 0.0
	world.position = Vector2.ZERO
	fx_layer.position = Vector2.ZERO
	var camera := _player_camera()
	if camera != null:
		camera.offset = Vector2.ZERO

func _update_screen_shake(delta: float) -> void:
	var camera := _player_camera()
	if camera == null:
		return
	if shake_time <= 0.0:
		if camera.offset != Vector2.ZERO:
			camera.offset = camera.offset.lerp(Vector2.ZERO, minf(1.0, delta * 28.0))
			if camera.offset.length() < 0.15:
				camera.offset = Vector2.ZERO
		return
	shake_time -= delta
	var target_offset := Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
	camera.offset = camera.offset.lerp(target_offset, minf(1.0, delta * 34.0))
	shake_intensity = max(0.0, shake_intensity - delta * 21.0)

func _player_camera() -> Camera2D:
	if player == null:
		return null
	return player.get_node_or_null("Camera2D") as Camera2D

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
	button.custom_minimum_size = Vector2(410, 78) if text.contains("\n") else Vector2(360, 62)
	button.pressed.connect(callback)
	overlay_list.add_child(button)

func _configure_overlay(position: Vector2, size: Vector2) -> void:
	overlay_panel.position = position
	overlay_panel.size = size
	overlay_panel.custom_minimum_size = size

func _flash_overlay_text(text: String) -> void:
	var label := _make_label(text, 26)
	label.global_position = Vector2(34, 168)
	label.size = Vector2(472, 72)
	label.custom_minimum_size = Vector2(472, 72)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	for projectile in enemy_projectiles:
		if is_instance_valid(projectile):
			projectile.queue_free()
	for pack in health_packs:
		if is_instance_valid(pack):
			pack.queue_free()
	for zone in hazard_zones:
		if is_instance_valid(zone):
			zone.queue_free()
	for attack in boss_attacks:
		if is_instance_valid(attack):
			attack.queue_free()
	if is_instance_valid(player):
		player.queue_free()
	if is_instance_valid(living_blade):
		living_blade.queue_free()
	enemies.clear()
	shards.clear()
	enemy_projectiles.clear()
	health_packs.clear()
	hazard_zones.clear()
	boss_attacks.clear()
	player = null
	living_blade = null
