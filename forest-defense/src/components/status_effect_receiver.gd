class_name StatusEffectReceiver
extends Node

signal effect_applied(effect: EffectData)
signal effect_expired(effect: EffectData)
signal crowd_control_changed(active_cc_types: Array[Constants.CrowdControlType])
signal stats_recalculated()

@export var can_receive_debuff: bool = true
@export var can_receive_crowd_control: bool = true

# Daftar efek aktif: Array of Dictionary { "data": EffectData, "remaining_time": float }
var active_effects: Array[Dictionary] = []


func _process(delta: float) -> void:
	if active_effects.is_empty():
		return
		
	var any_expired: bool = false
	for i in range(active_effects.size() - 1, -1, -1):
		active_effects[i]["remaining_time"] -= delta
		if active_effects[i]["remaining_time"] <= 0.0:
			var expired_data: EffectData = active_effects[i]["data"]
			active_effects.remove_at(i)
			effect_expired.emit(expired_data)
			any_expired = true
			
	if any_expired:
		_notify_state_updated()


## Menerapkan efek baru dengan validasi ketat Aturan R3, R4, dan R5
func apply_effect(effect: EffectData, source_role: int) -> bool:
	if effect == null:
		return false
		
	match effect.effect_kind:
		Constants.EffectKind.BUFF:
			# Hanya SUPPORTER yang boleh memberikan Buff
			if source_role != Constants.PlantRole.SUPPORTER:
				push_warning("Aturan R3 Ditolak: Hanya SUPPORTER yang boleh memberi BUFF.")
				return false
				
		Constants.EffectKind.DEBUFF:
			# Tolak debuff jika can_receive_debuff == false
			if not can_receive_debuff:
				return false
			# Hanya SUPPORTER yang boleh memberikan Debuff
			if source_role != Constants.PlantRole.SUPPORTER:
				push_warning("Aturan R3 Ditolak: Hanya SUPPORTER yang boleh memberi DEBUFF.")
				return false
				
		Constants.EffectKind.CROWD_CONTROL:
			# Hanya DEFENDER yang boleh memberikan CC
			if source_role != Constants.PlantRole.DEFENDER:
				push_warning("Aturan R4 Ditolak: Hanya DEFENDER yang boleh memberi CROWD_CONTROL.")
				return false
			if not can_receive_crowd_control:
				return false
				
	# Cek batas tumpukan (max_stacks) untuk effect_id yang sama
	if effect.effect_id != &"":
		var current_stacks: int = 0
		for entry in active_effects:
			var existing: EffectData = entry["data"]
			if existing.effect_id == effect.effect_id:
				current_stacks += 1
				if current_stacks >= maxi(1, effect.max_stacks):
					# Segarkan durasi jika sudah mencapai batas tumpukan
					entry["remaining_time"] = maxf(entry["remaining_time"], effect.duration)
					_notify_state_updated()
					return true
					
	active_effects.append({
		"data": effect,
		"remaining_time": effect.duration
	})
	effect_applied.emit(effect)
	_notify_state_updated()
	return true


## Formula Final = (Base + Sum(Flat)) * (1.0 + Sum(Percent))
func calculate_final_stat(base_value: float, stat_name: StringName = &"") -> float:
	var sum_flat: float = 0.0
	var sum_percent: float = 0.0
	
	for entry in active_effects:
		var eff: EffectData = entry["data"]
		if eff.effect_kind == Constants.EffectKind.BUFF or eff.effect_kind == Constants.EffectKind.DEBUFF:
			if stat_name == &"" or eff.target_stat == stat_name:
				sum_flat += eff.flat_modifier
				sum_percent += eff.percent_modifier
				
	return (base_value + sum_flat) * (1.0 + sum_percent)


## Helper statis jika ingin menguji formula langsung dengan daftar EffectData
static func compute_stat_formula(base_value: float, flat_bonuses: Array[float], percent_bonuses: Array[float]) -> float:
	var total_flat: float = 0.0
	for f in flat_bonuses:
		total_flat += f
	var total_pct: float = 0.0
	for p in percent_bonuses:
		total_pct += p
	return (base_value + total_flat) * (1.0 + total_pct)


func has_crowd_control(cc_type: Constants.CrowdControlType) -> bool:
	for entry in active_effects:
		var eff: EffectData = entry["data"]
		if eff.effect_kind == Constants.EffectKind.CROWD_CONTROL and eff.cc_type == cc_type:
			return true
	return false


func clear_all_effects() -> void:
	active_effects.clear()
	_notify_state_updated()


func _notify_state_updated() -> void:
	var active_ccs: Array[Constants.CrowdControlType] = []
	for entry in active_effects:
		var eff: EffectData = entry["data"]
		if eff.effect_kind == Constants.EffectKind.CROWD_CONTROL and not active_ccs.has(eff.cc_type):
			active_ccs.append(eff.cc_type)
	crowd_control_changed.emit(active_ccs)
	stats_recalculated.emit()
