extends Area2D

@export var speed: float = 150.0
@export var power: float = 0.0
#var shooter: Node2D = null  # optional: track who fired it

func _ready() -> void:
	scale = Vector2(1, 1) * (1.0 + power)
	speed *= 1+power
	print(speed)
	
	# handle git detection
	#area_entered.connect(_on_area_entered)
	#body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta

#func _on_area_entered(area: Area2D) -> void:
	#_handle_hit(area)

#func _on_body_entered(body: Node2D) -> void:
	#_handle_hit(body)

#func _handle_hit(target: Node) -> void:
	#if target == shooter:
	#	return
	#if target.has_method("take_damage"):
	#	target.take_damage(power * 10)  # example damage scaling
	#queue_free()
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
