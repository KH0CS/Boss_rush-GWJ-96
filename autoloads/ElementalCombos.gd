extends Node




#var combos: Dictionary = {
	#"fireball": {
		#"recepie": [Type.elements.FIRE,Type.elements.FIRE,Type.elements.FIRE],
		#"data": ProjectileData.new()
	#},
		#
	#"icicle": [Type.elements.ICE,Type.elements.ICE,Type.elements.ICE,],
	#"bolt": [Type.elements.LIGHTNING,Type.elements.LIGHTNING,Type.elements.LIGHTNING],
	#"water": [Type.elements.FIRE, Type.elements.ICE,Type.elements.ICE],
	#"firebolt": [Type.elements.FIRE, Type.elements.LIGHTNING,Type.elements.LIGHTNING],
	#"supercharged water orb": [Type.elements.FIRE, Type.elements.ICE, Type.elements.LIGHTNING],
#}

var combos: Dictionary = {
	"fireball": {
		"recepie": { Type.elements.FIRE : 3 },
		"shot_data": preload("res://scripts/weapon/shots/fireball_shot.tres")
	},
	"water": {
		"recepie": { Type.elements.FIRE : 1, Type.elements.ICE : 1, },
		"shot_data": preload("res://scripts/weapon/shots/fireball_shot.tres")
	},
	"supercharged water orb": {
		"recepie": { Type.elements.FIRE : 1, Type.elements.ICE : 1, Type.elements.LIGHTNING : 1 },
		"shot_data": preload("res://scripts/weapon/shots/fireball_shot.tres")
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
	#print("Elements dict:" + str(elements_dict))
	var shot = Shot.new()
	for combo_name in combos.keys():
		var current_recepie = combos[combo_name]["recepie"]
		if current_recepie.has_all(given_elements) and elements_dict.has_all(current_recepie.keys()):
			print(combo_name)
			shot = combos[combo_name]["shot_data"]
			return shot
	return shot
