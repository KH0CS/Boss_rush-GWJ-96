class_name Projectile
extends Area2D


@export var data: ProjectileData
var power: float = 0.0
var distance_traveled: float = 0
#var shooter: Node2D = null  # optional: track who fired it
@onready var visual: Sprite2D = %visual

var target_type: Type.target

func _ready() -> void:
	scale = Vector2(1, 1) * (1.0 + power)
	data.speed *= 1+power
	if data.texture:
		visual.texture = load(data.texture)


func _physics_process(delta: float) -> void:
	position += transform.x * data.speed * delta
	distance_traveled += data.speed * delta
	if distance_traveled >= data.max_distance:
		queue_free()
	
