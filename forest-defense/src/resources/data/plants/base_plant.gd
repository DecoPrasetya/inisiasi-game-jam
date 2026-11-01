class_name BasePlant
extends Node2D

## Sinyal wajib untuk TRD-002 agar GridPlacementManager menghapus plot saat tanaman mati
signal plant_died()

@export var stats: PlantStats

## Koordinat sel di grid (diisi otomatis saat ditanam oleh GridPlacementManager)
var grid_cell: Vector2i = Vector2i.ZERO
var current_level: int = 1

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")


func _ready() -> void:
	# Inisialisasi dari PlantStats jika tersedia
	if stats != null:
		setup_from_stats(stats)

func setup_from_stats(plant_data: PlantStats, cell: Vector2i = Vector2i.ZERO) -> void:
	stats = plant_data
	grid_cell = cell
	
	if sprite != null and stats.preview_texture != null and sprite.texture == null:
		sprite.texture = stats.preview_texture
		
