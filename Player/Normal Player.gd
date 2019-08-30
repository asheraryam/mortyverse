extends Sprite


# Called when the node enters the scene tree for the first time.
func _ready():
	set_active()

func set_active():
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if p != self:
			p.set_inactive()
			_connect_remote_to(p)
	
	set_physics_process(true)
			

func _connect_remote_to(p):
	$RemoteOne.remote_path = get_path_to(p)
	$RemoteTwo.remote_path = get_path_to(p)
	$RemoteThree.remote_path = get_path_to(p)

func set_inactive():
	set_physics_process(false)
	$RemoteOne.remote_path = null
	$RemoteTwo.remote_path = null
	$RemoteThree.remote_path = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
