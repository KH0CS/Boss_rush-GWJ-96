extends Area2D

# Use 'var' instead of 'const' so other scripts can rewrite it
@export var speed: float = 450.0 
@export var power: float = 0.0

func _ready() -> void:
	# Scales the projectile size dynamically based on the passed power
	scale = Vector2(1, 1) * (1.0 + power)

func _physics_process(delta: float) -> void:
	# Moves smoothly every frame using the assigned speed
	position += transform.x * speed * delta
