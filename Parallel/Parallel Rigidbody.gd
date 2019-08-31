extends RigidBody2D

var velocity : Vector2 = Vector2(0,0)
var parallel_target = null

var ray_down : RayCast2D
var jump_timer : Timer
func _ready():
	ray_down = get_node("RayDown")
	jump_timer = get_node("JumpTimer")
	if not ray_down:
		print("Added raycast")
		ray_down = RayCast2D.new()
		ray_down.name = "RayDown"
		ray_down.enabled = true
		ray_down.exclude_parent = true
		add_child(ray_down)
		ray_down.cast_to = Vector2(0,24)
	if not jump_timer:
		print("Added timer")
		jump_timer = Timer.new()
		jump_timer.name = "JumpTimer"
		jump_timer.wait_time= jump_time
		jump_timer.one_shot = true
		add_child(jump_timer)
		jump_timer.connect("timeout",self, "handle_jump_release")
		
export(bool) var allow_many_jumps = false

export(int) var speed_scale = 30

export(int) var max_hor_speed = 8
export(int) var accel_hor = 35
export(float) var deaccel_ratio = 0.5
onready var deaccel_hor = deaccel_ratio * accel_hor

export(float) var jump_time = 0.5
export(int) var accel_jump = 30
export(int) var max_jump = 3
export(int) var gravity_strength = 7

func _physics_process(delta):
	deaccel_horiz(delta)
	apply_gravity(delta)

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
	var col = ray_down.get_collider()
#	if col is StaticBody2D:
#		return true
	if col:
		return true
	
	return false

func set_target(_target):
	if parallel_target and not _target:
		velocity = parallel_target.velocity
	parallel_target = _target
	
		
func _integrate_forces(state):
	if is_physics_processing():
		state.linear_velocity = velocity
	else:
		state.linear_velocity = Vector2()
	if parallel_target:
		var xform = state.get_transform()
		xform.origin = parallel_target.global_position
		state.set_transform(xform)

func handle_move_right(delta):
	velocity.x = min(max_hor_speed*  speed_scale, velocity.x + (delta * accel_hor * speed_scale))

func handle_move_left(delta):
	velocity.x = max(-max_hor_speed* speed_scale, velocity.x - (delta * accel_hor * speed_scale))

var _jumped = false
func handle_jump(delta):
	if _jumped and not allow_many_jumps:
		return
	velocity.y = max(-max_jump* speed_scale, velocity.y - (delta * accel_jump * speed_scale))
	if jump_timer.is_stopped():
		jump_timer.start()
	
func handle_jump_release():
	_jumped = true
	if is_on_floor():
		_jumped = false
