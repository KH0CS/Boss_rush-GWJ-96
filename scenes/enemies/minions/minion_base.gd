class_name Minion
extends CharacterBody2D

signal collected( element: Type.elements)


@export var element: Type.elements = Type.elements.FIRE
@export_file() var texture

@export var move_range : int = 50
var distance_traveled: float = 0

@export var speed = 50
var current_direction: Vector2

@export var min_time: float = 0.1
@export var max_time: float = 1

var collect_speed: float = 100
## given when sucked, so it can follow to correct location
var gun_marker: Cannon


@onready var visual: Sprite2D = %Visual
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var move_timer: Timer = %MoveTimer


func _ready() -> void:
	visual.texture = load(texture)
	move_timer.wait_time = randf_range(min_time, max_time)
	move_timer.start()


func _process(delta: float) -> void:
	if current_direction.x < 0:
		visual.flip_h = true
	else:
		visual.flip_h = false

	## if we have gun marker we can collect otherwise roam
	if gun_marker:
		if global_position.distance_to(gun_marker.global_position) > 30:
			velocity = global_position.direction_to(gun_marker.global_position) * collect_speed
		else:
			_on_collect()
	else:
		if move_timer.time_left <= 0:
			distance_traveled += speed * delta
			velocity = current_direction * speed
			if distance_traveled >= move_range:
				## traveled the distance reset and wait
				move_timer.wait_time = randf_range(min_time, max_time)
				move_timer.start()
				distance_traveled = 0
			else:
				velocity = Vector2.ZERO
	move_and_slide()


func _get_random_direction() -> Vector2:
	var ranx = randf_range(-1, 1)
	var rany = randf_range(-1, 1)
	var random_direction = Vector2(ranx, rany).normalized()
	return random_direction


func _on_move_timer_timeout() -> void:
	current_direction = _get_random_direction()

func start_collect( gun: Cannon) -> void:
	gun_marker = gun
	
func _on_collect():
	## maybe play animation
	
	## send data 
	collected.emit(element)
	##queue free
	queue_free()


	
	
	
