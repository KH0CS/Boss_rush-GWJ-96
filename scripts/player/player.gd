extends CharacterBody2D

var speed = 125
# Self explanitory this is your movement with the project input map very very basic
func movement():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(delta: float) -> void:
	movement()
	move_and_slide()
