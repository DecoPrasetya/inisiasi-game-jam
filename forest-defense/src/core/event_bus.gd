extends Node
# (Konstanta lainnya tetap di sini...)

# --- Alur Siklus Game ---
signal game_phase_changed(old_phase: Constants.GamePhase, new_phase: Constants.GamePhase)
signal day_started(day_number: int)
signal night_started(day_number: int)
signal night_ended(day_number: int)
signal game_over(days_survived: int)

# --- Ekonomi & Sumber Daya ---
signal resource_changed(current_balance: int, delta: int)
signal enemy_killed(reward_amount: int, enemy_id: StringName, death_position: Vector2)

# --- Entitas Rumah ---
signal house_health_changed(current_hp: float, max_hp: float)
signal house_upgraded(new_level: int, new_plant_space: int, max_plant_level: int)
signal house_destroyed()

# --- Entitas Tanaman ---
signal plant_placement_requested(plant_id: StringName, grid_cell: Vector2i)
signal plant_placed(plant_id: StringName, grid_cell: Vector2i, instance: Node2D)
signal plant_removed(grid_cell: Vector2i)
signal plant_upgraded(grid_cell: Vector2i, new_level: int)
signal plant_health_changed(grid_cell: Vector2i, current_hp: float, max_hp: float)

# --- Gelombang & Musuh ---
signal wave_spawn_started(day_number: int, total_enemies: int)
signal enemy_spawned(enemy_node: Node2D, side: Constants.SpawnSide)
signal enemy_count_changed(remaining_enemies: int)
