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
	switch_world_to(get_tree().get_nodes_in_group("start_world")[0], false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if game.current_world:
		if Input.is_action_just_pressed("next_world"):
			go_to_next_world()
		if Input.is_action_just_pressed("prev_world"):
			go_to_prev_world()
		
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
	
	switch_world_to(get_world_by_id(target_index), true)
#	var duration = 0.5
#	$Center/Tween.interpolate_property($Center,"rotation", 
#	$Center.rotation, 
#	world_rotations[target_index],0.5,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
#	$Center/Tween.start()

func go_to_prev_world():
	
	var target_index = (game.current_world.INDEX - 1) #% world_rotations.size()
	if game.current_world.INDEX == 0:
		target_index = world_rotations.size()-1
	
	switch_world_to(get_world_by_id(target_index), false)

var target_world
func switch_world_to(_target_world, forward):
	if $Center/CenterTween.is_active():
		print("Tween active, exiting")
		return
	target_world = _target_world
	var duration = 0.5
	if game.current_world:
		game.bgm.fade_out(str(game.current_world.INDEX))
		pause_worlds()
	else:
		duration = 0.001
	game.bgm.fade_in(str(_target_world.INDEX))
		
	var current_degrees = $Center.rotation.x
#	var target_degrees = current_degrees
	var target_degrees = world_rotations[_target_world.INDEX]
#	target_degrees.x = deg2rad(world_rotations[_target_world.INDEX].x)
	if game.current_world:
		if forward:
			target_degrees.x = deg2rad(5.4545)
		else:
			target_degrees.x = - deg2rad(5.4545)
	else:
		target_degrees.x = 0
		
	var target_angle = target_degrees.x
		
#	var target_degrees = current_degrees 
#	if game.current_world.INDEX < _target_world.INDEX or (
#	game.current_world.INDEX == world_rotations.size()-1 and _target_world.INDEX== 0):
#		target_degrees.x += 90
#	else:
#		target_degrees.x -= 90

#	if abs(target_degrees.x - current_degrees.x) > 180:
#		target_degrees.x -= 360 #* sign(target_degrees.x)
	
	
#	if game.current_world.INDEX == 0 and _target_world.INDEX == world_rotations.size() -1:
#		degrees = Vector3(360,0,0)
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		p.update_facing()
	
	print("Attempting to start world rotation")

	$Center/CenterTween.interpolate_method(self,"rotate_world_center_by", 
	0, 
	target_angle,0.5,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Center/CenterTween.start()

var sum_of_rotations = 0
func rotate_world_center_by(radian_angle):
	sum_of_rotations += radian_angle
#	if rad2deg(sum_of_rotations) <=90:
	$Center.rotate_x(radian_angle)
#	else:
#		sum_of_rotations -= radian_angle

func _on_Center_tween_completed(object, key):
	var needed = (deg2rad(90) * sign(sum_of_rotations)) - sum_of_rotations
	print("Angle difference was " + str(needed))
	$Center.rotate_x(needed)
	print("Sum of rotations is : " + str(rad2deg(sum_of_rotations + needed)))
	sum_of_rotations = 0
	target_world.set_active()

func pause_worlds():
	var worlds = get_tree().get_nodes_in_group("world")
	for w in worlds:
		w.set_inactive()
