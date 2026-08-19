@tool
class_name spawn_manager
extends Marker2D

enum mob_spawning {
	on_screen,# mobs spawn if the spawner comes back into camera view
	on_timer, # mob/s spawn once the timer goes off, starts on spawn
	on_death, # mobs spawn on timer, when you die
}

enum

@export var packed_scene: PackedScene: set = set_packed_scene
@export var no_mobs_spawn = false
@export var mobs_spawn = true:
	get: return mobs_spawn_
	set(value): mobs_spawn_ = value
	

@export var mob_spawning_type: mob_spawning = mob_spawning.on_screen
@export var mob_spawn_cooldown_time: float = 0.0
@export var mob_randomized_cooldown_time: float = 0.0

var mobs_spawn_ : bool = true
var mobs_respawn: bool = true
var mobs_currently_on_screen: bool = false

var mob_spawn_manager: spawn_manager = null

@onready var mob_respawn_timer: Timer = $respawn_timer
@onready var visibility_notifier = $VisibleOnScreenNotifier2D

func _ready() -> void:
	mob_spawn_manager = 
