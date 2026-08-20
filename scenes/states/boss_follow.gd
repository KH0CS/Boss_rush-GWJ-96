extends State
class_name BossFollow


@export var player: Player
@export var move_speed: float = 50
@export var max_state_time: float = 1
@export var timer: Timer

@export_group("Visuals")
@export var boss: CharacterBody2D
@export var animation_player: AnimationPlayer
@export var sprite: Sprite2D




func Enter() -> void:
	#print("entered follow")
	player = get_tree().get_first_node_in_group("Player") as Player
	if animation_player.has_animation("spin"):
		animation_player.play("spin")
	
	if not timer.timeout.is_connected(transition_to_random):
		timer.timeout.connect(transition_to_random)
	timer.wait_time = max_state_time
	timer.start()


func Physics_Update() -> void:
	var direction = player.global_position - boss.global_position
	
	if direction.length() > 50:
		boss.velocity = direction.normalized() * move_speed
	else:
		boss.velocity = Vector2.ZERO
	
	if direction.length() > 2000:
		Transitioned.emit(self, "bossidle")
	

func transition_to_random() -> void:
	var rand_state: State = transition_States.pick_random()
	#print("follew should transition to: " + rand_state.name.to_lower())

	Transitioned.emit(self, rand_state.name.to_lower())
	timer.timeout.disconnect(transition_to_random)
