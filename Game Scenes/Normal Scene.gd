extends Node2D


export(int) var INDEX = 0 

export(NodePath) var player 


# Called when the node enters the scene tree for the first time.
func _ready():
	game.current_world = self

func set_active():
	var worlds = get_tree().get_nodes_in_group("world")
	for w in worlds:
		if w != self:
			w.set_inactive()
	
	set_physics_process(true)
	
	player.set_active()

func set_inactive():
	set_physics_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
