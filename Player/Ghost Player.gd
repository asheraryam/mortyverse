extends "res://Parallel/Parallel Rigidbody.gd"


export(int) var PHASE_FORCE = 180

var phase_timer : Timer
var phase_tween : Tween

func _ready():
	phase_timer = get_node("Phase Timer")
	phase_tween = Tween.new()
	

var pre_phase_position: Vector2
func _on_physics_process(delta):
	if Input.is_action_just_pressed("interact") and $"Penalty Timer".is_stopped():
		get_node("CollisionShape2D").disabled = true
		if not phase_timer.is_stopped():
			return
		var impulse = Vector2(0,0)
		if siding_left:
			impulse.x -= PHASE_FORCE
		else:
			impulse.x += PHASE_FORCE
		
		phase_vector = impulse
		pre_phase_position = global_position
		phase_tween.interpolate_property(
		self,"phase_vector",impulse,Vector2(0,0), 
		phase_timer.wait_time,
		Tween.TRANS_SINE,Tween.EASE_OUT)
		$AnimationPlayer.play("phase")
		phase_tween.start()
#		apply_central_impulse(impulse)
		phase_timer.start()

func phase_timout():
	get_node("CollisionShape2D").disabled = false
	var bodies =  $StuckInside.get_overlapping_bodies()
	if bodies.size() > 0:
		print("Ghost stuck")
		force_position(pre_phase_position)
		$"Penalty Timer".start()
	force_reset_walk()
	


func play_anim(anim_name):
	if not $Sprite.frames.has_animation(anim_name):
		print("Player does not have animation!")
		return
	if phase_timer.is_stopped():
		$Sprite.play(anim_name)
	else:
		$Sprite.play("phase")
		
