class_name  ProjectileData
extends Resource

#@export var name: String = "Test"
#@export var desc: String = "bla bla"
@export_file var texture 
@export var shot_sfx: SoundEffect.SOUND_EFFECT_TYPE = SoundEffect.SOUND_EFFECT_TYPE.CANNON
@export var on_hit_sfx: SoundEffect.SOUND_EFFECT_TYPE = SoundEffect.SOUND_EFFECT_TYPE.CANNON
#@export var element: Type.elements = Type.elements.FIRE
@export var damage: float = 10
@export var heal:  float = 0
@export var max_distance: float = 1000
