class_name PlantStats
extends Resource

@export_group("Identitas & Visual")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
# Tekstur yang muncul mengikuti kursor saat akan menanam (GhostPreview)
@export var preview_texture: Texture2D
# Scene tanaman (.tscn) yang akan di-instantiate
@export var scene: PackedScene

@export_group("Klasifikasi & Ekonomi")
@export var role: Constants.PlantRole = Constants.PlantRole.DAMAGE_DEALER
@export var rarity: Constants.Rarity = Constants.Rarity.COMMON
# Biaya pembelian tanaman yang akan dipotong dari GameManager
@export_range(0, 9999, 1) var cost: int = 25

@export_group("Statistik Dasar & Pertempuran")
@export_range(1.0, 10000.0, 1.0) var max_hp: float = 100.0
@export_range(0.0, 1000.0, 0.5) var attack_damage: float = 10.0
@export_range(0.1, 20.0, 0.05) var attack_speed: float = 1.0
# Jangkauan serang/area efek dalam satuan pixel (digunakan oleh RangeIndicator)
@export_range(0.0, 1000.0, 1.0) var attack_range: float = 160.0

@export_group("Efek Status & Crowd Control")
@export var applied_effects: Array[Resource] = []


# Fungsi bantu untuk mengecek DPS (Sesuai Constants.MIN_DAMAGE_DEALER_DPS)
func get_dps() -> float:
	return attack_damage * attack_speed
