class_name EnemyStats
extends Resource

@export_group("Identitas & Visual")
@export var id: StringName = &"katak_penyembur"
@export var display_name: String = "Katak Penyembur"
@export var texture: Texture2D
@export var scene: PackedScene

@export_group("Klasifikasi & Ekonomi")
@export var attack_type: Constants.AttackType = Constants.AttackType.MELEE
@export_range(0, 1000, 1) var reward_amount: int = 10

@export_group("Statistik Pertempuran Dasar")
@export_range(1.0, 50000.0, 1.0) var base_max_hp: float = 50.0
@export_range(5.0, 500.0, 1.0) var move_speed: float = 35.0
@export_range(0.0, 1000.0, 0.5) var attack_damage: float = 10.0
@export_range(0.1, 10.0, 0.05) var attack_cooldown: float = 1.2
@export_range(10.0, 600.0, 1.0) var attack_range: float = 28.0
