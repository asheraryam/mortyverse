extends Node


var fading_out = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	game.bgm = self
	var tracks = $tracks.get_children()
	for track in tracks:
		track.volume_db = -60
		track.playing = true
		fading_out[track.name] =false
		var tween = Tween.new()
		tween.name = "Tween"
		track.add_child(tween)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func fade_out(node_path, time = 1, reset = false):
	get_node("tracks/"+node_path+"/Tween").stop(get_node("tracks/"+node_path))
	get_node("tracks/"+node_path+"/Tween").interpolate_property(get_node("tracks/"+node_path), "volume_db", get_node(
	"tracks/"+node_path).volume_db, -60, time, Tween.TRANS_SINE,Tween.EASE_OUT)
	get_node("tracks/"+node_path+"/Tween").start()
	fading_out[node_path] = true
	yield(get_node("tracks/"+node_path+"/Tween"),"tween_completed")
	if fading_out[node_path]:
		if reset:
			get_node("tracks/"+node_path).stop()
	
func fade_in(node_path, time = 1, reset = false):
	fading_out[node_path] = false
	get_node("tracks/"+node_path+"/Tween").stop(get_node("tracks/"+node_path))
	if not get_node("tracks/"+node_path).is_playing() or reset:
		get_node("tracks/"+node_path).play()
	get_node("tracks/"+node_path+"/Tween").interpolate_property(get_node("tracks/"+node_path), "volume_db", get_node(
	"tracks/"+node_path).volume_db, 0, time, Tween.TRANS_SINE,Tween.EASE_IN)
	get_node("tracks/"+node_path+"/Tween").start()