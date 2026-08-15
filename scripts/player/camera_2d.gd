# camera_follow.gd
extends Camera2D

@export var follow_speed = 6.0  # Higher = snappier, lower = more floaty
@export var camera_offset = Vector2(0, 0)
@export var look_ahead_amount = Vector2(10.0, 10.0)  # Separate X/Y strength
@export var look_ahead_speed = 3.0

var player: CharacterBody2D
var look_ahead_offset = Vector2.ZERO

func _ready():
	player = get_parent()

func _process(delta):
	if not player:
		return
	
	# Frame-rate independent smoothing
	var target_pos = player.global_position + camera_offset
	global_position = global_position.lerp(target_pos, 1.0 - exp(-follow_speed * delta))
	
	# Look-ahead camera shifts toward movement direction on both axes
	var target_look_ahead = Vector2.ZERO
	if player.velocity.x != 0:
		target_look_ahead.x = sign(player.velocity.x) * look_ahead_amount.x
	if player.velocity.y != 0:
		target_look_ahead.y = sign(player.velocity.y) * look_ahead_amount.y
	
	look_ahead_offset = look_ahead_offset.lerp(target_look_ahead, 1.0 - exp(-look_ahead_speed * delta))
	global_position += look_ahead_offset * delta * 10
