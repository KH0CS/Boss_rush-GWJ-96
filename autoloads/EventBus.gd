extends Node

signal player_healing_charges_changed(current_charges: int)
signal player_health_changed(current_health)
signal player_died

signal storage_changed(current_storage: Array[Type.elements])
signal shot_fired(shot_name: String)

signal boss_health_changed(current_health)
signal boss_died
