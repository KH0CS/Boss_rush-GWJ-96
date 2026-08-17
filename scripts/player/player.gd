class_name Player
extends CharacterBody2D

#signal health_changed
#signal died 


@export var gun: Cannon

# player stats
@export var max_health: float = 100
var health: float = 100:
	set(value):
		health = clamp(value, 0, max_health)
		EventBus.player_health_changed.emit(health)
		if health == 0:
			EventBus.player_died.emit()

# Player movement
var move_speed: float = 125.0
var acceleration: float = 250.0
var friction: float = 500.0
var external_force_decay: float = 250.0

var move_velocity: Vector2 = Vector2.ZERO
var external_velocity: Vector2 = Vector2.ZERO

@onready var charge_bar: ProgressBar = %ChargeBar


func _ready() -> void:
	add_to_group("player") # This makes it easier to find the player, and make references
	
	charge_bar.value = gun.charge_time 
	charge_bar.max_value = gun.max_charge_time 
	

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_damage"):
		take_damage(10)


func _physics_process(_delta: float) -> void:
	if gun.charge_time > 0:
		charge_bar.visible = true
	else:
		charge_bar.visible = false
	charge_bar.value = gun.charge_time 
	
	movement(_delta)
	move_and_slide()


func movement(delta: float):
	var input_dir := Input.get_vector("left", "right", "up", "down")
	
	if input_dir != Vector2.ZERO:
		move_velocity = move_velocity.move_toward(input_dir * move_speed, acceleration * delta)
	else:
		move_velocity = move_velocity.move_toward(Vector2.ZERO, friction * delta)
	
	external_velocity = external_velocity.lerp(Vector2.ZERO, 1.0 - exp(-external_force_decay * delta))
	
	velocity = move_velocity + external_velocity

# Used by other/external scripts to apply forces to the player
func apply_force(force: Vector2):
	external_velocity += external_velocity

func take_damage(amount: float) -> void:
	health -= amount
