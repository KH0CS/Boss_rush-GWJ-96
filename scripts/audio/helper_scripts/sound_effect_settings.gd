@tool
class_name SoundEffect
extends Resource

## SoundEffect resource for configuring sound effects with AudioManager. This resource works with both 2D and 3D audio_manager nodes.
##
## SETUP:
## 1. Add your sound effect names to the SOUND_EFFECT_TYPE enum below (one per sound)
## 2. Create a new SoundEffect resource in inspector (AudioManager > New Resource > SoundEffect)
## 3. Assign an audio file and configure settings.
## 4. Use AudioManagers sound functions to play/stop (and more) this sound anywhere in your game.
##
## IMPORTANT - ENUM ORDERING:
## - Never reorder enum values after creation! Always add new sounds to the END of the enum.
## - Never delete existing enum values (this breaks resource references).
## - If you must reorganize, do it manually: update the enum, then reassign type in each existing SoundEffect resource.
## - Reordering without updating resources will cause the wrong sounds to play and potential crashes.

## Add your sound effect names here. Each sound needs its own unique enum value. Never use UNASSIGNED_SOUND for actual sounds - it's only for unassigned/default state.
## Example: FOOTSTEP, PLAYER_JUMP, EXPLOSION
enum SOUND_EFFECT_TYPE {
	UNASSIGNED_SOUND, # Add new sounds below this line, separated by commas
	BEEPS,
	CANNON,
	CANNON2,
	SUCTION_SHORT,
	SUCTION_MEDIUM,
	SUCTION_LONG,
	DODGE,
	FOOTSTEP,
	PLAYER_TAKING_DAMAGE
}

##-------------------------- Inspector Settings - Configure these for each SoundEffect resource in the inspector ----------##
@export_group("Basic Settings")
@export var preview_toggle: bool = false: ## Toggle preview playback with all settings applied (including pitch randomization).
	set(value):
		if Engine.is_editor_hint():
			_set_preview_toggle(value)
	get:
		return _preview_toggle

@export_range(0, 10) var limit: int = 0 ## Max instances playing at once. 0 = unlimited. Prevents audio spam (e.g., limit footsteps to 3).
@export var type: SOUND_EFFECT_TYPE ## Which sound effect this resource represents (must match one enum value).
@export var sound_effect: AudioStream ## The audio file to play.
@export_range(-40, 6, 0.1) var volume: float = 0 ## Volume in decibels. 0 = default, negative = quieter, positive = louder.
@export_range(0.0, 5.0, 0.1) var volume_randomness: float = 0.0 ## Adds volume variation in dB (0-5). Higher = more variety on each play.
@export_range(0.1, 4.0, .01) var pitch_scale: float = 1.0 ## Base pitch. 1.0 = normal, 0.5 = half speed, 2.0 = double speed.
@export_range(0.0, 0.5, .01) var pitch_randomness: float = 0.0 ## Adds pitch variation (0-50%). Higher = more variety on each play.
@export var bus_name: StringName = &"Master" ## Audio bus to route this sound through (e.g., "SFX", "Master").

@export_group("2D Settings")
@export_range(1, 4096, 1) var max_distance: float = 2000 ## Max distance in pixels where sound is audible (2D only).
@export_range(0.0, 200.0, .01) var attenuation: float = 1.0 ## How fast volume drops with distance. 1.0 = linear, 2.0 = faster, 0.5 = slower (2D only).
@export_range(0.0, 3.0, .01) var panning_strength: float = 1.0 ## How much left/right panning based on position. 0 = centered, 1 = normal stereo (2D only).

@export_group("3D Settings")
@export_enum("Inverse", "Inverse Square", "Logarithmic", "Disabled") var attenuation_model_3d: int = 0 ## How volume attenuates over distance in 3D space (3D only).
@export_range(0.1, 100.0, 0.1) var unit_size_3d: float = 10 ## Reference distance for attenuation calculations in 3D (3D only).
@export_range(-80, 6.0, 0.1) var max_db_3d: float = 6.0 ## Maximum volume ceiling for 3D playback. Prevents sounds from being too loud (3D only).
@export_range(0, 10000.0, 0.1) var max_distance_3d: float = 0.0 ## Maximum distance in meters where 3D sound is audible (3D only).

@export_group("Debug")
@export var debug_print: bool = false ## Enable console logs when this sound plays or hits its limit.

##----------------------------------------------------- INTERNAL AUDIO LIMIT MANAGEMENT -----------------------------------------------##
# These functions are called automatically by the AudioManager. You don't need to call these directly.
var audio_count: int = 0 ## The instances of this [AudioStream] currently playing.

## Takes [param amount] to change the [member audio_count]. 
func change_audio_count(amount: int) -> void:
	audio_count = max(0, audio_count + amount)


## Checks whether the audio limit is reached. Returns true if the [member audio_count] is less than the [member limit].
func has_open_limit() -> bool:
	return limit == 0 or audio_count < limit


## Decrements the [member audio_count] when a sound finishes playing. Connected automatically by the AudioManager to each sound's finished signal.
func on_audio_finished() -> void:
	log_finished()
	change_audio_count(-1)

## ----------------------------------------------------------- HELPER METHODS ------------------------------------------------------- ##

## Returns a randomized pitch scale value that is guaranteed to be valid (> 0.0). Uses [member pitch_scale] and [member pitch_randomness] to calculate the final value.
func get_randomized_pitch_scale() -> float:
	var rng = RandomNumberGenerator.new()
	return max(0.01, pitch_scale + rng.randf_range(-pitch_randomness, pitch_randomness))

## Returns a randomized volume in dB based on [member volume] and [member volume_randomness].
func get_randomized_volume_db() -> float:
	if volume_randomness == 0.0:
		return volume
	var rng = RandomNumberGenerator.new()
	return volume + rng.randf_range(-volume_randomness, volume_randomness)

#----------- INTERNAL DEBUG LOGGING -----------#
# These functions are called automatically by the AudioManager when debug_print is enabled.
# You don't need to call these directly.

# Logs details about a 2D sound being played, including position, bus, actual volume and pitch after calculations, and current audio count vs limit.
func log_playing_2d(position: Vector2, bus: StringName, actual_volume: float, actual_pitch: float) -> void:
	if debug_print:
		print("[%s] Playing 2D at position (%.1f, %.1f) | bus: %s | volume: %.1f dB | pitch: %.2f | count: %d/%d" % [
			SOUND_EFFECT_TYPE.keys()[type],
			position.x, position.y,
			bus,
			actual_volume,
			actual_pitch,
			audio_count,
			limit if limit > 0 else 999
		])

# Logs details about a 3D sound being played, including position, bus, actual volume and pitch after calculations, and current audio count vs limit.
func log_playing_3d(position: Vector3, bus: StringName, actual_volume: float, actual_pitch: float) -> void:
	if debug_print:
		print("[%s] Playing 3D at position (%.1f, %.1f, %.1f) | bus: %s | volume: %.1f dB | pitch: %.2f | count: %d/%d" % [
			SOUND_EFFECT_TYPE.keys()[type],
			position.x, position.y, position.z,
			bus,
			actual_volume,
			actual_pitch,
			audio_count,
			limit if limit > 0 else 999
		])

# Logs details about a non-positional sound being played, including bus, actual volume and pitch after calculations, and current audio count vs limit.
func log_playing_non_positional(bus: StringName, actual_volume: float, actual_pitch: float) -> void:
	if debug_print:
		print("[%s] Playing (non-positional) | bus: %s | volume: %.1f dB | pitch: %.2f | count: %d/%d" % [
			SOUND_EFFECT_TYPE.keys()[type],
			bus,
			actual_volume,
			actual_pitch,
			audio_count,
			limit if limit > 0 else 999
		])

# Logs when a sound effect hits its limit and cannot play, including current audio count vs limit.
func log_limit_reached() -> void:
	if debug_print:
		print("[%s] LIMIT REACHED! Count: %d/%d" % [SOUND_EFFECT_TYPE.keys()[type], audio_count, limit])

# Logs when a sound finishes playing and is queued for free, including current audio count vs limit.
func log_finished() -> void:
	if debug_print:
		print("[%s] Finished & queued free | count: %d/%d" % [SOUND_EFFECT_TYPE.keys()[type], audio_count - 1, limit if limit > 0 else 999])

# Logs when a layer volume change is triggered for a synchronized sound effect loop.
func log_layer_volume_change(layer: int, end_db: float, fade_duration: float) -> void:
	if debug_print:
		if fade_duration > 0.0:
			print("[%s] Changing layer %d volume to %.1f dB over %.1f seconds" % [SOUND_EFFECT_TYPE.keys()[type], layer, end_db, fade_duration])
		else:
			print("[%s] Changing layer %d volume to %.1f dB (instant)" % [SOUND_EFFECT_TYPE.keys()[type], layer, end_db])

## ---------------------------------------------------- EDITOR PREVIEW PLAYER ------------------------------------------------------- ##
var _preview_player: AudioStreamPlayer ## Editor preview player (only used in editor).
var _preview_toggle: bool = false ## Internal toggle state for preview playback. Separate from the exported [member preview_toggle] to allow resetting without triggering the setter logic.

## Creates and returns an AudioStreamPlayer configured with this sound effect's settings (including randomized pitch). Used for editor preview.
func create_preview_player() -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = sound_effect
	player.volume_db = get_randomized_volume_db()
	player.pitch_scale = get_randomized_pitch_scale()
	player.bus = bus_name
	return player

## Internal preview functions for @tool editor functionality
func _play_preview() -> void:
	if not sound_effect:
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
		_preview_toggle = false

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

func _to_string() -> String:
	return "%s (%s)" % [SOUND_EFFECT_TYPE.keys()[type], sound_effect.resource_name if sound_effect else "No Stream"]
