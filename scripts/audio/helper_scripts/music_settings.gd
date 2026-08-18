@tool
class_name MusicTrack
extends Resource

## MusicTrack resource for configuring music playback with AudioManager. This resource works with both 2D and 3D audio_manager nodes.
##
## SETUP: 
## 1. Add your track names to the TRACK_TYPE enum below (one per music track)
## 2. Create a new MusicTrack resource in inspector (AudioManager > New Resource > MusicTrack)
## 3. Assign the audio and configure settings.
## 4. Use AudioManagers music functions to play/stop (and more) this track anywhere in your game.
##
## IMPORTANT - ENUM ORDERING:
## - Never reorder enum values after creation! Always add new tracks to the END of the enum.
## - Never delete existing enum values (this breaks resource references).
## - If you must reorganize or delete, update the inspector after manually: update the enum, then reassign track_type in each following MusicTrack resource in the inspector.
## - Reordering without updating resources will cause the wrong music to play and potential crashes.

## Add your music track names here. Each track needs its own unique enum value. Never use UNASSIGNED_MUSIC_TRACK for actual tracks - it's only for unassigned/default state.
## Example: MENU_MUSIC, BATTLE_MUSIC, VICTORY_MUSIC
enum TRACK_TYPE {
	UNASSIGNED_MUSIC_TRACK, # Add new tracks below this line, separated by commas
	WORM_BOSS_P1,
	DEATH_SCREEN

}

## -------------------------- Inspector Settings - Configure these for each MusicTrack resource in the inspector ----------##
# Inspector Settings - Configure these for each MusicTrack resource in the inspector.
@export_group("Basic Settings")
@export var preview_toggle: bool = false: ## Toggle preview playback with all settings applied.
	set(value):
		if Engine.is_editor_hint():
			_set_preview_toggle(value)
	get:
		return _preview_toggle
@export var track_type: TRACK_TYPE = TRACK_TYPE.UNASSIGNED_MUSIC_TRACK ## Which music track this resource represents (must match one enum value).
@export var stream: AudioStream ## The audio file to play (supports all stream types, AudioStreamInteractive, AudioStreamSynchronized, etc.).
@export_range(-40, 20) var volume_db: float = 0.0 ## Volume in decibels. 0 = normal, negative = quieter, positive = louder.
@export var bus_name: StringName = &"Master" ## Audio bus to route this music through (e.g., "Music", "Master").
@export_subgroup("Advanced preview (AudioStreamInteractive only)")
@export var preview_clip_index: int = 0 ## Clip index for AudioStreamInteractive preview.
@export var preview_change_to_clip: bool = false: ## Switch to clip index on the preview player.
	set(value):
		if value and Engine.is_editor_hint():
			_preview_change_to_clip()
		preview_change_to_clip = false

@export_group("Debug")
@export var debug_print: bool = false ## Enable console logs when this track plays, stops, or changes.


## -------------------------- PREVIEW PLAYER FUNCTIONS -------------------------- ##
## Creates and returns an AudioStreamPlayer configured with this music track's settings. Used for editor preview.
var _preview_player: AudioStreamPlayer ## Editor preview player (only used in editor).
var _preview_toggle: bool = false

func create_preview_player() -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	player.bus = bus_name
	return player

## Internal preview functions for @tool editor functionality
func _play_preview() -> void:
	if not stream:
		push_warning("Cannot preview: no audio stream assigned")
		return
	_stop_preview(false)
	_preview_player = create_preview_player()
	if Engine.get_singleton("EditorInterface"):
		Engine.get_singleton("EditorInterface").get_editor_main_screen().add_child(_preview_player)
		_preview_player.finished.connect(_on_preview_finished)
		_preview_player.play()
	else:
		_preview_player.queue_free()
		_preview_player = null

func _stop_preview(reset_toggle: bool = true) -> void:
	if _preview_player and is_instance_valid(_preview_player):
		_preview_player.queue_free()
		_preview_player = null
	if reset_toggle:
		_preview_toggle = false

func _on_preview_finished() -> void:
	_stop_preview(true)

func _set_preview_toggle(value: bool) -> void:
	_preview_toggle = value
	if value:
		_play_preview()
	else:
		_stop_preview(true)

func _ensure_preview_player() -> bool:
	if not stream:
		push_warning("Cannot preview: no audio stream assigned")
		return false
	if not _preview_player or not is_instance_valid(_preview_player):
		_preview_player = create_preview_player()
		if Engine.get_singleton("EditorInterface"):
			Engine.get_singleton("EditorInterface").get_editor_main_screen().add_child(_preview_player)
			_preview_player.finished.connect(_on_preview_finished)
		else:
			_preview_player.queue_free()
			_preview_player = null
			return false
	if not _preview_player.playing:
		_preview_player.play()
	return true

func _preview_change_to_clip() -> void:
	if not stream:
		push_warning("Cannot preview clip change: no audio stream assigned")
		return
	if not (stream is AudioStreamInteractive):
		push_warning("Preview clip change requires AudioStreamInteractive")
		return
	if not _ensure_preview_player():
		return
	var playback = _preview_player.get_stream_playback()
	if playback and playback.has_method("switch_to_clip"):
		playback.switch_to_clip(preview_clip_index)
	else:
		push_warning("Preview clip change failed: playback does not support switch_to_clip")

#----------- INTERNAL DEBUG LOGGING -----------#
# These functions are called automatically by the AudioManager when debug_print is enabled.
# You don't need to call these directly.


func log_playing(bus: StringName, actual_volume_db: float) -> void:
	if debug_print:
		print("[MusicTrack.%s] Playing music (bus: %s, volume: %.1f dB)" % [TRACK_TYPE.keys()[track_type], bus, actual_volume_db])

func log_retrieved_from_memory() -> void:
	if debug_print:
		print("[MusicTrack.%s] Retrieved from memory" % TRACK_TYPE.keys()[track_type])

func log_clip_switch(clip_index: int) -> void:
	if debug_print:
		print("[MusicTrack.%s] Switching to clip %d" % [TRACK_TYPE.keys()[track_type], clip_index])

func log_layer_volume_change(layer: int, end_db: float, fade_duration: float) -> void:
	if debug_print:
		if fade_duration > 0.0:
			print("[MusicTrack.%s] Fading layer %d to %.1f dB over %.2fs" % [TRACK_TYPE.keys()[track_type], layer, end_db, fade_duration])
		else:
			print("[MusicTrack.%s] Setting layer %d to %.1f dB (instant)" % [TRACK_TYPE.keys()[track_type], layer, end_db])

func log_stopping(fade_time: float) -> void:
	if debug_print:
		if fade_time > 0.0:
			print("[MusicTrack.%s] Stopping with fade (%.2fs)" % [TRACK_TYPE.keys()[track_type], fade_time])
		else:
			print("[MusicTrack.%s] Stopping (instant)" % TRACK_TYPE.keys()[track_type])

func log_stopping_all(fade_time: float) -> void:
	if debug_print:
		if fade_time > 0.0:
			print("[MusicTrack.%s] Stopping ALL with fade (%.2fs)" % [TRACK_TYPE.keys()[track_type], fade_time])
		else:
			print("[MusicTrack.%s] Stopping ALL (instant)" % TRACK_TYPE.keys()[track_type])

## -------------------------- UTILITY FUNCTIONS -------------------------- ##

func _to_string() -> String:
	return "%s (%s)" % [TRACK_TYPE.keys()[track_type], stream.resource_name if stream else "No Stream"]
