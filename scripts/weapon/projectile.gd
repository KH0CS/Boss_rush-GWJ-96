class_name Projectile
extends Area2D


@export var data: ProjectileData
@export var speed: float = 150.0

var power: float = 0.0
var distance_traveled: float = 0
#var shooter: Node2D = null  # optional: track who fired it
@export var visual: Sprite2D 

var target_type: Type.target

func _ready() -> void:
	scale = Vector2(1, 1) * (1.0 + power)
	speed *= 1+power
	if data.texture:
		visual.texture = load(data.texture)


func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta
	distance_traveled += speed * delta
	if distance_traveled >= data.max_distance:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	match target_type:
		Type.target.PLAYER:
			if body is Player:
				print("Taarget was the player")
				if body.has_method("take_damage"):
					if body.take_damage(data.damage):
						queue_free()
		Type.target.BOSS:
			if body is Boss:
				print("Taarget was the boss")
				if body.has_method("take_damage"):
					if body.take_damage(data.damage):
						queue_free()
					
