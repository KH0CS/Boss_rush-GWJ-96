extends GridContainer

## preload icons
const FIRE_MINION = preload("uid://bb3nee0fj330i")
const ICE_MINION = preload("uid://eujy5j8tlopn")
const LIGHTNING_MINION = preload("uid://jew1sjk6ux1u")
const EARTH_MINION = preload("uid://w4nw1k0qbqnv")




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.storage_changed.connect(_on_storage_changed)
	# clear 
	for child in get_children():
		child.queue_free()

func _on_storage_changed(current_storage: Array[Type.elements]) -> void:
	# clear 
	for child in get_children():
		child.queue_free()
	# create and add new texture rectangles
	for element in current_storage:
		var rect: TextureRect = TextureRect.new()
		match element:
			Type.elements.FIRE:
				rect.texture = FIRE_MINION
			Type.elements.ICE:
				rect.texture = ICE_MINION
			Type.elements.EARTH:
				rect.texture = EARTH_MINION
			Type.elements.LIGHTNING:
				rect.texture = LIGHTNING_MINION
			_:
				rect.texture = FIRE_MINION
		add_child(rect)
