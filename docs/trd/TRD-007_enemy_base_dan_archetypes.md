# 📐 TRD-007: Base Enemy Framework & Archetypes

> **Technical Reference Document (TRD) - Kerangka Dasar & Arketipe Musuh**  
> ID Modul: **TRD-007**  
> Sumber Kebenaran: 🟢 **[SKETCH: Atribut Hewan/Monster, Tipe Serangan, Deskripsi Skill]**, 📘 **[PRD: 5.3, 7.2]**, ⚙️ **[REKAYASA DESAIN: Stat Archetypes & AI Perilaku]**, 🔵 **[TEKNIS GODOT]**  
> Penanggung Jawab: **Programmer 3**

---

## 1. Deskripsi Modul & Lingkup Kerja

Modul ini mendefinisikan kerangka teknis seluruh hewan dan monster di dalam hutan:
1. Memastikan setiap musuh memiliki 3 atribut wajib sketch: **Health Point**, **Tipe Serangan** (`MELEE`, `RANGED`, `NON_ATTACKING`), dan **Deskripsi Kemampuan/Skill** yang jelas dan detail.
2. Mengelola pergerakan musuh dari sisi spawn menuju Rumah di pusat peta.
3. Mengatur penyerangan terhadap tanaman yang menghalangi atau Rumah jika musuh telah mencapainya.
4. Menjatuhkan reward *Resource* saat HP musuh mencapai 0.

---

## 2. Tabel Rekayasa Arketipe Musuh ⚙️ [REKAYASA DESAIN]

| Nama Musuh | Tipe Serangan 🟢 | HP Dasar | Speed | Dmg | Jeda | Range | Drop | Deskripsi Kemampuan Wajib 🟢 [SKETCH] |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **Serigala Hutan** *(Forest Wolf)* | `MELEE` | 40 | 75 | 6 | 1.0s | 24px | 6 | Serigala lincah yang berlari cepat menuju tanaman terdekat dari jalur masuknya. Menggigit target setiap 1 detik secara konstan tanpa henti hingga target hancur sebelum melanjutkan langkah ke Rumah. |
| **Babi Hutan Liar** *(Wild Boar)* | `MELEE` | 120 | 45 | 15 | 1.6s | 28px | 14 | Babi hutan bertubuh tebal yang menerobos pertahanan. Saat pertama kali mendeteksi tanaman dalam jarak 60px, ia melakukan sundulan cepat berkecepatan +40% yang memberikan damage awal ganda sebelum kembali ke ritme serang biasa. |
| **Katak Penyembur** *(Spitter Toad)* | `RANGED` | 36 | 35 | 8 | 2.0s | 120px | 9 | Katak beracun yang berhenti di kejauhan begitu mendeteksi target dalam jangkauan 120px. Meludahkan asam berkala setiap 2 detik dan sangat rentan hancur jika didekati karena nyawanya yang rendah. |
| **Dukun Lumut** *(Mossback Shaman)* | `NON_ATTACKING` | 75 | 30 | 0 | 0.0s | 0px | 18 | Dukun hutan purba yang sama sekali tidak memberi damage ke tanaman maupun Rumah. Memancarkan spora penyembuh yang memulihkan 4 HP per detik pada seluruh monster lain di sekitarnya dalam radius 80px. |

---

## 3. Node Hierarchy & Struktur Scene 🔵 [TEKNIS GODOT]

Scene: `res://src/entities/enemies/base_enemy.tscn`

```text
BaseEnemy (CharacterBody2D, script: base_enemy.gd, collision_layer = 4, collision_mask = 0)
├── VisualSprite (AnimatedSprite2D)
├── PhysicalCollision (CollisionShape2D, capsule kecil di tapak kaki)
├── HealthComponent (Node, max_health = diisi dari stats)
├── StatusEffectReceiver (Node, can_receive_debuff = true)
├── HurtboxComponent (Area2D, collision_layer = 4, collision_mask = 8)
├── AttackRangeArea (Area2D, collision_layer = 0, collision_mask = 2|1)
│   └── RangeShape (CollisionShape2D)
├── AttackTimer (Timer)
└── HealthBar (ProgressBar, visual HP bar di atas kepala)
```

---

## 4. Skema Data Resource (`EnemyStats`) 🔵 [TEKNIS GODOT]

File: `res://src/resources/schemas/enemy_stats.gd`

```gdscript
class_name EnemyStats
extends Resource

@export_group("Identitas & Deskripsi 🟢")
@export var id: StringName
@export var display_name: String
@export var attack_type: Constants.AttackType
@export_multiline var skill_description: String # Wajib minimal 2 kalimat / 80 karakter

@export_group("Statistik Tempur ⚙️")
@export var base_hp: float = 40.0
@export var move_speed: float = 50.0
@export var attack_damage: float = 6.0
@export var attack_interval: float = 1.0
@export var attack_range: float = 24.0
@export var reward: int = 6
```

---

## 5. Implementasi GDScript `BaseEnemy` 🔵 [TEKNIS GODOT]

File: `res://src/entities/enemies/base_enemy.gd`

```gdscript
class_name BaseEnemy
extends CharacterBody2D

@export var stats: EnemyStats

@onready var health_component: HealthComponent = $HealthComponent
@onready var status_receiver: StatusEffectReceiver = $StatusEffectReceiver
@onready var attack_timer: Timer = $AttackTimer
@onready var visual_sprite: AnimatedSprite2D = $VisualSprite
@onready var attack_area: Area2D = $AttackRangeArea

var current_target: Node2D = null
var current_move_speed: float = 50.0

func _ready() -> void:
	_init_stats()
	health_component.died.connect(_on_died)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_area.area_entered.connect(_on_target_detected)
	attack_area.area_exited.connect(_on_target_lost)

func _init_stats() -> void:
	if not stats:
		return
	health_component.set_max_health(stats.base_hp)
	current_move_speed = stats.move_speed
	attack_timer.wait_time = stats.attack_interval
	
	# Konfigurasi radius deteksi serang
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = stats.attack_range
	$AttackRangeArea/RangeShape.shape = circle

func apply_wave_scaling(hp_mult: float) -> void:
	var scaled_hp: float = stats.base_hp * hp_mult
	health_component.set_max_health(scaled_hp)

func _physics_process(delta: float) -> void:
	# Efek Crowd Control Stun/Root 🟢 [SKETCH: R4]
	if status_receiver.is_under_cc(Constants.CrowdControlType.STUN) or \
	   status_receiver.is_under_cc(Constants.CrowdControlType.ROOT):
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	# Perhitungan kecepatan gerak dengan modifikasi Buff/Debuff/Slow
	var final_speed: float = status_receiver.calculate_stat("speed", stats.move_speed)
	if status_receiver.is_under_cc(Constants.CrowdControlType.SLOW):
		final_speed *= 0.65 # Efek slow bawaan 35%
		
	if current_target != null:
		# Jika sedang bertarung atau menyerang, berhenti berjalan
		velocity = Vector2.ZERO
	else:
		# Bergerak menuju pusat (Rumah di koordinat Vector2.ZERO)
		var direction: Vector2 = (Vector2.ZERO - position).normalized()
		velocity = direction * final_speed
		
	move_and_slide()

func _on_target_detected(area: Area2D) -> void:
	# Musuh bertipe NON_ATTACKING dilarang menyerang target apa pun 🟢 [SKETCH]
	if stats.attack_type == Constants.AttackType.NON_ATTACKING:
		return
		
	if current_target == null and (area is HurtboxComponent or area is HouseEntity):
		current_target = area
		if attack_timer.is_stopped():
			attack_timer.start()
			_execute_attack() # Serangan pertama langsung dieksekusi

func _on_target_lost(area: Area2D) -> void:
	if current_target == area:
		current_target = null
		attack_timer.stop()

func _on_attack_timer_timeout() -> void:
	_execute_attack()

func _execute_attack() -> void:
	if current_target == null or not is_instance_valid(current_target):
		current_target = null
		attack_timer.stop()
		return
		
	var dmg: float = status_receiver.calculate_stat("damage", stats.attack_damage)
	
	if current_target is HurtboxComponent:
		(current_target as HurtboxComponent).receive_hit(dmg, -1, false)
	elif current_target.has_method("take_damage"):
		current_target.take_damage(dmg)

func _on_died() -> void:
	EventBus.enemy_killed.emit(stats.reward, stats.id, global_position)
	queue_free()
```

---

## 6. Matriks QA & Kriteria Penerimaan

- [ ] **T-ENEMY-01**: Seluruh data `EnemyStats` wajib memiliki `skill_description` dengan panjang $\ge 80$ karakter dan mendeskripsikan perilaku tempur secara detail.
- [ ] **T-ENEMY-02**: Musuh bertipe `NON_ATTACKING` (cth. Mossback Shaman) tidak pernah memicu serangan dan damage ke tanaman atau Rumah tetap 0.
- [ ] **T-ENEMY-03**: Saat musuh mati, memancarkan sinyal `enemy_killed` dengan payload nilai `reward` yang sesuai data `.tres`.
- [ ] **T-ENEMY-04**: Efek status `STUN` dari Defender langsung menghentikan pergerakan (`velocity = Vector2.ZERO`) dan menghentikan timer serang musuh.
