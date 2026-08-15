extends Node2D

const speed = 450


# This is taking care of the position of the bulelt every frame so it looks smooth. 
func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
