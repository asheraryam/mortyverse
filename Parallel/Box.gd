extends RigidBody2D

export(int) var box_index = 0

var parallel_target : RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	get_bros()

var bros = []
func get_bros():
	var others = get_tree().get_nodes_in_group("box")
	for b in others:
		if b != self and b.box_index == box_index:
			bros.append(b)
			print("Owner: " + b.owner.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_active():
	if game.current_world == owner:
		set_target(null)
		for b in bros:
			b.set_target(self)
		

func set_target(_target):
	if not _target and parallel_target:
		linear_velocity = parallel_target.linear_velocity
	parallel_target = _target

func _integrate_forces(s):
	if parallel_target:
		var xform = s.get_transform()
		xform.origin = parallel_target.global_position
		s.set_transform(xform)

func set_grabbed():
	for b in bros:
		b.owner.player_node.parallel_grab(b)

func set_released():
	for b in bros:
		print("boxes owner " + str(b.owner.name))
		b.owner.player_node.parallel_release()
	
