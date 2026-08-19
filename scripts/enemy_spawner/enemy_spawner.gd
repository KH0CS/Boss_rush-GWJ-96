
extends Node2D

@export var move_range : int = 50
var distance_traveled: float = 0

@export var speed = 50
var current_direction: Vector2

@export var min_time: float = 0.1
@export var max_time: float = 1


@onready var visual: AnimatedSprite2D 
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var move_timer: Timer = $Timer
@onready var world = get_node("/root/World")




func _process(delta: float) -> void:
	if current_direction.x < 0:
		visual.flip_h = true
	else:
		visual.flip_h = false
var old_man_mob_scene := preload("res://scenes/old_man_mob.tscn")
var spawn_points = []


# This is iterating (looking through) the children of the enemy_spawner 
# and is specifically looking for the marker 2D which I have 4 of
# there are 4 so I append them into the spawn_points list variable
func _ready() -> void:
	move_timer.wait_time = randf_range(min_time, max_time)
	move_timer.start()
	for i in get_children():
		if i is Marker2D:
			spawn_points.append(i)

# This is making the spawn positions randomly spawn mobs at different points. 
# I instantiate the mob scene old_man_mob_scene (which will change for final game) to spawn
# at the spawn positions. 
# The world.add_child(old_man_mob) works with the @onready var world getting the root "World"
# To add a child the old_man_mob to the World scene. 
func _on_timer_timeout() -> void:
	var spawn_position = spawn_points[randi() % spawn_points.size()]
	var old_man_mob = old_man_mob_scene.instantiate()
	old_man_mob.position = spawn_position.position
	world.add_child(old_man_mob)
