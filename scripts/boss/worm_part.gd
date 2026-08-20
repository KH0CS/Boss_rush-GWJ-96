class_name WormPart
extends CharacterBody2D


const SPEED = 100

@export var part_to_follow: CharacterBody2D
@export var sprite_2d: Sprite2D

func _physics_process(delta: float) -> void:
	var direction = part_to_follow.global_position - global_position
	var distance = global_position.distance_to(part_to_follow.global_position)
	
	if distance > 10:
		velocity = direction.normalized() * SPEED
	else:
		velocity = Vector2.ZERO

		
	look_at(part_to_follow.global_position)
	move_and_slide()
