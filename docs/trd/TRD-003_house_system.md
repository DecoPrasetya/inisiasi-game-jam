# 📐 TRD-003: House System (Rumah Pusat)

> **Technical Reference Document (TRD) - Entitas & Logika Rumah**  
> ID Modul: **TRD-003**  
> Sumber Kebenaran: 🟢 **[SKETCH: Rumah, Aturan R5, R6, R7]**, 📘 **[PRD: 5.1, 9.3]**, ⚙️ **[REKAYASA DESAIN: Skala Leveling & Biaya]**, 🔵 **[TEKNIS GODOT]**  
> Penanggung Jawab: **Programmer 1**

---

## 1. Deskripsi Modul & Lingkup Kerja

Rumah adalah objektif utama yang harus dilindungi pemain di pusat hutan. Modul ini bertanggung jawab atas:
1. Pengelolaan poin nyawa (HP) Rumah sebagai penentu kondisi Game Over saat HP mencapai 0.
2. Penegakan **Aturan R5**: HP Rumah **boleh menerima Buff** (misal peningkatan HP dari Supporter), namun **kebal mutlak terhadap segala bentuk Debuff**.
3. Penegakan **Aturan R6**: Level Rumah menjadi batas atas (cap) peningkatan level seluruh tanaman.
4. Penegakan **Aturan R7**: Peningkatan level Rumah menambah kapasitas lahan aktif (**Space Tanaman**).

---

## 2. Skema & Formula Rekayasa Level Rumah ⚙️ [REKAYASA DESAIN]

Rumah dapat ditingkatkan hingga Level 10 dengan rincian parameter terukur:

| Level Rumah | Maksimum HP | Space Tanaman (R7) | Maks Level Tanaman (R6) | Biaya Upgrade (Resource) |
| :---: | :---: | :---: | :---: | :---: |
| **1** | 250 | 4 | 1 | – (Level Awal) |
| **2** | 380 | 6 | 2 | 100 |
| **3** | 550 | 8 | 3 | 220 |
| **4** | 780 | 10 | 4 | 380 |
| **5** | 1,100 | 12 | 5 | 600 |
| **6** | 1,500 | 14 | 6 | 900 |
| **7** | 2,000 | 16 | 7 | 1,300 |
| **8** | 2,600 | 18 | 8 | 1,800 |
| **9** | 3,300 | 20 | 9 | 2,500 |
| **10** | 4,200 | 24 | 10 | 3,500 |

*Catatan Mekanik Naik Level*: Saat Rumah naik level, selisih HP maksimum baru dengan yang lama ditambahkan langsung ke HP saat ini ($\text{HP Baru} = \text{HP Lama} + \Delta\text{HP Maks}$).

---

## 3. Node Hierarchy & Struktur Scene 🔵 [TEKNIS GODOT]

Scene: `res://src/entities/house/house.tscn`

```text
House (Area2D, script: house.gd, collision_layer = 1, collision_mask = 0)
├── VisualSprite (AnimatedSprite2D)
├── FootprintCollision (CollisionPolygon2D, bentuk belah ketupat 3x3)
├── HealthComponent (Node, can_receive_debuff = false)
├── StatusEffectReceiver (Node, can_receive_debuff = false)
└── UpgradeVFX (GPUParticles2D, meletup saat level naik)
```

---

## 4. Spesifikasi Skema Data Resource (`HouseStats`) 🔵 [TEKNIS GODOT]

File: `res://src/resources/schemas/house_stats.gd`

```gdscript
class_name HouseStats
extends Resource

@export var max_level: int = 10
@export var base_hp_table: Array[float] = [250.0, 380.0, 550.0, 780.0, 1100.0, 1500.0, 2000.0, 2600.0, 3300.0, 4200.0]
@export var plant_space_table: Array[int] = [4, 6, 8, 10, 12, 14, 16, 18, 20, 24]
@export var upgrade_cost_table: Array[int] = [0, 100, 220, 380, 600, 900, 1300, 1800, 2500, 3500]

func get_max_hp(level: int) -> float:
	var idx: int = clamp(level - 1, 0, base_hp_table.size() - 1)
	return base_hp_table[idx]

func get_plant_space(level: int) -> int:
	var idx: int = clamp(level - 1, 0, plant_space_table.size() - 1)
	return plant_space_table[idx]

func get_upgrade_cost(to_level: int) -> int:
	var idx: int = clamp(to_level - 1, 0, upgrade_cost_table.size() - 1)
	return upgrade_cost_table[idx]
```

---

## 5. Implementasi GDScript Logika Rumah 🔵 [TEKNIS GODOT]

File: `res://src/entities/house/house.gd`

```gdscript
class_name HouseEntity
extends Area2D

@export var stats: HouseStats
@onready var health_component: HealthComponent = $HealthComponent
@onready var status_receiver: StatusEffectReceiver = $StatusEffectReceiver
@onready var visual_sprite: AnimatedSprite2D = $VisualSprite

var current_level: int = 1

func _ready() -> void:
	# Konfigurasi proteksi mutlak Aturan R5 🟢 [SKETCH]
	health_component.can_receive_debuff = false
	status_receiver.can_receive_debuff = false
	
	_apply_level_stats(current_level)
	
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_house_destroyed)

func get_current_space() -> int:
	return stats.get_plant_space(current_level)

func get_max_plant_level() -> int:
	# 🟢 [SKETCH: Aturan R6] Maksimal level tanaman sama dengan level rumah
	return current_level

func can_upgrade() -> bool:
	if current_level >= stats.max_level:
		return false
	var cost: int = stats.get_upgrade_cost(current_level + 1)
	return GameManager.has_enough_resource(cost)

func upgrade_house() -> bool:
	if not can_upgrade():
		return false
		
	var next_level: int = current_level + 1
	var cost: int = stats.get_upgrade_cost(next_level)
	
	GameManager.spend_resource(cost)
	current_level = next_level
	_apply_level_stats(current_level)
	
	EventBus.house_upgraded.emit(current_level, get_current_space(), get_max_plant_level())
	return true

func _apply_level_stats(lvl: int) -> void:
	var old_max_hp: float = health_component.max_health
	var new_max_hp: float = stats.get_max_hp(lvl)
	var hp_delta: float = max(0.0, new_max_hp - old_max_hp)
	
	health_component.set_max_health(new_max_hp)
	if old_max_hp > 0.0:
		health_component.heal(hp_delta)
		
	EventBus.house_health_changed.emit(health_component.current_health, health_component.max_health)

func _on_health_changed(cur_hp: float, max_hp: float) -> void:
	EventBus.house_health_changed.emit(cur_hp, max_hp)

func _on_house_destroyed() -> void:
	EventBus.house_destroyed.emit()
```

---

## 6. Matriks QA & Kriteria Penerimaan

- [ ] **T-HOUSE-01 (Kekebalan Debuff - R5)**: Mengirimkan efek modifier dengan `is_debuff = true` ke Rumah ditolak oleh `StatusEffectReceiver` dan tidak mengurangi stat apa pun.
- [ ] **T-HOUSE-02 (Penerimaan Buff - R5)**: Mengirimkan efek heal atau peningkatan max HP dari Supporter ke Rumah berhasil dieksekusi.
- [ ] **T-HOUSE-03 (Batas Level Tanaman - R6)**: Sistem upgrade tanaman memeriksa `plant.level < house.get_max_plant_level()`. Jika level rumah 2, tanaman tidak dapat naik ke level 3.
- [ ] **T-HOUSE-04 (Game Over)**: Mengurangi HP Rumah hingga 0 memicu sinyal `house_destroyed` dan menghentikan game.
