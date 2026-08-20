extends CharacterBody2D

var speed = 150
var health = 20
var player_chase = false
var player = null


func _physics_process(delta: float) -> void:
	if player_chase:
		position += (player.position - position)/ speed


func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null 
	player_chase = false
