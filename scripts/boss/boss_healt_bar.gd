extends TextureProgressBar
class_name BossHealthBar

@export var boss: Boss


func _ready() -> void:
	EventBus.boss_health_changed.connect(_on_boss_health_changed)
	max_value = boss.max_health
	value = boss.current_health


func _on_boss_health_changed(current_health) -> void:
	value = current_health
