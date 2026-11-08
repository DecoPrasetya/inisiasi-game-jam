class_name BaseEnemy
extends Node2D

@export var stats: EnemyStats

var spawn_side: Constants.SpawnSide = Constants.SpawnSide.NORTH_EAST
var hp_multiplier: float = 1.0
var target_position: Vector2 = Vector2.ZERO
var current_target_node: Node2D = null
var taunt_target_node: Node2D = null
var _attack_timer: float = 0.0
var _is_dead: bool = false

@onready var anim_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var health_component: HealthComponent = get_node_or_null("HealthComponent")
@onready var status_receiver: StatusEffectReceiver = get_node_or_null("StatusEffectReceiver")
@onready var hurtbox_component: HurtboxComponent = get_node_or_null("HurtboxComponent")
@onready var hitbox_component: HitboxComponent = get_node_or_null("HitboxComponent")


func _ready() -> void:
	add_to_group("enemies")
	_ensure_combat_components()
	if stats != null:
		setup_enemy(stats, hp_multiplier, spawn_side, target_position)
	queue_redraw()


func _ensure_combat_components() -> void:
	anim_sprite = get_node_or_null("AnimatedSprite2D")
	if anim_sprite == null:
		anim_sprite = AnimatedSprite2D.new()
		anim_sprite.name = "AnimatedSprite2D"
		add_child(anim_sprite)
		
	if health_component == null:
		health_component = HealthComponent.new()
		health_component.name = "HealthComponent"
		add_child(health_component)
		
	health_component.is_enemy_entity = true
	if not health_component.died.is_connected(_on_died):
		health_component.died.connect(_on_died)
	if not health_component.health_changed.is_connected(_on_health_changed):
		health_component.health_changed.connect(_on_health_changed)
		
	if status_receiver == null:
		status_receiver = StatusEffectReceiver.new()
		status_receiver.name = "StatusEffectReceiver"
		add_child(status_receiver)
	status_receiver.can_receive_debuff = true
	status_receiver.can_receive_crowd_control = true
	if not status_receiver.stats_recalculated.is_connected(queue_redraw):
		status_receiver.stats_recalculated.connect(queue_redraw)
	if not status_receiver.effect_applied.is_connected(_on_status_effect_applied):
		status_receiver.effect_applied.connect(_on_status_effect_applied)
		
	if hurtbox_component == null:
		hurtbox_component = HurtboxComponent.new()
		hurtbox_component.name = "HurtboxComponent"
		var hurt_col := CollisionShape2D.new()
		var hurt_circle := CircleShape2D.new()
		hurt_circle.radius = 16.0
		hurt_col.shape = hurt_circle
		hurtbox_component.add_child(hurt_col)
		add_child(hurtbox_component)
	hurtbox_component.health_component = health_component
	hurtbox_component.status_receiver = status_receiver
	hurtbox_component.configure_collision_layer(Constants.LAYER_ENEMIES)
	
	if hitbox_component == null:
		hitbox_component = HitboxComponent.new()
		hitbox_component.name = "HitboxComponent"
		var hit_col := CollisionShape2D.new()
		var hit_circle := CircleShape2D.new()
		hit_circle.radius = 16.0
		hit_col.shape = hit_circle
		hitbox_component.add_child(hit_col)
		add_child(hitbox_component)
	hitbox_component.source_role = -1 # -1 menandakan serangan berasal dari Musuh
	hitbox_component.configure_collision_layers(
		Constants.LAYER_ENEMIES,
		[Constants.LAYER_PLANTS, Constants.LAYER_HOUSE]
	)


func setup_enemy(
	enemy_data: EnemyStats,
	multiplier: float = 1.0,
	side: Constants.SpawnSide = Constants.SpawnSide.NORTH_EAST,
	center_world_pos: Vector2 = Vector2.ZERO
) -> void:
	stats = enemy_data
	hp_multiplier = multiplier
	spawn_side = side
	target_position = center_world_pos
	_is_dead = false
	
	_ensure_combat_components()
	status_receiver.clear_all_effects()
	
	if anim_sprite != null:
		anim_sprite.scale = Vector2(0.05, 0.05)
		play_animation(&"idle")
		
	var scaled_hp: float = (stats.base_max_hp if stats != null else 50.0) * hp_multiplier
	health_component.initialize(scaled_hp, true)
	hitbox_component.damage = stats.attack_damage if stats != null else 10.0
	
	visible = true
	queue_redraw()
	
func play_animation(anim_name: StringName) -> void:
	if anim_sprite == null or anim_sprite.sprite_frames == null:
		return
	if anim_sprite.sprite_frames.has_animation(anim_name) and anim_sprite.sprite_frames.get_frame_count(anim_name) > 0:
		anim_sprite.play(anim_name)
	elif anim_sprite.sprite_frames.has_animation(&"death") and anim_sprite.sprite_frames.get_frame_count(&"death") > 0:
		# Fallback sementara karena di katak_penyembur.tscn saat ini baru animasi 'death' yang ada dlu
		anim_sprite.play(&"death")
		

func _physics_process(delta: float) -> void:
	if _is_dead or GameManager.current_phase != Constants.GamePhase.NIGHT:
		return
		
	if status_receiver != null:
		if status_receiver.has_crowd_control(Constants.CrowdControlType.STUN) \
			or status_receiver.has_crowd_control(Constants.CrowdControlType.ROOT) \
			or status_receiver.has_crowd_control(Constants.CrowdControlType.BLOCK):
			return
			
	var base_spd: float = stats.move_speed if stats != null else 35.0
	var final_spd: float = maxf(0.0, status_receiver.calculate_final_stat(base_spd, &"move_speed"))
	var atk_range: float = stats.attack_range if stats != null else 36.0
	
	# Validasi apakah target Taunt (Defender) masih hidup dan aktif menarik aggro
	if taunt_target_node != null:
		if not is_instance_valid(taunt_target_node) \
			or not taunt_target_node.visible \
			or ("_is_dying" in taunt_target_node and taunt_target_node._is_dying):
			taunt_target_node = null
			
	# Jika terkena Aggro/Taunt dan belum sampai di jarak pukul Defender, belok ke arah Defender!
	if taunt_target_node != null:
		var dist_to_defender: float = global_position.distance_to(taunt_target_node.global_position)
		if dist_to_defender <= atk_range:
			current_target_node = taunt_target_node
		else:
			# Berjalan menghampiri Defender terlebih dahulu
			var dir_to_def: Vector2 = (taunt_target_node.global_position - global_position).normalized()
			global_position += dir_to_def * final_spd * delta
			if anim_sprite != null and abs(dir_to_def.x) > 0.05:
				anim_sprite.flip_h = dir_to_def.x < 0.0
			return
	else:
		# Jika tidak ada Taunt, cek tanaman biasa yang menghalangi jalan
		current_target_node = _find_blocking_plant(atk_range)
	
	# menyerang tanaman target jika sudah berada dalam jarak pukul
	if current_target_node != null:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			var base_cd: float = stats.attack_cooldown if stats != null else 1.2
			_attack_timer = maxf(0.1, status_receiver.calculate_final_stat(base_cd, &"attack_cooldown"))
			_perform_attack()
		return
		
	# Jika tidak ada tanaman yang menghalangi/menarik aggro, lanjut berjalan menuju Rumah (0,0)
	var dist_to_center: float = global_position.distance_to(target_position)
	if dist_to_center > atk_range:
		var dir: Vector2 = (target_position - global_position).normalized()
		global_position += dir * final_spd * delta
		
		if anim_sprite != null and abs(dir.x) > 0.05:
			anim_sprite.flip_h = dir.x < 0.0
	else:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			var base_cd: float = stats.attack_cooldown if stats != null else 1.2
			_attack_timer = maxf(0.1, status_receiver.calculate_final_stat(base_cd, &"attack_cooldown"))
			var base_dmg: float = stats.attack_damage if stats != null else 10.0
			var final_dmg: float = maxf(0.0, status_receiver.calculate_final_stat(base_dmg, &"attack_damage"))
			
			if GameManager.has_method("damage_house"):
				GameManager.damage_house(final_dmg)


func _find_blocking_plant(range_px: float) -> Node2D:
	var max_dist_sq: float = range_px * range_px
	var nearest_plant: Node2D = null
	var min_d_sq: float = max_dist_sq
	
	for node in get_tree().get_nodes_in_group("plants"):
		var pl: Node2D = node as Node2D
		if pl != null and is_instance_valid(pl) and pl.visible:
			var d_sq: float = global_position.distance_squared_to(pl.global_position)
			if d_sq <= min_d_sq:
				min_d_sq = d_sq
				nearest_plant = pl
	return nearest_plant
	
func set_taunt_target(defender_node: Node2D) -> void:
	if defender_node != null and is_instance_valid(defender_node):
		taunt_target_node = defender_node
		
func _on_status_effect_applied(effect: EffectData) -> void:
	if effect.effect_kind == Constants.EffectKind.CROWD_CONTROL and effect.cc_type == Constants.CrowdControlType.KNOCKBACK:
		# Dorong musuh menjauh dari pusat rumah / tanaman
		var push_dir: Vector2 = (global_position - target_position).normalized()
		if push_dir == Vector2.ZERO:
			push_dir = Vector2.UP
		global_position += push_dir * 35.0
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, Color(0.9, 0.15, 0.15, 0.45))
	draw_arc(Vector2.ZERO, 12.0, 0.0, TAU, 24, Color(1.0, 0.3, 0.3, 0.9), 1.5)
	
	if anim_sprite == null or anim_sprite.sprite_frames == null:
		draw_circle(Vector2(0, -10), 10.0, Color(0.85, 0.2, 0.2, 1.0))
		
	if health_component != null:
		var bar_w: float = 34.0
		var bar_h: float = 5.0
		var bar_pos := Vector2(-bar_w * 0.5, -38.0)
		var hp_ratio: float = clampf(health_component.current_hp / maxf(1.0, health_component.max_hp), 0.0, 1.0)
		
		draw_rect(Rect2(bar_pos, Vector2(bar_w, bar_h)), Color(0.1, 0.1, 0.1, 0.85), true)
		draw_rect(Rect2(bar_pos, Vector2(bar_w * hp_ratio, bar_h)), Color(1.0, 0.25, 0.25, 1.0), true)
		
		var side_short: String = ["NE", "SE", "SW", "NW"][spawn_side]
		var info_text: String = "%s (%.0f)" % [side_short, health_component.current_hp]
		draw_string(
			ThemeDB.fallback_font,
			Vector2(-24, -42),
			info_text,
			HORIZONTAL_ALIGNMENT_CENTER,
			48,
			10,
			Color(1.0, 0.95, 0.4, 1.0)
		)
	
	var atk_range: float = stats.attack_range if stats != null else 36.0
	draw_arc(Vector2.ZERO, atk_range, 0.0, TAU, 32, Color(1.0, 0.2, 0.2, 0.2), 1.0)


func _perform_attack() -> void:
	if current_target_node != null and is_instance_valid(current_target_node):
		if current_target_node.has_method("take_damage"):
			var base_dmg: float = stats.attack_damage if stats != null else 10.0
			var final_dmg: float = maxf(0.0, status_receiver.calculate_final_stat(base_dmg, &"attack_damage"))
			current_target_node.take_damage(final_dmg, -1, self)


## Default source_role adalah DAMAGE_DEALER agar serangan valid atau tombol debug [K] bisa membunuh musuh
func take_damage(
	amount: float,
	source_role: int = Constants.PlantRole.DAMAGE_DEALER,
	source_node: Node = null
) -> bool:
	if _is_dead:
		return false
	if health_component != null:
		return health_component.take_damage(amount, source_role, source_node)
	die()
	return true


func die() -> void:
	_on_died()


func _on_health_changed(_current_hp: float, _max_hp: float) -> void:
	queue_redraw()


func _on_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	
	if status_receiver != null:
		status_receiver.clear_all_effects()
		
	var reward: int = stats.reward_amount if stats != null else 10
	var enemy_id: StringName = stats.id if stats != null else &"enemy"
	
	GameManager.add_resource(reward)
	EventBus.enemy_killed.emit(reward, enemy_id, global_position)
	
	var parent_node: Node = get_parent()
	if parent_node != null and parent_node.get_parent() != null and parent_node.get_parent().has_method("return_enemy_to_pool"):
		parent_node.get_parent().return_enemy_to_pool(self)
	else:
		queue_free()
