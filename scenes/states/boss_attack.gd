extends State
class_name BossAttack


@export var player: Player
@export var max_state_time: float = 1
@export var timer: Timer


@export_group("Visuals")
@export var boss: Boss
@export var animation_player: AnimationPlayer
@export var sprite: Sprite2D


## when it neters it picks a random attack based on the range

@export var attacks: Dictionary = {
	"attack1": {
		"animation_name": "spread_shot",
		"shot_data": preload("res://scenes/bosses/shots/boss_spread_shot.tscn")
	},
	"attack2": {
		"animation_name": "burst",
		"shot_data": preload("res://scenes/bosses/shots/boss_spread_shot.tscn")
	},
}


func Enter() -> void:
	#print("entered attack")
	player = get_tree().get_first_node_in_group("Player") as Player
	## play attack animation
	
	## spawn attack
	var rand_attack = attacks.keys().pick_random()
	var attack_data = attacks[rand_attack]
	var shot_data = attack_data["shot_data"].instantiate() as ShotBase
	shot_data.shooter = boss.shoot_point
	boss.add_child(shot_data)

	if not timer.timeout.is_connected(transition_to_random):
		timer.timeout.connect(transition_to_random)
	timer.wait_time = max_state_time
	timer.start()
	
func transition_to_random() -> void:
	var rand_state: State = transition_States.pick_random()
	#print("should transition to: " + rand_state.name.to_lower())
	Transitioned.emit(self, rand_state.name.to_lower())
	timer.timeout.disconnect(transition_to_random)
