extends Spatial

var world_rotations = [ 
	Vector3(0,0,0),
	Vector3(90,0,0),
	Vector3(180,0,0),
	Vector3(270,0,0)
	]

# Called when the node enters the scene tree for the first time.
func _ready():
	game.main_node = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var target_world


func get_world_by_id(i):
	var worlds = get_tree().get_nodes_in_group("world")
	for w in worlds:
		if w.INDEX == i:
			return w
	
func go_to_next_world():
	if $Center/Tween.is_active():
		return
#	$Center/Tween.stop_all()
	var target_index = (game.current_world.INDEX + 1) % world_rotations.size()
	
	switch_world_to(get_world_by_id(target_index))
#	var duration = 0.5
#	$Center/Tween.interpolate_property($Center,"rotation", 
#	$Center.rotation, 
#	world_rotations[target_index],0.5,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
#	$Center/Tween.start()
	
func switch_world_to(_target_world):
	target_world = _target_world
	var duration = 0.5
	$Center/Tween.interpolate_property($Center,"rotation", 
	$Center.rotation, 
	world_rotations[_target_world.INDEX],0.5,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Center/Tween.start()

func _on_Center_tween_completed(object, key):
	target_world.set_active()
