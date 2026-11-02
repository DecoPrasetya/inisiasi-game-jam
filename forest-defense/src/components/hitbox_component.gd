class_name HitboxComponent
extends Area2D

signal hit_landed(hurtbox: Area2D)

@export var damage: float = 10.0
# ubah -1 jika pemilik Hitbox adalah Musuh 
# isi dengan Constants.PlantRole jika Tanaman
@export var source_role: int = -1
@export var applied_effects: Array[EffectData] = []

var owner_entity: Node = null


func _ready() -> void:
	owner_entity = get_parent()
	monitoring = true
	monitorable = true
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)


# Mengatur Collision Layer & Mask secara aman menggunakan nomor layer dari Constants.gd (1..32)
func configure_collision_layers(own_layer: int, target_masks: Array[int]) -> void:
	collision_layer = 0
	collision_mask = 0
	if own_layer >= 1 and own_layer <= 32:
		set_collision_layer_value(own_layer, true)
	for m in target_masks:
		if m >= 1 and m <= 32:
			set_collision_mask_value(m, true)


func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area as HurtboxComponent
		if hurtbox.owner_entity == owner_entity and owner_entity != null:
			return
		hurtbox.receive_hit(self)
		hit_landed.emit(hurtbox)
