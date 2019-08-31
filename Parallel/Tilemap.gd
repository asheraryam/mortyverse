extends TileMap

export(TileSet) var parallel_tileset

# Called when the node enters the scene tree for the first time.
func _ready():
	tile_set = parallel_tileset

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
