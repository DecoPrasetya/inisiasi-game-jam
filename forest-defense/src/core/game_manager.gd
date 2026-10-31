extends Node

@export var day_duration: float = Constants.DAY_DURATION_SECONDS

var current_phase: Constants.GamePhase = Constants.GamePhase.MENU
var current_day: int = 1
var day_timer: float = 0.0
var active_enemy_count: int = 0
var days_survived: int = 0

func _ready() -> void:
	EventBus.enemy_spawned.connect(_on_enemy_spawned)
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.house_destroyed.connect(_on_house_destroyed)

func _process(delta: float) -> void:
	if current_phase == Constants.GamePhase.DAY:
		day_timer -= delta
		if day_timer <= 0.0:
			start_night()

func start_new_game() -> void:
	current_day = 1
	days_survived = 0
	active_enemy_count = 0
	_set_phase(Constants.GamePhase.DAY)
	day_timer = day_duration
	EventBus.day_started.emit(current_day)

func fast_forward_day() -> void:
	if current_phase == Constants.GamePhase.DAY:
		day_timer = 0.0
		start_night()

func start_night() -> void:
	_set_phase(Constants.GamePhase.NIGHT)
	EventBus.night_started.emit(current_day)

func end_night() -> void:
	days_survived = current_day
	EventBus.night_ended.emit(current_day)
	current_day += 1
	day_timer = day_duration
	_set_phase(Constants.GamePhase.DAY)
	EventBus.day_started.emit(current_day)

func _set_phase(new_phase: Constants.GamePhase) -> void:
	var old_phase: Constants.GamePhase = current_phase
	current_phase = new_phase
	EventBus.game_phase_changed.emit(old_phase, new_phase)

func _on_enemy_spawned(_enemy_node: Node2D, _side: Constants.SpawnSide) -> void:
	active_enemy_count += 1
	EventBus.enemy_count_changed.emit(active_enemy_count)

func _on_enemy_killed(_reward: int, _id: StringName, _pos: Vector2) -> void:
	active_enemy_count = max(0, active_enemy_count - 1)
	EventBus.enemy_count_changed.emit(active_enemy_count)
	
	# Syarat selesai malam: semua musuh gelombang telah dimusnahkan 📘 [PRD: 4.2]
	if current_phase == Constants.GamePhase.NIGHT and active_enemy_count == 0:
		end_night()

func _on_house_destroyed() -> void:
	_set_phase(Constants.GamePhase.GAME_OVER)
	EventBus.game_over.emit(days_survived)
