extends Node3D

## Audio manager for playing sound effects and music in 3D scenes.
## 
## SETUP: Make sure that Sound_Effect_Settings and Music_Settings resources exist in project, then set up your 'Sound Effects' and 'Music Tracks' in the Inspector. 
## Once set up, you can call the public methods from the manager (play_audio, play_music, etc.) from anywhere in your game code.
##
## LIST OF PUBLIC FUNCTIONS (more info above each function declaration):
## SOUND EFFECTS - ONE-SHOT:
##		play_audio_at_location(location, sound_effect_type) - Play a sound at a specific location (3D positional audio).
##		play_audio(sound_effect_type) - Play a sound without position (non-positional audio).
## SOUND EFFECTS - LOOPING:
##		play_loop_at_position(parent_node, sound_effect_type, has_start_clip) - Start a simple loop at a node position.
## 		play_loop(sound_effect_type, has_start_clip) - Start a simple non-positional loop. Can optionally auto-advance to clip 1 if using AudioStreamInteractive with start clips.
##		stop_loop(sound_effect_type) - Stop a specified loop (works for both positional and non-positional).
##		change_loop_to_clip(loop_type, clip_index, is_final_clip) - Switch an active loop to a different clip (for AudioStreamInteractive loops).
##		change_loop_layer_volume(loop_type, layer, end_db, fade_duration) - Change volume of a layer in synchronized sound effect loop with optional fade.
##
## MUSIC - BASIC:
##		play_music(music_track_type, fade_in_duration) - Start playing a music track with optional fade in.
##		stop_music(music_track_type, fade_time) - Stop a specified music track with optional fade out.
##		stop_all_music(fade_time) - Stop all active music tracks with optional fade out.
##		change_to_track(old_track, fade_out_duration, new_track, fade_in_duration) - Crossfade between music tracks.
##		get_active_music(music_track_type) - Get a reference to an active music track by type.
## MUSIC - ADVANCED:
##		change_music_to_clip(music_track_type, clip_index) - Switch to a different clip in interactive music node. (Follows transition rules set in the AudioStreamInteractive resource)
##		change_music_layer_volume(music_track_type, layer, end_db, fade_duration) - Change volume of a layer in synchronized music node with optional fade.
##
## MANAGE EXTERNAL PLAYERS:
##		get_managed_player(player_name) - Get a reference to a managed AudioStreamPlayer by name.
##		stop_all_managed_players() - Stop all managed AudioStreamPlayers.
##
## HELPER METHODS
##		stop_all_audio(music_fade_time) - Stop all active sounds and music. Music can make use of fade out, with looping sounds stopping instantly.

func _ready() -> void:
	#Create the sound_effect and music track dictionaries for quick lookup, and validate that all enum values have assigned resources.
	for sound_effect: SoundEffect in sound_effects:
		sound_effect_dict[sound_effect.type] = sound_effect
	for music_track: MusicTrack in music_tracks:
		music_tracks_dict[music_track.track_type] = music_track
	_validate_all_audiotypes_content()

#----------------------------------------------------------------- SOUND EFFECT METHODS -------------------------------------------------------------#

@export var warn_on_missing_sound_assignments: bool = false ## Enable this to show warnings for enum values without assigned resources.

var sound_effect_dict: Dictionary = {} ## Internal reference dictionary built from the sound_effects array at startup.
@export var sound_effects: Array[SoundEffect] ## Add your SoundEffect resources here in the Inspector. These are loaded into memory on startup.

#--------------- ONE-SHOT SOUND EFFECT METHODS ---------------#

## Creates a sound effect at a specific location if the limit has not been reached. Pass [param location] for the global position of the audio effect, and [param type] for the SoundEffect to be queued.
func play_audio_at_location(location: Vector3, type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		if sound_effect.has_open_limit():
			sound_effect.change_audio_count(1)
			var new_3d_audio: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
			add_child(new_3d_audio)
			new_3d_audio.position = location
			new_3d_audio.stream = sound_effect.sound_effect
			new_3d_audio.volume_db = sound_effect.get_randomized_volume_db()
			new_3d_audio.bus = _get_valid_bus_name(sound_effect.bus_name)
			new_3d_audio.pitch_scale = sound_effect.get_randomized_pitch_scale()
			new_3d_audio.max_distance = sound_effect.max_distance_3d
			new_3d_audio.attenuation_model = sound_effect.attenuation_model_3d as AudioStreamPlayer3D.AttenuationModel
			new_3d_audio.unit_size = sound_effect.unit_size_3d
			new_3d_audio.max_db = sound_effect.max_db_3d
			sound_effect.log_playing_3d(location, new_3d_audio.bus, new_3d_audio.volume_db, new_3d_audio.pitch_scale)
			new_3d_audio.finished.connect(sound_effect.on_audio_finished)
			new_3d_audio.finished.connect(new_3d_audio.queue_free)
			new_3d_audio.play()
		else:
			sound_effect.log_limit_reached() # Debug log if debug_print is enabled for this sound effect
	else:
		push_warning("AudioManager3D: Sound type not found: " + str(type))

## Creates a sound effect if the limit has not been reached. Pass [param type] for the SoundEffect to be queued.
func play_audio(type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		if sound_effect.has_open_limit():
			sound_effect.change_audio_count(1)
			var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
			add_child(new_audio)
			new_audio.stream = sound_effect.sound_effect
			new_audio.volume_db = sound_effect.get_randomized_volume_db()
			new_audio.bus = _get_valid_bus_name(sound_effect.bus_name)
			new_audio.pitch_scale = sound_effect.get_randomized_pitch_scale()
			sound_effect.log_playing_non_positional(new_audio.bus, new_audio.volume_db, new_audio.pitch_scale)
			new_audio.finished.connect(sound_effect.on_audio_finished)
			new_audio.finished.connect(new_audio.queue_free)
			new_audio.play()
		else:
			sound_effect.log_limit_reached() # Debug log if debug_print is enabled for this sound effect
	else:
		push_warning("AudioManager3D: Sound type not found: " + str(type))


#--------------- LOOPING SOUND METHODS ---------------#
# All looping functions make use of helper methods (starting with _start_) that handle the actual audio creation and playback to keep code a bit shorter.

var active_looping_sounds: Dictionary = {} ## Tracks active looping sounds by their loop type. Stores {loop_type: {player: AudioStreamPlayer/AudioStreamPlayer3D, parent_node: Node3D/null}}

## Starts a simple looping sound at a node position. Pass [param parent_node] for the node to attach audio to (often self is perfect), [param loop_type] for the looping sound. Optionally pass [param has_start_clip] to automatically transition to clip 1 after 0.1 seconds (useful for start clips that transition to main loop). Use method [stop_loop] to stop it.
func play_loop_at_position(parent_node: Node3D, loop_type: SoundEffect.SOUND_EFFECT_TYPE, has_start_clip: bool = false) -> void:
	# Validate parent node
	if parent_node == null or not is_instance_valid(parent_node):
		push_warning("AudioManager3D: Invalid parent_node for loop")
		return
	
	# If a loop is already active for this type, warn and don't start a new one
	if active_looping_sounds.has(loop_type):
		push_warning("AudioManager3D: Loop " + str(SoundEffect.SOUND_EFFECT_TYPE.keys()[loop_type]) + " already playing")
		return
	
	# Start the loop directly
	_start_loop_3d(loop_type, parent_node, 0)
	
	# If this is a start clip, transition to clip 1 after a short delay
	if has_start_clip:
		get_tree().create_timer(0.1).timeout.connect(func():
			if active_looping_sounds.has(loop_type):
				change_loop_to_clip(loop_type, 1, false)
		)


## Starts a simple non-positional looping sound (no start or end clips). Pass [param loop_type] for the looping sound. Optionally pass [param has_start_clip] to automatically transition to clip 1 after 0.1 seconds. Use [method stop_loop] to stop it.
func play_loop(loop_type: SoundEffect.SOUND_EFFECT_TYPE, has_start_clip: bool = false) -> void:
	# If a loop is already active for this type, warn and don't start a new one
	if active_looping_sounds.has(loop_type):
		push_warning("AudioManager3D: Loop " + str(SoundEffect.SOUND_EFFECT_TYPE.keys()[loop_type]) + " already playing")
		return
	
	# Start the loop directly
	_start_loop(loop_type, 0)
	
	# If this is a start clip, transition to clip 1 after a short delay
	if has_start_clip:
		get_tree().create_timer(0.1).timeout.connect(func():
			if active_looping_sounds.has(loop_type):
				change_loop_to_clip(loop_type, 1, false)
		)


## Stops any looping sound (works for both positional and non-positional, no end clip). Pass [param loop_type] to identify which loop to stop. Stops the loop immediately without playing an end sound.
func stop_loop(loop_type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if not active_looping_sounds.has(loop_type):
		return
	
	var loop_data = active_looping_sounds[loop_type]
	var loop_player = loop_data.player
	
	# Decrement audio count for the sound effect
	if sound_effect_dict.has(loop_type):
		var sound_effect: SoundEffect = sound_effect_dict[loop_type]
		sound_effect.on_audio_finished()
	
	# Stop and clean up the loop (works for both AudioStreamPlayer and AudioStreamPlayer3D)
	if is_instance_valid(loop_player):
		loop_player.stop()
		loop_player.queue_free()
	
	active_looping_sounds.erase(loop_type)

## Changes a specific sound effect loop to a different clip index, if supported by the stream type (AudioStreamInteractive). Pass [param loop_type] for the loop to change, [param clip_index] for the target clip, and optionally [param is_final_clip] to mark this as the last clip. If is_final_clip is true, the loop will automatically stop after the clip finishes (auto-calculates duration). Follows transition rules set in the AudioStreamInteractive resource.
func change_loop_to_clip(loop_type: SoundEffect.SOUND_EFFECT_TYPE, clip_index: int, is_final_clip: bool = false) -> void:
	if active_looping_sounds.has(loop_type):
		var loop_data = active_looping_sounds[loop_type]
		var loop_player = loop_data.player
		
		if loop_player != null and is_instance_valid(loop_player):
			var playback = loop_player.get_stream_playback()
			if playback != null:
				playback.switch_to_clip(clip_index)
				
				if is_final_clip:
					var stream = loop_player.stream as AudioStreamInteractive
					if stream != null:
						var clip_stream = stream.get_clip_stream(clip_index)
						if clip_stream != null:
							var clip_length = clip_stream.get_length()
							if clip_length > 0.05:
								var cleanup_timer = get_tree().create_timer(clip_length)
								loop_data["final_clip_timer"] = cleanup_timer
								
								var captured_loop_type = loop_type
								var captured_loop_player = loop_player
								
								cleanup_timer.timeout.connect(func():
									if active_looping_sounds.has(captured_loop_type) and is_instance_valid(captured_loop_player):
										var sound_effect = sound_effect_dict.get(captured_loop_type)
										if sound_effect:
											sound_effect.on_audio_finished()
										active_looping_sounds.erase(captured_loop_type)
										captured_loop_player.stop()
										captured_loop_player.queue_free()
								)
							else:
								push_warning("AudioManager3D: Final clip for " + str(SoundEffect.SOUND_EFFECT_TYPE.keys()[loop_type]) + " is too short (< 50ms), skipping auto-stop")
				else:
					loop_data.erase("final_clip_timer")
			else:
				push_warning("AudioManager3D: Could not get playback for loop " + str(SoundEffect.SOUND_EFFECT_TYPE.keys()[loop_type]))
		else:
			push_warning("AudioManager3D: Loop player is invalid for " + str(SoundEffect.SOUND_EFFECT_TYPE.keys()[loop_type]))
	else:
		push_warning("AudioManager3D: Loop " + str(SoundEffect.SOUND_EFFECT_TYPE.keys()[loop_type]) + " is not currently playing")

## Changes the volume of a specific layer in a synchronized sound effect loop (AudioStreamSynchronized). Pass [param type] for the loop type, [param layer] for the layer index (0-based), [param end_db] for the target volume in dB, and [param fade_duration] for fade time in seconds (0 = instant change).
func change_loop_layer_volume(type: SoundEffect.SOUND_EFFECT_TYPE, layer: int, end_db: float, fade_duration: float = 0.0) -> void:
	if active_looping_sounds.has(type):
		var loop_data = active_looping_sounds[type]
		var loop_player = loop_data.player
		var stream = loop_player.stream as AudioStreamSynchronized
		if sound_effect_dict.has(type):
			sound_effect_dict[type].log_layer_volume_change(layer, end_db, fade_duration) # Debug log if debug_print is enabled for this sound effect
		
		# If fade_duration is greater than 0, create a tween to animate the volume change.
		if fade_duration > 0.0:
			# Get current volume for this layer
			var current_volume = stream.get_sync_stream_volume(layer)
			# Create tween to animate from current to end_db
			var volume_tween := create_tween().set_ease(Tween.EASE_IN_OUT)
			# Tween the volume change and apply it to the stream each frame of the tween
			volume_tween.tween_method(
				func(volume: float) -> void:
					stream.set_sync_stream_volume(layer, volume),
				current_volume,
				end_db,
				fade_duration
			)
		else:
			# Instant volume change
			stream.set_sync_stream_volume(layer, end_db)

#--------------- MUSIC TRACK METHODS ---------------#
var music_tracks_dict: Dictionary = {} ## Internal reference dictionary built from the music_tracks array at startup.
@export var music_tracks: Array[MusicTrack] ## Add your MusicTrack resources here in the Inspector. These are loaded into memory on startup.

var active_music_dict: Dictionary = {} ## Dictionary of active music instances keyed by TRACK_TYPE. Allows multiple simultaneous tracks (one per type).

## Plays a music track. Pass [param type] for the MusicTrack enum value to play. Only one instance per TRACK_TYPE can play simultaneously. Pass [param fade_in_duration] for the fade-in time in seconds (0 = no fade, instant play). Returns the AudioStreamPlayer instance.
func play_music(type: MusicTrack.TRACK_TYPE, fade_in_duration: float = 0.0) -> AudioStreamPlayer:
	# Check if this track type is already playing
	if active_music_dict.has(type):
		return active_music_dict[type] # Already playing, return existing
	
	# Validate that the track type exists in the music_tracks_dictand and give it settings for that track type, then play it with optional fade-in.
	if music_tracks_dict.has(type):
		var music_track: MusicTrack = music_tracks_dict[type]
		var new_music: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(new_music)
		new_music.stream = music_track.stream
		new_music.bus = _get_valid_bus_name(music_track.bus_name)
		music_track.log_playing(new_music.bus, music_track.volume_db)
		
		# Set initial volume based on fade_in_duration
		if fade_in_duration > 0.0:
			# Start at silent and fade in
			new_music.volume_db = -80.0
			new_music.play()
			# Create fade-in tween
			var fade_tween := create_tween().set_ease(Tween.EASE_IN_OUT)
			fade_tween.tween_property(new_music, "volume_db", music_track.volume_db, fade_in_duration)
		else:
			# No fade, instant play at full volume
			new_music.volume_db = music_track.volume_db
			new_music.play()

		# Store the active music instance in the dictionary
		active_music_dict[type] = new_music
		return new_music
	else:
		push_warning("AudioManager3D: Music type not found: " + str(type))
		return null


## Stops a specific music track. Pass [param type] to stop that track and [param fade_time] for fade out duration in seconds (0 = instant stop).
func stop_music(type: MusicTrack.TRACK_TYPE, fade_time: float = 0.0) -> void:
	if active_music_dict.has(type):
		var music = active_music_dict[type]
		if music_tracks_dict.has(type):
			music_tracks_dict[type].log_stopping(fade_time) # Debug log if debug_print is enabled for this music track
		if fade_time > 0.0:
			#Create the fade tween and execute the fade
			var fade_tween := create_tween().set_ease(Tween.EASE_IN_OUT)
			fade_tween.tween_property(music, "volume_db", -80.0, fade_time)
			
			#Once the fade is complete, stop and free the music instance
			fade_tween.finished.connect(func():
				if active_music_dict.has(type):
					music.stop()
					music.queue_free()
					active_music_dict.erase(type)
		)
		else:
			#Instant stop
			music.stop()
			music.queue_free()
			active_music_dict.erase(type)

## Stops all active music tracks. Pass [param fade_time] for fade out duration in seconds (0 = instant stop).
func stop_all_music(fade_time: float = 0.0) -> void:
	# First log the stopping of all tracks for debug purposes
	for track_type in active_music_dict.keys():
		if music_tracks_dict.has(track_type):
			music_tracks_dict[track_type].log_stopping_all(fade_time) # Debug log if debug_print is enabled for each active music track
	
	# Then execute the fade out and stop for each track
	for track_type in active_music_dict.keys():
		var music = active_music_dict[track_type]
		if fade_time > 0.0:
			var fade_tween := create_tween().set_ease(Tween.EASE_IN_OUT)
			fade_tween.tween_property(music, "volume_db", -80.0, fade_time)
			fade_tween.finished.connect(func():
				if is_instance_valid(music):
					music.stop()
					music.queue_free()
			)
		# If no fade, stop immediately
		else:
			music.stop()
			music.queue_free()

	# Clear the active music dictionary after stopping all tracks
	active_music_dict.clear()

## Crossfades from one music track to another by fading out the old track while fading in the new track. Pass [param old_track] for the track to fade out and [param fade_out_duration] for the fade-out time in seconds, [param new_track] for the track to fade in and [param fade_in_duration] for the fade-in time in seconds. Returns the new AudioStreamPlayer instance.
func change_to_track(old_track: MusicTrack.TRACK_TYPE, fade_out_duration: float, new_track: MusicTrack.TRACK_TYPE, fade_in_duration: float) -> AudioStreamPlayer:
	# Stop the old track if it's playing
	if active_music_dict.has(old_track):
		stop_music(old_track, fade_out_duration)
	# Play the new track with fade-in
	return play_music(new_track, fade_in_duration)

## Gets a reference to a specific active music track by type, if one exists. Can be used to directly access the AudioStreamPlayer to change properties. Pass [param type] to get the specific track. Returns null if the track is not currently playing.
func get_active_music(type: MusicTrack.TRACK_TYPE) -> AudioStreamPlayer:
	if active_music_dict.has(type):
		if music_tracks_dict.has(type):
			music_tracks_dict[type].log_retrieved_from_memory()
		return active_music_dict[type]
	return null

## ---------- ADVANCED MUSIC METHODS ---------- #

## Changes a specific music track to a different clip index, if supported by the stream type (AudioStreamInteractive). Pass [param type] for the track to change and [param clip_index] for the target clip. Follows transition rules set in the AudioStreamInteractive resource.
func change_music_to_clip(type: MusicTrack.TRACK_TYPE, clip_index: int) -> void:
	if active_music_dict.has(type):
		if music_tracks_dict.has(type):
			music_tracks_dict[type].log_clip_switch(clip_index)
		active_music_dict[type].get_stream_playback().switch_to_clip(clip_index)

## Changes the volume of a specific layer in a synchronized music track (AudioStreamSynchronized). Pass [param type] for the track, [param layer] for the layer index (0-based), [param end_db] for the target volume in dB, and [param fade_duration] for fade time in seconds (0 = instant change).
func change_music_layer_volume(type: MusicTrack.TRACK_TYPE, layer: int, end_db: float, fade_duration: float = 0.0) -> void:
	if active_music_dict.has(type):
		var music = active_music_dict[type]
		var stream = music.stream as AudioStreamSynchronized
		if music_tracks_dict.has(type):
			music_tracks_dict[type].log_layer_volume_change(layer, end_db, fade_duration) # Debug log if debug_print is enabled for this music track
		
		# If fade_duration is greater than 0, create a tween to animate the volume change.
		if fade_duration > 0.0:
			# Get current volume for this layer
			var current_volume = stream.get_sync_stream_volume(layer)
			# Create tween to animate from current to end_db
			var volume_tween := create_tween().set_ease(Tween.EASE_IN_OUT)
			# Tween the volume change and apply it to the stream each frame of the tween
			volume_tween.tween_method(
				func(volume: float) -> void:
					stream.set_sync_stream_volume(layer, volume),
				current_volume,
				end_db,
				fade_duration
			)
		else:
			# Instant volume change
			stream.set_sync_stream_volume(layer, end_db)

#--------------- MANAGED PLAYERS ---------------#
# This section allows actual nodes of AudioStreamPlayer or AudioStreamPlayer3D existing elsewhere in the scene (for instance on an enemy scene) to be registered with the AudioManager for centralized management. 
# This is useful for audio players that are part of specific scenes or objects but still need to be controlled (e.g., stopped) by the AudioManager, such as character-specific looping sounds or environmental audio sources.
# Its a way to make use of the features limited by this system, but present in an actual AudioStreaPlayer node (like visual representations of spatialization or more settings) while still having the AudioManager be aware of them to stop them when needed (like on a scene change or other event).
# To use this, add the AudioManagerHelper script to any AudioStreamPlayer or AudioStreamPlayer3D node in your scenes and set a unique player name in inspector. The helper script will automatically register the player with the AudioManager3D. 
# Then you can call [method get_managed_player] with that name to get a reference to the player, or call [method stop_all_managed_players] to stop all registered players at once.

var managed_players: Dictionary[String, Node] = {} ## Dictionary of AudioStreamPlayer/AudioStreamPlayer3D nodes registered via AudioManagerHelper script.

## Get a managed audio player by name. Pass [param player_name] for the key in the managed_players dictionary. Returns null if player is not found or is no longer valid (scene unloaded).
func get_managed_player(player_name: String) -> Node:
	var player = managed_players.get(player_name)
	if player and not is_instance_valid(player):
		push_warning("AudioManager 3D: Managed player '" + str(player_name) + "' is no longer valid (scene was unloaded)")
		return null
	return player

## Stops all managed AudioStreamPlayers. Safe to call even if some players have been freed (e.g., when changing scenes).
func stop_all_managed_players() -> void:
	for player in managed_players.values():
		if is_instance_valid(player):
			player.stop()

#------------------------------------------------ HELPER METHODS ------------------------------------------------#
# These methods are internal helpers that support the main functions above. 
# They are marked private (_) and not intended for direct use.
# Stop_all_audio is a public helper that can be used to stop all active audio in one call, which is especially useful for scene transitions or level ends. It stops all looping sounds immediately and can fade out music tracks if desired, while also stopping any registered managed players.

## Stops all active audio - one-shot sounds cannot be stopped as they auto-cleanup, but this stops all looping sounds, music tracks, and managed players. Useful for scene transitions or level ends. Pass [param music_fade_time] for music fade duration in seconds (0 = instant stop, looping sounds always stop instantly).
func stop_all_audio(music_fade_time: float = 0.0) -> void:
	# Stop all active looping sounds immediately
	for loop_type in active_looping_sounds.keys():
		var loop_player = active_looping_sounds[loop_type].player
		if is_instance_valid(loop_player):
			loop_player.stop()
			loop_player.queue_free()
	active_looping_sounds.clear()
	
	# Stop all music tracks (with optional fade)
	stop_all_music(music_fade_time)
	
	# Stop all managed players
	stop_all_managed_players()

## Gets the string name of a TRACK_TYPE enum value for error messages and warnings.
func _get_track_type_name(value: MusicTrack.TRACK_TYPE) -> String:
	return MusicTrack.TRACK_TYPE.keys()[value]

## Validates that all sound effects and music tracks have content assigned and warns about unassigned resources or unused enum values. Called automatically during _ready().
func _validate_all_audiotypes_content() -> void:
	# Validate sound effects
	var unassigned_soundeffect_types = []
	for i in range(sound_effects.size()):
		var sound_effect: SoundEffect = sound_effects[i]
		var effect_type = sound_effect.type
		if effect_type == SoundEffect.SOUND_EFFECT_TYPE.UNASSIGNED_SOUND:
			unassigned_soundeffect_types.append(i)
	
	if not unassigned_soundeffect_types.is_empty():
		push_warning("AudioManager3D: SoundEffect(s) at index " + str(unassigned_soundeffect_types) + " still set to UNASSIGNED_SOUND")
	
	# Gather unused sound effect enum values
	if warn_on_missing_sound_assignments:
		var missing_sound_effect_values = []
		var used_sound_types = sound_effect_dict.keys()
		for effect_type in SoundEffect.SOUND_EFFECT_TYPE.values():
			if effect_type != SoundEffect.SOUND_EFFECT_TYPE.UNASSIGNED_SOUND and effect_type not in used_sound_types:
				missing_sound_effect_values.append(SoundEffect.SOUND_EFFECT_TYPE.keys()[effect_type])
		
		if not missing_sound_effect_values.is_empty():
			push_warning("AudioManager3D: Unused sound types: " + ", ".join(missing_sound_effect_values))
	
	# Validate music tracks
	var unassigned_tracks = []
	for i in range(music_tracks.size()):
		var music_track: MusicTrack = music_tracks[i]
		var track_type = music_track.track_type
		if track_type == MusicTrack.TRACK_TYPE.UNASSIGNED_MUSIC_TRACK:
			unassigned_tracks.append(i)
	
	if not unassigned_tracks.is_empty():
		push_warning("AudioManager3D: MusicTrack(s) at index " + str(unassigned_tracks) + " still set to UNASSIGNED_MUSIC_TRACK")
	
	# Gather unused music track enum values
	if warn_on_missing_sound_assignments:
		var missing_music_track_values = []
		var used_track_types = music_tracks_dict.keys()
		for track_type in MusicTrack.TRACK_TYPE.values():
			if track_type != MusicTrack.TRACK_TYPE.UNASSIGNED_MUSIC_TRACK and track_type not in used_track_types:
				missing_music_track_values.append(MusicTrack.TRACK_TYPE.keys()[track_type])
		
		if not missing_music_track_values.is_empty():
			push_warning("AudioManager3D: Unused music types: " + ", ".join(missing_music_track_values))

## Validates a bus name exists in AudioServer. If the bus doesn't exist or is empty, falls back to "Master" with a warning.
func _get_valid_bus_name(requested: StringName) -> StringName:
	var requested_text = String(requested).strip_edges()
	if requested_text.is_empty():
		push_warning("AudioManager3D: Empty bus name, using Master")
		return &"Master"
	if AudioServer.get_bus_index(requested_text) == -1:
		push_warning("AudioManager3D: Bus '" + str(requested_text) + "' not found, using Master")
		return &"Master"
	return StringName(requested_text)


## Internal helper to start a positional 3D looping sound. Creates an AudioStreamPlayer3D as a child of [param parent_node] so it follows the parent's position automatically. Called by play_loop_at_position().
func _start_loop_3d(loop_type: SoundEffect.SOUND_EFFECT_TYPE, parent_node: Node3D, starting_clip_index: int = 0) -> void:
	if sound_effect_dict.has(loop_type):
		var loop_sound: SoundEffect = sound_effect_dict[loop_type]
		if loop_sound.has_open_limit():
			loop_sound.change_audio_count(1)
			var loop_audio: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
			
			# Parent to the node so it follows automatically
			parent_node.add_child(loop_audio)
			loop_audio.position = Vector3.ZERO # Relative to parent
			
			loop_audio.stream = loop_sound.sound_effect
			loop_audio.volume_db = loop_sound.get_randomized_volume_db()
			loop_audio.bus = _get_valid_bus_name(loop_sound.bus_name)
			loop_audio.pitch_scale = loop_sound.get_randomized_pitch_scale()
			loop_audio.max_distance = loop_sound.max_distance_3d
			loop_audio.attenuation_model = loop_sound.attenuation_model_3d as AudioStreamPlayer3D.AttenuationModel
			loop_audio.unit_size = loop_sound.unit_size_3d
			loop_audio.max_db = loop_sound.max_db_3d
			loop_sound.log_playing_3d(parent_node.global_position, loop_audio.bus, loop_audio.volume_db, loop_audio.pitch_scale) # Debug log if debug_print is enabled for this sound effect
			
			loop_audio.play()
			
			# Store the loop player reference and parent node (playback will be fetched when needed)
			active_looping_sounds[loop_type] = {
				"player": loop_audio,
				"parent_node": parent_node
			}
			
			# Switch to starting clip if specified and stream is AudioStreamInteractive
			if starting_clip_index > 0:
				# Get playback after play() call
				await get_tree().process_frame
				var playback = loop_audio.get_stream_playback()
				if playback != null:
					playback.switch_to_clip(starting_clip_index)
			
			# Clean up on finished (if loop somehow ends naturally)
			loop_audio.finished.connect(func():
				loop_sound.on_audio_finished()
				if active_looping_sounds.has(loop_type):
					active_looping_sounds.erase(loop_type)
				loop_audio.queue_free()
			)
		else:
			loop_sound.log_limit_reached() # Debug log if debug_print is enabled for this sound effect

## Internal helper to start a non-positional looping sound. Creates an AudioStreamPlayer as a child of the AudioManager. Called by play_loop().
func _start_loop(loop_type: SoundEffect.SOUND_EFFECT_TYPE, starting_clip_index: int = 0) -> void:
	if sound_effect_dict.has(loop_type):
		var loop_sound: SoundEffect = sound_effect_dict[loop_type]
		if loop_sound.has_open_limit():
			loop_sound.change_audio_count(1)
			var loop_audio: AudioStreamPlayer = AudioStreamPlayer.new()
			add_child(loop_audio)
			loop_audio.stream = loop_sound.sound_effect
			loop_audio.volume_db = loop_sound.get_randomized_volume_db()
			loop_audio.bus = _get_valid_bus_name(loop_sound.bus_name)
			loop_audio.pitch_scale = loop_sound.get_randomized_pitch_scale()
			loop_sound.log_playing_non_positional(loop_audio.bus, loop_audio.volume_db, loop_audio.pitch_scale)
			
			loop_audio.play()
			
			# Store the loop player reference (playback will be fetched when needed)
			active_looping_sounds[loop_type] = {
				"player": loop_audio
			}
			
			# Switch to starting clip if specified and stream is AudioStreamInteractive
			if starting_clip_index > 0:
				# Get playback after play() call
				await get_tree().process_frame
				var playback = loop_audio.get_stream_playback()
				if playback != null:
					playback.switch_to_clip(starting_clip_index)
			
			# Clean up on finished (if loop somehow ends naturally)
			loop_audio.finished.connect(func():
				loop_sound.on_audio_finished()
				if active_looping_sounds.has(loop_type):
					active_looping_sounds.erase(loop_type)
				loop_audio.queue_free()
			)
		else:
			loop_sound.log_limit_reached() # Debug log if debug_print is enabled for this sound effect
	else:
		push_warning("AudioManager3D: Loop sound type not found: " + str(loop_type))
