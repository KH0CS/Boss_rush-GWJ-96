class_name Cannon
extends Node2D

#signal storage_changed(current_storage: Array[Type.elements])
signal charge_status(current_storage: Array)

const PROJECTILE = preload("res://scenes/weapon/projectile.tscn")

@export var player: Player
# Charge time settings
@export var min_charge_to_release : float = 0.2  # below this = "tap", no charge
@export var max_charge_time : float = 1.5  # seconds to reach full charge
@export var gun_rotation_speed: float = 15.0  # higher = snappier, lower = smoother
@export var recoil_strength: float = 500.0 # recoil strength

@export var gun_storage: Array[Type.elements] = []
		#:
	#set(value):
		#gun_storage = value
		#EventBus.storage_changed.emit(gun_storage)
@export var max_ammo_ammount: int = 3
@export var max_storage_size: int = 10

@export var vacuum_power: float = 25

@onready var gun_muzzle: Marker2D = %Marker2D
@onready var vaccum: Area2D = %Vaccum

var is_charging := false
var charge_time := 0.0:
	set(current_charge):
		charge_time = current_charge
		update_charge_visual(current_charge, min_charge_to_release, max_charge_time)

var minions_in_vacuum: Array[Minion] = []
var vacuum_active: bool = false

func _input(_event: InputEvent) -> void:
	# Vaccum only active while right click is pressed
	if Input.is_action_pressed("vacuum") and gun_storage.size() < max_storage_size:
		vacuum_active = true
	else:
		vacuum_active = false


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
	if Input.is_action_just_pressed("shoot") and gun_storage.size() >= 3:
		is_charging = true
		charge_time = 0.0

	
	# Add charge using the delta
	if is_charging:
		charge_time += delta
		charge_time = min(charge_time, max_charge_time)
	
	else:
		charge_time = 0.0
	
	if Input.is_action_just_released("shoot") and is_charging:
		release_attack(charge_time)
		is_charging = false

func _physics_process(delta: float) -> void:
	if vacuum_active == true:
		for minion in minions_in_vacuum:
			if global_position.distance_to(minion.global_position) < 30:
				minion.collect()
				add_ammo(minion.element)
			
			var direction = (global_position - minion.global_position).normalized()
			minion.apply_force(direction * vacuum_power)


func release_attack(time_held: float) -> void:
	var charge_ratio := time_held / max_charge_time  # 0.0 to 1.0
	
	# only release projectile
	if time_held > min_charge_to_release:
		do_charged_attack(charge_ratio)

func do_charged_attack(power: float) -> void:
	## Copy the first 3 elements from gun_storage
	var barrel: Array[Type.elements] = []
	for i in range(max_ammo_ammount):
		barrel.append(gun_storage[i])
	
	
	## figure out the projectiles
	var shot = ElementalCombos.get_elemental_combo(barrel)
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
	
	# Applying the recoil, the recoil strength is proportional to the the charge time
	player.apply_force((-Vector2.from_angle(rotation) * recoil_strength) * power)
	
	## remove elementals from gun
	gun_storage.pop_front()
	gun_storage.pop_front()
	gun_storage.pop_front()
	EventBus.storage_changed.emit(gun_storage)
	

func update_charge_visual(current_charge: float, minimum_charge, max_charge: float) -> void:
	# Currently just changes the bar
	# TODO: Add indicator(Charging, Full Charged, Failed to Shoot)
	var charge = min((current_charge/max_charge) * 100, 100)
	
	charge_status.emit(charge)



func add_ammo(ammo_type: Type.elements) -> void:
	gun_storage.append(ammo_type)
	print(gun_storage)
	EventBus.storage_changed.emit(gun_storage)


func _on_vaccum_body_entered(body: Node2D) -> void:
	if body is Minion:
		minions_in_vacuum.append(body)

func _on_vaccum_body_exited(body: Node2D) -> void:
	if body is Minion:
		minions_in_vacuum.erase(body)
