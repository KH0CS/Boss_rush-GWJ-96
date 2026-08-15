extends Node2D

const BULLET = preload("res://scenes/bullet.tscn")

@onready var gun_muzzle: Marker2D = $Marker2D

# Charge time settings
@export var min_charge_to_release := 0.2  # below this = "tap", no charge
@export var max_charge_time := 1.5  # seconds to reach full charge
@export var gun_rotation_speed: float = 15.0  # higher = snappier, lower = smoother

var is_charging := false
var charge_time := 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Calculate the angle to the mouse instead of instantly looking at it
	var target_angle = (get_global_mouse_position() - global_position).angle()
	
	# Smoothly rotate toward that angle
	rotation = lerp_angle(rotation, target_angle, gun_rotation_speed * delta)
	
	# Keep rotation in 0-360 range
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	
	# Flip sprite when facing left
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1
	
	# Start charging when you click "click"
	if Input.is_action_just_pressed("shoot"):
		is_charging = true
		charge_time = 0.0
	
	# Add charge using the delta
	if is_charging:
		charge_time += delta
		charge_time = min(charge_time, max_charge_time)
		
		# Update UI for charging
		update_charge_visual(charge_time / max_charge_time)

	if Input.is_action_just_released("shoot") and is_charging:
		release_attack(charge_time)
		is_charging = false

func release_attack(time_held: float) -> void:
	var charge_ratio := time_held / max_charge_time  # 0.0 to 1.0
	
	# only release projectile
	if time_held > min_charge_to_release:
		do_charged_attack(charge_ratio)

func do_charged_attack(power: float) -> void:
	var bullet_spawn = BULLET.instantiate()
	get_tree().root.add_child(bullet_spawn)
	
	bullet_spawn.global_position = gun_muzzle.global_position
	bullet_spawn.rotation = rotation
	
	# Scales the projectile size based on the power
	# This is 100% temporary, I wanted to see if charged attacks are working without any UI
	bullet_spawn.scale = Vector2(2, 2) * (1 + power)

func update_charge_visual(ratio: float) -> void:
	pass # update a charge bar, charge effects, sprite cahnges for charging, etc...
