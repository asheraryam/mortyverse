extends Node2D
tool

export(TileSet) var terrain_tiles
export(TileSet) var bushes_tiles

# Called when the node enters the scene tree for the first time.
func _ready():
	if owner and owner.has_method("player_set_active"):
		get_node("Bushes").tile_set = bushes_tiles
		if terrain_tiles:
			get_node("Terrain").tile_set = terrain_tiles
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
