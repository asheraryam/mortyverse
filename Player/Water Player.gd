extends "res://Parallel/Parallel Rigidbody.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_inactive():
	set_physics_process(false)


func entered_airsection():
	$Bubbles.emitting = false
	inside_airsection = true

func exited_airsection():
	$Bubbles.emitting = true
	inside_airsection = false
