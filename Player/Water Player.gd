extends KinematicBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_inactive():
	set_physics_process(false)
	$Remote0.remote_path = ""
	$Remote1.remote_path = ""
	$Remote2.remote_path = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
