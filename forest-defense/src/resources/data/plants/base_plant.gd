class_name BasePlant
extends Node2D

signal plant_died()

@export var stats: PlantStats

var grid_cell: Vector2i = Vector2i.ZERO
var current_level: int = 1

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var health_component: HealthComponent = get_node_or_null("HealthComponent")
@onready var status_receiver: StatusEffectReceiver = get_node_or_null("StatusEffectReceiver")
@onready var hurtbox_component: HurtboxComponent = get_node_or_null("HurtboxComponent")


func _ready() -> void:
	_ensure_combat_components()
	if stats != null:
		setup_from_stats(stats, grid_cell)


func _ensure_combat_components() -> void:
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)
		
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
		status_receiver = StatusEffectReceiver.new()
		status_receiver.name = "StatusEffectReceiver"
		add_child(status_receiver)
	status_receiver.can_receive_debuff = true
	status_receiver.can_receive_crowd_control = false
	
	if hurtbox_component == null:
		hurtbox_component = HurtboxComponent.new()
		hurtbox_component.name = "HurtboxComponent"
		var col := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 18.0
		col.shape = circle
		hurtbox_component.add_child(col)
		add_child(hurtbox_component)
	hurtbox_component.health_component = health_component
	hurtbox_component.status_receiver = status_receiver
	hurtbox_component.configure_collision_layer(Constants.LAYER_PLANTS)


func setup_from_stats(plant_data: PlantStats, cell: Vector2i = Vector2i.ZERO) -> void:
	stats = plant_data
	grid_cell = cell
	_ensure_combat_components()
	
	if sprite != null and stats != null and stats.preview_texture != null and sprite.texture == null:
		sprite.texture = stats.preview_texture
		
	var base_hp: float = stats.max_hp if stats != null else 100.0
	health_component.initialize(base_hp, false)
	status_receiver.clear_all_effects()


## Mengambil nilai stat akhir setelah dihitung dengan rumus TRD-005: (Base + Flat) * (1 + Percent)
func get_final_stat(stat_name: StringName, default_base: float = 0.0) -> float:
	var base_val: float = default_base
	if stats != null and stat_name in stats:
		base_val = float(stats.get(stat_name))
	if status_receiver != null:
		return status_receiver.calculate_final_stat(base_val, stat_name)
	return base_val


func take_damage(amount: float, source_role: int = -1, source_node: Node = null) -> void:
	if health_component != null:
		health_component.take_damage(amount, source_role, source_node)
	else:
		die()


func die() -> void:
	_on_died()


func _on_health_changed(current_hp: float, max_hp: float) -> void:
	EventBus.plant_health_changed.emit(grid_cell, current_hp, max_hp)


func _on_died() -> void:
	plant_died.emit()
	queue_free()
