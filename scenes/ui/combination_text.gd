extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.shot_fired.connect(_on_shot_fired)

func _on_shot_fired(shot_name: String) -> void:
	text = shot_name
