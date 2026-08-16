extends Control

@onready var charge_bar: TextureProgressBar = $ChargeBar

func _ready():
	# Find the Player in the scene tree
	await get_tree().node_added
	var player = get_tree().root.get_node_or_null("World/Player/Cannon")
	if player:
		player.charge_status.connect(_set_charge)
	

func _set_charge(current: float):
	charge_bar.value = current
