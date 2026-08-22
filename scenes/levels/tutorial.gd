extends Node2D

## this file was to test if maaacks level_lost system works for us
signal level_lost

@export var level_boss: Boss

#@export var boss_music 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)
	AudioManager.stop_all_music(2)


func _on_player_died() -> void:
	AudioManager.stop_all_music(2)
	AudioManager.play_music(MusicTrack.TRACK_TYPE.DEATH_SCREEN,0.5)
	#AudioManager.get_managed_player("death_music_player").play()
	level_lost.emit()
