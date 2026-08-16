class_name Player
extends CharacterBody2D


@export var gun: Cannon 
var speed = 125

@onready var charge_bar: ProgressBar = %ChargeBar




func _ready() -> void:
	charge_bar.value = gun.charge_time 
	charge_bar.max_value = gun.max_charge_time 


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
