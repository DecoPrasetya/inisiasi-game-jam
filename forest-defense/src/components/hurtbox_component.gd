class_name HurtboxComponent
extends Area2D

signal hit_received(hitbox: HitboxComponent)

@export var health_component: HealthComponent
@export var status_receiver: StatusEffectReceiver

var owner_entity: Node = null


func _ready() -> void:
	owner_entity = get_parent()
	monitoring = false
	monitorable = true
	
	# Cari otomatis di sibling node jika belum di-assign lewat Inspector
	if health_component == null and owner_entity != null:
		health_component = owner_entity.get_node_or_null("HealthComponent")
	if status_receiver == null and owner_entity != null:
		status_receiver = owner_entity.get_node_or_null("StatusEffectReceiver")


func configure_collision_layer(own_layer: int) -> void:
	collision_layer = 0
	collision_mask = 0
	if own_layer >= 1 and own_layer <= 32:
		set_collision_layer_value(own_layer, true)

# fungsi yang mengatur efek saat terkena hit
func receive_hit(hitbox: HitboxComponent) -> void:
	if hitbox == null:
		return
		
	# damage ke HealthComponent (Hanya jika damage > 0)
	if health_component != null and hitbox.damage > 0.0:
		#var hp_comp = health_component as HealthComponent
		#if hp_comp != null and hp_comp.has_method("take_damage"):
			#hp_comp.take_damage(hitbox.damage, hitbox.source_role, hitbox.owner_entity)
		health_component.take_damage(hitbox.damage, hitbox.source_role, hitbox.owner_entity)
		
	# efek status / CC ke StatusEffectReceiver
	if status_receiver != null and not hitbox.applied_effects.is_empty():
		#var status_rec = status_receiver as StatusEffectReceiver
		#if status_rec != null and status_rec.has_method("apply_effect"):
			#for effect in hitbox.applied_effects:
				#if effect != null:
					#status_rec.apply_effect(effect, hitbox.source_role)
		for effect in hitbox.applied_effects:
			if effect != null:
				status_receiver.apply_effect(effect, hitbox.source_role)
				
	hit_received.emit(hitbox)
