
extends Node2D


@onready var world = get_node("/root/enemy_spawner")




var old_man_mob_scene := preload("res://scenes/old_man_mob.tscn")
var spawn_points = []


# This is iterating (looking through) the children of the enemy_spawner 
# and is specifically looking for the marker 2D which I have 4 of
# there are 4 so I append them into the spawn_points list variable
func _ready() -> void:
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
