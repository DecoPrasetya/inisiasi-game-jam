class_name WaveSpawner
extends Node2D

const TILE_HALF_WIDTH: float = 32.0
const TILE_HALF_HEIGHT: float = 16.0

@export var spawn_radius: int = 7
@export var min_spawn_delay: float = 0.8
@export var max_spawn_delay: float = 2.5
@export var initial_pool_size: int = 25

@export var grid_reference: GridPlacementManager
@export var enemy_catalog: Array[EnemyStats] = []

@onready var enemy_container: Node2D = get_node_or_null("EnemyContainer")
@onready var spawn_timer: Timer = get_node_or_null("SpawnTimer")

## Gudang penyimpanan objek musuh yang sedang tidak aktif (Pool)
var _inactive_enemy_pool: Array[Node2D] = []
var _spawn_queue: Array[Dictionary] = []
var _is_spawning: bool = false


func _ready() -> void:
	if enemy_container == null:
		enemy_container = Node2D.new()
		enemy_container.name = "EnemyContainer"
		enemy_container.y_sort_enabled = true
		add_child(enemy_container)
		
	if spawn_timer == null:
		spawn_timer = Timer.new()
		spawn_timer.name = "SpawnTimer"
		add_child(spawn_timer)
		
	spawn_timer.one_shot = true
	if not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		
	if not EventBus.night_started.is_connected(_on_night_started):
		EventBus.night_started.connect(_on_night_started)
	if not EventBus.game_over.is_connected(_on_game_over):
		EventBus.game_over.connect(_on_game_over)
		
	# Inisialisasi awal Object Pooling di background
	_prewarm_enemy_pool(initial_pool_size)


# Sistem Enemy Pooling
func _prewarm_enemy_pool(count: int) -> void:
	for i in range(count):
		var enemy_inst := _create_new_enemy_instance()
		if enemy_inst != null:
			enemy_inst.visible = false
			enemy_inst.set_process(false)
			enemy_inst.set_physics_process(false)
			_inactive_enemy_pool.append(enemy_inst)


func _create_new_enemy_instance() -> Node2D:
	var fallback_stats: EnemyStats = enemy_catalog[0] if not enemy_catalog.is_empty() else null
	var inst: Node2D = null
	
	if fallback_stats != null and fallback_stats.scene != null:
		inst = fallback_stats.scene.instantiate() as Node2D
	else:
		inst = BaseEnemy.new()
		
	if not inst.has_method("setup_enemy"):
		inst.set_script(BaseEnemy)
		
	return inst


func _acquire_enemy_from_pool(data: EnemyStats) -> Node2D:
	var enemy_inst: Node2D = null
	
	if not _inactive_enemy_pool.is_empty():
		enemy_inst = _inactive_enemy_pool.pop_back()
	else:
		enemy_inst = _create_new_enemy_instance()
		
	if enemy_inst != null:
		# Masukkan ke tree jika belum menjadi anak dari enemy_container
		if enemy_inst.get_parent() == null:
			enemy_container.add_child(enemy_inst)
			
		enemy_inst.visible = true
		enemy_inst.set_process(true)
		enemy_inst.set_physics_process(true)
			
	return enemy_inst


func return_enemy_to_pool(enemy_node: Node2D) -> void:
	if enemy_node == null:
		return
		
	enemy_node.visible = false
	enemy_node.set_process(false)
	enemy_node.set_physics_process(false)
	enemy_node.global_position = Vector2(-9999, -9999)
	
	if enemy_node.get_parent() == enemy_container:
		enemy_container.remove_child(enemy_node)
		
	if not _inactive_enemy_pool.has(enemy_node):
		_inactive_enemy_pool.append(enemy_node)

func _on_enemy_returned_to_pool(enemy_node: Node2D) -> void:
	return_enemy_to_pool(enemy_node)

# Alur Spawning & Scaling
func calculate_total_enemies(day_number: int) -> int:
	return WaveData.calculate_total_enemies(day_number)


func calculate_hp_multiplier(day_number: int) -> float:
	return WaveData.calculate_hp_multiplier(day_number)


func get_spawn_grid_cell(side: Constants.SpawnSide) -> Vector2i:
	var offset: int = randi_range(-spawn_radius + 1, spawn_radius - 1)
	var cell: Vector2i
	
	match side:
		Constants.SpawnSide.NORTH_EAST:
			cell = Vector2i(offset, -spawn_radius)
		Constants.SpawnSide.SOUTH_EAST:
			cell = Vector2i(spawn_radius, offset)
		Constants.SpawnSide.SOUTH_WEST:
			cell = Vector2i(offset, spawn_radius)
		Constants.SpawnSide.NORTH_WEST:
			cell = Vector2i(-spawn_radius, offset)
		_:
			cell = Vector2i(0, -spawn_radius)
	return cell


func grid_to_world(cell: Vector2i) -> Vector2:
	if grid_reference != null:
		return grid_reference.to_global(grid_reference.grid_to_world(cell))
	var wx: float = (cell.x - cell.y) * TILE_HALF_WIDTH
	var wy: float = (cell.x + cell.y) * TILE_HALF_HEIGHT
	return to_global(Vector2(wx, wy))


func _on_night_started(day_number: int) -> void:
	start_wave_for_day(day_number)


func start_wave_for_day(day_number: int) -> void:
	stop_spawning()
	
	var total_enemies: int = calculate_total_enemies(day_number)
	var hp_mult: float = calculate_hp_multiplier(day_number)
	
	if enemy_catalog.is_empty():
		enemy_catalog.append(_create_default_enemy_stats())
		
	var sides: Array[Constants.SpawnSide] = [
		Constants.SpawnSide.NORTH_EAST,
		Constants.SpawnSide.SOUTH_EAST,
		Constants.SpawnSide.SOUTH_WEST,
		Constants.SpawnSide.NORTH_WEST
	]
	
	for i in range(total_enemies):
		var side: Constants.SpawnSide = sides[i % sides.size()]
		var chosen_stats: EnemyStats = enemy_catalog[i % enemy_catalog.size()]
		_spawn_queue.append({
			"stats": chosen_stats,
			"side": side,
			"hp_multiplier": hp_mult
		})
		
	_is_spawning = true
	EventBus.wave_spawn_started.emit(day_number, total_enemies)
	_spawn_next_in_queue()


func stop_spawning() -> void:
	_is_spawning = false
	_spawn_queue.clear()
	if spawn_timer != null:
		spawn_timer.stop()


func _spawn_next_in_queue() -> void:
	if not _is_spawning or _spawn_queue.is_empty():
		_is_spawning = false
		return
		
	var entry: Dictionary = _spawn_queue.pop_front()
	_instantiate_enemy(entry["stats"], entry["side"], entry["hp_multiplier"])
	
	if not _spawn_queue.is_empty():
		var next_delay: float = randf_range(min_spawn_delay, max_spawn_delay)
		spawn_timer.start(next_delay)
	else:
		_is_spawning = false


func _on_spawn_timer_timeout() -> void:
	_spawn_next_in_queue()


func _instantiate_enemy(data: EnemyStats, side: Constants.SpawnSide, hp_mult: float) -> void:
	var spawn_cell: Vector2i = get_spawn_grid_cell(side)
	var world_pos: Vector2 = grid_to_world(spawn_cell)
	var center_pos: Vector2 = grid_to_world(Vector2i.ZERO)
	
	# Ambil musuh dari pool
	var enemy_inst: Node2D = _acquire_enemy_from_pool(data)
	if enemy_inst == null:
		return
		
	enemy_inst.global_position = world_pos
	
	if enemy_inst.has_method("setup_enemy"):
		enemy_inst.setup_enemy(data, hp_mult, side, center_pos)
		
	EventBus.enemy_spawned.emit(enemy_inst, side)


func _on_game_over(_days: int) -> void:
	stop_spawning()


func _create_default_enemy_stats() -> EnemyStats:
	var fallback := EnemyStats.new()
	fallback.id = &"katak_penyembur"
	fallback.display_name = "Katak Penyembur"
	fallback.base_max_hp = 50.0
	fallback.move_speed = 40.0
	fallback.reward_amount = 15
	if ResourceLoader.exists("res://assets/entities/enemies/katak_penyembur/katak_penyembur_hop.png"):
		fallback.texture = load("res://assets/entities/enemies/katak_penyembur/katak_penyembur_hop.png")
	return fallback
	
