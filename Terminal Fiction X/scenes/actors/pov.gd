extends Spatial

onready var animPlayer = get_node("AnimationPlayer")

func _on_camera_shake(intensity):
	print("shake intensity: ", intensity)
	if intensity > 12: intensity = 12
	
	#set shake to the animation called shake
	var shake : Animation = animPlayer.get_animation("shake")
	
	#set the values of the animation tracks of shake
	shake.track_set_key_value(0, 0, Vector3(1,1,1) * intensity)
	shake.track_set_key_value(0, 1, Vector3(-1,-1,1) * intensity)
	shake.track_set_key_value(0, 2, Vector3(1,1,-1) * intensity)
	shake.track_set_key_value(0, 3, Vector3(0,0,0))
	
	#play the animation
	animPlayer.play("shake")
