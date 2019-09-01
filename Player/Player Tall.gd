extends "res://Parallel/Parallel Rigidbody.gd"

var tallness = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_physics_process(delta):
	if Input.is_action_just_pressed("jump"):
		switch_tallness()
	
	._on_physics_process(delta)
	

func switch_tallness():
	print("Switch tall level")
	if tallness == 1:
		ray_left = get_node("RayLeft1")
		ray_right = get_node("RayRight1")
		$Sprite.offset.y = -24
		$Tall1.disabled = false
		$Tall2.disabled = true
		tallness = 2
		$Sprite.play("default2")
		play_anim(current_anim_base)
	elif tallness == 2:
		ray_left = get_node("RayLeft")
		ray_right = get_node("RayRight")
		$Sprite.offset.y = -12
		$Tall1.disabled = false
		$Tall2.disabled = false
		tallness = 1
		$Sprite.play("default1")
		play_anim(current_anim_base)

var current_anim_base 
func play_anim(anim_name):
	current_anim_base = anim_name
	return
	$Sprite.play(anim_name+str(tallness))
	
