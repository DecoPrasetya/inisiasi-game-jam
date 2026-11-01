class_name WaveData
extends Resource

@export var day_number: int = 1
@export var enemy_pool: Array[EnemyStats] = []
@export var min_spawn_interval: float = 0.8
@export var max_spawn_interval: float = 2.5

# Total Musuh(N) = 4 + 2 * (N - 1)
static func calculate_total_enemies(day: int) -> int:
	var valid_day: int = maxi(1, day)
	return 4 + 2 * (valid_day - 1)

# HP Multiplier(N) = 1.0 + 0.06 * (N - 1)
static func calculate_hp_multiplier(day: int) -> float:
	var valid_day: int = maxi(1, day)
	return 1.0 + 0.06 * float(valid_day - 1)
