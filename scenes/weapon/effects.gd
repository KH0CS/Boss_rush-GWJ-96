class_name ShootingEffects
extends Node2D

# effects positioning
@onready var marker: Marker2D = $VacuumMarker

# shooting
@onready var shoot_animation: AnimatedSprite2D = $ShootAnimation
@onready var shoot_effect: GPUParticles2D = $ShootEffect

# vacuum
@onready var vacuum_effect: GPUParticles2D = $VacuumEffect
@export var cone_length: float = 100.0
@export var cone_half_angle_deg: float = 25.0
@export var point_count: int = 100


func _ready() -> void:
	shoot_animation.hide()
	_setup_vacuum()
	_setup_shoot()

func shoot() -> void:
	shoot_animation.show()
	shoot_animation.play("fire")
	shoot_effect.restart()
	shoot_effect.emitting = true
	await shoot_animation.animation_finished
	shoot_animation.hide()


func vacuum(active: bool) -> void:
	vacuum_effect.emitting = active

func _setup_vacuum() -> void:
	vacuum_effect.position = to_local(marker.global_position)
	
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINTS
	mat.emission_point_count = point_count
	mat.emission_point_texture = _generate_cone_point_texture()
	
	mat.direction = Vector3(0, 0, 0)
	mat.spread = 80.0
	mat.initial_velocity_min = 0.0
	mat.initial_velocity_max = 20.0
	mat.gravity = Vector3.ZERO
	mat.radial_accel_min = -800.0
	mat.radial_accel_max = -1000.0
	
	var curve := Curve.new()
	curve.add_point(Vector2(0, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	var curve_tex := CurveTexture.new()
	curve_tex.curve = curve
	mat.scale_curve = curve_tex
	
	vacuum_effect.process_material = mat
	vacuum_effect.amount = 150
	vacuum_effect.lifetime = 0.3
	vacuum_effect.emitting = false

func _setup_shoot() -> void:
	shoot_effect.position = to_local(marker.global_position)

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(1, 0, 0)
	mat.spread = cone_half_angle_deg
	mat.initial_velocity_min = 150.0
	mat.initial_velocity_max = 2500
	mat.gravity = Vector3.ZERO
	
	mat.color = Color(1.0, 0.388, 0.173, 0.459)
	
	# --- size ---
	mat.scale_min = 1.5
	mat.scale_max = 4.0
	
	# fade size out over lifetime
	var curve := Curve.new()
	curve.add_point(Vector2(0, 1.0))
	curve.add_point(Vector2(1.0, 0.0))
	var curve_tex := CurveTexture.new()
	curve_tex.curve = curve
	mat.scale_curve = curve_tex
	
	shoot_effect.process_material = mat
	shoot_effect.amount = 12
	shoot_effect.lifetime = 0.4
	shoot_effect.one_shot = true
	shoot_effect.explosiveness = 1.0
	shoot_effect.emitting = false

func _generate_cone_point_texture() -> ImageTexture:
	var half_angle_rad = deg_to_rad(cone_half_angle_deg)
	var image := Image.create(point_count, 1, false, Image.FORMAT_RGBF)

	for i in point_count:
		var t = randf()
		var x = t * cone_length
		var half_width = x * tan(half_angle_rad)
		var y = randf_range(-half_width, half_width)
		# Encode point position into pixel color (R=x, G=y, B=0)
		image.set_pixel(i, 0, Color(x, y, 0.0))

	return ImageTexture.create_from_image(image)
