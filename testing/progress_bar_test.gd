extends TextureProgressBar

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.player_health_changed.connect(_on_player_health_changed)
	value = player.health
	max_value = player.max_health


func _on_player_health_changed(current_health) -> void:
	value = current_health
