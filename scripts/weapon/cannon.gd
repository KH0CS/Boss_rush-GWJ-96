class_name Cannon
extends Node2D

#signal storage_changed(current_storage: Array[Type.elements])

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

@onready var cannon_effects: ShootingEffects = $Effects

var is_charging := false
var charge_time := 0.0

var minions_in_vacuum: Array[Minion] = []
var vacuum_active: bool = false:
	set(value):
		vacuum_active = value
		cannon_effects.vacuum(value)

func _input(_event: InputEvent) -> void:
	# input
	if Input.is_action_just_pressed("shoot") and vacuum_active == false and gun_storage.size() >= 3:
		is_charging = true
		charge_time = 0.0
	
	if Input.is_action_pressed("vacuum") and is_charging == false and gun_storage.size() < max_storage_size:
		vacuum_active = true
		if SoundEffect.SOUND_EFFECT_TYPE.SUCTION_LONG not in AudioManager.active_looping_sounds.keys():
			AudioManager.play_loop(SoundEffect.SOUND_EFFECT_TYPE.SUCTION_LONG)
	
	if Input.is_action_just_pressed("vacuum") and gun_storage.size() >= max_storage_size:
		AudioManager.play_audio(SoundEffect.SOUND_EFFECT_TYPE.BEEPS)
	
	# Input release checks
	if Input.is_action_just_released("shoot") and is_charging:
		release_attack(charge_time)
		is_charging = false
		cannon_effects.shoot()
	
	if Input.is_action_just_released("vacuum") and vacuum_active:
		vacuum_active = false
		minions_in_vacuum.clear()
		if SoundEffect.SOUND_EFFECT_TYPE.SUCTION_LONG in AudioManager.active_looping_sounds.keys():
			AudioManager.stop_loop(SoundEffect.SOUND_EFFECT_TYPE.SUCTION_LONG)

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
	
	# Add charge using the delta
	if is_charging:
		charge_time += delta
		charge_time = min(charge_time, max_charge_time)
	else:
		charge_time = 0.0

func _physics_process(_delta: float) -> void:
	if vacuum_active == true:
		# This is somewhat ineffecient but is the most reliabe method for checking on the minions,
		# because relying on body_enter/exit causes some weird edge cases,
		# causing minions to not get sucked in even if in the vacuum
		## if minions_in_vacuum.is_empty(): # putting loop on this statement will make it more effecient but the pulling of the minions is will one by one except for the first pull
		for body in vaccum.get_overlapping_bodies():
			if not body in minions_in_vacuum:
				minions_in_vacuum.append(body)
		
		
		# minion handling logic
		for minion in minions_in_vacuum:
			if is_instance_valid(minion): # incase of any weird deletion prevents crashes
				# apply SUCKING FORCE?!?!??!!!!
				minion.apply_force((global_position - minion.global_position).normalized() * vacuum_power)
				
				# Adds the minion into the ammo
				if global_position.distance_to(minion.global_position) < 30:
					minion.collect()
					add_ammo(minion.element)
					minions_in_vacuum.erase(minion)
					
				# cancels the vacuum if the storage is full 
				if gun_storage.size() == max_storage_size:
					vacuum_active = false
					minions_in_vacuum.clear()
					AudioManager.play_audio(SoundEffect.SOUND_EFFECT_TYPE.BEEPS)


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
	var shot_node = shot.instantiate() as ShotBase
	shot_node.power = power * 0.1
	shot_node.shooter = self
	add_child(shot_node)
	
	## Applying the recoil, the recoil strength is proportional to the the charge time
	player.apply_force((-Vector2.from_angle(rotation) * recoil_strength) * power)
	
	## remove elementals from gun
	for i in range(max_ammo_ammount):
		gun_storage.pop_front()
	EventBus.storage_changed.emit(gun_storage)


func add_ammo(ammo_type: Type.elements) -> void:
	gun_storage.append(ammo_type)
	#print(gun_storage)
	EventBus.storage_changed.emit(gun_storage)


#func _on_vaccum_body_entered(body: Node2D) -> void:
#	if vacuum_active and body is Minion:
#		minions_in_vacuum.append(body)

# commented out to make catching the elementals eassier
# works because the vacuum only needs to touch the minions once and theyll get sucked in
#func _on_vaccum_body_exited(body: Node2D) -> void:
#	if body is Minion:
#		minions_in_vacuum.erase(body)
