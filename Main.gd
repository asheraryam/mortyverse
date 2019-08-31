extends Spatial

var world_rotations = [ 
	Vector3(0,0,0),
	Vector3(90,0,0),
#	Vector3(180,0,0),
#	Vector3(270,0,0)
	]

# Called when the node enters the scene tree for the first time.
func _ready():
	game.main_node = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_just_pressed("next_world"):
		go_to_next_world()
	if Input.is_action_just_pressed("prev_world"):
		go_to_prev_world()
		
	if Input.is_action_pressed("move_left"):
		game.current_world.player_node.handle_move_left(delta)
	if Input.is_action_pressed("move_right"):
		game.current_world.player_node.handle_move_right(delta)
	
	if Input.is_action_pressed("jump"):
		game.current_world.player_node.handle_jump(delta)
	if Input.is_action_just_released("jump"):
		game.current_world.player_node.handle_jump_release()

func get_world_by_id(i):
	var worlds = get_tree().get_nodes_in_group("world")
	for w in worlds:
		if w.INDEX == i:
			print("Found world at " + str(i))
			return w
	print("Not found world at " + str(i))
	
func go_to_next_world():
#	$Center/Tween.stop_all()
	var target_index = (game.current_world.INDEX + 1) % world_rotations.size()
	
	switch_world_to(get_world_by_id(target_index))
#	var duration = 0.5
#	$Center/Tween.interpolate_property($Center,"rotation", 
#	$Center.rotation, 
#	world_rotations[target_index],0.5,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
#	$Center/Tween.start()

func go_to_prev_world():
	
	var target_index = (game.current_world.INDEX - 1) % world_rotations.size()
	if game.current_world.INDEX == 0:
		target_index = world_rotations.size()-1
	
	switch_world_to(get_world_by_id(target_index))

var target_world
func switch_world_to(_target_world):
	if $Center/CenterTween.is_active():
		return
	target_world = _target_world
	var duration = 0.5
	pause_worlds()
	$Center/CenterTween.interpolate_property($Center,"rotation_degrees", 
	$Center.rotation_degrees, 
	world_rotations[_target_world.INDEX],0.5,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Center/CenterTween.start()

func _on_Center_tween_completed(object, key):
	target_world.set_active()

func pause_worlds():
	var worlds = get_tree().get_nodes_in_group("world")
	for w in worlds:
		w.set_inactive()
