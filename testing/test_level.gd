extends Node2D

## this file was to test if maaacks level_lost system works for us
signal level_lost

@onready var debug_label: Label = %Debug_Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)
	EventBus.shot_fired.connect(_on_shot_fired)
	debug_label.text = ""



func _on_player_died() -> void:
	level_lost.emit()


func _on_shot_fired(shot_name: String) -> void:
	debug_label.text = shot_name
