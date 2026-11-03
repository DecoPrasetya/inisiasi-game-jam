extends Node

var _pass := 0
var _fail := 0

func _ready() -> void:
	await get_tree().process_frame
	_t_core_01()
	_t_core_02()
	_t_core_03()
	_t_core_04()
	print("=== HASIL: %d lulus, %d gagal ===" % [_pass, _fail])

func _check(label: String, condition: bool) -> void:
	if condition:
		_pass += 1
		print("  ✅ ", label)
	else:
		_fail += 1
		print("  ❌ ", label)

# Lambda di GDScript menangkap variabel by value, jadi pakai Array untuk menampung hasil sinyal.
func _capture(sig: Signal) -> Array:
	var got := []
	sig.connect(func(arg = null): got.append(arg))
	return got

func _t_core_01() -> void:
	print("T-CORE-01")
	GameManager.current_day = 5  # sengaja dikotori, harus ter-reset
	var got := _capture(EventBus.day_started)
	GameManager.start_new_game()
	_check("fase = DAY", GameManager.current_phase == Constants.GamePhase.DAY)
	_check("current_day = 1", GameManager.current_day == 1)
	_check("day_started(1) terpancar sekali", got == [1])

func _t_core_02() -> void:
	print("T-CORE-02")
	GameManager.start_new_game()
	GameManager.day_timer = 30.0  # sisa waktu siang
	var got := _capture(EventBus.night_started)
	GameManager.fast_forward_day()
	_check("timer dipotong ke 0", GameManager.day_timer == 0.0)
	_check("fase = NIGHT", GameManager.current_phase == Constants.GamePhase.NIGHT)
	_check("night_started(1) terpancar sekali", got == [1])

func _t_core_03() -> void:
	print("T-CORE-03")
	GameManager.start_new_game()
	GameManager.fast_forward_day()
	var ended := _capture(EventBus.night_ended)
	var enemy_a := Node2D.new()
	var enemy_b := Node2D.new()
	EventBus.enemy_spawned.emit(enemy_a, Constants.SpawnSide.NORTH_EAST)
	EventBus.enemy_spawned.emit(enemy_b, Constants.SpawnSide.SOUTH_WEST)
	_check("active_enemy_count = 2", GameManager.active_enemy_count == 2)

	EventBus.enemy_killed.emit(10, &"test", Vector2.ZERO)
	_check("1 musuh tersisa: masih NIGHT", GameManager.current_phase == Constants.GamePhase.NIGHT)
	_check("1 musuh tersisa: night_ended belum terpancar", ended.is_empty())

	EventBus.enemy_killed.emit(10, &"test", Vector2.ZERO)
	_check("0 musuh: night_ended terpancar", ended == [1])
	_check("0 musuh: kembali ke DAY", GameManager.current_phase == Constants.GamePhase.DAY)
	_check("hari naik ke 2", GameManager.current_day == 2)
	enemy_a.free()
	enemy_b.free()

func _t_core_04() -> void:
	print("T-CORE-04")
	GameManager.start_new_game()
	var over := _capture(EventBus.game_over)
	EventBus.house_destroyed.emit()
	_check("fase = GAME_OVER", GameManager.current_phase == Constants.GamePhase.GAME_OVER)
	_check("game_over(days_survived) terpancar", over == [GameManager.days_survived])
