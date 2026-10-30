# 📐 TRD-008: Plant Base Framework

> **Technical Reference Document (TRD) - Kerangka Dasar & Siklus Hidup Tanaman**  
> ID Modul: **TRD-008**  
> Sumber Kebenaran: 🟢 **[SKETCH: Atribut Tanaman, Aturan R1, R6]**, 📘 **[PRD: 5.2, 11.3, 11.4]**, ⚙️ **[REKAYASA DESAIN: Formula Upgrade & Jangkauan]**, 🔵 **[TEKNIS GODOT]**  
> Penanggung Jawab: **Programmer 2**

---

## 1. Deskripsi Modul & Lingkup Kerja

Modul ini adalah pondasi pewarisan bagi seluruh tanaman pembela di game:
1. Memastikan setiap tanaman memiliki 5 atribut dasar sketch: **Role** (satu role mutlak), **Skill Passive**, **Cost**, **Health Point**, dan **Rarity**.
2. Menegakkan **Aturan R1**: Tanaman hanya terikat pada tepat satu role (`DAMAGE_DEALER`, `SUPPORTER`, atau `DEFENDER`).
3. Menegakkan **Aturan R6**: Level peningkatan tanaman tidak boleh melebihi level Rumah saat ini.
4. Mengelola deteksi musuh/kawan dalam radius serang serta siklus hidup (penempatan, upgrade, dan kematian).

---

## 2. Formula Progresi Stat & Biaya Upgrade ⚙️ [REKAYASA DESAIN]

Setiap tanaman dimulai pada Level 1. Saat ditingkatkan ke level $L$:
1. **Peningkatan HP Maksimum**:
   $$\text{HP}(L) = \text{base\_hp} \times (1.0 + 0.20 \times (L - 1))$$
2. **Peningkatan Stat Utama (DPS / Kuat Heal / Kuat CC)**:
   $$\text{Stat}(L) = \text{base\_stat} \times (1.0 + 0.20 \times (L - 1))$$
3. **Biaya Upgrade ke Level $L$**:
   $$\text{Biaya}(L) = \text{round}\left( \text{base\_cost} \times 1.5^{(L - 1)} \right)$$

---

## 3. Node Hierarchy & Struktur Scene 🔵 [TEKNIS GODOT]

Scene: `res://src/entities/plants/base_plant.tscn`

```text
BasePlant (Node2D, script: base_plant.gd, y_sort_enabled = true)
├── VisualSprite (AnimatedSprite2D)
├── HealthComponent (Node, max_health = diisi dari stats)
├── StatusEffectReceiver (Node, can_receive_debuff = true)
├── HurtboxComponent (Area2D, collision_layer = 2, collision_mask = 0)
│   └── Shape (CollisionShape2D, elips alas tanaman)
├── DetectionArea (Area2D, collision_layer = 0, collision_mask = 4)
│   └── RangeShape (CollisionShape2D, lingkaran jangkauan)
├── ActionTimer (Timer, pemicu serangan/heal/aura)
└── SelectionRing (Sprite2D, visual seleksi lingkaran saat di-klik)
```

---

## 4. Skema Data Resource (`PlantStats`) 🔵 [TEKNIS GODOT]

File: `res://src/resources/schemas/plant_stats.gd`

```gdscript
class_name PlantStats
extends Resource

@export_group("Identitas & Atribut Wajib 🟢")
@export var id: StringName
@export var display_name: String
@export var role: Constants.PlantRole # 🟢 Tepat satu role
@export var rarity: Constants.Rarity
@export var cost: int = 50
@export var base_hp: float = 60.0
@export_multiline var passive_description: String

@export_group("Parameter Tempur ⚙️")
@export var base_dps: float = 0.0 # Wajib >= 1.0 khusus Damage Dealer 🟢
@export var base_attack_interval: float = 1.0
@export var attack_range: float = 120.0
@export var unlock_house_level: int = 1

@export_group("Visual & Scene 🔵")
@export var preview_texture: Texture2D
@export var scene: PackedScene
```

---

## 5. Implementasi GDScript `BasePlant` 🔵 [TEKNIS GODOT]

File: `res://src/entities/plants/base_plant.gd`

```gdscript
class_name BasePlant
extends Node2D

signal plant_clicked(plant_node: BasePlant)
signal plant_died()

@export var stats: PlantStats

@onready var health_component: HealthComponent = $HealthComponent
@onready var status_receiver: StatusEffectReceiver = $StatusEffectReceiver
@onready var visual_sprite: AnimatedSprite2D = $VisualSprite
@onready var detection_area: Area2D = $DetectionArea
@onready var action_timer: Timer = $ActionTimer
@onready var selection_ring: Sprite2D = $SelectionRing

var current_level: int = 1
var active_targets: Array[Node2D] = []

func _ready() -> void:
	selection_ring.visible = false
	_init_stats()
	health_component.died.connect(_on_died)
	detection_area.area_entered.connect(_on_target_entered)
	detection_area.area_exited.connect(_on_target_exited)
	action_timer.timeout.connect(_on_action_timer_timeout)

func _init_stats() -> void:
	if not stats:
		return
	health_component.set_max_health(stats.base_hp)
	action_timer.wait_time = stats.base_attack_interval
	
	# Bentuk radius jangkauan
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = stats.attack_range
	$DetectionArea/RangeShape.shape = circle

# 🟢 [SKETCH: R6] Batasan Level Upgrade Tanaman
func can_upgrade() -> bool:
	var house_max_lvl: int = GameManager.get_max_plant_level_cap()
	if current_level >= house_max_lvl:
		return false # Diblokir Aturan R6
		
	var upgrade_cost: int = get_upgrade_cost()
	return GameManager.has_enough_resource(upgrade_cost)

func get_upgrade_cost() -> int:
	return int(round(stats.cost * pow(1.5, current_level)))

func upgrade_plant() -> bool:
	if not can_upgrade():
		return false
		
	var cost: int = get_upgrade_cost()
	GameManager.spend_resource(cost)
	current_level += 1
	
	# Tingkatkan HP Maksimum (+20% per level)
	var new_max_hp: float = stats.base_hp * (1.0 + 0.20 * (current_level - 1))
	health_component.set_max_health(new_max_hp)
	health_component.heal(new_max_hp * 0.20)
	
	EventBus.plant_upgraded.emit(stats.id, current_level)
	return true

func _on_target_entered(area: Area2D) -> void:
	var target_entity: Node2D = area.owner as Node2D
	if target_entity and not active_targets.has(target_entity):
		active_targets.append(target_entity)
		if action_timer.is_stopped():
			action_timer.start()

func _on_target_exited(area: Area2D) -> void:
	var target_entity: Node2D = area.owner as Node2D
	if target_entity and active_targets.has(target_entity):
		active_targets.erase(target_entity)
		if active_targets.is_empty():
			action_timer.stop()

# Virtual method yang di-override oleh kelas turunan tanaman spesifik
func _on_action_timer_timeout() -> void:
	pass

func _on_died() -> void:
	plant_died.emit()
	queue_free()

func set_selected(is_selected: bool) -> void:
	selection_ring.visible = is_selected
```

---

## 6. Matriks QA & Kriteria Penerimaan

- [ ] **T-BASEPLANT-01**: Setiap instansiasi tanaman membaca `PlantStats` dan memiliki nilai HP, Cost, dan Role yang sesuai.
- [ ] **T-BASEPLANT-02**: Saat Rumah berada di Level 2, memanggil `upgrade_plant()` pada tanaman Level 2 mengembalikan `false` dan tidak memotong saldo (Aturan R6).
- [ ] **T-BASEPLANT-03**: Saat HP tanaman mencapai 0, `plant_died` terpancar, plot lahan dibebaskan, dan node dihapus dari tree.
