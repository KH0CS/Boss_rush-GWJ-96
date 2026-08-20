class_name ShotBase
extends Node2D


@export var projectiles: Array[PackedScene]
@export var interval: float = 0
@export var spread: float = 0
@export var target_type: Type.target
@export var default_power: float = 1

@export var shooter: Node2D

var power: float = 0
var current_projectile: int = 0
var spread_per_projectile: float = 0
var middle_idx: float = 0

@export var interval_timer: Timer

func _ready() -> void:
	spread_per_projectile = spread / projectiles.size() 
	middle_idx = (projectiles.size() - 1) / 2.0
	# setup interval
	if interval > 0:
		interval_timer.wait_time = interval
		interval_timer.start()
		shoot()
	else:
		for p in projectiles:
			shoot()
	
	

func shoot() -> void:
	# intantiate the projectile scene
	var spawned_projetile = projectiles[current_projectile].instantiate() as Projectile
	
	# set location
	spawned_projetile.global_position = shooter.global_position
	
	# set target type
	spawned_projetile.target_type = target_type
	
	# Set projectile charge
	# TODO: fix, workaround for now (power needs to be passed
	if power > 0:
		spawned_projetile.power = power
	else:
		spawned_projetile.power = default_power
		
	# apply rotation
	if spread > 0:
		var distance_to_middle = current_projectile - middle_idx
		var angle = spread_per_projectile * distance_to_middle
		
		spawned_projetile.rotation_degrees = shooter.rotation_degrees + angle
	else:
		spawned_projetile.rotation_degrees = shooter.rotation_degrees 
		
	## Can probalby be moved to projectile
	AudioManager.play_audio(spawned_projetile.data.shot_sfx)
	get_tree().root.add_child(spawned_projetile)
	current_projectile += 1
	# if all projetiles have been spawned this node can be removed
	if current_projectile >= projectiles.size():
		print("Removing shot")
		queue_free()
	#reset timer
	if interval > 0:
		interval_timer.start()


func _on_interval_timer_timeout() -> void:
	shoot()
