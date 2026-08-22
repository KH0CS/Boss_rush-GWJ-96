extends TextureProgressBar
class_name PlayerHealthBar

@export var player: Player
@export var healing_charges_cont: HBoxContainer
var heal_icon = preload("res://assets/sprites/ui/health bar/plus_icon.png")

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		print("Found player: ", player)
	else:
		print("Player not found")
		return
	EventBus.player_healing_charges_changed.connect(_on_healing_charges_changed)
	_on_healing_charges_changed(player.healing_charges)
	value = player.health
	max_value = player.max_health
	player.health_changed.connect(_on_player_health_changed)



func _on_player_health_changed(current_health) -> void:
	value = current_health

func _on_healing_charges_changed(current_charges) -> void:
	for child in healing_charges_cont.get_children():
		child.queue_free()
	
	for i in range(current_charges):
		var new_rect: TextureRect = TextureRect.new()
		new_rect.texture = heal_icon
		new_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		healing_charges_cont.add_child(new_rect)
		
