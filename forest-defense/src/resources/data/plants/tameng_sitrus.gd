class_name TamengSitrus
extends BasePlant

@export_group("Defender Parameters (Aturan R4)")
@export var applied_cc_type: Constants.CrowdControlType = Constants.CrowdControlType.SLOW
@export var cc_duration: float = 3.0
@export var slow_percent_modifier: float = -0.35

@export_group("Active Skill: Aggro / Taunt")
@export var taunt_radius: float = 160.0
@export var taunt_duration: float = 5.0
@export var taunt_cooldown: float = 8.0

var is_taunt_active: bool = false
var _skill_timer: float = 0.0

func _on_plant_configured() -> void:
	if stats != null:
		stats.role = Constants.PlantRole.DEFENDER
		if stats.attack_range <= 0.0:
			stats.attack_range = taunt_radius
	is_taunt_active = false
	# Mulai malam langsung siap mengaktifkan skill dalam 1 detik
	_skill_timer = 1.0
	_setup_detection_area(Constants.LAYER_ENEMIES)

func _process_night_behavior(delta: float) -> void:
	_skill_timer -= delta
	
	if is_taunt_active:
		# Selama skill aktif, tarik semua musuh di sekitar ke tanaman ini
		_apply_taunt_to_nearby_enemies()
		if _skill_timer <= 0.0:
			is_taunt_active = false
			_skill_timer = taunt_cooldown
	else:
		# Saat cooldown selesai, aktifkan skill jika ada musuh di jangkauan
		if _skill_timer <= 0.0:
			if _has_enemies_in_taunt_range():
				activate_aggro_skill()
			else:
				_skill_timer = 0.2 # Cek ulang tiap 0.2 detik hingga ada musuh mendekat
				
	queue_redraw()


func activate_aggro_skill() -> void:
	is_taunt_active = true
	_skill_timer = taunt_duration
	play_animation(&"attack")
	_apply_taunt_to_nearby_enemies()
	queue_redraw()


func _has_enemies_in_taunt_range() -> bool:
	var radius: float = get_final_stat(&"attack_range", taunt_radius)
	if radius <= 0.0:
		radius = taunt_radius
	var max_dist_sq: float = radius * radius
	
	for node in get_tree().get_nodes_in_group("enemies"):
		var en: Node2D = node as Node2D
		if en != null and is_instance_valid(en) and en.visible and not ("_is_dead" in en and en._is_dead):
			if global_position.distance_squared_to(en.global_position) <= max_dist_sq:
				return true
	return false


func _apply_taunt_to_nearby_enemies() -> void:
	var radius: float = get_final_stat(&"attack_range", taunt_radius)
	if radius <= 0.0:
		radius = taunt_radius
	var max_dist_sq: float = radius * radius
	
	for node in get_tree().get_nodes_in_group("enemies"):
		var en: Node2D = node as Node2D
		if en == null or not is_instance_valid(en) or not en.visible:
			continue
		if "_is_dead" in en and en._is_dead:
			continue
			
		if global_position.distance_squared_to(en.global_position) <= max_dist_sq:
			# Set target paksa pada musuh
			if en.has_method("set_taunt_target"):
				en.set_taunt_target(self)
				
			# Kirim status TAUNT resmi ke StatusEffectReceiver (Aturan R4)
			var enemy_receiver: StatusEffectReceiver = en.get_node_or_null("StatusEffectReceiver")
			if enemy_receiver != null:
				var taunt_eff := EffectData.new()
				taunt_eff.effect_id = &"defender_taunt"
				taunt_eff.effect_kind = Constants.EffectKind.CROWD_CONTROL
				taunt_eff.cc_type = Constants.CrowdControlType.TAUNT
				taunt_eff.duration = 0.5
				enemy_receiver.apply_effect(taunt_eff, Constants.PlantRole.DEFENDER)

## Dipanggil otomatis oleh BasePlant.take_damage saat tanaman diserang
func _on_damaged_by_enemy(_amount: float, source_node: Node) -> void:
	if source_node != null and is_instance_valid(source_node):
		_retaliate_with_crowd_control(source_node)


func _retaliate_with_crowd_control(enemy_node: Node) -> void:
	var enemy_status_receiver: StatusEffectReceiver = enemy_node.get_node_or_null("StatusEffectReceiver")
	if enemy_status_receiver == null:
		return
		
	if stats != null and not stats.applied_effects.is_empty():
		for eff in stats.applied_effects:
			if eff != null and eff.effect_kind == Constants.EffectKind.CROWD_CONTROL:
				enemy_status_receiver.apply_effect(eff, Constants.PlantRole.DEFENDER)
		return
		
	var cc_effect := EffectData.new()
	cc_effect.effect_id = &"tameng_sitrus_cc"
	cc_effect.effect_kind = Constants.EffectKind.CROWD_CONTROL
	cc_effect.cc_type = applied_cc_type
	cc_effect.duration = cc_duration
	
	if applied_cc_type == Constants.CrowdControlType.SLOW:
		cc_effect.target_stat = &"move_speed"
		cc_effect.percent_modifier = slow_percent_modifier
		
	enemy_status_receiver.apply_effect(cc_effect, Constants.PlantRole.DEFENDER)


func _draw() -> void:
	var radius: float = get_final_stat(&"attack_range", taunt_radius)
	if radius <= 0.0:
		radius = taunt_radius
		
	# 1. Gambar Aura Aggro saat Skill Aktif
	if is_taunt_active:
		draw_circle(Vector2.ZERO, radius, Color(1.0, 0.55, 0.1, 0.10))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(1.0, 0.65, 0.1, 0.75), 2.0)
	else:
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(1.0, 0.8, 0.2, 0.2), 1.0)
		
	draw_circle(Vector2.ZERO, 12.0, Color(0.95, 0.65, 0.1, 0.5))
	draw_arc(Vector2.ZERO, 12.0, 0.0, TAU, 32, Color(1.0, 0.8, 0.2, 0.9), 2.0)
	
	# Panggil super._draw() untuk menggambar HP Bar & teks Level bawaan BasePlant
	super._draw()
	
	# 2. Gambar BAR SKILL AKTIF tepat di bawah HP Bar (di atas tanaman)
	var bar_w: float = 32.0
	var bar_h: float = 4.0
	var skill_bar_pos := Vector2(-bar_w * 0.5, -28.0) # HP Bar ada di Y = -34.0
	
	var fill_ratio: float = 0.0
	var bar_color := Color(0.2, 0.85, 1.0, 1.0) # Biru Cyan saat mengisi Cooldown / Siap
	
	if is_taunt_active:
		# Saat aktif: bar berkurang dari penuh ke habis (Warna Oranye Terang)
		fill_ratio = clampf(_skill_timer / maxf(0.1, taunt_duration), 0.0, 1.0)
		bar_color = Color(1.0, 0.6, 0.1, 1.0)
	else:
		# Saat cooldown: bar terisi dari 0 ke penuh
		fill_ratio = clampf(1.0 - (_skill_timer / maxf(0.1, taunt_cooldown)), 0.0, 1.0)
		
	draw_rect(Rect2(skill_bar_pos, Vector2(bar_w, bar_h)), Color(0.1, 0.1, 0.1, 0.85), true)
	draw_rect(Rect2(skill_bar_pos, Vector2(bar_w * fill_ratio, bar_h)), bar_color, true)
