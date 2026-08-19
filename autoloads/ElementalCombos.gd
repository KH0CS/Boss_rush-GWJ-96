extends Node

var combos: Dictionary = {
	## single element
	"fireball": {
		"recepie": { Type.elements.FIRE : 3 },
		"shot_data": preload("res://scenes/shots/premade_shots/spread_shot.tscn")
	},
	"icicle":{
		"recepie": { Type.elements.ICE : 3 },
		"shot_data": preload("res://scenes/shots/premade_shots/burst.tscn")
	},
	"boulder":{
		"recepie": { Type.elements.EARTH : 3 },
		"shot_data": preload("res://scenes/shots/premade_shots/burst.tscn")
	},
	"lightning":{
		"recepie": { Type.elements.LIGHTNING : 3 },
		"shot_data": preload("res://scenes/shots/premade_shots/burst.tscn")
	},
	
	## 2 differnt elements
	"water": {
		"recepie": { Type.elements.FIRE : 1, Type.elements.ICE : 1, },
		"shot_data": preload("res://scenes/shots/premade_shots/burst.tscn")
	},
	"firebolt": {
		"recepie": { Type.elements.FIRE : 1, Type.elements.LIGHTNING : 1, },
		"shot_data": preload("res://scenes/shots/premade_shots/spread_shot.tscn")
	},
	"lava": {
		"recepie": { Type.elements.FIRE : 1, Type.elements.EARTH : 1, },
		"shot_data": preload("res://scenes/shots/premade_shots/spread_shot.tscn")
	},
	"mud": {
		"recepie": { Type.elements.ICE : 1, Type.elements.EARTH : 1, },
		"shot_data": preload("res://scenes/shots/premade_shots/spread_shot.tscn")
	},
	"lightning boulder": {
		"recepie": { Type.elements.LIGHTNING : 1, Type.elements.EARTH : 1, },
		"shot_data": preload("res://scenes/shots/premade_shots/spread_shot.tscn")
	},
	"ice lightning": {
		"recepie": { Type.elements.LIGHTNING : 1, Type.elements.ICE : 1, },
		"shot_data": preload("res://scenes/shots/premade_shots/spread_shot.tscn")
	},
	
	## 3 different types
	"supercharged water orb": {
		"recepie": { Type.elements.FIRE : 1, Type.elements.ICE : 1, Type.elements.LIGHTNING : 1 },
		"shot_data": preload("res://scenes/shots/premade_shots/spread_shot.tscn")
	},
	"fire water boulder": {
		"recepie": { Type.elements.FIRE : 1, Type.elements.ICE : 1, Type.elements.EARTH : 1 },
		"shot_data": preload("res://scenes/shots/premade_shots/spread_shot.tscn")
	},
	"lightning water boulder": {
		"recepie": { Type.elements.LIGHTNING : 1, Type.elements.ICE : 1, Type.elements.EARTH : 1 },
		"shot_data": preload("res://scenes/shots/premade_shots/spread_shot.tscn")
	},
}



func get_elemental_combo(given_elements: Array[Type.elements]) -> PackedScene:
	# convert array int dict so we can use has_all method both ways
	var elements_dict = {}
	for el in given_elements:
		if elements_dict.has(el):
			elements_dict[el] += 1
		else:
			elements_dict[el] = 1
	# fallback shot
	var shot = preload("res://scenes/shots/shot_base.tscn")
	for combo_name in combos.keys():
		var current_recepie = combos[combo_name]["recepie"]
		if current_recepie.has_all(given_elements) and elements_dict.has_all(current_recepie.keys()):
			print(combo_name)
			shot = combos[combo_name]["shot_data"]
			EventBus.shot_fired.emit(combo_name)
			return shot
	push_error("Didnt find compatible combo")
	return shot
