extends TextureProgressBar
class_name PlayerHealthBar

@export var player: Player

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		print("Found player: ", player)
	else:
		print("Player not found")
		return

	
	value = player.health
	max_value = player.max_health
	player.health_changed.connect(_on_player_health_changed)



func _on_player_health_changed(current_health) -> void:
	value = current_health
