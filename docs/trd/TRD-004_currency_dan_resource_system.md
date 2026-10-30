# 📐 TRD-004: Currency & Resource Economy System

> **Technical Reference Document (TRD) - Sistem Ekonomi & Sumber Daya**  
> ID Modul: **TRD-004**  
> Sumber Kebenaran: 🟢 **[SKETCH: Skenario Drop Resource Musuh]**, 📘 **[PRD: 6.3, 9.1]**, ⚙️ **[REKAYASA DESAIN: Saldo Awal 120, Auto-Fly Orb, No-Refund]**, 🔵 **[TEKNIS GODOT]**  
> Penanggung Jawab: **Programmer 3**

---

## 1. Deskripsi Modul & Lingkup Kerja

Modul ini bertanggung jawab atas sirkulasi satu-satunya mata uang game (*Resource*):
1. Mengelola saldo pemain secara persisten selama sesi bertahan hidup berlangsung.
2. Memproses penerimaan reward sumber daya saat hewan/monster berhasil dimusnahkan.
3. Menangani efek visual berupa drop orb melayang yang ditarik secara otomatis ke arah indikator HUD.
4. Memvalidasi transaksi pengeluaran (pembelian bibit tanaman, upgrade tanaman, upgrade Rumah).
5. Menerapkan aturan **Tanpa Pengembalian (No-Refund)** saat tanaman dicabut atau mati.

---

## 2. Parameter & Formula Ekonomi ⚙️ [REKAYASA DESAIN]

| Parameter | Nilai Rekayasa | Keterangan Desain |
| :--- | :---: | :--- |
| **Saldo Awal Pemain** | `120` Resource | Cukup untuk membeli 2 tanaman Common (cth. Tameng Sitrus @50) di Hari 1. |
| **Batas Minimum Saldo** | `0` Resource | Transaksi langsung dibatalkan jika saldo tidak mencukupi (tidak boleh minus). |
| **Mekanisme Pengambilan** | Otomatis (Auto-Vacuum) | Orb muncul di titik mati musuh, memantul sejenak (0.3s), lalu melesat ke HUD. |
| **Refund Pencabutan** | `0%` (No-Refund) | Menghindari eksploitasi pemain memindahkan tanaman sesaat sebelum musuh lewat. |

---

## 3. Node Hierarchy & Struktur Scene Orb 🔵 [TEKNIS GODOT]

Scene: `res://src/systems/economy/resource_drop_orb.tscn`

```text
ResourceDropOrb (Area2D, script: resource_drop_orb.gd, collision_layer = 16)
├── GlowSprite (Sprite2D, texture tetesan air/kristal bercahaya)
├── SparkleParticles (GPUParticles2D)
├── HoverAnimationPlayer (AnimationPlayer)
└── SoundPlayer (AudioStreamPlayer2D, SFX gemerincing sumber daya)
```

---

## 4. Implementasi GDScript Resource Manager 🔵 [TEKNIS GODOT]

File: `res://src/systems/economy/resource_manager.gd`

```gdscript
class_name ResourceManager
extends Node

const INITIAL_BALANCE: int = 120

var current_balance: int = INITIAL_BALANCE

func _ready() -> void:
	EventBus.day_started.connect(_on_day_started)
	EventBus.enemy_killed.connect(_on_enemy_killed)

func reset_balance() -> void:
	current_balance = INITIAL_BALANCE
	EventBus.resource_changed.emit(current_balance, 0)

func has_sufficient(amount: int) -> bool:
	return current_balance >= amount

func spend(amount: int) -> bool:
	if amount <= 0:
		return true
	if not has_sufficient(amount):
		return false
		
	current_balance -= amount
	EventBus.resource_changed.emit(current_balance, -amount)
	return true

func add(amount: int) -> void:
	if amount <= 0:
		return
	current_balance += amount
	EventBus.resource_changed.emit(current_balance, amount)

func _on_enemy_killed(reward_amount: int, _enemy_id: StringName, death_position: Vector2) -> void:
	_spawn_drop_orb(reward_amount, death_position)

func _spawn_drop_orb(amount: int, pos: Vector2) -> void:
	var orb_scene: PackedScene = preload("res://src/systems/economy/resource_drop_orb.tscn")
	var orb: ResourceDropOrb = orb_scene.instantiate() as ResourceDropOrb
	orb.position = pos
	orb.reward_value = amount
	get_tree().current_scene.add_child(orb)

func _on_day_started(day: int) -> void:
	if day == 1:
		reset_balance()
```

---

## 5. Implementasi GDScript Orb Terbang (Auto-Vacuum) 🔵 [TEKNIS GODOT]

File: `res://src/systems/economy/resource_drop_orb.gd`

```gdscript
class_name ResourceDropOrb
extends Area2D

@export var reward_value: int = 10
@export var float_duration: float = 0.35
@export var fly_speed: float = 800.0

var is_flying_to_hud: bool = false
var hud_target_pos: Vector2 = Vector2(80, 40) # Posisi ikon resource pada viewport HUD

func _ready() -> void:
	# Efek pop-out memantul saat musuh pecah
	var tween: Tween = create_tween()
	var random_offset: Vector2 = Vector2(randf_range(-25, 25), randf_range(-25, 10))
	tween.tween_property(self, "position", position + random_offset, float_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_start_fly_to_hud)

func _start_fly_to_hud() -> void:
	is_flying_to_hud = true

func _process(delta: float) -> void:
	if not is_flying_to_hud:
		return
		
	# Melesat ke posisi HUD di layar
	var screen_transform: Transform2D = get_canvas_transform()
	var current_screen_pos: Vector2 = screen_transform * position
	var dir_to_hud: Vector2 = (hud_target_pos - current_screen_pos).normalized()
	
	position += dir_to_hud * fly_speed * delta
	
	if current_screen_pos.distance_to(hud_target_pos) < 30.0:
		_collect()

func _collect() -> void:
	# Tambahkan saldo ke sistem
	var mgr: ResourceManager = get_tree().root.get_node_or_null("GameManager/ResourceManager")
	if mgr:
		mgr.add(reward_value)
	queue_free()
```

---

## 6. Matriks QA & Kriteria Penerimaan

- [ ] **T-ECON-01**: Pemain memulai game baru dengan saldo tepat 120 Resource.
- [ ] **T-ECON-02**: Membeli tanaman seharga 50 mengurangi saldo menjadi 70 dan memancarkan `resource_changed(70, -50)`.
- [ ] **T-ECON-03**: Upaya pembelian saat saldo tidak mencukupi menghasilkan return `false` dan tidak mengubah saldo.
- [ ] **T-ECON-04**: Musuh mati memancarkan `enemy_killed(reward, id, pos)`, memunculkan drop orb, dan bertambah ke saldo saat orb mencapai HUD.
- [ ] **T-ECON-05**: Mencabut tanaman yang sudah ada di lahan tidak mengembalikan resource apa pun.
