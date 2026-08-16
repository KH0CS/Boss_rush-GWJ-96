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
		

var speed = 125

@onready var charge_bar: ProgressBar = %ChargeBar




func _ready() -> void:
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
	
	movement()
	move_and_slide()


func movement():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
	
func take_damage(amount: float) -> void:
	health -= amount
	
