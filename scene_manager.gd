extends Node

var current_level: Node = null
#var loading_screen_scene = preload("res://ui/loading_screen.tscn")
var current_scene: String # for checking, and restarting scence logic

func change_scene(path: String) -> void:
	call_deferred("_deferred_change_scene", path)
	current_scene = path

func restart_scence() -> void:
	_deferred_change_scene(current_scene)

func _deferred_change_scene(path: String) -> void:
	# TODO LOADING SCREEN
	if current_level:
		current_level.queue_free()
	var new_scene = load(path).instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	current_level = new_scene
