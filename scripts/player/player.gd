class_name Player
extends CharacterBody2D

# Had to make my own implementation because of weird bug when instatiating returning 'null' EventBus donnt work for instatiated scences
signal health_changed(value)

@export var gun: Cannon

# player stats
@export var max_health: float = 100
var health: float = 100:
	set(value):
		health = clamp(value, 0, max_health)
		
		health_changed.emit(value)
		
		EventBus.player_health_changed.emit(health)
		if health <= 0:
			EventBus.player_died.emit()

# Player movement
@export_group("Movement")
@export var move_speed: float = 125.0
@export var acceleration: float = 300.0
@export var friction: float = 250.0
@export var external_velocity_decay: float = 4.0

@export_group("Dash")
@export var dash_distance: float = 500
@export var dash_charges: int = 1
@export var dash_cooldown: float = 1
@export var dash_timer: Timer
@export var invincible_time: float = 0.3
@export var invincible_timer: Timer
var invincible: bool = false:
	set(value):
		invincible = value
		if !invincible:
			modulate = Color.WHITE
		else:
			modulate = Color.BLUE

@export_group("Healing")
@export_file() var heal_icon
@export var healing_charges: int = 3:
	set(value):
		healing_charges = value
		EventBus.player_healing_charges_changed.emit(healing_charges)
@export var heal_per_charge: float = 5


var move_velocity: Vector2 = Vector2.ZERO
var external_velocity: Vector2 = Vector2.ZERO

@onready var charge_bar: ProgressBar = %ChargeBar
@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	add_to_group("player") # This makes it easier to find the player, and make references
	
	charge_bar.value = gun.charge_time 
	charge_bar.max_value = gun.max_charge_time 

	#Setup dash timers
	dash_timer.wait_time = dash_cooldown
	invincible_timer.wait_time = invincible_time
	

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_damage"):
		
		heal(heal_per_charge)
		#apply_force((get_global_mouse_position() - global_position).normalized() * -250)
	if Input.is_action_just_pressed("Dash"):
		dash()
		take_damage(10)
		

func _physics_process(delta: float) -> void:
	if gun.charge_time > 0:
		charge_bar.visible = true
	else:
		charge_bar.visible = false
	charge_bar.value = gun.charge_time 
	
	movement(delta)
	move_and_slide()


func movement(delta: float):
	var input_dir := Input.get_vector("left", "right", "up", "down")
	
	if input_dir != Vector2.ZERO:
		if SoundEffect.SOUND_EFFECT_TYPE.FOOTSTEP not in AudioManager.active_looping_sounds.keys():
			AudioManager.play_loop(SoundEffect.SOUND_EFFECT_TYPE.FOOTSTEP)
		animation_player.play("walk_forward")
		move_velocity = move_velocity.move_toward(input_dir * move_speed, acceleration * delta)
	else:
		animation_player.play("idle")
		if SoundEffect.SOUND_EFFECT_TYPE.FOOTSTEP in AudioManager.active_looping_sounds.keys():
			AudioManager.stop_loop(SoundEffect.SOUND_EFFECT_TYPE.FOOTSTEP)
		move_velocity = move_velocity.move_toward(Vector2.ZERO, friction * delta)
	
	external_velocity = external_velocity.lerp(Vector2.ZERO, 1.0 - exp(-external_velocity_decay * delta))
	
	velocity = move_velocity + external_velocity

# Used by other/external scripts to apply forces to the body
func apply_force(force: Vector2):
	external_velocity += force

func dash() -> void:
	if dash_charges > 0:
		# movement
		var input_dir := Input.get_vector("left", "right", "up", "down")
		if input_dir != Vector2.ZERO:
			external_velocity += input_dir * 500
		else:
			external_velocity += Vector2.UP * 500
			
		invincible = true
		invincible_timer.start()
		
		dash_charges -= 1
		dash_timer.start()
	return
	


func heal( amount: float) -> void:
	if healing_charges > 0:
		healing_charges -= 1
		health += amount
		# TODO: play heal sfx

## Returns wheteher the reciver took damage or not
func take_damage(amount: float) -> bool:
	if invincible:
		return false
	health -= amount
	AudioManager.play_audio(SoundEffect.SOUND_EFFECT_TYPE.PLAYER_TAKING_DAMAGE)
	return true


func _on_dash_timer_timeout() -> void:
	dash_charges += 1
	dash_timer.stop()


func _on_invinicbilty_timer_timeout() -> void:
	invincible = false
