extends RigidBody2D

export(int) var BOX_INDEX = 0

var parallel_target : RigidBody2D

var original_owner
func _ready():
	original_owner = owner
	get_bros()

var bros = []
func get_bros():
	var others = get_tree().get_nodes_in_group("box")
	for b in others:
		if b != self and b.BOX_INDEX == BOX_INDEX:
			bros.append(b)
			print("Owner: " + b.owner.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_active():
	if not original_owner:
		print("Box with no owner!")
	if game.current_world == original_owner:
		print("Setting box active in world " + original_owner.name)
		set_target(null)
		for b in bros:
			b.set_target(self)
		

func set_target(_target):
	if not _target and parallel_target:
		linear_velocity = parallel_target.linear_velocity
	parallel_target = _target

var found_floor = false
var floor_index
func _integrate_forces(s):
#	found_floor = false
#	floor_index = -1
#	var count = s.get_contact_count() -1
#	for x in range(count):
#		var ci = s.get_contact_local_normal(x)
#		if ci.dot(Vector2(0, -1)) > 0.6:
#			found_floor = true
#			floor_index = x
				
	if parallel_target:
		var xform = s.get_transform()
		xform.origin = parallel_target.global_position
		s.set_transform(xform)

func set_grabbed():
	for b in bros:
		b.original_owner.player_node.parallel_grab(b)

func set_released():
	for b in bros:
		print("boxes owner " + str(b.original_owner.name))
		b.original_owner.player_node.parallel_release()


