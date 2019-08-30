extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_inactive():
	set_physics_process(false)


var velocity = Vector2(0,0)
var max_hor_speed = 1000
var accel_hor = 3000
var deaccel_hor = 1500
func _physics_process(delta):
	velocity = linear_velocity
	
	if abs(velocity.x) > 0:
		var change = sign(velocity.x) * delta * deaccel_hor
		if abs(change) > abs(velocity.x):
			change = velocity.x
		velocity.x = velocity.x - change
	
	

func handle_move_right(delta):
	print("Go right")
	velocity.x = min(max_hor_speed, velocity.x + (delta * accel_hor))

func handle_move_left(delta):
	print("Go left")
	velocity.x = max(-max_hor_speed, velocity.x - (delta * accel_hor))

var target = null
func set_target(_target):
	target = _target
	
func _integrate_forces(state):
	state.linear_velocity = velocity
	if target:
		print("Force position for " + str(name))
		var xform = state.get_transform()
		xform.origin = target.global_position
		state.set_transform(xform)
