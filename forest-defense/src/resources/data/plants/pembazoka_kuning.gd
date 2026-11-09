class_name PembazokaKuning
extends BasePlant

var _attack_cooldown_timer: float = 0.0


func _on_plant_configured() -> void:
	if stats != null:
		stats.role = Constants.PlantRole.DAMAGE_DEALER
	_setup_detection_area(Constants.LAYER_ENEMIES)


func _process_night_behavior(delta: float) -> void:
	_attack_cooldown_timer -= delta
	if _attack_cooldown_timer > 0.0:
		return
		
	var target_enemy: Node2D = _find_nearest_enemy_in_range()
	if target_enemy != null:
		var atk_speed: float = maxf(0.1, get_final_stat(&"attack_speed", 1.2))
		_attack_cooldown_timer = 1.0 / atk_speed
		_fire_projectile_at(target_enemy)


func _find_nearest_enemy_in_range() -> Node2D:
	var max_range: float = get_final_stat(&"attack_range", 240.0)
	var max_range_sq: float = max_range * max_range
	var nearest_enemy: Node2D = null
	var min_dist_sq: float = max_range_sq
	
	var candidates: Array[Node] = get_tree().get_nodes_in_group("enemies")
	if candidates.is_empty() and get_tree().current_scene != null:
		var spawner: Node = get_tree().current_scene.find_child("EnemyContainer", true, false)
		if spawner != null:
			candidates = spawner.get_children()
			
	for node in candidates:
		var en: Node2D = node as Node2D
		if _is_valid_enemy_target(en):
			var d_sq: float = global_position.distance_squared_to(en.global_position)
			if d_sq <= min_dist_sq:
				min_dist_sq = d_sq
				nearest_enemy = en
				
	return nearest_enemy


func _is_valid_enemy_target(en: Node2D) -> bool:
	if en == null or not is_instance_valid(en) or not en.visible:
		return false
	if "_is_dead" in en and en._is_dead:
		return false
	return true


func _fire_projectile_at(target: Node2D) -> void:
	var final_damage: float = maxf(
		Constants.MIN_DAMAGE_DEALER_DPS,
		get_final_stat(&"attack_damage", 10.0)
	)
	
	set_facing_direction(target.global_position)
	play_animation(&"attack")
	
	var projectile := _create_projectile_hitbox(final_damage, target)
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position + Vector2(0, -14)
	projectile.owner_entity = self


func _create_projectile_hitbox(dmg: float, target: Node2D) -> HitboxComponent:
	var proj := HitboxComponent.new()
	proj.name = "PeaProjectile"
	proj.damage = dmg
	proj.source_role = Constants.PlantRole.DAMAGE_DEALER
	proj.configure_collision_layers(
		Constants.LAYER_PROJECTILES,
		[Constants.LAYER_ENEMIES]
	)
	
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 8.0
	col.shape = shape
	proj.add_child(col)
	
	var visual := Polygon2D.new()
	visual.color = Color(1.0, 0.9, 0.1, 1.0)
	visual.polygon = PackedVector2Array([
		Vector2(-6, -6), Vector2(6, -6), Vector2(6, 6), Vector2(-6, 6)
	])
	proj.add_child(visual)
	
	proj.set_meta("has_hit", false)
	
	proj.hit_landed.connect(func(_hurtbox: Area2D):
		if is_instance_valid(proj) and not proj.get_meta("has_hit"):
			proj.set_meta("has_hit", true)
			proj.queue_free()
	)
	
	var start_pos: Vector2 = global_position + Vector2(0, -14)
	var dist: float = start_pos.distance_to(target.global_position)
	var travel_time: float = clampf(dist / 360.0, 0.08, 0.6)
	
	var tween: Tween = proj.create_tween()
	tween.tween_method(func(weight: float):
		if not is_instance_valid(proj) or proj.get_meta("has_hit"):
			return
		if _is_valid_enemy_target(target):
			proj.global_position = start_pos.lerp(target.global_position + Vector2(0, -12), weight)
	, 0.0, 1.0, travel_time)
	
	tween.tween_callback(func():
		if is_instance_valid(proj) and not proj.get_meta("has_hit"):
			proj.set_meta("has_hit", true)
			if _is_valid_enemy_target(target):
				var hurtbox: HurtboxComponent = target.get_node_or_null("HurtboxComponent") as HurtboxComponent
				if hurtbox != null:
					hurtbox.receive_hit(proj)
				elif target.has_method("take_damage"):
					target.take_damage(dmg, Constants.PlantRole.DAMAGE_DEALER, self)
			proj.queue_free()
	)
	
	return proj


func _draw() -> void:
	draw_circle(Vector2.ZERO, 10.0, Color(1.0, 0.85, 0.1, 0.45))
	draw_arc(Vector2.ZERO, get_final_stat(&"attack_range", 240.0), 0.0, TAU, 48, Color(1.0, 0.9, 0.2, 0.22), 1.0)
	super._draw()
