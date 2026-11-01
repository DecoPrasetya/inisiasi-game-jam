class_name BaseEnemy
extends Node2D

@export var stats: EnemyStats

var spawn_side: Constants.SpawnSide = Constants.SpawnSide.NORTH_EAST
var hp_multiplier: float = 1.0
var target_position: Vector2 = Vector2.ZERO
var current_target_node: Node2D = null
var _attack_timer: float = 0.0
var _is_dead: bool = false

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")


func _ready() -> void:
	if stats != null:
		setup_enemy(stats, hp_multiplier, spawn_side, target_position)
		
	


func setup_enemy(
	enemy_data: EnemyStats,
	multiplier: float = 1.0,
	side: Constants.SpawnSide = Constants.SpawnSide.NORTH_EAST,
	center_world_pos: Vector2 = Vector2.ZERO
) -> void:
	stats = enemy_data
	hp_multiplier = multiplier
	spawn_side = side
	target_position = center_world_pos
	_is_dead = false # Reset status hidup
	
	if sprite == null:
		sprite = get_node_or_null("Sprite2D")
		if sprite == null:
			sprite = Sprite2D.new()
			sprite.name = "Sprite2D"
			add_child(sprite)

	# Muat tekstur dengan aman
	if stats != null and stats.texture != null:
		sprite.texture = stats.texture
	elif ResourceLoader.exists("res://assets/entities/enemies/katak_penyembur/katak_penyembur_hop.png"):
		sprite.texture = load("res://assets/entities/enemies/katak_penyembur/katak_penyembur_hop.png")
		
	if sprite.texture != null:
		var tex_w: int = sprite.texture.get_width()
		var tex_h: int = sprite.texture.get_height()
		if tex_h > 0 and tex_w >= tex_h * 2:
			sprite.hframes = maxi(1, int(round(float(tex_w) / float(tex_h))))
			sprite.vframes = 1
			sprite.frame = 0
			
		sprite.scale = Vector2(0.05, 0.05) 
		
		sprite.offset = Vector2(0, -24)
		
	
	visible = true
	queue_redraw()
	


func _physics_process(delta: float) -> void:
	if _is_dead or GameManager.current_phase != Constants.GamePhase.NIGHT:
		return
		
	var move_spd: float = stats.move_speed if stats != null else 35.0
	var atk_range: float = stats.attack_range if stats != null else 28.0
	var dist_to_center: float = global_position.distance_to(target_position)
	
	# Bergerak menuju pusat Rumah (0,0) jika belum masuk jarak serang
	if dist_to_center > atk_range:
		var dir: Vector2 = (target_position - global_position).normalized()
		global_position += dir * move_spd * delta
		if sprite != null and abs(dir.x) > 0.05:
			sprite.flip_h = dir.x < 0.0
	else:
		# Menyerang saat mencapai pusat/target
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_attack_timer = stats.attack_cooldown if stats != null else 1.2
			_perform_attack()


func _perform_attack() -> void:
	if current_target_node != null and is_instance_valid(current_target_node):
		if current_target_node.has_method("take_damage"):
			current_target_node.take_damage(stats.attack_damage if stats != null else 10.0)


func take_damage() -> void:
	if _is_dead:
		return
	die()


func die() -> void:
	_on_died()


func _on_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	
	var reward: int = stats.reward_amount if stats != null else 10
	var enemy_id: StringName = stats.id if stats != null else &"enemy"
	
	GameManager.add_resource(reward)
	EventBus.enemy_killed.emit(reward, enemy_id, global_position)
	
	# KEMBALIKAN KE POOL
	var spawner := get_tree().get_first_node_in_group("wave_spawner")
	if spawner != null and spawner.has_method("return_enemy_to_pool"):
		spawner.return_enemy_to_pool(self)
	else:
		queue_free()
