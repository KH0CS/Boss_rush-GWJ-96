extends State
class_name BossIdle

@export var player: Player
@export var max_state_time: float = 1
@export var timer: Timer


@export_group("Visuals")
@export var boss: CharacterBody2D
@export var animation_player: AnimationPlayer
@export var sprite: Sprite2D



func Enter() -> void:
	#print("Enetered: Idle")
	if animation_player.has_animation("idle"):
		animation_player.play("idle")
	player = get_tree().get_first_node_in_group("Player") as Player
	timer.wait_time = randf_range(0,max_state_time)
	
	if not timer.timeout.is_connected(transition_to_random):
		timer.timeout.connect(transition_to_random)
	timer.wait_time = max_state_time
	timer.start()

func Physics_Update() -> void:
	var direction = player.global_position - boss.global_position
	boss.velocity = Vector2.ZERO
	
	if direction.length() < 50:
		Transitioned.emit(self, "bossfollow")

func transition_to_random() -> void:
	var rand_state: State = transition_States.pick_random()
	#print(" idle should transition to: " + rand_state.name.to_lower())

	Transitioned.emit(self, rand_state.name.to_lower())
	timer.timeout.disconnect(transition_to_random)
