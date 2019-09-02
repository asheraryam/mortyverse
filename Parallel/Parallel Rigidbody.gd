extends RigidBody2D

var velocity : Vector2 = Vector2(0,0)
var parallel_target = null

export(bool) var can_jump = true
export(bool) var can_grab_box = true

export(bool) var allow_many_jumps = false

var ray_down : RayCast2D
var ray_left : RayCast2D
var ray_right : RayCast2D

var original_owner 
func _ready():
	original_owner = owner
	add_collision_exception_with(self)
	if has_node("RayDown"):
		ray_down = get_node("RayDown")
	else:
		print("Added raycast")
		ray_down = RayCast2D.new()
		ray_down.name = "RayDown"
		ray_down.enabled = true
		ray_down.exclude_parent = true
		ray_down.collision_mask = pow(2,0) + pow(2,2) # Mask layers 1 and 3
		add_child(ray_down)
		ray_down.cast_to = Vector2(0,24)
	if has_node("RayLeft"):
		ray_left = get_node("RayLeft")
	else:
		print("Added raycast")
		ray_left = RayCast2D.new()
		ray_left.name = "RayLeft"
		ray_left.enabled = true
		ray_left.exclude_parent = true
		ray_left.collision_mask = pow(2,2) # Mask layer 3 for boxes
		add_child(ray_left)
		ray_left.position.y += 6
		ray_left.cast_to = Vector2(-14,0)
	
	if has_node("RayRight"):
		ray_right = get_node("RayRight")
	else:
		print("Added raycast")
		ray_right = RayCast2D.new()
		ray_right.name = "RayRight"
		ray_right.enabled = true
		ray_right.exclude_parent = true
		ray_right.collision_mask = pow(2,2) # Mask layer 3 for boxes
		ray_right.position.y += 6
		add_child(ray_right)
		ray_right.cast_to = Vector2(14,0)

var grabbing_object :PhysicsBody2D = null

func _physics_process(delta):
	_on_physics_process(delta)
	
func _on_physics_process(delta):
	check_hover()
	if Input.is_action_just_pressed("interact") and can_grab_box:
		print("Grabbing with " + name)
		if grabbing_object:
			box_released(false)
#			grabbing_object.call_deferred("set_released")
		elif found_floor:
			print("Try interact")
			var col
			if siding_left:
				col = ray_left.get_collider()
			else:
				col = ray_right.get_collider()
			
			if col:
				print("Found body")
				set_box_grabbed(col, false)
#				col.call_deferred("set_grabbed")
				

var last_hover
func check_hover():
	var col
	if siding_left:
		col = ray_left.get_collider()
	else:
		col = ray_right.get_collider()
		
	if last_hover and (col != last_hover or not can_grab_box):
		last_hover.hover_off()
	
	last_hover = col
	if not grabbing_object and col and can_grab_box and found_floor:
		col.hover_on()
	
func set_inactive():
	set_physics_process(false)
				
func clear_grabbed():
	grabbing_object = null
	
func parallel_grab(box):
	set_box_grabbed(box, true)

func parallel_release():
	box_released(true)
	
func set_box_grabbed(col, parallel= false):
#	col.add_collision_exception_with(self)
#	add_collision_exception_with(col)
	grabbing_object = col
	var before_trans = col.global_position
#	col.mode =RigidBody2D.MODE_KINEMATIC
#	col.get_parent().remove_child(col)
#	add_child(col)
#	col.global_position = before_trans
	col.set_grabbed(self)
	if not parallel:
		col.get_node("Sprite").scale.y = 0.8

func box_released(parallel = false):
	if grabbing_object:
#		grabbing_object.remove_collision_exception_with(self)
		box_stuck = false
		var before_trans = grabbing_object.global_position
		if not parallel:
#			remove_child(grabbing_object)
#			get_parent().get_node("SharedLevel").get_node("Boxes Parent").add_child(grabbing_object)
#			grabbing_object.global_position = before_trans
			grabbing_object.get_node("Sprite").scale.y = 1
		grabbing_object.set_released(self)
#		grabbing_object.mode =RigidBody2D.MODE_CHARACTER
#		remove_collision_exception_with(grabbing_object)
		call_deferred("clear_grabbed")
	
func is_on_floor():
	#	get_node("RayDown").force_update_transform()
#	get_node("RayDown").force_raycast_update()
	var col = ray_down.get_collider()
#	if col is StaticBody2D:
#		return true
	if col:
		return true
	
	return false

func update_facing():
	if parallel_target:
		siding_left = parallel_target.siding_left
		if siding_left:
			$Sprite.scale.x = -1
		else:
			$Sprite.scale.x = 1

func set_target(_target):
	if parallel_target and not _target:
		jumping = parallel_target.jumping
		airborne_time = parallel_target.airborne_time
		if parallel_target.grabbing_object:
			if can_grab_box:
				grab_parallel_box(parallel_target.grabbing_object)
			parallel_target.box_released()
		linear_velocity = parallel_target.linear_velocity
	parallel_target = _target

func grab_parallel_box(box):
	for b in box.bros:
		if b.original_owner.owner == original_owner:
			set_box_grabbed(b, true)
	

var siding_left = false
var floor_h_velocity = 0
var airborne_time = 0
var MAX_FLOOR_AIRBORNE_TIME = 0.5
var jumping = false
var stopping_jump
var box_stuck
export(int) var STOP_JUMP_FORCE = 200
export(int) var WALK_MAX_VELOCITY = 150
export(int) var WALK_ACCEL = 600
export(int) var WALK_DEACCEL = 500
export(int) var JUMP_VELOCITY = 120
export(int) var AIR_ACCEL = 400
export(int) var AIR_DEACCEL = 120
var found_floor = false

func _integrate_forces(s):
	# Find the floor (a contact with upwards facing collision normal)
	var floor_index = -1
	found_floor = false
	var box_landed = false
	
	for x in range(s.get_contact_count()):
		var ci = s.get_contact_local_normal(x)
		if ci.dot(Vector2(0, -1)) > 0.6:
			found_floor = true
			floor_index = x
		
	if is_physics_processing():
		var lv = s.get_linear_velocity()
		var step = s.get_step()
		
		var new_siding_left = siding_left
		
		# Get the controls
		var move_left = Input.is_action_pressed("move_left")
		var move_right = Input.is_action_pressed("move_right")
		var jump = Input.is_action_pressed("jump") and can_jump
		var new_jump = Input.is_action_just_pressed("jump") and can_jump and not inside_airsection
#			var shoot = Input.is_action_pressed("shoot")
#			var spawn = Input.is_action_pressed("spawn")
		
#			if spawn:
#				var e = enemy.instance()
#				var p = position
#				p.y = p.y - 100
#				e.position = p
#				get_parent().add_child(e)
		
		# Deapply prev floor velocity
		lv.x -= floor_h_velocity
		floor_h_velocity = 0.0
		

		
		# A good idea when implementing characters of all kinds,
		# compensates for physics imprecision, as well as human reaction delay.
#			if shoot and not shooting:
#				shoot_time = 0
#				var bi = bullet.instance()
#				var ss
#				if siding_left:
#					ss = -1.0
#				else:
#					ss = 1.0
#				var pos = position + $bullet_shoot.position * Vector2(ss, 1.0)
#
#				bi.position = pos
#				get_parent().add_child(bi)
#
#				bi.linear_velocity = Vector2(800.0 * ss, -80)
#
#				$sprite/smoke.restart()
#				$sound_shoot.play()
#
#				add_collision_exception_with(bi) # Make bullet and this not collide
#			else:
#				shoot_time += step
		
		if found_floor:
			airborne_time = 0.0
		else:
			airborne_time += step # Time it spent in the air
		
		var on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME
		
		# Process jump
		if jumping:
			if lv.y > 0:
				# Set off the jumping flag if going down
				jumping = false
			elif not jump:
				stopping_jump = true
			
			if stopping_jump:
				lv.y += STOP_JUMP_FORCE * step
				
		# Check siding
		if lv.x < 0 and move_left:
			new_siding_left = true
		elif lv.x > 0 and move_right:
			new_siding_left = false
		
		if on_floor:
			# Process logic when character is on floor
			if move_left and not move_right:
				if lv.x > -WALK_MAX_VELOCITY:
					lv.x -= WALK_ACCEL * step
			elif move_right and not move_left:
				if lv.x < WALK_MAX_VELOCITY:
					lv.x += WALK_ACCEL * step
			else:
				var xv = abs(lv.x)
				xv -= WALK_DEACCEL * step
				if xv < 0:
					xv = 0
				lv.x = sign(lv.x) * xv
			
			# Check jump
			if not jumping and new_jump and found_floor:
				lv.y = -JUMP_VELOCITY
				jumping = true
				stopping_jump = false
#					$sound_jump.play()
			
			
#				if jumping:
#					new_anim = "jumping"
#				elif abs(lv.x) < 0.1:
#					if shoot_time < MAX_SHOOT_POSE_TIME:
#						new_anim = "idle_weapon"
#					else:
#						new_anim = "idle"
#				else:
#					if shoot_time < MAX_SHOOT_POSE_TIME:
#						new_anim = "run_weapon"
#					else:
#						new_anim = "run"
		else:
			# Process logic when the character is in the air
			if move_left and not move_right:
				if lv.x > -WALK_MAX_VELOCITY:
					lv.x -= AIR_ACCEL * step
			elif move_right and not move_left:
				if lv.x < WALK_MAX_VELOCITY:
					lv.x += AIR_ACCEL * step
			else:
				var xv = abs(lv.x)
				xv -= AIR_DEACCEL * step
				if xv < 0:
					xv = 0
				lv.x = sign(lv.x) * xv
			
			if allow_many_jumps and not inside_airsection:
				# Check jump
				if not jumping and jump:
					lv.y = -JUMP_VELOCITY
					jumping = true
					stopping_jump = false
#					$sound_jump.play()
			
#				if lv.y < 0:
#					if shoot_time < MAX_SHOOT_POSE_TIME:
#						new_anim = "jumping_weapon"
#					else:
#						new_anim = "jumping"
#				else:
#					if shoot_time < MAX_SHOOT_POSE_TIME:
#						new_anim = "falling_weapon"
#					else:
#						new_anim = "falling"
		
		# Update siding
		if new_siding_left != siding_left:
			if new_siding_left:
				$Sprite.scale.x = -1
			else:
				$Sprite.scale.x = 1
			
			siding_left = new_siding_left
		
		# Change animation
#			if new_anim != anim:
#				anim = new_anim
#				$anim.play(anim)
#
#			shooting = shoot
		
		# Apply floor velocity
		if found_floor:
			floor_h_velocity = s.get_contact_collider_velocity_at_position(floor_index).x
			lv.x += floor_h_velocity
		
		if (allow_many_jumps and (new_jump or jumping)) or (not allow_many_jumps and abs(lv.y)>10):
			dimensional_play_anim("jump")
		else:
			if abs(lv.x) > 0.5:
				dimensional_play_anim("run")
			else:
				dimensional_play_anim("default")
		# Finally, apply gravity and set back the linear velocity
		if not has_node("Phase Timer") or get_node("Phase Timer").is_stopped():
			lv += s.get_total_gravity() * step
		if _reset_walk_requested:
			_reset_walk_requested = false
			lv.x = 0
		if has_node("Phase Timer") and not get_node("Phase Timer").is_stopped():
			lv = phase_vector
		if grabbing_object and grabbing_object.found_floor:
			box_stuck = true
		if box_stuck:
#			if lv.y >0:
			lv.y = -1.6
		
		if _force_position_requested:
			var xform = s.get_transform()
			xform.origin = _forced_position
			s.set_transform(xform)
			_force_position_requested = false

		s.set_linear_velocity(lv)
	else:
		pass
#		s.linear_velocity = velocity
#		s.linear_velocity = Vector2()
	if parallel_target:
		var xform = s.get_transform()
		xform.origin = parallel_target.global_position
		s.set_transform(xform)

var phase_vector : Vector2
var _reset_walk_requested = false
func force_reset_walk():
	_reset_walk_requested = true

var _force_position_requested = false
var _forced_position : Vector2 
func force_position(pos):
	_forced_position = pos
	_force_position_requested = true

func dimensional_play_anim(anim_name):
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		p.play_anim(anim_name)

func play_anim(anim_name):
	$Sprite.play(anim_name)

func collect_artifact(thing : PhysicsBody2D):
	thing.self_destruct()
	# play collect sfx

var inside_airsection = false
