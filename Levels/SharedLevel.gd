extends Node2D

export(TileSet) var terrain_tiles

# Called when the node enters the scene tree for the first time.
func _ready():
	if terrain_tiles:
		get_node("Terrain").tile_set = terrain_tiles

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
