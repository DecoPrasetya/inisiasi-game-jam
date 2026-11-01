extends Node2D

@onready var planting_grid: GridPlacementManager = $PlantingGrid
@onready var wave_spawner: WaveSpawner = get_node_or_null("WaveSpawner")

## Opsional: Masukkan file .tres PlantStats jika sudah dibuat di FileSystem
@export var test_plant_stats: PlantStats

var status_label: Label


func _ready() -> void:
	# 1. Posisikan pusat grid (0,0) tepat di tengah layar
	var screen_center: Vector2 = get_viewport_rect().size * 0.5
	planting_grid.position = screen_center
	planting_grid.queue_redraw()
	
	# 2. Siapkan WaveSpawner (gunakan node di scene atau buat otomatis jika belum dipasang)
	_ensure_wave_spawner_ready(screen_center)
	
	# 3. Inisialisasi state ekonomi, kapasitas rumah, dan siklus game di GameManager
	GameManager.current_resource = 100
	GameManager.current_house_space = 5
	GameManager.start_new_game()
	
	# 4. Buat data tanaman uji otomatis jika belum diisi di Inspector
	if test_plant_stats == null:
		test_plant_stats = _create_mock_plant_stats()
		
	# 5. Buat UI Label di layar untuk memantau Fase, Gelombang, Resource & Space R7
	_setup_debug_hud()
	_update_hud_text("Siap! Tekan [1] untuk menanam atau [N] untuk memulai Malam.")
	
	# 6. Hubungkan sinyal EventBus untuk log real-time di HUD
	EventBus.plant_placed.connect(_on_plant_placed)
	EventBus.plant_removed.connect(_on_plant_removed)
	EventBus.resource_changed.connect(func(_bal: int, _delta: int): _update_hud_text())
	
	EventBus.day_started.connect(_on_day_started)
	EventBus.night_started.connect(_on_night_started)
	EventBus.night_ended.connect(_on_night_ended)
	EventBus.wave_spawn_started.connect(_on_wave_spawn_started)
	EventBus.enemy_spawned.connect(_on_enemy_spawned)
	EventBus.enemy_count_changed.connect(func(_rem: int): _update_hud_text())


func _process(_delta: float) -> void:
	# Perbarui tampilan timer siang secara berkala saat fase DAY
	if GameManager.current_phase == Constants.GamePhase.DAY and status_label != null:
		_update_hud_text()


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
		
	match event.keycode:
		# --- KONTROL TRD-002 (GRID & PENANAMAN) ---
		KEY_1:
			planting_grid.select_plant_for_placement(test_plant_stats)
			_update_hud_text("Mode Tanam AKTIF (Klik Kiri: Tanam | Klik Kanan: Batal)")
		KEY_S:
			planting_grid.toggle_shovel_mode()
			if planting_grid.is_shovel_mode_active:
				_update_hud_text("Mode SEKOP AKTIF (Klik Kiri pada tanaman untuk mencabut)")
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
			
		# --- KONTROL TRD-006 (WAVE SPAWNER & MALAM) ---
		KEY_N:
			if GameManager.current_phase == Constants.GamePhase.DAY:
				GameManager.fast_forward_day()
			else:
				_update_hud_text("Saat ini sudah berada di fase MALAM!")
		KEY_0:
			# Lompat langsung ke Hari 10 dan mulai Malam (Uji 22 musuh & HP Mult 1.54x)
			wave_spawner.stop_spawning()
			_clear_all_active_enemies()
			GameManager.current_day = 10
			GameManager.start_night()
		KEY_K:
			_kill_one_active_enemy()
		KEY_L:
			_kill_all_active_enemies()
		KEY_5:
			_run_automated_qa_checks()


# --- Penyiapan WaveSpawner ---

func _ensure_wave_spawner_ready(center_pos: Vector2) -> void:
	if wave_spawner == null:
		wave_spawner = WaveSpawner.new()
		wave_spawner.name = "WaveSpawner"
		var container := Node2D.new()
		container.name = "EnemyContainer"
		container.y_sort_enabled = true
		wave_spawner.add_child(container)
		var timer := Timer.new()
		timer.name = "SpawnTimer"
		timer.one_shot = true
		wave_spawner.add_child(timer)
		add_child(wave_spawner)
		
	wave_spawner.position = center_pos
	wave_spawner.grid_reference = planting_grid


# --- Fungsi Simulasi Pertempuran & Kematian Musuh (TRD-006) ---

func _kill_one_active_enemy() -> void:
	var enemies: Array[Node] = wave_spawner.enemy_container.get_children()
	if enemies.is_empty():
		_update_hud_text("Belum ada musuh di layar (tunggu antrean spawn atau tekan [N] mulai malam)!")
		return
		
	for node in enemies:
		if is_instance_valid(node) and not node.is_queued_for_deletion():
			if node.has_method("die"):
				node.die()
			elif node.has_method("take_damage"):
				node.take_damage(999999.0)
			_update_hud_text("1 Musuh dibunuh! Sisa musuh gelombang: %d" % GameManager.active_enemy_count)
			return


func _kill_all_active_enemies() -> void:
	var enemies: Array[Node] = wave_spawner.enemy_container.get_children()
	if enemies.is_empty():
		_update_hud_text("Tidak ada musuh di layar saat ini.")
		return
		
	var killed_now: int = 0
	for node in enemies:
		if is_instance_valid(node) and not node.is_queued_for_deletion():
			if node.has_method("die"):
				node.die()
				killed_now += 1
	_update_hud_text("Membunuh %d musuh yang ada di layar! Sisa antrean gelombang: %d" % [killed_now, GameManager.active_enemy_count])


func _clear_all_active_enemies() -> void:
	for node in wave_spawner.enemy_container.get_children():
		node.queue_free()
	GameManager.active_enemy_count = 0


# --- Fungsi Automated QA Assert (TRD-002 & TRD-006) ---

func _run_automated_qa_checks() -> void:
	# 1. Uji QA TRD-002 (Grid & Rumah 3x3)
	var t_grid_1: bool = not planting_grid.is_cell_valid_for_planting(Vector2i(0, 0)) \
		and not planting_grid.is_cell_valid_for_planting(Vector2i(-1, 1))
	var out_cell := Vector2i(planting_grid.grid_radius_x + 1, 0)
	var t_grid_2: bool = not planting_grid.is_cell_valid_for_planting(out_cell)
	
	# 2. Uji QA TRD-006 (Formula Endless Scaling & Spawn di Luar Lahan)
	var day1_count: int = wave_spawner.calculate_total_enemies(1)
	var day10_count: int = wave_spawner.calculate_total_enemies(10)
	var day10_hp_mult: float = wave_spawner.calculate_hp_multiplier(10)
	
	var t_wave_day1: bool = (day1_count == 4)
	var t_wave_day10: bool = (day10_count == 22) and is_equal_approx(day10_hp_mult, 1.54)
	
	# Cek keempat sisi spawn selalu menghasilkan koordinat di luar batas lahan (|x| + |y| > 5)
	var t_wave_bounds: bool = true
	for side in [
		Constants.SpawnSide.NORTH_EAST,
		Constants.SpawnSide.SOUTH_EAST,
		Constants.SpawnSide.SOUTH_WEST,
		Constants.SpawnSide.NORTH_WEST
	]:
		var c: Vector2i = wave_spawner.get_spawn_grid_cell(side)
		if abs(c.x) + abs(c.y) <= 5:
			t_wave_bounds = false
			
	print("=== HASIL UJI QA TRD-002 & TRD-006 ===")
	print("TRD-002 Area Rumah 3x3 Diblokir : ", "PASS" if t_grid_1 else "FAIL")
	print("TRD-002 Luar Diamond Diblokir   : ", "PASS" if t_grid_2 else "FAIL")
	print("TRD-006 Hari 1 = 4 Musuh        : ", "PASS (%d)" % day1_count if t_wave_day1 else "FAIL")
	print("TRD-006 Hari 10 = 22, HP 1.54x  : ", "PASS (%d musuh, %.2fx HP)" % [day10_count, day10_hp_mult] if t_wave_day10 else "FAIL")
	print("TRD-006 Spawn Luar Grid (R=7)   : ", "PASS" if t_wave_bounds else "FAIL")
	
	_update_hud_text(
		"QA TRD-006 -> Hari 1 (4): %s | Hari 10 (22 & 1.54x): %s | Spawn R=7: %s" % [
			"PASS" if t_wave_day1 else "FAIL",
			"PASS" if t_wave_day10 else "FAIL",
			"PASS" if t_wave_bounds else "FAIL"
		]
	)


# --- Handler Sinyal EventBus ---

func _on_day_started(day_num: int) -> void:
	_update_hud_text("SIANG HARI %d dimulai! Silakan menanam sebelum malam tiba." % day_num)


func _on_night_started(day_num: int) -> void:
	var hp_mult: float = wave_spawner.calculate_hp_multiplier(day_num)
	_update_hud_text("MALAM HARI %d dimulai! (HP Multiplier Musuh: %.2fx)" % [day_num, hp_mult])


func _on_wave_spawn_started(day_num: int, total_enemies: int) -> void:
	_update_hud_text("Gelombang Malam %d: Menyiapkan %d musuh dari 4 sisi..." % [day_num, total_enemies])


func _on_enemy_spawned(_enemy_node: Node2D, side: Constants.SpawnSide) -> void:
	var side_name: String = Constants.SpawnSide.keys()[side]
	_update_hud_text("Musuh muncul dari sisi %s! (Sisa gelombang: %d)" % [side_name, GameManager.active_enemy_count])


func _on_night_ended(day_num: int) -> void:
	_update_hud_text("MALAM HARI %d SELESAI! Seluruh musuh gelombang telah musnah." % day_num)


func _on_plant_placed(plant_id: StringName, cell: Vector2i, _inst: Node2D) -> void:
	_update_hud_text("Berhasil menanam '%s' di sel %s" % [plant_id, str(cell)])


func _on_plant_removed(cell: Vector2i) -> void:
	_update_hud_text("Plot di sel %s telah kosong kembali." % str(cell))


# --- Pembuat Data Tanaman Uji & Pencabut Tanaman ---

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


func _kill_one_random_plant() -> void:
	var cells: Array = planting_grid.occupied_plots.keys()
	if cells.is_empty():
		_update_hud_text("Tidak ada tanaman di lahan untuk dihapus!")
		return
		
	var target_cell: Vector2i = cells[0]
	planting_grid.remove_plant_at_cell(target_cell)
	_update_hud_text("Simulasi T-GRID-04: Tanaman di %s mati (plot bebas, tanpa refund)." % str(target_cell))


# --- UI HUD Debug di Layar ---

func _setup_debug_hud() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	status_label = Label.new()
	status_label.position = Vector2(20, 20)
	status_label.add_theme_font_size_override("font_size", 14)
	canvas.add_child(status_label)


func _update_hud_text(extra_msg: String = "") -> void:
	if status_label == null:
		return
	var phase_str: String = Constants.GamePhase.keys()[GameManager.current_phase]
	var hp_mult: float = wave_spawner.calculate_hp_multiplier(GameManager.current_day) if wave_spawner != null else 1.0
	var last_msg: String = extra_msg
	if last_msg == "" and status_label.text.contains(">> Status: "):
		last_msg = status_label.text.get_slice(">> Status: ", 1)
		
	var text := "=== SANDBOX PROG 1: TRD-002 (GRID) & TRD-006 (WAVE SPAWNER) ===\n"
	text += "Hari: %d | Fase: %s" % [GameManager.current_day, phase_str]
	if GameManager.current_phase == Constants.GamePhase.DAY:
		text += " (Sisa Waktu Siang: %.1fs)\n" % maxf(0.0, GameManager.day_timer)
	else:
		text += " | Sisa Musuh Gelombang: %d (HP Mult: %.2fx)\n" % [GameManager.active_enemy_count, hp_mult]
		
	text += "Resource: %d | Tanaman Terisi (R7): %d / %d Space Rumah\n\n" % [
		GameManager.current_resource,
		planting_grid.occupied_plots.size(),
		GameManager.get_current_house_space()
	]
	text += "[Kontrol Grid TRD-002]\n"
	text += "• [1] : Pilih Bibit Tanaman | [S] : Mode Sekop (Cabut Tanaman)\n"
	text += "• [2] : Bunuh 1 Tanaman | [3] : +50 Resource | [4] : +1 Space Rumah\n\n"
	text += "[Kontrol Gelombang TRD-006]\n"
	text += "• [N] : Mulai Malam Sekarang (Fast-Forward Siang)\n"
	text += "• [0] : Uji Malam HARI 10 (22 Musuh, HP Multiplier 1.54x)\n"
	text += "• [K] : Bunuh 1 Musuh di Layar | [L] : Bunuh Semua Musuh di Layar\n"
	text += "• [5] : Jalankan Automated Assert QA (TRD-002 & TRD-006)\n"
	if last_msg != "":
		text += "\n>> Status: " + last_msg
	status_label.text = text
