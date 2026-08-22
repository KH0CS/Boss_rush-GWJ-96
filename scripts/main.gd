extends Node

# Load new scene
func _ready() -> void:
	SceneManager.change_scene("res://scenes/levels/tutorial.tscn")
