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
	switch_world_to(get_tree().get_nodes_in_group("start_world")[0], 0)

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
	
	switch_world_to(get_world_by_id(target_index), 1)
#	var duration = 0.5
#	$Center/Tween.interpolate_property($Center,"rotation", 
#	$Center.rotation, 
#	world_rotations[target_index],0.5,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
#	$Center/Tween.start()

func go_to_prev_world():
	
	var target_index = (game.current_world.INDEX - 1) #% world_rotations.size()
	if game.current_world.INDEX == 0:
		target_index = world_rotations.size()-1
	
	switch_world_to(get_world_by_id(target_index), -1)

var target_world
var before_basis
var after_basis
func switch_world_to(_target_world, index_change):
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
	var target_degrees = world_rotations[_target_world.INDEX]
	if game.current_world:
		target_degrees.x = deg2rad(90) * index_change
	else:
		target_degrees.x = 0
		
	var target_angle = target_degrees.x
	
	before_basis = $Center.global_transform.basis
	after_basis = $Center.global_transform.basis.rotated(Vector3(1,0,0), target_angle)

	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		p.update_facing()
	
	print("Attempting to start world rotation")

	$Center/CenterTween.interpolate_method(self,"rotate_world_center_by", 
	0, 
	1,0.5,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Center/CenterTween.start()

func rotate_world_center_by(radian_angle):
	$Center.global_transform.basis = before_basis.slerp(after_basis, radian_angle)

func _on_Center_tween_completed(object, key):
	target_world.set_active()

func pause_worlds():
	var worlds = get_tree().get_nodes_in_group("world")
	for w in worlds:
		w.set_inactive()
