# 📐 TRD-006: Wave Spawner & Enemy Director

> **Technical Reference Document (TRD) - Sistem Spawner 4-Sisi & Sutradara Gelombang**  
> ID Modul: **TRD-006**  
> Sumber Kebenaran: 🟢 **[SKETCH: Serangan 4 Sisi, Endless Scaling]**, 📘 **[PRD: 4.4, 6.4]**, ⚙️ **[REKAYASA DESAIN: Formula Pertumbuhan Musuh & Multiplier HP]**, 🔵 **[TEKNIS GODOT]**  
> Penanggung Jawab: **Programmer 1**

---

## 1. Deskripsi Modul & Lingkup Kerja

Modul ini mengatur ancaman malam hari yang menyerang dari belantara hutan:
1. Menghasilkan posisi spawn di luar batas lahan diamond dari **4 Sisi (4 Directions)**: `NORTH_EAST`, `SOUTH_EAST`, `SOUTH_WEST`, `NORTH_WEST`.
2. Menerapkan formula perkembangan tak terbatas (**Endless Scaling**) seiring pertambahan hari (jumlah musuh bertambah, HP bertumbuh, variasi musuh makin ganas).
3. Mendistribusikan musuh secara seimbang atau dengan fokus ancaman tertentu (*weighted flank*) agar pemain tidak menumpuk tanaman di satu sisi saja.
4. Mendeteksi selesainya malam saat seluruh musuh dalam gelombang telah berhasil dimusnahkan.

---

## 2. Geometri Spawn 4-Sisi Belah Ketupat ⚙️ [REKAYASA DESAIN]

Grid diamond beradius 5 sel ($R = 5$). Garis batas spawn diletakkan pada radius perimeter luar $R_{spawn} = 7$ sel:

```text
                           North (0, -7)
                           /           \
     [NORTH_WEST]         /             \         [NORTH_EAST]
                         /    ◇ ◇ ◇ ◇    \
       West (-7, 0)     /   ◇ ◇ ■ ■ ◇ ◇   \     East (7, 0)
                        \   ◇ ◇ ■ ■ ◇ ◇   /
     [SOUTH_WEST]        \    ◇ ◇ ◇ ◇    /        [SOUTH_EAST]
                          \             /
                           \           /
                           South (0, 7)
```

Titik spawn didistribusikan di sepanjang 4 garis tepi luar dengan interpolasi acak ($t \in [0.1, 0.9]$):
- **NORTH_EAST (NE)**: Garis dari `(0, -7)` ke `(7, 0)`
- **SOUTH_EAST (SE)**: Garis dari `(7, 0)` ke `(0, 7)`
- **SOUTH_WEST (SW)**: Garis dari `(0, 7)` ke `(-7, 0)`
- **NORTH_WEST (NW)**: Garis dari `(-7, 0)` ke `(0, -7)`

---

## 3. Formula Progresi Endless Hari demi Hari ⚙️ [REKAYASA DESAIN]

Untuk Hari ke-$N$:
1. **Total Jumlah Musuh per Malam**:
   $$\text{Total Musuh}(N) = 4 + 2 \times (N - 1)$$
   - *Hari 1*: 4 musuh (tepat 1 per sisi)
   - *Hari 2*: 6 musuh
   - *Hari 5*: 12 musuh (rata-rata 3 per sisi)
   - *Hari 10*: 22 musuh + Boss
2. **Pengganda HP Musuh (Health Scaling)**:
   $$\text{HP Mult}(N) = 1.0 + 0.06 \times (N - 1)$$
   - *Hari 1*: $1.0\times$ (100% HP dasar)
   - *Hari 5*: $1.24\times$ (124% HP)
   - *Hari 10*: $1.54\times$ (154% HP)
3. **Jeda Waktu Antar-Spawn (Stagger Interval)**:
   $$\text{Interval}(N) = \max(0.8, 2.5 - 0.1 \times (N - 1)) \text{ detik}$$

---

## 4. Skema Data Gelombang (`WaveData`) 🔵 [TEKNIS GODOT]

File: `res://src/resources/schemas/wave_data.gd`

```gdscript
class_name WaveData
extends Resource

class SpawnEntry:
	@export var enemy_scene: PackedScene
	@export var count: int = 1
	@export var side: Constants.SpawnSide
	@export var spawn_delay: float = 1.5

@export var day_number: int = 1
@export var hp_multiplier: float = 1.0
@export var spawn_queue: Array[SpawnEntry] = []
```

---

## 5. Implementasi GDScript Wave Spawner 🔵 [TEKNIS GODOT]

File: `res://src/systems/wave_spawner/wave_spawner.gd`

```gdscript
class_name WaveSpawner
extends Node2D

@export var enemy_container: Node2D
@export var enemy_catalog: Array[PackedScene] = [] # Daftar prefab musuh yang terbuka

var spawn_timer: Timer
var pending_spawns: Array[Dictionary] = [] # Array antrian spawn

func _ready() -> void:
	EventBus.night_started.connect(_on_night_started)
	
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_process_next_spawn)
	add_child(spawn_timer)

func _on_night_started(day: int) -> void:
	_generate_endless_wave(day)
	_process_next_spawn()

func _generate_endless_wave(day: int) -> void:
	pending_spawns.clear()
	var total_count: int = 4 + 2 * (day - 1) # ⚙️ Formula Endless
	var hp_mult: float = 1.0 + 0.06 * (day - 1)
	var sides: Array[Constants.SpawnSide] = [
		Constants.SpawnSide.NORTH_EAST,
		Constants.SpawnSide.SOUTH_EAST,
		Constants.SpawnSide.SOUTH_WEST,
		Constants.SpawnSide.NORTH_WEST
	]
	
	EventBus.wave_spawn_started.emit(day, total_count)
	
	for i in range(total_count):
		# Putar giliran sisi secara seimbang di awal, atau random di hari tinggi
		var chosen_side: Constants.SpawnSide = sides[i % 4]
		var enemy_scene: PackedScene = enemy_catalog[0] # Default tier 1
		
		# Variasi musuh terbuka seiring hari 📘 [PRD: 6.4]
		if day >= 3 and enemy_catalog.size() > 1 and i % 3 == 0:
			enemy_scene = enemy_catalog[1] # Tipe Ranged
		if day >= 6 and enemy_catalog.size() > 2 and i % 5 == 0:
			enemy_scene = enemy_catalog[2] # Tipe Tank/Non-Attacking
			
		pending_spawns.append({
			"scene": enemy_scene,
			"side": chosen_side,
			"hp_mult": hp_mult,
			"delay": max(0.8, 2.5 - 0.1 * (day - 1))
		})

func _process_next_spawn() -> void:
	if pending_spawns.is_empty():
		return
		
	var entry: Dictionary = pending_spawns.pop_front()
	_spawn_enemy(entry["scene"], entry["side"], entry["hp_mult"])
	
	if not pending_spawns.is_empty():
		spawn_timer.start(entry["delay"])

func _spawn_enemy(scene: PackedScene, side: Constants.SpawnSide, hp_mult: float) -> void:
	var enemy: BaseEnemy = scene.instantiate() as BaseEnemy
	enemy.position = _calculate_spawn_position(side)
	enemy_container.add_child(enemy)
	
	# Terapkan pengali HP gelombang
	enemy.apply_wave_scaling(hp_mult)
	
	EventBus.enemy_spawned.emit(enemy, side)

func _calculate_spawn_position(side: Constants.SpawnSide) -> Vector2:
	var hw: float = 32.0
	var hh: float = 16.0
	var t: float = randf_range(0.15, 0.85)
	var cell_pos: Vector2
	
	match side:
		Constants.SpawnSide.NORTH_EAST:
			cell_pos = Vector2(0, -7).lerp(Vector2(7, 0), t)
		Constants.SpawnSide.SOUTH_EAST:
			cell_pos = Vector2(7, 0).lerp(Vector2(0, 7), t)
		Constants.SpawnSide.SOUTH_WEST:
			cell_pos = Vector2(0, 7).lerp(Vector2(-7, 0), t)
		Constants.SpawnSide.NORTH_WEST:
			cell_pos = Vector2(-7, 0).lerp(Vector2(0, -7), t)
			
	var wx: float = (cell_pos.x - cell_pos.y) * hw
	var wy: float = (cell_pos.x + cell_pos.y) * hh
	return Vector2(wx, wy)
```

---

## 6. Matriks QA & Kriteria Penerimaan

- [ ] **T-WAVE-01**: Pada Hari 1, spawner memunculkan tepat 4 musuh, dengan masing-masing 1 musuh berasal dari tiap sisi mata angin (NE, SE, SW, NW).
- [ ] **T-WAVE-02**: Pada Hari 10, jumlah musuh yang dihasilkan adalah $4 + 2 \times 9 = 22$ musuh dengan HP multiplier $1.0 + 0.06 \times 9 = 1.54\times$.
- [ ] **T-WAVE-03**: Seluruh musuh yang di-spawn berada di luar batas lahan tanam ($|x| + |y| > 5$).
- [ ] **T-WAVE-04**: Sinyal `night_ended` baru terpancar setelah seluruh 22 musuh terbunuh tanpa tersisa.
