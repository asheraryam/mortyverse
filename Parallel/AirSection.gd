extends Area2D



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AirSection_body_entered(body):
	if body.has_method("entered_airsection"):
		body.entered_airsection()


func _on_AirSection_body_exited(body):
	if body.has_method("exited_airsection"):
		body.exited_airsection()
