class_name Minion
extends CharacterBody2D

signal collected( element: Type.elements)

@export var element: Type.elements = Type.elements.FIRE
@export_file() var texture

@export var move_range : int = 50
var distance_traveled: float = 0

@export var move_speed: float = 50.0
var current_direction: Vector2

@export var min_time: float = 0.1
@export var max_time: float = 1

var collect_speed: float = 100
## given when sucked, so it can follow to correct location

@onready var visual: Sprite2D = %Visual
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var move_timer: Timer = %MoveTimer

# Minion movement: TO ADD
var acceleration: float = 75.0
var friction: float = 150.0
var external_velocity_decay: float = 5.0

var move_velocity: Vector2 = Vector2.ZERO
var external_velocity: Vector2 = Vector2.ZERO

var in_vacuum_radius: bool = false

func _ready() -> void:
	add_to_group("minion") # This makes it easier to find the minion, and make references

	
	visual.texture = load(texture)
	move_timer.wait_time = randf_range(min_time, max_time)
	move_timer.start()


func _process(delta: float) -> void:
	if current_direction.x < 0:
		visual.flip_h = true
	else:
		visual.flip_h = false

	if move_timer.time_left <= 0:
		distance_traveled += move_speed * delta
		if distance_traveled >= move_range:
			## traveled the distance reset and wait
			move_timer.wait_time = randf_range(min_time, max_time)
			move_timer.start()
			distance_traveled = 0
		else:
			velocity = Vector2.ZERO

	movement(delta)
	
	move_and_slide()


func movement(delta: float):
	if current_direction != Vector2.ZERO:
		move_velocity = move_velocity.move_toward(current_direction * move_speed, acceleration * delta)
	else:
		move_velocity = move_velocity.move_toward(Vector2.ZERO, friction * delta)
	
	external_velocity = external_velocity.lerp(Vector2.ZERO, 1.0 - exp(-external_velocity_decay * delta))
	
	velocity = move_velocity + external_velocity

# Used by other/external scripts to apply forces to the body
func apply_force(force: Vector2):
	external_velocity += force


func _get_random_direction() -> Vector2:
	var ranx = randf_range(-1, 1)
	var rany = randf_range(-1, 1)
	var random_direction = Vector2(ranx, rany).normalized()
	return random_direction


func _on_move_timer_timeout() -> void:
	current_direction = _get_random_direction()

func collect():
	## maybe play animation
	
	## send data 
	collected.emit(element)
	##queue free
	queue_free()
