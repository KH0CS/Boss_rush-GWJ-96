extends CharacterBody2D
class_name Boss

@export var shoot_point: Marker2D
@export var player: Player

@export var max_health: float = 500
@export var current_health: float = 500:
	set(value):
		current_health = clamp(value, 0, max_health)
		EventBus.boss_health_changed.emit(current_health)
		if current_health == 0:
			EventBus.boss_died.emit()
		


func _physics_process(delta: float) -> void:
	if player:
		shoot_point.look_at(player.global_position)
	
	move_and_slide()


func take_damage(amount: float) -> void:
	print("Boss took " + str(amount) + " damage")
	current_health -= amount
	# TODO: play sfx
