extends Boss

@export var head_visual: Sprite2D


func _ready() -> void:
	# get player if not given
	player = get_tree().get_first_node_in_group("Player")
	
func _process(delta: float) -> void:
	if player:
		head_visual.look_at(player.global_position)
