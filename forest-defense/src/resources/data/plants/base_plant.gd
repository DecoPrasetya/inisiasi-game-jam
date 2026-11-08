class_name BasePlant
extends Node2D

signal plant_died()
signal plant_selected(plant_node: BasePlant)
signal level_upgraded(new_level: int)

@export var stats: PlantStats

var grid_cell: Vector2i = Vector2i.ZERO
var current_level: int = 1
var is_selected: bool = false
var _is_dying: bool = false

const SCALABLE_OUTPUT_STATS: Array[StringName] = [
	&"attack_damage",
	&"support_power"
]

@onready var anim_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var health_component: HealthComponent = get_node_or_null("HealthComponent")
@onready var status_receiver: StatusEffectReceiver = get_node_or_null("StatusEffectReceiver")
@onready var hurtbox_component: Area2D = get_node_or_null("HurtboxComponent")
@onready var detection_area: Area2D = get_node_or_null("DetectionArea")
var detection_shape: CollisionShape2D = null


func _ready() -> void:
	add_to_group("plants")
	_ensure_combat_components()
	if stats != null:
		setup_from_stats(stats, grid_cell)
	else:
		play_animation(&"idle")


func _physics_process(delta: float) -> void:
	if _is_dying or GameManager.current_phase != Constants.GamePhase.NIGHT:
		return
	_process_night_behavior(delta)


# --- INISIALISASI KOMPONEN & KONFIGURASI STATS ---

func _ensure_combat_components() -> void:
	anim_sprite = get_node_or_null("AnimatedSprite2D")
	if anim_sprite == null:
		anim_sprite = AnimatedSprite2D.new()
		anim_sprite.name = "AnimatedSprite2D"
		add_child(anim_sprite)
		
	if health_component == null:
		health_component = get_node_or_null("HealthComponent")
	if health_component == null:
		health_component = HealthComponent.new()
		health_component.name = "HealthComponent"
		add_child(health_component)
	health_component.is_enemy_entity = false
	if not health_component.health_changed.is_connected(_on_health_changed):
		health_component.health_changed.connect(_on_health_changed)
	if not health_component.died.is_connected(_on_died):
		health_component.died.connect(_on_died)
		
	if status_receiver == null:
		status_receiver = get_node_or_null("StatusEffectReceiver")
	if status_receiver == null:
		status_receiver = StatusEffectReceiver.new()
		status_receiver.name = "StatusEffectReceiver"
		add_child(status_receiver)
	status_receiver.can_receive_debuff = true
	status_receiver.can_receive_crowd_control = false
	if not status_receiver.stats_recalculated.is_connected(_on_stats_recalculated):
		status_receiver.stats_recalculated.connect(_on_stats_recalculated)
	
	if hurtbox_component == null:
		hurtbox_component = get_node_or_null("HurtboxComponent")
	if hurtbox_component == null:
		hurtbox_component = HurtboxComponent.new()
		hurtbox_component.name = "HurtboxComponent"
		var col := CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var circle := CircleShape2D.new()
		circle.radius = 18.0
		col.shape = circle
		hurtbox_component.add_child(col)
		add_child(hurtbox_component)
		
	hurtbox_component.health_component = health_component
	hurtbox_component.status_receiver = status_receiver
	hurtbox_component.configure_collision_layer(Constants.LAYER_PLANTS)
	hurtbox_component.input_pickable = true
	if not hurtbox_component.input_event.is_connected(_on_hurtbox_input_event):
		hurtbox_component.input_event.connect(_on_hurtbox_input_event)

	_setup_detection_area()


func _setup_detection_area(target_layer: int = Constants.LAYER_ENEMIES) -> void:
	var detect_radius: float = get_final_stat(&"attack_range", 160.0)
	if detection_area == null:
		detection_area = get_node_or_null("DetectionArea")
	if detection_area == null:
		detection_area = Area2D.new()
		detection_area.name = "DetectionArea"
		detection_area.monitoring = true
		detection_area.monitorable = false
		
		detection_shape = CollisionShape2D.new()
		detection_shape.name = "DetectionCollisionShape2D"
		var circle := CircleShape2D.new()
		circle.radius = detect_radius
		detection_shape.shape = circle
		detection_area.add_child(detection_shape)
		add_child(detection_area)
	else:
		detection_shape = detection_area.get_node_or_null("DetectionCollisionShape2D")
		if detection_shape == null:
			detection_shape = detection_area.get_node_or_null("CollisionShape2D")
		if detection_shape != null:
			var circle := CircleShape2D.new()
			circle.radius = detect_radius
			detection_shape.shape = circle

	detection_area.collision_layer = 0
	detection_area.collision_mask = 0
	if target_layer >= 1 and target_layer <= 32:
		detection_area.set_collision_mask_value(target_layer, true)


func setup_from_stats(plant_data: PlantStats, cell: Vector2i = Vector2i.ZERO) -> void:
	stats = plant_data
	grid_cell = cell
	current_level = 1
	_is_dying = false
	_ensure_combat_components()
	
	# Kecilkan hanya visual sprite-nya, JANGAN root node-nya agar radius collision & HP bar tidak rusak!
	scale = Vector2.ONE
	if anim_sprite != null:
		anim_sprite.scale = Vector2(0.05, 0.05)
		
	var base_hp: float = get_level_scaled_max_hp(1)
	health_component.initialize(base_hp, false)
	status_receiver.clear_all_effects()
	_setup_detection_area()
	play_animation(&"idle")
	
	_on_plant_configured()
	queue_redraw()


# --- VIRTUAL HOOKS (UNTUK DI-OVERRIDE OLEH SUB-CLASS TANAMAN) ---

## Dipanggil setelah setup_from_stats selesai
func _on_plant_configured() -> void:
	pass


## Dipanggil setiap physics frame hanya pada saat fase NIGHT
func _process_night_behavior(_delta: float) -> void:
	if _is_dying or GameManager.current_phase != Constants.GamePhase.NIGHT:
		return


## Dipanggil saat tanaman menerima damage dari musuh (berguna untuk efek balasan Defender)
func _on_damaged_by_enemy(_amount: float, _source_node: Node) -> void:
	pass


## Dipanggil saat tanaman naik level
func _on_level_upgraded(_new_level: int) -> void:
	pass


# --- MANAJEMEN VISUAL & ANIMASI TERPADU ---

func play_animation(anim_name: StringName) -> void:
	if anim_sprite != null and anim_sprite.sprite_frames != null:
		if anim_sprite.sprite_frames.has_animation(anim_name):
			anim_sprite.play(anim_name)


func set_facing_direction(target_global_pos: Vector2) -> void:
	var flip: bool = target_global_pos.x < global_position.x
	if anim_sprite != null:
		anim_sprite.flip_h = flip


# --- KALKULASI STAT & PERTEMPURAN ---

## Mengambil nilai stat akhir dengan rumus TRD-005: (Base + Flat) * (1 + Percent)
func get_final_stat(stat_name: StringName, default_base: float = 0.0) -> float:
	var base_val: float = default_base
	if stats != null and stat_name in stats:
		base_val = float(stats.get(stat_name))
	
	if SCALABLE_OUTPUT_STATS.has(stat_name):
		base_val *= get_level_stat_multiplier(current_level)
		
	if status_receiver != null:
		return status_receiver.calculate_final_stat(base_val, stat_name)
	return base_val


func take_damage(amount: float, source_role: int = -1, source_node: Node = null) -> void:
	if _is_dying:
		return
	if health_component != null:
		var damaged: bool = health_component.take_damage(amount, source_role, source_node)
		if damaged and not health_component.is_dead:
			_play_hit_animation()
			_on_damaged_by_enemy(amount, source_node)
	else:
		die()


func _play_hit_animation() -> void:
	if anim_sprite != null and anim_sprite.sprite_frames != null and anim_sprite.sprite_frames.has_animation(&"hit"):
		anim_sprite.play(&"hit")
		await anim_sprite.animation_finished
		if not _is_dying and health_component != null and not health_component.is_dead:
			play_animation(&"idle")


func die() -> void:
	_on_died()


func _on_health_changed(current_hp: float, max_hp: float) -> void:
	EventBus.plant_health_changed.emit(grid_cell, current_hp, max_hp)
	queue_redraw()


func _on_stats_recalculated() -> void:
	if detection_shape != null and detection_shape.shape is CircleShape2D:
		(detection_shape.shape as CircleShape2D).radius = get_final_stat(&"attack_range", 160.0)
	queue_redraw()


func _on_died() -> void:
	if _is_dying:
		return
	_is_dying = true
	
	if anim_sprite != null and anim_sprite.sprite_frames != null and anim_sprite.sprite_frames.has_animation(&"death"):
		anim_sprite.play(&"death")
		await anim_sprite.animation_finished
		
	plant_died.emit()
	queue_free()


# --- SISTEM UPGRADE (+20% STAT, BIAYA 1.5^(L-1), & ATURAN R6) ---

func get_level_stat_multiplier(level_to_check: int = current_level) -> float:
	return 1.0 + Constants.PLANT_STAT_GROWTH_PER_LEVEL * float(maxi(0, level_to_check - 1))


func get_level_scaled_max_hp(level_to_check: int = current_level) -> float:
	var base_hp: float = stats.max_hp if stats != null else 100.0
	return base_hp * get_level_stat_multiplier(level_to_check)


func get_upgrade_cost(level_to_check: int = current_level) -> int:
	var base_cost: float = float(stats.cost if stats != null else 25)
	return roundi(base_cost * pow(Constants.PLANT_UPGRADE_COST_MULT, float(maxi(0, level_to_check - 1))))


## Penegakan Aturan R6: Mengembalikan false jika level tanaman >= level Rumah
func can_upgrade() -> bool:
	var house_lvl: int = 1
	if GameManager.has_method("get_current_house_level"):
		house_lvl = GameManager.get_current_house_level()
	elif "current_house_level" in GameManager:
		house_lvl = GameManager.current_house_level
		
	return current_level < house_lvl


func try_upgrade() -> bool:
	if not can_upgrade():
		push_warning("Aturan R6 Ditolak: Level tanaman tidak boleh melebihi Level Rumah!")
		return false
		
	var cost_to_upgrade: int = get_upgrade_cost()
	if not GameManager.spend_resource(cost_to_upgrade):
		push_warning("Upgrade gagal: Resource tidak cukup (butuh %d)." % cost_to_upgrade)
		return false
		
	var old_max_hp: float = health_component.max_hp
	current_level += 1
	var new_max_hp: float = get_level_scaled_max_hp(current_level)
	
	health_component.max_hp = new_max_hp
	health_component.heal(maxf(0.0, new_max_hp - old_max_hp))
	
	_on_level_upgraded(current_level)
	level_upgraded.emit(current_level)
	EventBus.plant_upgraded.emit(grid_cell, current_level)
	queue_redraw()
	return true


# --- SELEKSI KLIK & VISUALISASI HP BAR / LEVEL ---

func _on_hurtbox_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		set_selected(not is_selected)
		plant_selected.emit(self)


func set_selected(selected: bool) -> void:
	is_selected = selected
	queue_redraw()


func _draw() -> void:
	if is_selected:
		draw_arc(Vector2.ZERO, 20.0, 0.0, TAU, 32, Color(0.2, 1.0, 0.4, 0.9), 2.0)
		
	if health_component != null:
		var bar_w: float = 32.0
		var bar_h: float = 4.0
		var bar_pos := Vector2(-bar_w * 0.5, -34.0)
		var hp_ratio: float = clampf(health_component.current_hp / maxf(1.0, health_component.max_hp), 0.0, 1.0)
		
		draw_rect(Rect2(bar_pos, Vector2(bar_w, bar_h)), Color(0.1, 0.1, 0.1, 0.85), true)
		draw_rect(Rect2(bar_pos, Vector2(bar_w * hp_ratio, bar_h)), Color(0.2, 0.95, 0.3, 1.0), true)
		
		draw_string(
			ThemeDB.fallback_font,
			Vector2(-20, -38),
			"Lv.%d" % current_level,
			HORIZONTAL_ALIGNMENT_CENTER,
			40,
			10,
			Color(0.8, 1.0, 0.8, 1.0)
		)
