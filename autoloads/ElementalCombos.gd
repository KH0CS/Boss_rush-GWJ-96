extends Node




#var combos: Dictionary = {
	#"fireball": {
		#"recepie": [Type.elements.FIRE,Type.elements.FIRE,Type.elements.FIRE],
		#"data": ProjectileData.new()
	#},
	#"icicle": [Type.elements.ICE,Type.elements.ICE,Type.elements.ICE,],
	#"bolt": [Type.elements.LIGHTNING,Type.elements.LIGHTNING,Type.elements.LIGHTNING],
	#boulder
	#"water": [Type.elements.FIRE, Type.elements.ICE,Type.elements.ICE],
	#lave
	#mud n, 
	#light erth
	#f, i, n
	#f, l, n
	# i, l, n
	#"firebolt": [Type.elements.FIRE, Type.elements.LIGHTNING,Type.elements.LIGHTNING],
	#"supercharged water orb": [Type.elements.FIRE, Type.elements.ICE, Type.elements.LIGHTNING],
#}

var combos: Dictionary = {
	## single element
	"fireball": {
		"recepie": { Type.elements.FIRE : 3 },
		"shot_data": preload("res://resources/shot_presets/fireball_shot.tres")
	},
	"icicle":{
		"recepie": { Type.elements.ICE : 3 },
		"shot_data": preload("res://resources/shot_presets/fireball_shot.tres")
	},
	"boulder":{
		"recepie": { Type.elements.EARTH : 3 },
		"shot_data": preload("res://resources/shot_presets/fireball_shot.tres")
	},
	"lightning":{
		"recepie": { Type.elements.LIGHTNING : 3 },
		"shot_data": preload("res://resources/shot_presets/fireball_shot.tres")
	},
	
	## 2 differnt elements
	"water": {
		"recepie": { Type.elements.FIRE : 1, Type.elements.ICE : 1, },
		"shot_data": preload("res://resources/shot_presets/fireball_shot.tres")
	},
	"firebolt": {
		"recepie": { Type.elements.FIRE : 1, Type.elements.LIGHTNING : 1, },
		"shot_data": preload("res://resources/shot_presets/fireball_shot.tres")
	},
	"lava": {
		"recepie": { Type.elements.FIRE : 1, Type.elements.EARTH : 1, },
		"shot_data": preload("res://resources/shot_presets/fireball_shot.tres")
	},
	"mud": {
		"recepie": { Type.elements.ICE : 1, Type.elements.EARTH : 1, },
		"shot_data": preload("res://resources/shot_presets/fireball_shot.tres")
	},
	"lightning boulder": {
		"recepie": { Type.elements.LIGHTNING : 1, Type.elements.EARTH : 1, },
		"shot_data": preload("res://resources/shot_presets/fireball_shot.tres")
	},
	"ice lightning": {
		"recepie": { Type.elements.LIGHTNING : 1, Type.elements.ICE : 1, },
		"shot_data": preload("res://resources/shot_presets/fireball_shot.tres")
	},
	
	## 3 different types
	"supercharged water orb": {
		"recepie": { Type.elements.FIRE : 1, Type.elements.ICE : 1, Type.elements.LIGHTNING : 1 },
		"shot_data": preload("res://resources/shot_presets/fireball_shot.tres")
	},
	"fire water boulder": {
		"recepie": { Type.elements.FIRE : 1, Type.elements.ICE : 1, Type.elements.EARTH : 1 },
		"shot_data": preload("res://resources/shot_presets/fireball_shot.tres")
	},
	"lightning water boulder": {
		"recepie": { Type.elements.LIGHTNING : 1, Type.elements.ICE : 1, Type.elements.EARTH : 1 },
		"shot_data": preload("res://resources/shot_presets/fireball_shot.tres")
	},
}

func get_elemental_combo(given_elements: Array[Type.elements]) -> Shot:
	# convert array int dict so we can use has_all method both ways
	var elements_dict = {}
	for el in given_elements:
		if elements_dict.has(el):
			elements_dict[el] += 1
		else:
			elements_dict[el] = 1
	# fallback shot
	var shot = preload("res://resources/shot_presets/fireball_shot.tres")
	for combo_name in combos.keys():
		var current_recepie = combos[combo_name]["recepie"]
		if current_recepie.has_all(given_elements) and elements_dict.has_all(current_recepie.keys()):
			print(combo_name)
			shot = combos[combo_name]["shot_data"]
			EventBus.shot_fired.emit(combo_name)
			return shot
	return shot
