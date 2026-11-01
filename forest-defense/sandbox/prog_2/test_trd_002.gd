extends Node2D

@onready var planting_grid: GridPlacementManager = $PlantingGrid

@export var test_plant_stats: PlantStats

var status_label: Label


func _ready() -> void:
	planting_grid.position = get_viewport_rect().size * 0.5
	planting_grid.queue_redraw()
	
	GameManager.current_resource = 1000
	GameManager.current_house_space = 5
	GameManager.start_new_game()
	
	if test_plant_stats == null:
		test_plant_stats = _create_mock_plant_stats()
		
	_setup_debug_hud()
	_update_hud_text("Tekan [1] untuk mulai memilih tanaman.")
	
	EventBus.plant_placed.connect(_on_plant_placed)
	EventBus.plant_removed.connect(_on_plant_removed)
	EventBus.resource_changed.connect(func(_bal: int, _delta: int): _update_hud_text())


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
		
	match event.keycode:
		KEY_1:
			planting_grid.select_plant_for_placement(test_plant_stats)
			_update_hud_text("Mode Tanam AKTIF (Klik Kiri: Tanam | Klik Kanan: Batal)")
		KEY_S:
			planting_grid.toggle_shovel_mode()
			if planting_grid.is_shovel_mode_active:
				_update_hud_text("Mode SEKOP AKTIF (Klik Kiri pada tanaman untuk mencabut | Klik Kanan / [S]: Batal)")
			else:
				_update_hud_text("Mode SEKOP NONAKTIF")
		KEY_2:
			_kill_one_random_plant()
		KEY_3:
			GameManager.add_resource(50)
			_update_hud_text("Resource +50 ditambahkan!")
		KEY_4:
			GameManager.current_house_space += 1
			_update_hud_text("Space Rumah (R7) ditambah menjadi %d!" % GameManager.get_current_house_space())
		KEY_5:
			_run_automated_qa_checks()


# --- Pembuat Data Tanaman Uji Otomatis (Fallback Tanpa Aset) ---

func _create_mock_plant_stats() -> PlantStats:
	var mock := PlantStats.new()
	mock.id = &"pembazoka_kuning_test"
	mock.display_name = "Pembazoka Kuning (Uji)"
	mock.cost = 25
	mock.max_hp = 100.0
	mock.attack_range = 140.0
	
	var img := Image.create(28, 28, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.85, 0.1, 1.0))
	mock.preview_texture = ImageTexture.create_from_image(img)
	
	if ResourceLoader.exists("res://src/resources/data/plants/base_plant.tscn"):
		mock.scene = load("res://src/resources/data/plants/base_plant.tscn")
	else:
		var root_plant := BasePlant.new()
		root_plant.name = "MockPlant"
		var spr := Sprite2D.new()
		spr.name = "Sprite2D"
		spr.texture = mock.preview_texture
		spr.offset = Vector2(0, -10)
		root_plant.add_child(spr)
		spr.owner = root_plant
		
		var packed := PackedScene.new()
		packed.pack(root_plant)
		mock.scene = packed
		root_plant.free()
		
	return mock


# Uji Coba & Simulasi Kriteria QA

func _kill_one_random_plant() -> void:
	var cells: Array = planting_grid.occupied_plots.keys()
	if cells.is_empty():
		_update_hud_text("Tidak ada tanaman di lahan untuk dihapus!")
		return
		
	var target_cell: Vector2i = cells[0]
	var plant_node: Node = planting_grid.occupied_plots[target_cell]
	if is_instance_valid(plant_node):
		if plant_node.has_method("die"):
			plant_node.die()
		elif plant_node.has_signal("plant_died"):
			plant_node.emit_signal("plant_died")
			plant_node.queue_free()
		else:
			planting_grid._on_plant_died(target_cell)
			plant_node.queue_free()
	_update_hud_text("Simulasi T-GRID-04: Tanaman di %s mati (plot bebas, tanpa refund)." % str(target_cell))


func _run_automated_qa_checks() -> void:
	var t1: bool = not planting_grid.is_cell_valid_for_planting(Vector2i(0, 0)) \
		and not planting_grid.is_cell_valid_for_planting(Vector2i(-1, 1))
	
	var t2: bool = not planting_grid.is_cell_valid_for_planting(Vector2i(3, 3)) \
		and not planting_grid.is_cell_valid_for_planting(Vector2i(0, 6))
	
	print("=== HASIL UJI QA TRD-002 ===")
	print("T-GRID-01 (Blokir Area Rumah 3x3): ", "PASS" if t1 else "FAIL")
	print("T-GRID-02 (Blokir Luar Diamond R>5): ", "PASS" if t2 else "FAIL")
	_update_hud_text("QA Check T-GRID-01: %s | T-GRID-02: %s" % ["PASS" if t1 else "FAIL", "PASS" if t2 else "FAIL"])


# --- UI HUD Debug di Layar ---
func _setup_debug_hud() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	status_label = Label.new()
	status_label.position = Vector2(20, 20)
	status_label.add_theme_font_size_override("font_size", 15)
	canvas.add_child(status_label)


func _update_hud_text(extra_msg: String = "") -> void:
	if status_label == null:
		return
	var text := "=== SANDBOX PROG 1: TRD-002 DIAMOND GRID ===\n"
	text += "Resource: %d (Biaya Tanam: %d)\n" % [GameManager.current_resource, test_plant_stats.cost]
	text += "Terisi (Aturan R7): %d / %d Space Rumah\n\n" % [planting_grid.occupied_plots.size(), GameManager.get_current_house_space()]
	text += "[Kontrol Keyboard]\n"
	text += "• [1] : Pilih Tanaman (Munculkan Ghost Preview)\n"
	text += "• [Klik Kiri] : Tanam di Sel Hijau | [Klik Kanan] : Batal\n"
	text += "• [2] : Bunuh 1 Tanaman (Uji T-GRID-04 Bebaskan Lahan)\n"
	text += "• [3] : Tambah +50 Resource\n"
	text += "• [4] : Tambah +1 Kapasitas Space Rumah (R7)\n"
	text += "• [5] : Jalankan Assert QA T-GRID-01 & T-GRID-02\n"
	if extra_msg != "":
		text += "\n>> Status: " + extra_msg
	status_label.text = text


func _on_plant_placed(plant_id: StringName, cell: Vector2i, _inst: Node2D) -> void:
	_update_hud_text("Berhasil menanam '%s' di sel %s" % [plant_id, str(cell)])


func _on_plant_removed(cell: Vector2i) -> void:
	_update_hud_text("Plot di sel %s telah kosong kembali." % str(cell))
