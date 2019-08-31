extends RigidBody2D

var velocity : Vector2 = Vector2(0,0)
var parallel_target = null

var ray_down_left : RayCast2D
#var ray_down_right : RayCast2D
var jump_timer : Timer
func _ready():
	ray_down_left = get_node("RayDownLeft")
#	ray_down_right = get_node("RayDownLeft")
	jump_timer = get_node("JumpTimer")
	if not ray_down_left:
		print("Added raycast")
		ray_down_left = RayCast2D.new()
		ray_down_left.name = "RayDownLeft"
		ray_down_left.enabled = true
		ray_down_left.exclude_parent = true
		ray_down_left.collision_mask = pow(2,0) + pow(2,2) # Mask layers 1 and 3
		add_child(ray_down_left)
#		ray_down_left.position.x = -9.25
		ray_down_left.cast_to = Vector2(0,24)
#	if not ray_down_right:
#		print("Added raycast")
#		ray_down_right = RayCast2D.new()
#		ray_down_right.name = "RayDownRight"
#		ray_down_right.enabled = true
#		ray_down_right.exclude_parent = true
#		ray_down_right.collision_mask = pow(2,0) + pow(2,2) # Mask layers 1 and 3
#		add_child(ray_down_right)
#		ray_down_right.position.x = 9.25
#		ray_down_right.cast_to = Vector2(0,24)
	if not jump_timer:
		print("Added timer")
		jump_timer = Timer.new()
		jump_timer.name = "JumpTimer"
		jump_timer.wait_time= jump_time
		jump_timer.one_shot = true
		add_child(jump_timer)
		jump_timer.connect("timeout",self, "handle_jump_release")
		
export(bool) var allow_many_jumps = false

export(int) var speed_scale = 1

export(int) var max_hor_speed = 8
export(int) var accel_hor = 35
export(float) var deaccel_ratio = 0.5
onready var deaccel_hor = deaccel_ratio * accel_hor

export(float) var jump_time = 0.25
export(int) var accel_jump = 50
export(int) var max_jump = 4
export(int) var start_jump = 0.05
export(int) var gravity_strength = 15

var last_delta
func _physics_process(delta):
	pass
#	deaccel_horiz(delta)
#	last_delta = delta
#	apply_gravity(delta)

func deaccel_horiz(delta):
	if abs(velocity.x) > 0: # Deaccel horizontally
		var change = sign(velocity.x) * delta * deaccel_hor * speed_scale
		if abs(change) > abs(velocity.x):
			change = velocity.x
		velocity.x = velocity.x - change

func apply_gravity(delta):
	if is_on_floor():
		_jumped = false
		if(velocity.y >0):
			velocity.y =0

	velocity.y = velocity.y + (delta * gravity_strength * speed_scale)

func is_on_floor():
	#	get_node("RayDown").force_update_transform()
#	get_node("RayDown").force_raycast_update()
	var col = ray_down_left.get_collider()
#	var col_two = ray_down_right.get_collider()
#	if col is StaticBody2D:
#		return true
#	if col or col_two:
	if col:
		return true
	
	return false

func set_target(_target):
	if parallel_target and not _target:
		velocity = parallel_target.velocity
	parallel_target = _target
	
var accel = Vector2()
func _integrate_forces(state):
	if is_physics_processing():
#		state.linear_velocity += accel + Vector2(0,gravity_strength)
		if abs(state.linear_velocity.x) > max_hor_speed*  speed_scale:
			state.linear_velocity.x = max_hor_speed*  speed_scale
#		state.linear_velocity.y += last_delta * gravity_strength * speed_scale * 100
	else:
		state.linear_velocity = Vector2()
	if parallel_target:
		var xform = state.get_transform()
		xform.origin = parallel_target.global_position
		state.set_transform(xform)

func handle_move_right(delta):
	accel.x =  delta * accel_hor * speed_scale
	velocity.x = min(max_hor_speed*  speed_scale, velocity.x + (delta * accel_hor * speed_scale))

func handle_move_left(delta):
	accel.x = - delta * accel_hor * speed_scale
	velocity.x = max(-max_hor_speed* speed_scale, velocity.x - (delta * accel_hor * speed_scale))

var _jumped = false
func handle_jump(delta):
	if _jumped and not allow_many_jumps:
		return
	if not _jumped and velocity.y == 0:
		velocity.y = -start_jump* speed_scale
		
		
	accel.y = - (delta * accel_jump * speed_scale)
	velocity.y = max(-max_jump* speed_scale, velocity.y - (delta * accel_jump * speed_scale))
	if jump_timer.is_stopped():
		jump_timer.start()
	
func handle_jump_release():
	_jumped = true
	if is_on_floor():
		_jumped = false
