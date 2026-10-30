# 📐 TRD-010: Modul Tanaman Spesifik - Pembazoka Kuning

> **Technical Reference Document (TRD) - Spesifikasi Teknis Tanaman Pembazoka Kuning**  
> ID Modul: **TRD-010**  
> Sumber Kebenaran: 🟢 **[SKETCH: Aturan Damage Dealer R2]**, 🟢 **[LIST TANAMAN: Pembazoka Kuning]**, 📘 **[PRD: 5.2.1, 7.1]**, ⚙️ **[REKAYASA DESAIN: DPS 15.0 Konstan, Roket Area, Reload 3.5s]**, 🔵 **[TEKNIS GODOT]**  
> Penanggung Jawab: **Programmer 2**

---

## 1. Deskripsi Karakter & Identitas Modul

**Pembazoka Kuning** adalah artileri tempur jarak jauh berkekuatan destruktif tinggi:
- **Visual Asli 🟢**: Buah pisang berhelm taktis yang memanggul senjata bazoka besar dengan amunisi roket pisang.
- **Role 🟢**: `DAMAGE_DEALER` (Satu role mutlak, Aturan R1).
- **Cost 🟢**: `220` Resource (*Kategori: Sangat Tinggi*).
- **Rarity 🟢**: `EPIC` (*Kategori: Luar Biasa*).
- **Kemampuan Inti 🟢**: Memiliki damage area (AOE) masif, jangkauan sangat jauh, namun dibatasi oleh jeda reload yang lama.

---

## 2. Rekayasa Matematika DPS Konstan ⚙️ [REKAYASA DESAIN]

🟢 **Kepatuhan Aturan R2**: Sketch mewajibkan damage konstan per detik tanpa angka acak (tanpa critical rate, tanpa random range).

### 2.1 Formula Perhitungan DPS Dasar (Level 1)
- **Jeda Tembak (Reload Cooldown)**: `3.5` detik
- **Damage per Ledakan Roket**: `52.5` Flat Damage
- **Perhitungan Kerusakan Per Detik (Constant DPS)**:
  $$\text{DPS Konstan} = \frac{\text{Damage per Tembakan}}{\text{Jeda Reload}} = \frac{52.5}{3.5} = 15.0 \text{ DPS}$$
  *Kepatuhan R2: $15.0 \ge 1.0$ (Memenuhi syarat minimum DPS Damage Dealer)*.
- **Radius Ledakan Area (AOE)**: `45.0` px
- **Jarak Tembak (Attack Range)**: `180.0` px (Jangkauan terjauh di lini belakang).
- **Base HP**: `45.0` (Unit kaca/fragile, butuh dilindungi Defender).
- **Syarat Buka Rumah (Unlock Level)**: Rumah Level 2.

### 2.2 Skema Peningkatan Level (Level 1 - 5)
Formula: $\text{Dmg}(L) = 52.5 \times (1.0 + 0.20 \times (L - 1))$

| Level Tanaman | Damage per Ledakan | DPS Konstan | Health Point | Biaya Upgrade | Syarat Level Rumah 🟢 |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **Lv 1** | 52.5 | 15.0 | 45.0 | – | Rumah Lv 2 |
| **Lv 2** | 63.0 | 18.0 | 54.0 | 330 | Rumah Lv 2 |
| **Lv 3** | 73.5 | 21.0 | 63.0 | 495 | Rumah Lv 3 |
| **Lv 4** | 84.0 | 24.0 | 72.0 | 742 | Rumah Lv 4 |
| **Lv 5** | 94.5 | 27.0 | 81.0 | 1,113 | Rumah Lv 5 |

---

## 3. Spesifikasi Proyektil Balistik (*Banana Rocket*) ⚙️ [REKAYASA DESAIN]

1. **Lintasan Parabola**: Roket pisang ditembakkan ke udara dan menukik melengkung menuju titik koordinat target.
2. **Detonasi Area (AOE)**: Saat mencapai koordinat tanah sasaran, proyektil meledak dalam radius $45$ px.
3. **Penerapan Aturan R2**: Hanya musuh (`Layer 3 - Enemies`) yang terkena pengurangan HP. Tidak ada efek CC (slow/stun dilarang keras karena hak eksklusif Defender).

---

## 4. Node Hierarchy & Struktur Scene 🔵 [TEKNIS GODOT]

### 4.1 Scene Tanaman: `pembazoka_kuning.tscn`
```text
PembazokaKuning (Node2D, inherits base_plant.tscn, script: pembazoka_kuning.gd)
├── VisualSprite (AnimatedSprite2D, animasi: idle, aim, shoot, reload)
├── HealthComponent (Node, max_health = 45.0)
├── StatusEffectReceiver (Node, can_receive_debuff = true)
├── HurtboxComponent (Area2D, collision_layer = 2, collision_mask = 0)
├── DetectionArea (Area2D, collision_layer = 0, collision_mask = 4)
│   └── RangeShape (CollisionShape2D, Circle radius = 180.0)
├── ReloadTimer (Timer, wait_time = 3.5, one_shot = true)
└── MuzzlePoint (Marker2D, titik moncong bazoka)
```

### 4.2 Scene Proyektil: `banana_rocket.tscn`
```text
BananaRocket (Node2D, script: banana_rocket.gd)
├── RocketSprite (Sprite2D, texture pisang berpendorong api)
├── SmokeTrail (GPUParticles2D, asap pembakaran mesin roket)
├── ExplosionHitbox (Area2D, collision_layer = 8, collision_mask = 4)
│   └── HitboxShape (CollisionShape2D, Circle radius = 45.0)
└── ExplosionVFX (GPUParticles2D, kobaran ledakan kuning pisang)
```

---

## 5. Implementasi GDScript `PembazokaKuning` 🔵 [TEKNIS GODOT]

File: `res://src/entities/plants/damage_dealer/pembazoka_kuning.gd`

```gdscript
class_name PembazokaKuning
extends BasePlant

@export var rocket_scene: PackedScene = preload("res://src/entities/plants/damage_dealer/banana_rocket.tscn")
@onready var muzzle_point: Marker2D = $MuzzlePoint
@onready var reload_timer: Timer = $ReloadTimer

var is_reloading: bool = false

func _ready() -> void:
	super._ready()
	reload_timer.timeout.connect(_on_reload_complete)

func _process(_delta: float) -> void:
	if not is_reloading and not active_targets.is_empty():
		var valid_target: BaseEnemy = _get_best_target()
		if valid_target:
			_fire_rocket(valid_target.global_position)

func _get_best_target() -> BaseEnemy:
	# Prioritaskan musuh yang berada paling dekat dengan Rumah (Vector2.ZERO)
	var best_enemy: BaseEnemy = null
	var min_distance_to_house: float = INF
	
	for enemy_node in active_targets:
		if is_instance_valid(enemy_node):
			var dist: float = enemy_node.global_position.distance_to(Vector2.ZERO)
			if dist < min_distance_to_house:
				min_distance_to_house = dist
				best_enemy = enemy_node as BaseEnemy
				
	return best_enemy

func _fire_rocket(target_pos: Vector2) -> void:
	is_reloading = true
	visual_sprite.play("shoot")
	
	var rocket: BananaRocket = rocket_scene.instantiate() as BananaRocket
	rocket.global_position = muzzle_point.global_position
	
	# Hitung damage konstan berdasarkan level dan buff
	var base_dmg: float = 52.5 * (1.0 + 0.20 * (current_level - 1))
	var final_dmg: float = status_receiver.calculate_stat("damage", base_dmg)
	
	rocket.launch(target_pos, final_dmg)
	get_tree().current_scene.add_child(rocket)
	
	visual_sprite.animation_finished.connect(func():
		if is_reloading:
			visual_sprite.play("reload")
	, CONNECT_ONE_SHOT)
	
	reload_timer.start(stats.base_attack_interval)

func _on_reload_complete() -> void:
	is_reloading = false
	visual_sprite.play("idle")
```

---

## 6. Implementasi GDScript `BananaRocket` (Balistik & AOE) 🔵 [TEKNIS GODOT]

File: `res://src/entities/plants/damage_dealer/banana_rocket.gd`

```gdscript
class_name BananaRocket
extends Node2D

@export var flight_duration: float = 0.8
@export var peak_height: float = 60.0

@onready var explosion_hitbox: Area2D = $ExplosionHitbox
@onready var rocket_sprite: Sprite2D = $RocketSprite
@onready var explosion_vfx: GPUParticles2D = $ExplosionVFX

var start_pos: Vector2
var target_pos: Vector2
var elapsed_time: float = 0.0
var damage_payload: float = 52.5
var is_detonated: bool = false

func launch(target: Vector2, dmg: float) -> void:
	start_pos = global_position
	target_pos = target
	damage_payload = dmg
	elapsed_time = 0.0
	is_detonated = false

func _process(delta: float) -> void:
	if is_detonated:
		return
		
	elapsed_time += delta
	var t: float = clamp(elapsed_time / flight_duration, 0.0, 1.0)
	
	# Interpolasi posisi horizontal
	var current_ground: Vector2 = start_pos.lerp(target_pos, t)
	# Lengkungan parabola balistik vertikal
	var arc_offset: float = -4.0 * peak_height * t * (1.0 - t)
	
	global_position = Vector2(current_ground.x, current_ground.y + arc_offset)
	
	# Rotasi menghadap sudut pergerakan roket
	rocket_sprite.rotation = (target_pos - start_pos).angle() + (t - 0.5) * 0.8
	
	if t >= 1.0:
		_detonate()

func _detonate() -> void:
	is_detonated = true
	rocket_sprite.visible = false
	explosion_vfx.restart()
	
	# Scan seluruh musuh di dalam radius AOE 45px
	var overlapping: Array[Area2D] = explosion_hitbox.get_overlapping_areas()
	for area in overlapping:
		if area is HurtboxComponent:
			# 🟢 [SKETCH: R2] - Memberikan damage dengan identitas DAMAGE_DEALER
			(area as HurtboxComponent).receive_hit(damage_payload, Constants.PlantRole.DAMAGE_DEALER, true)
			
	await get_tree().create_timer(0.4).timeout
	queue_free()
```

---

## 7. File Definisi Data Resource (`pembazoka_kuning.tres`) 🔵 [TEKNIS GODOT]

File: `res://src/resources/data/plants/pembazoka_kuning.tres`

```text
[gd_resource type="Resource" script_class="PlantStats" load_steps=3 format=3]

[ext_resource type="Script" path="res://src/resources/schemas/plant_stats.gd" id="1_stats"]
[ext_resource type="PackedScene" path="res://src/entities/plants/damage_dealer/pembazoka_kuning.tscn" id="2_scene"]

[resource]
script = ExtResource("1_stats")
id = &"pembazoka_kuning"
display_name = "Pembazoka Kuning"
role = 0 # Constants.PlantRole.DAMAGE_DEALER
rarity = 2 # Constants.Rarity.EPIC
cost = 220
base_hp = 45.0
base_dps = 15.0 # 🟢 DPS konstan = 52.5 dmg / 3.5s reload
base_attack_interval = 3.5
attack_range = 180.0
unlock_house_level = 2
passive_description = "Artileri Pisang: Menembakkan roket balistik berdaya ledak area 45px setiap 3.5 detik dengan damage konstan 52.5 poin tanpa variasi acak."
scene = ExtResource("2_scene")
```

---

## 8. Matriks QA & Kriteria Penerimaan

- [ ] **T-BAZOOKA-01 (Kepatuhan R1 & R2)**: Role bertipe `DAMAGE_DEALER`, dan hanya Pembazoka Kuning yang memicu event damage pada musuh.
- [ ] **T-BAZOOKA-02 (Determinisme DPS)**: Dalam pengujian 10 kali tembakan tanpa buff, damage yang keluar per tembakan selalu persis 52.5 (deviasi 0.0).
- [ ] **T-BAZOOKA-03 (Pemberian Damage AOE)**: 3 musuh yang bergerombol dalam radius 45px ledakan roket menerima pengurangan HP serempak.
- [ ] **T-BAZOOKA-04 (Larangan CC)**: Ledakan roket tidak menerapkan efek stun atau slow pada musuh (menjaga hak eksklusif Defender).
