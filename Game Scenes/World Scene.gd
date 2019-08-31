extends Node2D

export(bool) var start = false

export(int) var INDEX = 0 

export(NodePath) var player 

var player_node


# Called when the node enters the scene tree for the first time.
func _ready():
	player_node = get_node(player)
	if start:
		set_active()


func set_active():
	print("Set world active " + str(INDEX))
	game.current_world = self
	var worlds = get_tree().get_nodes_in_group("world")
	for w in worlds:
		if w != self:
			w.set_inactive()
	
	set_physics_process(true)
	
	player_set_active()

func set_inactive():
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if p != player_node:
			p.set_inactive()
	set_physics_process(false)
	
	
func player_set_active():
	player_node.set_target(null)
	player_node.set_physics_process(true)
	var players = get_tree().get_nodes_in_group("player")
	var connected_counter = 0
	for p in players:
		if p != player_node:
			p.set_inactive()
			p.set_target(player_node)
			connected_counter +=1 
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
