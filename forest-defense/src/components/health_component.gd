class_name HealthComponent
extends Node

signal health_changed(current_hp: float, max_hp: float)
signal damage_taken(amount: float, source_node: Node)
signal healed(amount: float)
signal died()

@export var max_hp: float = 100.0
@export var is_enemy_entity: bool = false

var current_hp: float = 100.0
var is_dead: bool = false


func _ready() -> void:
	current_hp = max_hp


func initialize(new_max_hp: float, enemy_flag: bool = is_enemy_entity) -> void:
	max_hp = maxf(1.0, new_max_hp)
	current_hp = max_hp
	is_dead = false
	is_enemy_entity = enemy_flag
	health_changed.emit(current_hp, max_hp)


## source_role: isi dengan Constants.PlantRole jika serangan berasal dari Tanaman,
## atau biarkan -1 jika serangan berasal dari Musuh / Environment.
func take_damage(amount: float, source_role: int = -1, source_node: Node = null) -> bool:
	if is_dead or amount <= 0.0:
		return false
		
	# Hanya tanaman dengan role DAMAGE_DEALER yang boleh mengurangi HP musuh
	if is_enemy_entity and source_role != -1:
		var is_valid_attacker: bool = (source_role == Constants.PlantRole.DAMAGE_DEALER)
		assert(
			is_valid_attacker,
			"Pelanggaran Aturan R2: Tanaman non-Damage Dealer dilarang memberi damage ke musuh!"
		)
		if not is_valid_attacker:
			push_error("Aturan R2 Diblokir: Role %d mencoba memberi damage ke musuh." % source_role)
			return false
			
	current_hp = maxf(0.0, current_hp - amount)
	damage_taken.emit(amount, source_node)
	health_changed.emit(current_hp, max_hp)
	
	if current_hp <= 0.0:
		is_dead = true
		died.emit()
		
	return true


func heal(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return
		
	current_hp = minf(max_hp, current_hp + amount)
	healed.emit(amount)
	health_changed.emit(current_hp, max_hp)
