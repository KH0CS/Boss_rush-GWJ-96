extends Node2D

const BULLET = preload("res://scenes/bullet.tscn")

@onready var gun_muzzle: Marker2D = $Marker2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# this is allowing the gun to look at and follow the mouse thus aiming
	look_at(get_global_mouse_position())
	
	# This part is giving you a min and max rotation of 0 up to 360.
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	
	# This part is making it so if the rotation of the gun either gets to 90 it will flip the sprite to face the other way and same with 270 degrees. 
	if rotation_degrees > 90 and rotation_degrees< 270:
		scale.y = -1
	else:
		scale.y = 1
	
	# This code is saying when you "click" or press the shoot button in our case "left click" a bullet (thanks to the preload up top and from our bullet script)
	# Will spawn each and every time you click. I have the bullet's spwn location set to the tip of the gun or muzzle
	if Input.is_action_just_pressed("shoot"):
		var bullet_spawn = BULLET.instantiate()
		get_tree().root.add_child(bullet_spawn)
		bullet_spawn.global_position = gun_muzzle.global_position
		bullet_spawn.rotation = rotation
	
