class_name AnggrekParamedis
extends BasePlant

@export_group("Supporter Parameters (Aturan R3)")
@export var buff_duration: float = 4.0
@export var buff_attack_percent: float = 0.20

var _support_cooldown_timer: float = 0.0


func _on_plant_configured() -> void:
	if stats != null:
		stats.role = Constants.PlantRole.SUPPORTER
	# Deteksi diarahkan ke layer tanaman kawan
	_setup_detection_area(Constants.LAYER_PLANTS)


func _process_night_behavior(delta: float) -> void:
	_support_cooldown_timer -= delta
	if _support_cooldown_timer > 0.0:
		return
		
	var action_speed: float = maxf(0.1, get_final_stat(&"attack_speed", 0.5))
	_support_cooldown_timer = 1.0 / action_speed
	_perform_support_pulse()


func _perform_support_pulse() -> void:
	var range_px: float = get_final_stat(&"attack_range", 180.0)
	var range_sq: float = range_px * range_px
	var heal_amount: float = get_final_stat(&"support_power", 15.0)
	
	play_animation(&"attack")
	
	for node in get_tree().get_nodes_in_group("plants"):
		var ally: BasePlant = node as BasePlant
		if ally == null or not is_instance_valid(ally) or ally._is_dying:
			continue
		if global_position.distance_squared_to(ally.global_position) > range_sq:
			continue
			
		# 1. Pulihkan HP tanaman rekan di dalam jangkauan
		if ally.health_component != null and ally.health_component.current_hp < ally.health_component.max_hp:
			ally.health_component.heal(heal_amount)
			
		# 2. Berikan Buff (Aturan R3: Hanya SUPPORTER yang diizinkan memberi BUFF/DEBUFF)
		if ally != self and ally.status_receiver != null:
			_apply_supporter_buff(ally.status_receiver)


func _apply_supporter_buff(target_receiver: StatusEffectReceiver) -> void:
	if stats != null and not stats.applied_effects.is_empty():
		for eff in stats.applied_effects:
			if eff != null and eff.effect_kind == Constants.EffectKind.BUFF:
				target_receiver.apply_effect(eff, Constants.PlantRole.SUPPORTER)
		return
		
	var buff := EffectData.new()
	buff.effect_id = &"anggrek_paramedis_buff"
	buff.effect_kind = Constants.EffectKind.BUFF
	buff.target_stat = &"attack_damage"
	buff.percent_modifier = buff_attack_percent
	buff.duration = buff_duration
	buff.max_stacks = 1
	target_receiver.apply_effect(buff, Constants.PlantRole.SUPPORTER)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 10.0, Color(0.9, 0.3, 0.8, 0.45))
	draw_arc(Vector2.ZERO, get_final_stat(&"attack_range", 180.0), 0.0, TAU, 48, Color(0.95, 0.4, 0.85, 0.25), 1.0)
	super._draw()
