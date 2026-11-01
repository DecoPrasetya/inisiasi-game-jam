class_name GridPlacementManager
extends Node2D

const TILE_HALF_WIDTH: float = 32.0
const TILE_HALF_HEIGHT: float = 16.0
@export_group("Ukuran Grid Belah Ketupat")
@export_range(2, 20, 1) var grid_radius_x: int = 5:
	set(value):
		grid_radius_x = value
		queue_redraw()

@export_range(2, 20, 1) var grid_radius_y: int = 5:
	set(value):
		grid_radius_y = value
		queue_redraw()

## Radius area terlarang Rumah di pusat (1 = 3x3 petak: -1, 0, 1)
@export_range(0, 5, 1) var house_footprint_radius: int = 1:
	set(value):
		house_footprint_radius = value
		queue_redraw()

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var plant_container: Node2D = $PlantContainer
@onready var selection_highlight: Polygon2D = $SelectionHighlight
@onready var ghost_preview: Sprite2D = $GhostPreview
@onready var range_indicator: Line2D = $GhostPreview/RangeIndicator

# penyimpanan tanaman aktif
var occupied_plots: Dictionary = {}
var active_selected_plant_data: PlantStats = null
var current_hovered_cell: Vector2i = Vector2i(999, 999)

# mode shovel
var is_shovel_mode_active: bool = false

# Daftar katalog PlantStats agar bisa dipanggil lewat plant_id dari EventBus
@export var plant_catalog: Array[PlantStats] = []
@export var show_debug_grid: bool = true:
	set(value):
		show_debug_grid = value
		queue_redraw()

func _ready() -> void:
	ghost_preview.visible = false
	selection_highlight.visible = false
	queue_redraw()
	
	if EventBus.has_signal("plant_placement_requested"):
		EventBus.plant_placement_requested.connect(_on_placement_requested)


func _unhandled_input(event: InputEvent) -> void:
	# MODE SEKOP AKTIF
	if is_shovel_mode_active:
		if event is InputEventMouseMotion:
			_update_shovel_cursor(get_global_mouse_position())
		elif event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				var clicked_cell: Vector2i = world_to_grid(to_local(get_global_mouse_position()))
				if is_cell_occupied(clicked_cell):
					remove_plant_at_cell(clicked_cell)
					cancel_placement()
				get_viewport().set_input_as_handled()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				cancel_placement()
				get_viewport().set_input_as_handled()
		return
		
	# IDLE
	if active_selected_plant_data == null:
		return
		
	# MODE MENANAM AKTIF
	if event is InputEventMouseMotion:
		_update_ghost_position(get_global_mouse_position())
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_attempt_place_at_hovered_cell()
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_placement()
			get_viewport().set_input_as_handled()


# Pemilihan, Pembatalan Mode Penanaman dan Sekop
func toggle_shovel_mode(enable: bool = not is_shovel_mode_active) -> void:
	active_selected_plant_data = null
	ghost_preview.visible = false
	is_shovel_mode_active = enable
	
	if is_shovel_mode_active:
		selection_highlight.visible = true
		_update_shovel_cursor(get_global_mouse_position())
	else:
		selection_highlight.visible = false


func select_plant_for_placement(plant_data: PlantStats) -> void:
	if plant_data == null:
		return
	is_shovel_mode_active = false
	active_selected_plant_data = plant_data
	
	if "preview_texture" in plant_data and plant_data.preview_texture != null:
		ghost_preview.texture = plant_data.preview_texture
	elif "icon" in plant_data and plant_data.icon != null:
		ghost_preview.texture = plant_data.icon
		
	var attack_range: float = 0.0
	if "attack_range" in plant_data:
		attack_range = plant_data.attack_range
	elif "range" in plant_data:
		attack_range = plant_data.range
	_draw_range_circle(attack_range)
	
	ghost_preview.visible = true
	selection_highlight.visible = true
	_update_ghost_position(get_global_mouse_position())


func cancel_placement() -> void:
	active_selected_plant_data = null
	is_shovel_mode_active = false
	ghost_preview.visible = false
	selection_highlight.visible = false
	current_hovered_cell = Vector2i(999, 999)


func _update_shovel_cursor(global_mouse_pos: Vector2) -> void:
	var local_mouse: Vector2 = to_local(global_mouse_pos)
	current_hovered_cell = world_to_grid(local_mouse)
	selection_highlight.position = grid_to_world(current_hovered_cell)
	
	if is_cell_occupied(current_hovered_cell):
		selection_highlight.color = Color(1.0, 0.45, 0.0, 0.55)
	else:
		selection_highlight.color = Color(0.7, 0.7, 0.7, 0.2)


# Konversi Koordinat Isometrik 2:1 
func grid_to_world(cell: Vector2i) -> Vector2:
	var wx: float = (cell.x - cell.y) * TILE_HALF_WIDTH
	var wy: float = (cell.x + cell.y) * TILE_HALF_HEIGHT
	return Vector2(wx, wy)


func world_to_grid(world_pos: Vector2) -> Vector2i:
	var gx: float = (world_pos.x / TILE_HALF_WIDTH + world_pos.y / TILE_HALF_HEIGHT) / 2.0
	var gy: float = (world_pos.y / TILE_HALF_HEIGHT - world_pos.x / TILE_HALF_WIDTH) / 2.0
	return Vector2i(roundi(gx), roundi(gy))


# Validasi Matematis & Aturan Game 
func is_within_diamond_bounds(cell: Vector2i) -> bool:
	return abs(cell.x) <= grid_radius_x and abs(cell.y) <= grid_radius_y


func is_house_footprint(cell: Vector2i) -> bool:
	# Area merah (rumah) di pusat
	return abs(cell.x) <= house_footprint_radius and abs(cell.y) <= house_footprint_radius


func is_cell_occupied(cell: Vector2i) -> bool:
	return occupied_plots.has(cell) and is_instance_valid(occupied_plots[cell])


func is_cell_valid_for_planting(cell: Vector2i) -> bool:
	# Cek batas diamond 11x11 (|x| + |y| <= 5)
	if not is_within_diamond_bounds(cell):
		return false
		
	# Cek area terlarang Rumah 3x3 di pusat ([-1..1, -1..1])
	if is_house_footprint(cell):
		return false
		
	# Cek apakah plot sudah terisi tanaman lain
	if is_cell_occupied(cell):
		return false
		
	# Aturan - Jumlah tanaman <= Space Tanaman Rumah
	var current_plant_count: int = occupied_plots.size()
	var house_space_limit: int = GameManager.get_current_house_space()
	if current_plant_count >= house_space_limit:
		return false
		
	return true


# Visualisasi Kursor & Eksekusi Penanaman
func _update_ghost_position(global_mouse_pos: Vector2) -> void:
	var local_mouse: Vector2 = to_local(global_mouse_pos)
	current_hovered_cell = world_to_grid(local_mouse)
	
	var snapped_world_pos: Vector2 = grid_to_world(current_hovered_cell)
	ghost_preview.position = snapped_world_pos
	selection_highlight.position = snapped_world_pos
	
	var is_valid_cell: bool = is_cell_valid_for_planting(current_hovered_cell)
	var can_afford: bool = true
	if active_selected_plant_data != null and "cost" in active_selected_plant_data:
		can_afford = GameManager.has_enough_resource(active_selected_plant_data.cost)
		
	if is_valid_cell and can_afford:
		ghost_preview.modulate = Color(0.2, 1.0, 0.2, 0.6) # Hijau = Valid
		selection_highlight.color = Color(0.2, 1.0, 0.2, 0.35)
	else:
		ghost_preview.modulate = Color(1.0, 0.2, 0.2, 0.6) # Merah = Invalid
		selection_highlight.color = Color(1.0, 0.2, 0.2, 0.35)


func _attempt_place_at_hovered_cell() -> void:
	if active_selected_plant_data == null:
		return
		
	if not is_cell_valid_for_planting(current_hovered_cell):
		return
		
	var plant_cost: int = active_selected_plant_data.cost if "cost" in active_selected_plant_data else 0
	if not GameManager.has_enough_resource(plant_cost):
		return
		
	GameManager.spend_resource(plant_cost)
	_instantiate_plant(active_selected_plant_data, current_hovered_cell)
	cancel_placement()


func _instantiate_plant(data: PlantStats, cell: Vector2i) -> void:
	if data == null or data.scene == null:
		push_error("GridPlacementManager: PlantStats atau PackedScene kosong!")
		return
		
	var plant_inst: Node2D = data.scene.instantiate() as Node2D
	plant_inst.position = grid_to_world(cell)
	plant_container.add_child(plant_inst)
	occupied_plots[cell] = plant_inst
	
	if plant_inst.has_method("setup_from_stats"):
		plant_inst.setup_from_stats(data, cell)
	
	var plant_id: StringName = data.id if "id" in data else StringName(data.resource_name)
	EventBus.plant_placed.emit(plant_id, cell, plant_inst)


func _on_plant_died(cell: Vector2i) -> void:
	if occupied_plots.has(cell):
		occupied_plots.erase(cell)
		EventBus.plant_removed.emit(cell)
		
func remove_plant_at_cell(cell: Vector2i) -> void:
	if not is_cell_occupied(cell):
		return
		
	var plant_node: Node2D = occupied_plots[cell]
	
	_on_plant_died(cell)
	plant_node.queue_free()

func _on_placement_requested(plant_id: StringName, grid_cell: Vector2i) -> void:
	# Handler jika ada sistem eksternal/test yang meminta penanaman langsung via EventBus
	for data in plant_catalog:
		if data != null and "id" in data and data.id == plant_id:
			if is_cell_valid_for_planting(grid_cell) and GameManager.spend_resource(data.cost):
				_instantiate_plant(data, grid_cell)
			break


func _draw_range_circle(radius: float) -> void:
	range_indicator.clear_points()
	if radius <= 0.0:
		range_indicator.visible = false
		return
		
	range_indicator.visible = true
	var segments: int = 32
	for i in range(segments):
		var angle: float = (float(i) / float(segments)) * TAU
		# Rasio elips isometrik 2:1 (lebar penuh, tinggi setengah)
		var px: float = cos(angle) * radius
		var py: float = sin(angle) * (radius * 0.5)
		range_indicator.add_point(Vector2(px, py))
		
# gambar grid
func _draw() -> void:
	if not show_debug_grid:
		return
		
	for x in range(-grid_radius_x, grid_radius_x + 1):
		for y in range(-grid_radius_y, grid_radius_y + 1):
			var cell := Vector2i(x, y)
			if not is_within_diamond_bounds(cell):
				continue
				
			var center: Vector2 = grid_to_world(cell)
			var pts := PackedVector2Array([
				center + Vector2(0.0, -TILE_HALF_HEIGHT), # Atas
				center + Vector2(TILE_HALF_WIDTH, 0.0),   # Kanan
				center + Vector2(0.0, TILE_HALF_HEIGHT),  # Bawah
				center + Vector2(-TILE_HALF_WIDTH, 0.0),  # Kiri
				center + Vector2(0.0, -TILE_HALF_HEIGHT)  # Tutup ke Atas
			])
			
			if is_house_footprint(cell):
				draw_colored_polygon(pts.slice(0, 4), Color(0.85, 0.2, 0.2, 0.35))
				draw_polyline(pts, Color(1.0, 0.3, 0.3, 0.8), 1.5)
			else:
				draw_colored_polygon(pts.slice(0, 4), Color(0.15, 0.5, 0.3, 0.2))
				draw_polyline(pts, Color(0.4, 0.9, 0.5, 0.55), 1.0)
				
	
