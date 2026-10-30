# 📐 TRD-002: Diamond Grid & Plant Placement System

> **Technical Reference Document (TRD) - Grid Isometrik & Penanaman**  
> ID Modul: **TRD-002**  
> Sumber Kebenaran: 🟢 **[SKETCH: Mapping CoC Belah Ketupat, Space Tanaman R7]**, 📘 **[PRD: 4.3, 9.2]**, ⚙️ **[REKAYASA DESAIN: Matematika Isometrik 2:1]**, 🔵 **[TEKNIS GODOT]**  
> Penanggung Jawab: **Programmer 1**

---

## 1. Deskripsi Modul & Lingkup Kerja

Modul ini bertanggung jawab atas:
1. Membangun representasi matematis dan visual dari grid isometrik berbentuk belah ketupat (diamond) 11×11.
2. Melakukan konversi bolak-balik antara koordinat grid (`Vector2i`) dan koordinat dunia (`Vector2`).
3. Mengontrol penempatan tanaman, validasi lahan, penandaan area terlarang (tapak Rumah 3×3 di pusat), serta penegakan batas kapasitas **Space Tanaman (R7)**.
4. Memberikan feedback visual (ghost preview) saat kursor memilih plot tanam.

---

## 2. Matematika Grid Isometrik Belah Ketupat ⚙️ [REKAYASA DESAIN]

### 2.1 Parameter Tile & Ukuran Grid
- **Rasio Proyeksi**: Isometrik standar 2:1
- **Lebar Sel (Tile Width, $W$)**: `64` px
- **Tinggi Sel (Tile Height, $H$)**: `32` px
- **Setengah Lebar ($hw$)**: $32.0$ px
- **Setengah Tinggi ($hh$)**: $16.0$ px
- **Sistem Koordinat Grid**: Berpusat di $(0, 0)$
- **Batas Diamond**: Radius grid $R = 5$ sel (total diagonal $11$ sel, dari $-5$ sampai $+5$)
  $$\text{Valid if: } |x| + |y| \le 5$$
- **Area Tapak Rumah (Footprint)**: Kotak $3 \times 3$ di pusat grid
  $$\text{House Area: } |x| \le 1 \text{ AND } |y| \le 1$$

```text
               (0, -5)                  <- Puncak Utara (NW/NE Corner)
               /     \
       (-5, 0)    ■    (5, 0)           <- Barat Daya / Tenggara
               \     /
               (0, 5)                   <- Ujung Selatan (SW/SE Corner)

■ = Area Terlarang Tapak Rumah 3x3 (-1..1, -1..1)
```

### 2.2 Rumus Transformasi Koordinat 🔵 [TEKNIS GODOT]

**Dari Grid ke Dunia (Grid to World):**
$$X_{world} = (grid.x - grid.y) \times hw$$
$$Y_{world} = (grid.x + grid.y) \times hh$$

**Dari Dunia ke Grid (World to Grid):**
$$grid.x = \text{round}\left( \frac{X_{world} / hw + Y_{world} / hh}{2} \right)$$
$$grid.y = \text{round}\left( \frac{Y_{world} / hh - X_{world} / hw}{2} \right)$$

---

## 3. Node Hierarchy & Struktur Scene 🔵 [TEKNIS GODOT]

Scene: `res://src/systems/grid_placement/planting_grid.tscn`

```text
PlantingGrid (Node2D, script: grid_placement_manager.gd)
├── TileMapLayer (TileSet Isometrik 64x32)
├── PlantContainer (Node2D, y_sort_enabled = true)
├── GhostPreview (Sprite2D, modulate = Color(0, 1, 0, 0.5))
│   └── RangeIndicator (Line2D, visual radius lingkaran jangkauan)
└── SelectionHighlight (Polygon2D, highlight belah ketupat pada sel aktif)
```

---

## 4. Spesifikasi Logika Penanaman & Validasi 🔵 [TEKNIS GODOT]

File: `res://src/systems/grid_placement/grid_placement_manager.gd`

```gdscript
class_name GridPlacementManager
extends Node2D

const TILE_HALF_WIDTH: float = 32.0
const TILE_HALF_HEIGHT: float = 16.0
const GRID_RADIUS: int = 5

@onready var plant_container: Node2D = $PlantContainer
@onready var ghost_preview: Sprite2D = $GhostPreview
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

var occupied_plots: Dictionary = {} # Vector2i -> Node2D
var active_selected_plant_data: PlantStats = null
var current_hovered_cell: Vector2i = Vector2i(999, 999)

func _ready() -> void:
	ghost_preview.visible = false
	EventBus.plant_placement_requested.connect(_on_placement_requested)

func _unhandled_input(event: InputEvent) -> void:
	if active_selected_plant_data == null:
		return
		
	if event is InputEventMouseMotion:
		_update_ghost_position(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_attempt_place_at_hovered_cell()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		cancel_placement()

func select_plant_for_placement(plant_data: PlantStats) -> void:
	active_selected_plant_data = plant_data
	ghost_preview.texture = plant_data.preview_texture
	ghost_preview.visible = true

func cancel_placement() -> void:
	active_selected_plant_data = null
	ghost_preview.visible = false

# --- Validasi Matematis & Aturan Game ---
func is_cell_valid_for_planting(cell: Vector2i) -> bool:
	# 1. Cek batas diamond 11x11 (|x| + |y| <= 5)
	if abs(cell.x) + abs(cell.y) > GRID_RADIUS:
		return false
		
	# 2. Cek area footprint Rumah 3x3 di pusat 🟢 [SKETCH]
	if abs(cell.x) <= 1 and abs(cell.y) <= 1:
		return false
		
	# 3. Cek apakah plot sudah terisi tanaman lain
	if occupied_plots.has(cell) and occupied_plots[cell] != null:
		return false
		
	# 4. Penegakan Aturan R7: Jumlah tanaman tidak boleh melebihi Space Tanaman Rumah 🟢 [SKETCH]
	var current_plant_count: int = occupied_plots.size()
	var house_space_limit: int = GameManager.get_current_house_space()
	if current_plant_count >= house_space_limit:
		return false
		
	return true

func grid_to_world(cell: Vector2i) -> Vector2:
	var wx: float = (cell.x - cell.y) * TILE_HALF_WIDTH
	var wy: float = (cell.x + cell.y) * TILE_HALF_HEIGHT
	return Vector2(wx, wy)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	var gx: float = (world_pos.x / TILE_HALF_WIDTH + world_pos.y / TILE_HALF_HEIGHT) / 2.0
	var gy: float = (world_pos.y / TILE_HALF_HEIGHT - world_pos.x / TILE_HALF_WIDTH) / 2.0
	return Vector2i(round(gx), round(gy))

func _update_ghost_position(mouse_pos: Vector2) -> void:
	var local_mouse: Vector2 = to_local(mouse_pos)
	current_hovered_cell = world_to_grid(local_mouse)
	ghost_preview.position = grid_to_world(current_hovered_cell)
	
	if is_cell_valid_for_planting(current_hovered_cell):
		ghost_preview.modulate = Color(0.2, 1.0, 0.2, 0.6) # Hijau = Valid
	else:
		ghost_preview.modulate = Color(1.0, 0.2, 0.2, 0.6) # Merah = Terlarang

func _attempt_place_at_hovered_cell() -> void:
	if not is_cell_valid_for_planting(current_hovered_cell):
		return
		
	# Cek ketersediaan resource ekonomi 🟢 [SKETCH]
	if not GameManager.has_enough_resource(active_selected_plant_data.cost):
		return
		
	GameManager.spend_resource(active_selected_plant_data.cost)
	_instantiate_plant(active_selected_plant_data, current_hovered_cell)
	cancel_placement()

func _instantiate_plant(data: PlantStats, cell: Vector2i) -> void:
	var plant_inst: Node2D = data.scene.instantiate() as Node2D
	plant_inst.position = grid_to_world(cell)
	plant_container.add_child(plant_inst)
	occupied_plots[cell] = plant_inst
	
	# Hubungkan sinyal kematian tanaman untuk membebaskan lahan
	if plant_inst.has_signal("plant_died"):
		plant_inst.plant_died.connect(func(): _on_plant_died(cell))
		
	EventBus.plant_placed.emit(data.id, cell, plant_inst)

func _on_plant_died(cell: Vector2i) -> void:
	if occupied_plots.has(cell):
		occupied_plots.erase(cell)
		EventBus.plant_removed.emit(cell)
```

---

## 5. Matriks QA & Kriteria Penerimaan

- [ ] **T-GRID-01**: Titik koordinat pusat `(0, 0)` dan area `[-1..1, -1..1]` tidak bisa ditanami (selalu ditolak karena milik Rumah).
- [ ] **T-GRID-02**: Sel di luar belah ketupat (misal `(3, 3)` di mana $|3| + |3| = 6 > 5$) menghasilkan `is_cell_valid_for_planting() == false`.
- [ ] **T-GRID-03**: Menanam saat `occupied_plots.size() == house.plant_space` langsung diblokir (Aturan R7).
- [ ] **T-GRID-04**: Ketika tanaman mati, plot terkait langsung dihapus dari kamus `occupied_plots` dan dapat ditanami kembali tanpa pengembalian uang (no refund).
