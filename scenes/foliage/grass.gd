extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

var stepped_on: Player = null

func _process(delta: float) -> void:
	if stepped_on:
		var dir = sign(global_position.x - stepped_on.global_position.x)
		
		# bendy thingy with the grass away
		var tween = create_tween()
		tween.tween_property(sprite, "skew", dir * 0.5, 0.05)
		# Spring back to normal with an elastic ease
		tween.tween_property(sprite, "skew", 0.0, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		stepped_on = body


func _on_body_exited(body: Node2D) -> void:
	stepped_on = null
