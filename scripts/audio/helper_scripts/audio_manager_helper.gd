class_name AudioManagerHelper
extends Node

## Helper script to automatically register/unregister audio player nodes with the AudioManager.
## Attach this as the script on an AudioStreamPlayer, AudioStreamPlayer2D, or AudioStreamPlayer3D node.
##
## SETUP:
## 1. Select an AudioStreamPlayer, AudioStreamPlayer2D, or AudioStreamPlayer3D node in your scene
## 2. Attach this script as the node's script
## 3. Set the player_name in the Inspector (e.g., "ambient_wind") for later reference
## 4. Select the manager_type (Auto, 2D, or 3D) - Auto detects from node type
## (4.1 If you change your manager's autoload name from the default, update manager_name_2d and/or manager_name_3d in the Inspector)
## 5. Done! The player will auto-register on scene load and auto-unregister when removed.
## Now you can trigger this player from anywhere using AudioManager2d(or3d).get_managed_player("player_name").play() or .stop()

@export var player_name: String = "player_name" ## The name to register this player under in the manager's managed_players dictionary.
@export_enum("Auto", "2D", "3D") var manager_type: int = 0 ## Which AudioManager to register with.
@export var manager_name_2d: StringName = &"AudioManager2d" ## Autoload name for the 2D manager (under /root).
@export var manager_name_3d: StringName = &"AudioManager3d" ## Autoload name for the 3D manager (under /root).

func _ready() -> void:
	if player_name.is_empty():
		push_warning("AudioManagerHelper: player_name is empty")
		return
	
	# Register with the appropriate manager
	_register_player()

## --------------------------- FUNCTIONS -------------------------- ##

func _exit_tree() -> void:
	# Unregister when this node leaves the scene tree
	_unregister_player()


func _register_player() -> void:
	var manager_node = _get_manager_node()
	if not manager_node:
		push_warning("AudioManagerHelper: Manager not found (check autoload)")
		return
	manager_node.managed_players[player_name] = self


func _unregister_player() -> void:
	var manager_node = _get_manager_node()
	if manager_node and manager_node.managed_players.has(player_name):
		manager_node.managed_players.erase(player_name)


func _get_manager_node() -> Node:
	var resolved_type = manager_type
	if manager_type == 0:
		if is_class("AudioStreamPlayer2D"):
			resolved_type = 1
		elif is_class("AudioStreamPlayer3D"):
			resolved_type = 2
		elif is_class("AudioStreamPlayer"):
			resolved_type = 1
		else:
			push_warning("AudioManagerHelper: Auto mode could not determine 2D/3D; defaulting to 2D")
			resolved_type = 1

	var manager_name = manager_name_2d if resolved_type == 1 else manager_name_3d
	return get_node_or_null("/root/%s" % manager_name)
