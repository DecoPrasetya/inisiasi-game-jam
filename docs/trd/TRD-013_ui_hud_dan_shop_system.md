# 📐 TRD-013: UI, HUD & Plant Shop System

> **Technical Reference Document (TRD) - Antarmuka Pengguna, HUD & Toko Tanaman**  
> ID Modul: **TRD-013**  
> Sumber Kebenaran: 🟢 **[SKETCH: UI Tanaman, Role & Rarity, Space Tanaman]**, 📘 **[PRD: 8.1, 8.2, 9.7]**, ⚙️ **[REKAYASA DESAIN: Tata Letak HUD, Kartu Belanja, Modal Detail Klik]**, 🔵 **[TEKNIS GODOT]**  
> Penanggung Jawab: **Programmer 3**

---

## 1. Deskripsi Modul & Lingkup Kerja

Modul ini bertanggung jawab atas seluruh antarmuka grafis (UI/UX) pemain:
1. **Heads-Up Display (HUD)**: Menyajikan informasi hari, waktu siang/malam, saldo resource, bar nyawa Rumah, serta kuota **Space Tanaman**.
2. **Shop Panel (Toko Bibit)**: Menampilkan kartu tanaman yang memvisualisasikan Role (ikon tegas), Rarity (bingkai warna), dan Cost.
3. Menangani penonaktifan pembelian cerdas (abu-abu) jika resource kurang, Space penuh (Aturan R7), atau level Rumah belum mencukupi.
4. **Modal Info Detail (Muncul Hanya Saat Diklik 📘)**: Menampilkan rincian stat lengkap dan deskripsi kemampuan saat entitas di-klik, bukan saat kursor hover.

---

## 2. Standar Visual Role & Rarity di UI 🟢 [SKETCH]

Pemain harus dapat mengenali peran dan kelangkaan sekilas tanpa membaca teks panjang:

| Role 🟢 | Ikon Simbol | Kode Warna Aksen | Keterangan Cepat |
| :--- | :---: | :---: | :--- |
| **Damage Dealer** | ⚔️ Pedang Bersilang | `#E74C3C` (Merah Menyala) | Satu-satunya pemberi damage musuh. |
| **Supporter** | 💚 Tetes Obat / Palang | `#2ECC71` (Hijau Segar) | Pemberi buff kawan & debuff musuh. |
| **Defender** | 🛡️ Perisai Kokoh | `#3498DB` (Biru Berlian) | Tank ber-HP tebal & pengendali Crowd Control. |

| Rarity 🟢 | Warna Border Kartu | Label Bahasa Indonesia 🟢 |
| :--- | :---: | :--- |
| **COMMON** | `#95A5A6` (Perak / Abu) | Umum (contoh: Tameng Sitrus) |
| **RARE** | `#2980B9` (Safir Biru) | Langka (contoh: Anggrek Paramedis) |
| **EPIC** | `#8E44AD` (Ametis Ungu) | Luar Biasa (contoh: Pembazoka Kuning) |
| **LEGENDARY** | `#F39C12` (Emas Berkilau) | Legendaris |

---

## 3. Node Hierarchy & Struktur Scene 🔵 [TEKNIS GODOT]

Scene: `res://src/ui/hud/hud.tscn`

```text
HUD (CanvasLayer, script: hud_controller.gd)
├── TopBarContainer (HBoxContainer)
│   ├── DayBadge (PanelContainer, teks: "Hari 1 - Siang")
│   ├── DayTimerLabel (Label, hitung mundur: "00:38")
│   ├── FastForwardButton (Button, teks: "Mulai Malam >>")
│   ├── ResourceDisplay (HBoxContainer, ikon air + label angka saldo)
│   ├── HouseHPBar (ProgressBar, bar merah HP Rumah)
│   └── PlantSpaceLabel (Label, teks: "Tanaman: 2 / 4")
├── ShopPanel (PanelContainer, posisi bawah layar)
│   └── PlantCardList (HBoxContainer, daftar instance shop_card.tscn)
├── AttackWarningOverlay (Control, panah berkedip di 4 sudut: NE, SE, SW, NW)
└── EntityInfoPopup (PanelContainer, modal sematan info klik)
    ├── CloseButton (Button)
    ├── EntityPortrait (TextureRect)
    ├── TitleLabel (Label)
    ├── RoleBadge (Label)
    ├── StatTable (VBoxContainer)
    └── DescriptionLabel (RichTextLabel)
```

---

## 4. Implementasi GDScript `HUDController` 🔵 [TEKNIS GODOT]

File: `res://src/ui/hud/hud_controller.gd`

```gdscript
class_name HUDController
extends CanvasLayer

@onready var day_badge: Label = $TopBarContainer/DayBadge/Label
@onready var day_timer_label: Label = $TopBarContainer/DayTimerLabel
@onready var fast_forward_btn: Button = $TopBarContainer/FastForwardButton
@onready var resource_label: Label = $TopBarContainer/ResourceDisplay/Label
@onready var house_hp_bar: ProgressBar = $TopBarContainer/HouseHPBar
@onready var plant_space_label: Label = $TopBarContainer/PlantSpaceLabel
@onready var plant_card_list: HBoxContainer = $ShopPanel/PlantCardList
@onready var info_popup: PanelContainer = $EntityInfoPopup

func _ready() -> void:
	info_popup.visible = false
	fast_forward_btn.pressed.connect(_on_fast_forward_pressed)
	
	EventBus.day_started.connect(_on_day_started)
	EventBus.night_started.connect(_on_night_started)
	EventBus.resource_changed.connect(_on_resource_changed)
	EventBus.house_health_changed.connect(_on_house_health_changed)
	EventBus.plant_placed.connect(func(_id, _cell, _inst): _update_space_display())
	EventBus.plant_removed.connect(func(_cell): _update_space_display())
	EventBus.house_upgraded.connect(func(_lvl, _spc, _max_p): _update_space_display())

func _process(_delta: float) -> void:
	if GameManager.current_phase == Constants.GamePhase.DAY:
		var time_left: int = int(ceil(GameManager.day_timer))
		day_timer_label.text = "%02d:%02d" % [time_left / 60, time_left % 60]

func _on_day_started(day: int) -> void:
	day_badge.text = "Hari %d (Siang)" % day
	fast_forward_btn.visible = true

func _on_night_started(day: int) -> void:
	day_badge.text = "Hari %d (Malam)" % day
	day_timer_label.text = "SERANGAN!"
	fast_forward_btn.visible = false

func _on_resource_changed(current_balance: int, _delta: int) -> void:
	resource_label.text = str(current_balance)

func _on_house_health_changed(cur_hp: float, max_hp: float) -> void:
	house_hp_bar.max_value = max_hp
	house_hp_bar.value = cur_hp

func _update_space_display() -> void:
	var used: int = GameManager.get_planted_count()
	var capacity: int = GameManager.get_current_house_space()
	plant_space_label.text = "Tanaman: %d / %d" % [used, capacity]
	
	# Peringatan warna merah jika kapasitas lahan sudah penuh (Aturan R7)
	if used >= capacity:
		plant_space_label.modulate = Color(1.0, 0.3, 0.3)
	else:
		plant_space_label.modulate = Color(1.0, 1.0, 1.0)

func _on_fast_forward_pressed() -> void:
	GameManager.fast_forward_day()

func show_entity_info(title: String, role_text: String, desc: String, stats_text: String) -> void:
	info_popup.visible = true
	$EntityInfoPopup/TitleLabel.text = title
	$EntityInfoPopup/RoleBadge.text = role_text
	$EntityInfoPopup/DescriptionLabel.text = desc
```

---

## 5. Implementasi GDScript `ShopCard` 🔵 [TEKNIS GODOT]

File: `res://src/ui/shop/shop_card.gd`

```gdscript
class_name ShopCard
extends Button

@export var plant_stats: PlantStats

@onready var icon_rect: TextureRect = $IconRect
@onready var cost_label: Label = $CostLabel
@onready var role_icon: TextureRect = $RoleIcon
@onready var border_rect: ReferenceRect = $BorderRect
@onready var lock_overlay: Panel = $LockOverlay

func _ready() -> void:
	pressed.connect(_on_card_pressed)
	_setup_card_visuals()

func _process(_delta: float) -> void:
	_update_availability()

func _setup_card_visuals() -> void:
	if not plant_stats:
		return
	icon_rect.texture = plant_stats.preview_texture
	cost_label.text = str(plant_stats.cost)
	
	# Pewarnaan Border Rarity 🟢
	match plant_stats.rarity:
		Constants.Rarity.COMMON:
			border_rect.border_color = Color("#95A5A6")
		Constants.Rarity.RARE:
			border_rect.border_color = Color("#2980B9")
		Constants.Rarity.EPIC:
			border_rect.border_color = Color("#8E44AD")
		Constants.Rarity.LEGENDARY:
			border_rect.border_color = Color("#F39C12")

func _update_availability() -> void:
	var can_afford: bool = GameManager.has_enough_resource(plant_stats.cost)
	var has_space: bool = GameManager.get_planted_count() < GameManager.get_current_house_space()
	var house_unlocked: bool = GameManager.get_current_house_level() >= plant_stats.unlock_house_level
	
	if can_afford and has_space and house_unlocked:
		disabled = false
		lock_overlay.visible = false
	else:
		disabled = true
		lock_overlay.visible = true

func _on_card_pressed() -> void:
	# Minta penempatan pada modul Grid Placement
	var grid_mgr: GridPlacementManager = get_tree().current_scene.get_node_or_null("PlantingGrid")
	if grid_mgr:
		grid_mgr.select_plant_for_placement(plant_stats)
```

---

## 6. Matriks QA & Kriteria Penerimaan

- [ ] **T-UI-01**: Nilai saldo pada HUD selalu sinkron dengan panggilan `add()` dan `spend()` di `ResourceManager`.
- [ ] **T-UI-02**: Saat kuota Space Tanaman penuh ($4/4$), seluruh kartu belanja di panel toko otomatis berubah menjadi non-aktif (disabled) dengan overlay abu-abu.
- [ ] **T-UI-03**: Mengklik entitas tanaman membuka modal `EntityInfoPopup` yang memuat deskripsi skill lengkap. Mengklik di luar modal menutup pop-up tersebut.
- [ ] **T-UI-04**: Ikon dan warna border pada kartu belanja (Tameng Sitrus = Common/Silver, Pembazoka Kuning = Epic/Ungu, Anggrek Paramedis = Rare/Biru) sesuai dengan spesifikasi Rarity.
