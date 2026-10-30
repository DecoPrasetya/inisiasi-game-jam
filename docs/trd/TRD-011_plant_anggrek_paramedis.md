# 📐 TRD-011: Modul Tanaman Spesifik - Anggrek Paramedis

> **Technical Reference Document (TRD) - Spesifikasi Teknis Tanaman Anggrek Paramedis**  
> ID Modul: **TRD-011**  
> Sumber Kebenaran: 🟢 **[SKETCH: Aturan Supporter R3]**, 🟢 **[LIST TANAMAN: Anggrek Paramedis]**, 📘 **[PRD: 5.2.2, 7.1]**, ⚙️ **[REKAYASA DESAIN: Heuristik Scan HP Terendah, Lempar Medkit, HPS 8.0]**, 🔵 **[TEKNIS GODOT]**  
> Penanggung Jawab: **Programmer 2**

---

## 1. Deskripsi Karakter & Identitas Modul

**Anggrek Paramedis** adalah unit medis garis belakang penopang ketahanan tim:
- **Visual Asli 🟢**: Bunga anggrek anggun yang membawa tas perlengkapan medis (medkit) bertanda palang hijau.
- **Role 🟢**: `SUPPORTER` (Satu role mutlak, Aturan R1).
- **Cost 🟢**: `110` Resource (*Kategori: Sedang*).
- **Rarity 🟢**: `RARE` (*Kategori: Langka*).
- **Kemampuan Inti 🟢**: Melempar medkit ke tanaman kawan yang terluka, dengan prioritas mutlak kepada tanaman yang memiliki jumlah sisa HP terendah di seluruh peta.

---

## 2. Rekayasa Matematika & Logika Penargetan ⚙️ [REKAYASA DESAIN]

### 2.1 Heuristik Penargetan (Lowest Absolute HP) 🟢 [SKETCH]
Sketch menentukan: *"prioritas ke tanaman dengan 'jumlah' hp paling rendah di map"*.
Algoritma pemindaian bekerja dengan tahapan:
1. Mengambil seluruh tanaman hidup di dalam `PlantContainer` serta entitas Rumah.
2. Memfilter hanya entitas yang mengalami kerusakan: $\text{current\_health} < \text{max\_health}$.
3. Jika seluruh tanaman dan Rumah berada pada 100% HP, Anggrek Paramedis **tidak melempar medkit** (menghemat amunisi obat).
4. Mengurutkan kandidat berdasarkan **sisa nilai absolut HP terkecil** ($\min(\text{current\_health})$).
5. Jika ada dua tanaman dengan HP yang sama persis, dipilih yang posisinya paling dekat dengan Anggrek Paramedis.

### 2.2 Parameter Pemulihan (Level 1)
- **Jeda Lempar (Toss Interval)**: `3.0` detik
- **Jumlah Heal per Medkit**: `24.0` HP
- **Kekuatan Pemulihan per Detik (Heal Per Second / HPS)**:
  $$\text{HPS} = \frac{24.0\text{ HP}}{3.0\text{ detik}} = 8.0\text{ HP/detik}$$
- **Jarak Lempar (Heal Range)**: Global / Seluruh Peta (Belah ketupat 11×11).
- **Base HP**: `55.0`
- **Damage Output**: `0.0` (🟢 **Aturan R2**: Dilarang mutlak menyerang musuh).
- **Crowd Control**: `None` (🟢 **Aturan R4**: CC hanya hak Defender).
- **Syarat Buka Rumah (Unlock Level)**: Rumah Level 2.

### 2.3 Skema Peningkatan Level (Level 1 - 5)
Formula: $\text{Heal}(L) = 24.0 \times (1.0 + 0.20 \times (L - 1))$

| Level Tanaman | Nilai Heal per Medkit | Nilai HPS | Health Point | Biaya Upgrade | Syarat Level Rumah 🟢 |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **Lv 1** | 24.0 HP | 8.0 HP/s | 55.0 | – | Rumah Lv 2 |
| **Lv 2** | 28.8 HP | 9.6 HP/s | 66.0 | 165 | Rumah Lv 2 |
| **Lv 3** | 33.6 HP | 11.2 HP/s | 77.0 | 247 | Rumah Lv 3 |
| **Lv 4** | 38.4 HP | 12.8 HP/s | 88.0 | 371 | Rumah Lv 4 |
| **Lv 5** | 43.2 HP | 14.4 HP/s | 99.0 | 556 | Rumah Lv 5 |

---

## 3. Node Hierarchy & Struktur Scene 🔵 [TEKNIS GODOT]

### 3.1 Scene Tanaman: `anggrek_paramedis.tscn`
```text
AnggrekParamedis (Node2D, inherits base_plant.tscn, script: anggrek_paramedis.gd)
├── VisualSprite (AnimatedSprite2D, animasi: idle, windup, toss, celebrate)
├── HealthComponent (Node, max_health = 55.0)
├── StatusEffectReceiver (Node, can_receive_debuff = true)
├── HurtboxComponent (Area2D, collision_layer = 2, collision_mask = 0)
├── TossMarker (Marker2D, titik lepas tas medkit)
└── HealTimer (Timer, wait_time = 3.0, autostart = true)
```

### 3.2 Scene Proyektil: `medkit_projectile.tscn`
```text
MedkitProjectile (Node2D, script: medkit_projectile.gd)
├── MedkitSprite (Sprite2D, tas dokter putih palang hijau)
├── SparkleTrail (GPUParticles2D, kilau salep penyembuh hijau lembut)
└── BurstHealVFX (GPUParticles2D, ledakan aura hati/silang hijau saat mendarat)
```

---

## 4. Implementasi GDScript `AnggrekParamedis` 🔵 [TEKNIS GODOT]

File: `res://src/entities/plants/supporter/anggrek_paramedis.gd`

```gdscript
class_name AnggrekParamedis
extends BasePlant

@export var medkit_scene: PackedScene = preload("res://src/entities/plants/supporter/medkit_projectile.tscn")
@onready var toss_marker: Marker2D = $TossMarker
@onready var heal_timer: Timer = $HealTimer

func _ready() -> void:
	super._ready()
	heal_timer.timeout.connect(_on_heal_timer_timeout)

func _on_heal_timer_timeout() -> void:
	var injured_target: Node2D = _find_most_injured_plant()
	if injured_target:
		_throw_medkit(injured_target)

# 🟢 [SKETCH] Heuristik Pencarian: Jumlah HP Paling Rendah di Seluruh Map
func _find_most_injured_plant() -> Node2D:
	var candidate_list: Array[Node2D] = []
	
	# 1. Kumpulkan seluruh tanaman di lahan
	var plant_container: Node2D = get_parent()
	if plant_container:
		for child in plant_container.get_children():
			if child is BasePlant and child != self and is_instance_valid(child):
				candidate_list.append(child)
				
	# 2. Masukkan Rumah ke dalam kandidat jika terluka 📘 [PRD: 5.1 & 5.2.2]
	var house: Node2D = get_tree().current_scene.get_node_or_null("House")
	if house and is_instance_valid(house):
		candidate_list.append(house)
		
	# 3. Cari entitas dengan current_health absolut paling kecil dan belum penuh
	var target_choice: Node2D = null
	var lowest_current_hp: float = INF
	
	for candidate in candidate_list:
		var hc: HealthComponent = candidate.get_node_or_null("HealthComponent")
		if hc and not hc.is_dead and hc.current_health < hc.max_health:
			if hc.current_health < lowest_current_hp:
				lowest_current_hp = hc.current_health
				target_choice = candidate
			elif is_equal_approx(hc.current_health, lowest_current_hp):
				# Pemecah seri: pilih yang berjarak lebih dekat
				if global_position.distance_to(candidate.global_position) < global_position.distance_to(target_choice.global_position):
					target_choice = candidate
					
	return target_choice

func _throw_medkit(target: Node2D) -> void:
	visual_sprite.play("toss")
	
	var medkit: MedkitProjectile = medkit_scene.instantiate() as MedkitProjectile
	medkit.global_position = toss_marker.global_position
	
	# Hitung nilai pemulihan berdasarkan level
	var heal_val: float = 24.0 * (1.0 + 0.20 * (current_level - 1))
	heal_val = status_receiver.calculate_stat("heal_power", heal_val)
	
	medkit.launch(target, heal_val)
	get_tree().current_scene.add_child(medkit)
```

---

## 5. Implementasi GDScript `MedkitProjectile` 🔵 [TEKNIS GODOT]

File: `res://src/entities/plants/supporter/medkit_projectile.gd`

```gdscript
class_name MedkitProjectile
extends Node2D

@export var flight_time: float = 0.7
@export var arc_height: float = 50.0

@onready var sprite: Sprite2D = $MedkitSprite
@onready var burst_vfx: GPUParticles2D = $BurstHealVFX

var target_node: Node2D
var start_pos: Vector2
var heal_amount: float = 24.0
var elapsed: float = 0.0
var is_delivered: bool = false

func launch(target: Node2D, amount: float) -> void:
	target_node = target
	heal_amount = amount
	start_pos = global_position
	elapsed = 0.0
	is_delivered = false

func _process(delta: float) -> void:
	if is_delivered:
		return
		
	elapsed += delta
	var t: float = clamp(elapsed / flight_time, 0.0, 1.0)
	
	# Lacak posisi target jika target bergerak/bergeser
	var dest_pos: Vector2 = target_node.global_position if is_instance_valid(target_node) else start_pos
	var current_ground: Vector2 = start_pos.lerp(dest_pos, t)
	var arc_offset: float = -4.0 * arc_height * t * (1.0 - t)
	
	global_position = Vector2(current_ground.x, current_ground.y + arc_offset)
	sprite.rotation += 10.0 * delta # Berputar di udara
	
	if t >= 1.0:
		_apply_heal_impact()

func _apply_heal_impact() -> void:
	is_delivered = true
	sprite.visible = false
	burst_vfx.restart()
	
	if is_instance_valid(target_node):
		var hc: HealthComponent = target_node.get_node_or_null("HealthComponent")
		if hc:
			# 🟢 [SKETCH: R3] Supporter memulihkan HP kawan
			hc.heal(heal_amount)
			
	await get_tree().create_timer(0.5).timeout
	queue_free()
```

---

## 6. File Definisi Data Resource (`anggrek_paramedis.tres`) 🔵 [TEKNIS GODOT]

File: `res://src/resources/data/plants/anggrek_paramedis.tres`

```text
[gd_resource type="Resource" script_class="PlantStats" load_steps=3 format=3]

[ext_resource type="Script" path="res://src/resources/schemas/plant_stats.gd" id="1_stats"]
[ext_resource type="PackedScene" path="res://src/entities/plants/supporter/anggrek_paramedis.tscn" id="2_scene"]

[resource]
script = ExtResource("1_stats")
id = &"anggrek_paramedis"
display_name = "Anggrek Paramedis"
role = 1 # Constants.PlantRole.SUPPORTER
rarity = 1 # Constants.Rarity.RARE
cost = 110
base_hp = 55.0
base_dps = 0.0 # Wajib 0 untuk Supporter 🟢
passive_description = "Lempar Medkit Medis: Melempar kotak obat berdaya sembuh 24 HP tiap 3 detik ke tanaman atau Rumah yang memiliki sisa poin nyawa paling kritis di seluruh map."
attack_range = 9999.0 # Global map-wide range
unlock_house_level = 2
scene = ExtResource("2_scene")
```

---

## 7. Matriks QA & Kriteria Penerimaan

- [ ] **T-ORCHID-01 (Kepatuhan R1 & R3)**: Role berlabel `SUPPORTER`. Mengirimkan heal ke kawan berhasil, dan tidak pernah memberi damage ke musuh (damage 0).
- [ ] **T-ORCHID-02 (Heuristik Penargetan)**: Diberikan 3 tanaman (Tanaman A HP 30/60, Tanaman B HP 15/60, Tanaman C HP 40/60). Medkit wajib terlempar ke **Tanaman B** (nilai absolut HP terendah = 15).
- [ ] **T-ORCHID-03 (Dukungan Rumah)**: Saat HP seluruh tanaman penuh namun Rumah terluka (misal HP 180/250), medkit wajib diarahkan dan menyembuhkan Rumah.
- [ ] **T-ORCHID-04 (Hemat Aksi)**: Saat HP seluruh tanaman dan Rumah berada pada 100%, timer tidak memunculkan proyektil medkit sia-sia.
