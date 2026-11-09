extends Node2D

@onready var planting_grid: GridPlacementManager = $PlantingGrid
@onready var wave_spawner: WaveSpawner = $WaveSpawner

var status_label: Label

func _ready() -> void:
	# 1. Posisikan grid di tengah layar
	var screen_center: Vector2 = get_viewport_rect().size * 0.5
	planting_grid.position = screen_center
	planting_grid.queue_redraw()
	
	if wave_spawner != null:
		wave_spawner.position = screen_center
		wave_spawner.grid_reference = planting_grid

	# 2. MENGAMBIL KATALOG DARI CHILD NODE
	# Jika Anda mengisi katalog lewat Inspector di node PlantingGrid & WaveSpawner,
	# parent bisa langsung membacanya seperti ini:
	var plant_catalog: Array[PlantStats] = planting_grid.plant_catalog
	var enemy_catalog: Array[EnemyStats] = wave_spawner.enemy_catalog
	
	# 3. Contoh validasi atau log untuk memastikan katalog terbaca
	print("Jumlah tanaman di katalog grid: ", plant_catalog.size())
	print("Jumlah musuh di katalog spawner: ", enemy_catalog.size())
	
	# Inisialisasi game manager dan HUD seperti biasa...
	GameManager.current_resource = 100
	GameManager.start_new_game()
	_setup_debug_hud()
	_update_hud_text("Siap! Tekan [1] untuk menanam dari katalog.")
	
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
			if not planting_grid.plant_catalog.is_empty():
				planting_grid.select_plant_for_placement(planting_grid.plant_catalog[0])
				_update_hud_text("Mode Menanam: Pembazoka Kuning (Damage Dealer) dipilih. Klik petak hijau untuk menanam.")
		KEY_2:
			if not planting_grid.plant_catalog.is_empty():
				planting_grid.select_plant_for_placement(planting_grid.plant_catalog[1])
				_update_hud_text("Mode Menanam: Tameng Sitrus (Defender) dipilih. Klik petak hijau untuk menanam.")
		KEY_S:
			planting_grid.toggle_shovel_mode()
			if planting_grid.is_shovel_mode_active:
				_update_hud_text("Mode SEKOP AKTIF (Klik Kiri pada tanaman untuk mencabut)")
			else:
				_update_hud_text("Mode SEKOP NONAKTIF")
		KEY_3:
			if not planting_grid.plant_catalog.is_empty():
				planting_grid.select_plant_for_placement(planting_grid.plant_catalog[2])
				_update_hud_text("Mode Menanam: Anggrek Paramedis (Support) dipilih. Klik petak hijau untuk menanam.")
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
		KEY_6:
			_run_trd_005_qa_checks()
		KEY_7:
			_trigger_assertion_r2_test()
		# Di dalam fungsi _input(event: InputEvent) pada test_core.gd, tambahkan:
		KEY_H:
			GameManager.upgrade_house_level()
			_update_hud_text("Level Rumah naik ke Lv.%d! Sekarang tanaman bisa di-upgrade." % GameManager.get_current_house_level())
		KEY_U:
			_upgrade_all_planted_plants()
		KEY_8:
			_run_trd_008_qa_checks()
		KEY_9:
			GameManager.add_resource(1000)
			_update_hud_text("Resource +1000 ditambahkan!")


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
	mock.id = &"pembazoka_kuning"
	mock.display_name = "Pembazoka Kuning"
	mock.role = Constants.PlantRole.DAMAGE_DEALER
	mock.cost = 25
	mock.max_hp = 100.0
	mock.attack_damage = 10.0 # 2x tembak langsung membunuh Katak Penyembur (50 HP) di Hari 1
	mock.attack_speed = 1.2   # Menembak 1.2 kali per detik
	mock.attack_range = 220.0 # Jangkauan tembak 220 px
	
	var img := Image.create(28, 28, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.85, 0.1, 1.0))
	mock.preview_texture = ImageTexture.create_from_image(img)
	
	# Rakit PackedScene menggunakan kelas PembazokaKuning agar langsung aktif menembak
	var root_plant := PembazokaKuning.new()
	root_plant.name = "PembazokaKuning"
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

# --- Fungsi Automated QA Assert Khusus TRD-005 (Combat & Status Effects) ---

func _run_trd_005_qa_checks() -> void:
	# 1. Uji Aturan R2: DAMAGE_DEALER diizinkan mengurangi HP musuh
	var test_enemy_hc := HealthComponent.new()
	test_enemy_hc.initialize(100.0, true) # true = entitas musuh
	var r2_valid: bool = test_enemy_hc.take_damage(25.0, Constants.PlantRole.DAMAGE_DEALER) \
		and is_equal_approx(test_enemy_hc.current_hp, 75.0)
	test_enemy_hc.free()
	
	# 2. Uji Aturan R5 (AC 2): StatusEffectReceiver menolak debuff jika can_receive_debuff == false
	var house_receiver := StatusEffectReceiver.new()
	house_receiver.can_receive_debuff = false
	var debuff_eff := EffectData.new()
	debuff_eff.effect_kind = Constants.EffectKind.DEBUFF
	debuff_eff.target_stat = &"armor"
	debuff_eff.flat_modifier = -10.0
	var r5_blocked: bool = (house_receiver.apply_effect(debuff_eff, Constants.PlantRole.SUPPORTER) == false)
	house_receiver.free()
	
	# 3. Uji Aturan R3 & R4 (AC 3): CC dari role selain DEFENDER wajib ditolak
	var enemy_receiver := StatusEffectReceiver.new()
	var cc_eff := EffectData.new()
	cc_eff.effect_kind = Constants.EffectKind.CROWD_CONTROL
	cc_eff.cc_type = Constants.CrowdControlType.STUN
	var r4_blocked_supporter: bool = (enemy_receiver.apply_effect(cc_eff, Constants.PlantRole.SUPPORTER) == false)
	var r4_blocked_dealer: bool = (enemy_receiver.apply_effect(cc_eff, Constants.PlantRole.DAMAGE_DEALER) == false)
	var r4_allowed_defender: bool = (enemy_receiver.apply_effect(cc_eff, Constants.PlantRole.DEFENDER) == true)
	var r4_pass: bool = r4_blocked_supporter and r4_blocked_dealer and r4_allowed_defender
	
	# 4. Uji Formula Stat Akhir (AC 4): Final = (Base + Sum(Flat)) * (1 + Sum(Percent))
	# Contoh: Base = 100, Flat = +20 dan -5 (Sum = +15), Percent = +0.30 dan -0.10 (Sum = +0.20)
	# Ekspektasi: (100 + 15) * (1 + 0.20) = 115 * 1.20 = 138.0
	enemy_receiver.clear_all_effects()
	var buff_1 := EffectData.new()
	buff_1.effect_kind = Constants.EffectKind.BUFF
	buff_1.target_stat = &"attack_damage"
	buff_1.flat_modifier = 20.0
	buff_1.percent_modifier = 0.30
	
	var debuff_1 := EffectData.new()
	debuff_1.effect_kind = Constants.EffectKind.DEBUFF
	debuff_1.target_stat = &"attack_damage"
	debuff_1.flat_modifier = -5.0
	debuff_1.percent_modifier = -0.10
	
	enemy_receiver.apply_effect(buff_1, Constants.PlantRole.SUPPORTER)
	enemy_receiver.apply_effect(debuff_1, Constants.PlantRole.SUPPORTER)
	var final_stat: float = enemy_receiver.calculate_final_stat(100.0, &"attack_damage")
	var formula_pass: bool = is_equal_approx(final_stat, 138.0)
	enemy_receiver.free()
	
	print("=== HASIL UJI QA TRD-005 (COMBAT & STATUS EFFECT) ===")
	print("AC-1 Aturan R2 (Damage Dealer Valid)        : ", "PASS" if r2_valid else "FAIL")
	print("AC-2 Aturan R5 (Tolak Debuff Rumah)         : ", "PASS" if r5_blocked else "FAIL")
	print("AC-3 Aturan R4 (Blokir CC Non-Defender)     : ", "PASS" if r4_pass else "FAIL")
	print("AC-4 Formula Stat (100+15)*(1+0.20) = 138.0 : ", "PASS (%.1f)" % final_stat if formula_pass else "FAIL")
	
	_update_hud_text(
		"QA TRD-005 -> R2: %s | R5 (No Debuff): %s | R4 (CC Defender): %s | Formula (138.0): %s" % [
			"PASS" if r2_valid else "FAIL",
			"PASS" if r5_blocked else "FAIL",
			"PASS" if r4_pass else "FAIL",
			"PASS" if formula_pass else "FAIL"
		]
	)


func _trigger_assertion_r2_test() -> void:
	print("Menguji AC-1 Aturan R2: Menyerang musuh dengan role SUPPORTER (Harus memicu Assertion Error di Debugger!)...")
	var dummy_enemy_hc := HealthComponent.new()
	dummy_enemy_hc.initialize(100.0, true)
	# Baris ini sengaja memicu assert() sesuai Acceptance Criteria 1 TRD-005:
	dummy_enemy_hc.take_damage(10.0, Constants.PlantRole.SUPPORTER)
	dummy_enemy_hc.free()


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
	text += "• [2] : defender | [3] : +50 Resource | [4] : +1 Space Rumah\n\n"
	text += "[Kontrol Gelombang TRD-006]\n"
	text += "• [N] : Mulai Malam Sekarang (Fast-Forward Siang)\n"
	text += "• [0] : Uji Malam HARI 10 (22 Musuh, HP Multiplier 1.54x)\n"
	text += "• [K] : Bunuh 1 Musuh di Layar | [L] : Bunuh Semua Musuh di Layar\n"
	text += "• [5] : Jalankan Automated Assert QA (TRD-002 & TRD-006)\n"
	text += "• [6] : Uji QA TRD-005 (R2, R4, R5, Formula)\n"
	text += "• [7] : Uji Assert Error R2 (Non-Damage Dealer)\n"
	if last_msg != "":
		text += "\n>> Status: " + last_msg
	status_label.text = text

func _upgrade_all_planted_plants() -> void:
	var upgraded_count: int = 0
	for cell in planting_grid.occupied_plots.keys():
		var pl: BasePlant = planting_grid.occupied_plots[cell] as BasePlant
		if pl != null and is_instance_valid(pl):
			if pl.try_upgrade():
				upgraded_count += 1
	if upgraded_count > 0:
		_update_hud_text("Berhasil meng-upgrade %d tanaman!" % upgraded_count)
	else:
		_update_hud_text("Upgrade ditolak! Cek Level Rumah (Aturan R6 - tekan [H]) atau kecukupan Resource.")


func _run_trd_008_qa_checks() -> void:
	var dummy_stats: PlantStats = _create_mock_plant_stats()
	dummy_stats.cost = 100
	dummy_stats.max_hp = 100.0
	dummy_stats.attack_damage = 50.0
	
	var test_plant := BasePlant.new()
	add_child(test_plant)
	test_plant.setup_from_stats(dummy_stats, Vector2i(2, 0))
	
	# AC-1: Membaca PlantStats dengan benar
	var ac1_pass: bool = is_equal_approx(test_plant.health_component.max_hp, 100.0) \
		and is_equal_approx(test_plant.get_final_stat(&"attack_damage"), 50.0)
		
	# AC-2: Penegakan Aturan R6 (Saat Level Rumah = 1 dan Level Tanaman = 1, can_upgrade() wajib FALSE)
	var saved_house_lvl: int = GameManager.get_current_house_level()
	var saved_res: int = GameManager.current_resource
	GameManager.current_house_level = 1
	GameManager.current_resource = 9999
	
	var r6_blocked_at_equal_lvl: bool = (test_plant.can_upgrade() == false) and (test_plant.try_upgrade() == false)
	
	# Naikkan Level Rumah ke 3 -> Upgrade ke Lv.2 (biaya 100 * 1.5^0 = 100) dan Lv.3 (biaya 100 * 1.5^1 = 150) harus berhasil
	GameManager.current_house_level = 3
	var cost_lv1_to_2: int = test_plant.get_upgrade_cost() # 100
	var upg_to_2_ok: bool = test_plant.try_upgrade()
	var hp_lv2_ok: bool = is_equal_approx(test_plant.health_component.max_hp, 120.0) # +20%
	var dmg_lv2_ok: bool = is_equal_approx(test_plant.get_final_stat(&"attack_damage"), 60.0) # +20%
	var cost_lv2_to_3: int = test_plant.get_upgrade_cost() # 150
	
	var scaling_pass: bool = (cost_lv1_to_2 == 100) and upg_to_2_ok and hp_lv2_ok and dmg_lv2_ok and (cost_lv2_to_3 == 150)
	
	# Kembalikan state GameManager & bersihkan node uji
	GameManager.current_house_level = saved_house_lvl
	GameManager.current_resource = saved_res
	test_plant.free()
	
	print("=== HASIL UJI QA TRD-008 (PLANT BASE FRAMEWORK) ===")
	print("AC-1 Baca PlantStats (HP 100, DMG 50)        : ", "PASS" if ac1_pass else "FAIL")
	print("AC-2 Aturan R6 (Tolak jika Lv.Plant >= Lv.H) : ", "PASS" if r6_blocked_at_equal_lvl else "FAIL")
	print("AC-3 Scaling +20% & Biaya 1.5^(L-1)          : ", "PASS" if scaling_pass else "FAIL")
	
	_update_hud_text(
		"QA TRD-008 -> AC1 (Stats): %s | AC2 (Aturan R6): %s | Scaling (+20%% & Cost 1.5x): %s" % [
			"PASS" if ac1_pass else "FAIL",
			"PASS" if r6_blocked_at_equal_lvl else "FAIL",
			"PASS" if scaling_pass else "FAIL"
		]
	)
	
func _create_mock_tameng_stats() -> PlantStats:
	var mock := PlantStats.new()
	mock.id = &"tameng_sitrus"
	mock.display_name = "Tameng Sitrus"
	mock.role = Constants.PlantRole.DEFENDER
	mock.rarity = Constants.Rarity.COMMON
	mock.cost = 40
	mock.max_hp = 200.0 # HP tebal khusus Defender
	
	# Buat kotak warna oranye keemasan sebagai preview visual
	var img := Image.create(28, 28, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.95, 0.65, 0.1, 1.0))
	mock.preview_texture = ImageTexture.create_from_image(img)
	
	# Rakit PackedScene menggunakan skrip TamengSitrus
	var root_plant := TamengSitrus.new()
	root_plant.name = "TamengSitrus"
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
