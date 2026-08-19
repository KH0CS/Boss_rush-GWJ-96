extends VBoxContainer

## preload icons
#const FIRE_MINION = preload("uid://bb3nee0fj330i")
#const ICE_MINION = preload("uid://eujy5j8tlopn")
#const LIGHTNING_MINION = preload("uid://jew1sjk6ux1u")
#const EARTH_MINION = preload("uid://w4nw1k0qbqnv")

@export var barrel: GridContainer
@export var storage: GridContainer

# TODO: change for actual elemnt icons
@export var elements_icons: Dictionary = {
	Type.elements.FIRE: preload("uid://bb3nee0fj330i"),
	Type.elements.ICE: preload("uid://eujy5j8tlopn"),
	Type.elements.LIGHTNING: preload("uid://jew1sjk6ux1u"),
	Type.elements.EARTH: preload("uid://w4nw1k0qbqnv"),
}


func _ready() -> void:
	EventBus.storage_changed.connect(_on_storage_changed)
	# clear barrel
	for child in barrel.get_children():
		child.queue_free()
	# clear storage 
	for child in storage.get_children():
		child.queue_free()

func _on_storage_changed(current_storage: Array[Type.elements]) -> void:
	# clear barrel
	for child in barrel.get_children():
		child.queue_free()
	# clear storage 
	for child in storage.get_children():
		child.queue_free()
	# create and add new texture rectangles
	var idx = 0
	for element in current_storage:
		var rect: TextureRect = TextureRect.new()
		rect.texture = elements_icons[element]
		if idx < 3:
			barrel.add_child(rect)
		else:
			storage.add_child(rect)
			
		idx += 1
