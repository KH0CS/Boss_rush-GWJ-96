extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

@export var texture_list: Array[Texture2D] = [
	preload("res://assets/sprites/foliage/grass_0001.png"),
	preload("res://assets/sprites/foliage/grass_0002.png"),
	preload("res://assets/sprites/foliage/grass_0003.png"),
	preload("res://assets/sprites/foliage/grass_0004.png"),
	preload("res://assets/sprites/foliage/grass_0005.png"),
	preload("res://assets/sprites/foliage/grass_0006.png"),
	preload("res://assets/sprites/foliage/grass_0007.png"),
	preload("res://assets/sprites/foliage/grass_0008.png"),
	preload("res://assets/sprites/foliage/grass_0009.png"),
]

var stepped_on = null
var tween: Tween = null

func _ready() -> void:
	if not texture_list.is_empty():
		sprite.texture = texture_list.pick_random()
	
	start_idle_sway()

func start_idle_sway() -> void:
	var random_time: float = randf_range(1.5, 2.5)
	var random_skew: float = randf_range(0.1, 0.2)
	
	if tween and tween.is_valid():
		tween.kill()
		
	tween = create_tween().set_loops() # .set_loops() makes it repeat infinitely
	
	# Sway right, then sway left, using smooth sine curves
	tween.tween_property(sprite, "skew", random_skew, random_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "skew", -random_skew, random_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("minions"):
		stepped_on = body
		
		if tween and tween.is_valid():
			tween.kill()
		
		tween = create_tween()
		var dir = sign(global_position.x - stepped_on.global_position.x)
		if dir == 0: dir = 1 
		
		tween.tween_property(sprite, "skew", dir * 0.3, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_body_exited(body: Node2D) -> void:
	if body == stepped_on:
		stepped_on = null
		
		if tween and tween.is_valid():
			tween.kill()
		
		tween = create_tween()
		
		tween.tween_property(sprite, "skew", 0.0, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		
		
		tween.tween_callback(start_idle_sway)
