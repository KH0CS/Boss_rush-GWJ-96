extends Control

@onready var charge_bar = $ChargeBar
@onready var charge_indicator = $ChargeBar/Indicators

func _ready():
	# Find the Player in the scene tree
	# await get_tree().node_added
	# var player = get_tree().root.get_node_or_null("World/Player/Cannon")
	# if player:
	#	player.charge_changed.connect(_set_charge)
	
	print("ui loaded")
	charge_indicator.play("idle_charge")
