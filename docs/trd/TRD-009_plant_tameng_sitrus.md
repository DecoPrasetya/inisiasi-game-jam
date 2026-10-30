# 📐 TRD-009: Modul Tanaman Spesifik - Tameng Sitrus

> **Technical Reference Document (TRD) - Spesifikasi Teknis Tanaman Tameng Sitrus**  
> ID Modul: **TRD-009**  
> Sumber Kebenaran: 🟢 **[SKETCH: Aturan Defender R4]**, 🟢 **[LIST TANAMAN: Tameng Sitrus]**, 📘 **[PRD: 5.2.3, 7.1]**, ⚙️ **[REKAYASA DESAIN: HP 220, Skill Hentakan CC, Passive Armor]**, 🔵 **[TEKNIS GODOT]**  
> Penanggung Jawab: **Programmer 2**

---

## 1. Deskripsi Karakter & Identitas Modul

**Tameng Sitrus** adalah lini pertahanan utama (Tanker) yang bertugas menghadang laju monster hutan:
- **Visual Asli 🟢**: Buah jeruk bersemangat yang memegang potongan tameng irisan jeruk tebal.
- **Role 🟢**: `DEFENDER` (Satu role mutlak, Aturan R1).
- **Cost 🟢**: `50` Resource (*Kategori: Rendah*).
- **Rarity 🟢**: `COMMON` (*Kategori: Umum*).
- **Kemampuan Inti 🟢**: Memiliki Health Point tebal jauh di atas rata-rata tanaman lain dan kemampuan Crowd Control eksklusif.

---

## 2. Rekayasa Stat & Pembuktian Aturan Emas ⚙️ [REKAYASA DESAIN]

### 2.1 Nilai Statistik Dasar (Level 1)
- **Base HP**: `220.0`
- **Cost**: `50` Resource
- **DPS**: `0.0` (🟢 **Aturan R2**: Tameng Sitrus *dilarang mutlak* memberikan damage ke musuh).
- **Attack Range**: `40.0` px (Radius kontak jarak dekat/melee).
- **Syarat Buka Rumah (Unlock Level)**: Level 1 (Tersedia langsung di awal game).

### 2.2 Pembuktian Matematis Aturan R4 (HP di Atas Rata-rata)
Rata-rata HP tanaman non-defender di katalog adalah:
$$\text{Rata-rata HP} \approx \frac{50 + 55}{2} = 52.5\text{ HP}$$
$$\text{HP Tameng Sitrus} = 220.0 > 52.5 \quad \text{✅ Lolos Uji Validasi R4}$$

### 2.3 Skema Peningkatan Level (Level 1 - 5)
Formula: $\text{HP}(L) = 220 \times (1.0 + 0.20 \times (L - 1))$

| Level Tanaman | Health Point (HP) | Efek Passive Armor | Biaya Upgrade | Syarat Level Rumah 🟢 |
| :---: | :---: | :---: | :---: | :---: |
| **Lv 1** | 220.0 | -3 Flat Dmg | – | Rumah Lv 1 |
| **Lv 2** | 264.0 | -4 Flat Dmg | 75 | Rumah Lv 2 |
| **Lv 3** | 308.0 | -5 Flat Dmg | 112 | Rumah Lv 3 |
| **Lv 4** | 352.0 | -6 Flat Dmg | 168 | Rumah Lv 4 |
| **Lv 5** | 396.0 | -7 Flat Dmg | 252 | Rumah Lv 5 |

---

## 3. Spesifikasi Mekanik Skill & Passive ⚙️ [REKAYASA DESAIN]

### 3.1 Skill Passive: *Tameng Kulit Tebal (Citrus Peel Armor)*
- Mengurangi damage fisik yang diterima sebesar **3 flat** (Level 1).
- Batas minimum damage yang diterima tetap **1 damage** (tidak boleh kebal total 0).
- 🟢 **Kepatuhan R2**: Tameng Sitrus **tidak memiliki duri/pantulan damage (no damage reflection/thorns)**, karena hanya Damage Dealer yang berhak mengurangi HP musuh!

### 3.2 Skill Aktif (CC): *Hentakan Sari Jeruk (Citrus Bash)*
- Setiap **4.0 detik**, jika terdapat minimal 1 musuh di dalam radius melee 40px:
  - Memancarkan gelombang semprotan asam sitrus.
  - Memberikan efek Crowd Control **SLOW 35%** selama 2.0 detik kepada musuh di sekitar.
  - Mendorong musuh mundur (**KNOCKBACK**) sejauh **20 piksel** menjauhi Tameng Sitrus.
  - Damage yang dihasilkan: **0 (Nol)**.

---

## 4. Node Hierarchy & Struktur Scene 🔵 [TEKNIS GODOT]

Scene: `res://src/entities/plants/defender/tameng_sitrus.tscn`

```text
TamengSitrus (Node2D, inherits base_plant.tscn, script: tameng_sitrus.gd)
├── VisualSprite (AnimatedSprite2D, animasi: idle, shield_block, bash)
├── HealthComponent (Node, max_health = 220.0)
├── StatusEffectReceiver (Node, can_receive_debuff = true)
├── HurtboxComponent (Area2D, collision_layer = 2, collision_mask = 0)
├── BashArea (Area2D, collision_layer = 0, collision_mask = 4)
│   └── BashRadiusShape (CollisionShape2D, Circle radius = 40.0)
├── BashTimer (Timer, wait_time = 4.0, autostart = true)
└── CitrusBashVFX (GPUParticles2D, partikel percikan jeruk kuning-oranye)
```

---

## 5. Implementasi GDScript `TamengSitrus` 🔵 [TEKNIS GODOT]

File: `res://src/entities/plants/defender/tameng_sitrus.gd`

```gdscript
class_name TamengSitrus
extends BasePlant

@onready var bash_area: Area2D = $BashArea
@onready var bash_timer: Timer = $BashTimer
@onready var bash_vfx: GPUParticles2D = $CitrusBashVFX
@onready var hurtbox: HurtboxComponent = $HurtboxComponent

var flat_armor: float = 3.0

func _ready() -> void:
	super._ready()
	bash_timer.timeout.connect(_on_bash_timer_timeout)
	
	# Intersepsi damage masuk untuk menerapkan passive armor
	if hurtbox:
		hurtbox.tree_entered.connect(_setup_armor_interceptor)

func _setup_armor_interceptor() -> void:
	# Hubungkan modifikasi damage masuk melalui HealthComponent
	pass

# ⚙️ [REKAYASA DESAIN] Override penerimaan hit dengan pengurangan armor
func apply_armor_reduction(incoming_damage: float) -> float:
	flat_armor = 3.0 + (current_level - 1) * 1.0
	var final_damage: float = max(1.0, incoming_damage - flat_armor)
	return final_damage

func _on_bash_timer_timeout() -> void:
	var overlapping_areas: Array[Area2D] = bash_area.get_overlapping_areas()
	var targets_found: bool = false
	
	for area in overlapping_areas:
		var enemy: BaseEnemy = area.owner as BaseEnemy
		if enemy and is_instance_valid(enemy):
			targets_found = true
			_apply_citrus_bash(enemy)
			
	if targets_found:
		visual_sprite.play("bash")
		bash_vfx.restart()

func _apply_citrus_bash(enemy: BaseEnemy) -> void:
	# 🟢 [SKETCH: Aturan R4] - Menerapkan CC Slow dan Knockback eksklusif Defender
	var receiver: StatusEffectReceiver = enemy.get_node_or_null("StatusEffectReceiver")
	if receiver:
		receiver.apply_cc(Constants.CrowdControlType.SLOW, 2.0, Constants.PlantRole.DEFENDER)
		
	# Efek fisik dorongan mundur (Knockback 20px)
	var push_direction: Vector2 = (enemy.global_position - global_position).normalized()
	if push_direction == Vector2.ZERO:
		push_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	enemy.position += push_direction * 20.0
```

---

## 6. File Definisi Data Resource (`tameng_sitrus.tres`) 🔵 [TEKNIS GODOT]

File: `res://src/resources/data/plants/tameng_sitrus.tres`

```text
[gd_resource type="Resource" script_class="PlantStats" load_steps=3 format=3]

[ext_resource type="Script" path="res://src/resources/schemas/plant_stats.gd" id="1_stats"]
[ext_resource type="PackedScene" path="res://src/entities/plants/defender/tameng_sitrus.tscn" id="2_scene"]

[resource]
script = ExtResource("1_stats")
id = &"tameng_sitrus"
display_name = "Tameng Sitrus"
role = 2 # Constants.PlantRole.DEFENDER
rarity = 0 # Constants.Rarity.COMMON
cost = 50
base_hp = 220.0
base_dps = 0.0 # Wajib 0 untuk Defender 🟢
passive_description = "Kulit Jeruk Tebal: Mengurangi damage fisik yang diterima sebesar 3 poin (min 1). Hentakan Sari Jeruk: Menghembuskan slow 35% dan knockback tiap 4 detik."
attack_range = 40.0
unlock_house_level = 1
scene = ExtResource("2_scene")
```

---

## 7. Matriks QA & Kriteria Penerimaan

- [ ] **T-SITRUS-01 (Kepatuhan R1)**: `stats.role == DEFENDER` secara tunggal tanpa atribut Damage Dealer.
- [ ] **T-SITRUS-02 (Kepatuhan R2)**: Tameng Sitrus tidak memicu pengurangan HP pada musuh mana pun (damage output = 0).
- [ ] **T-SITRUS-03 (Kepatuhan R4)**: Base HP 220 terbukti lebih tinggi daripada rata-rata seluruh tanaman non-defender.
- [ ] **T-SITRUS-04 (Crowd Control)**: Saat timer berdetik, musuh dalam radius 40px terdorong mundur 20px dan terkena status `SLOW`.
