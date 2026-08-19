extends Area2D

@onready var pos 



var speed = 250
var player_pos
var world_area

func _ready() -> void:
	$ProgressBar.value = 10
