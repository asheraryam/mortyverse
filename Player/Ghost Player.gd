extends "res://Parallel/Parallel Rigidbody.gd"


export(int) var PHASE_FORCE = 180

var phase_timer : Timer
var phase_tween : Tween

func _ready():
	phase_timer = Timer.new()
	phase_timer.name = "Phase Timer"
	add_child(phase_timer)
	phase_timer.one_shot = true
	phase_timer.wait_time = 0.3
	phase_timer.connect("timeout",self,"phase_timout")
	
	phase_tween = Tween.new()
	


func _on_physics_process(delta):
	if Input.is_action_just_pressed("interact"):
		get_node("CollisionShape2D").disabled = true
		if not phase_timer.is_stopped():
			return
		var impulse = Vector2(0,0)
		if siding_left:
			impulse.x -= PHASE_FORCE
		else:
			impulse.x += PHASE_FORCE
		
		phase_vector = impulse
		phase_tween.interpolate_property(
		self,"phase_vector",impulse,Vector2(0,0), 
		phase_timer.wait_time,
		Tween.TRANS_SINE,Tween.EASE_OUT)
		phase_tween.start()
			
#		apply_central_impulse(impulse)
		phase_timer.start()

func phase_timout():
	get_node("CollisionShape2D").disabled = false
	force_reset_walk()




