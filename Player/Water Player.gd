extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_inactive():
	set_physics_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

var target = null
func set_target(_target):
	target = _target
	
func _integrate_forces(state):
	if target:
		var xform = state.get_transform()
		xform.origin = target.global_position
		state.set_transform(xform)
