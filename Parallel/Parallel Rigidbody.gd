extends RigidBody2D

var velocity : Vector2 = Vector2(0,0)
var parallel_target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

export(int) var speed_scale = 30
export(int) var max_hor_speed = 10
export(int) var accel_hor = 30
export(int) var deaccel_hor = 15

export(int) var gravity_strength = 1
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
	velocity.y = velocity.y + (delta * gravity_strength * speed_scale)

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
	print("Go right")
	velocity.x = min(max_hor_speed*  speed_scale, velocity.x + (delta * accel_hor * speed_scale))

func handle_move_left(delta):
	print("Go left")
	velocity.x = max(-max_hor_speed* speed_scale, velocity.x - (delta * accel_hor * speed_scale))
