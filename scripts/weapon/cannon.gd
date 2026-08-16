class_name Cannon
extends Node2D

signal storage_changed(current_storage: Array)


const PROJECTILE = preload("res://scenes/weapon/projectile.tscn")

@export var player: Player
# Charge time settings
@export var min_charge_to_release : float = 0.2  # below this = "tap", no charge
@export var max_charge_time : float = 1.5  # seconds to reach full charge
@export var gun_rotation_speed: float = 15.0  # higher = snappier, lower = smoother

@export var gun_storage: Array[Type.elements] = []:
	set(value):
		gun_storage = value
		storage_changed.emit()
@export var max_ammo_ammount: int = 3
var possible_combos: Array = []


var is_charging := false
var charge_time := 0.0

@onready var gun_muzzle: Marker2D = %Marker2D
@onready var vaccum: Area2D = %Vaccum


func _input(_event: InputEvent) -> void:
	# Vaccum only active while right click is pressed
	if Input.is_action_pressed("vacuum") and gun_storage.size() < max_ammo_ammount:
		vaccum.monitoring = true
	else:
		vaccum.monitoring = false


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
	if Input.is_action_just_pressed("shoot") and gun_storage.size() == 3:
		is_charging = true
		charge_time = 0.0
	
	# Add charge using the delta
	if is_charging:
		charge_time += delta
		charge_time = min(charge_time, max_charge_time)
		
		# Update UI for charging
		update_charge_visual(charge_time / max_charge_time)
	else:
		charge_time = 0.0
		

	if Input.is_action_just_released("shoot") and is_charging:
		release_attack(charge_time)
		is_charging = false
		
	

func release_attack(time_held: float) -> void:
	var charge_ratio := time_held / max_charge_time  # 0.0 to 1.0
	
	# only release projectile
	if time_held > min_charge_to_release:
		do_charged_attack(charge_ratio)

func do_charged_attack(power: float) -> void:
	## figure out the projectiles
	var shot = ElementalCombos.get_elemental_combo(gun_storage)
	var rot_i = 0
	for projectile_data in shot.projectiles:
		var bullet_spawn = PROJECTILE.instantiate() as Projectile
		# give bullet new data 
		bullet_spawn.data = projectile_data
		bullet_spawn.target_type = shot.target_type
		bullet_spawn.global_position = gun_muzzle.global_position
		
		# rotate and add spread
		bullet_spawn.rotation = rotation + (shot.spread * rot_i)
		rot_i += 1
		
		# Set projectile charge
		bullet_spawn.power = power * 0.1
		
		get_tree().root.add_child(bullet_spawn)
		await get_tree().create_timer(shot.interval).timeout

	## remove elementals from gun
	gun_storage.pop_front()
	gun_storage.pop_front()
	gun_storage.pop_front()


func update_charge_visual(_ratio: float) -> void:
	pass # update a charge bar, charge effects, sprite cahnges for charging, etc...



func add_ammo(ammo_type: Type.elements) -> void:
	gun_storage.append(ammo_type)
	print(gun_storage)



func _on_vaccum_body_entered(body: Node2D) -> void:
	## check if its minion
	if body is Minion:
		body.start_collect(self)
	
	
	
