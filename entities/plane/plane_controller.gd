class_name PlaneController
extends Node3D

@export var horizontal_rotation_curve: Curve
@export var vertical_rotation_curve: Curve

@export var max_horizontal_rotation: float = 30.0
@export var max_vertical_rotation: float = 15.0

@export var rotation_speed: float = 20.0

@export var subtle_rotation: float = 5.0
@export var subtle_time_mod: float = 0.7

var weights: Array[WeightSystem] = []

var weight_vector: Vector2 = Vector2.ZERO

var time_counter: float = 0.0

var pitch_offset: float = 0.0

@onready var body: StaticBody3D = %Body
@onready var mass_center: Marker3D = %MassCenter
@onready var mesh: MeshInstance3D = %Mesh

func _process(delta: float) -> void:
	process_weight_vector()
	apply_rotation(delta)
	process_subtle_movement(delta)

func _physics_process(delta: float) -> void:
	body.global_rotation = mesh.global_rotation
	body.global_position = mesh.global_position


func process_weight_vector() -> void:
	if weights.is_empty(): return
	
	weight_vector = Vector2.ZERO
	for weight_node in weights:
		var weight_point: Vector2 = Vector2(mass_center.global_position.x - weight_node.global_position.x, mass_center.global_position.z - weight_node.global_position.z)
		weight_vector += weight_point * weight_node.weight

func apply_rotation(delta: float) -> void:
	var current_pitch: float = mesh.rotation.x
	var current_roll: float = mesh.rotation.z
	
	var vertical_inclination: float = -vertical_rotation_curve.sample(weight_vector.y) * max_vertical_rotation
	var horizontal_inclination: float = horizontal_rotation_curve.sample(weight_vector.x) * max_horizontal_rotation
	
	var target_pitch: float = deg_to_rad(vertical_inclination)
	var target_roll: float = deg_to_rad(horizontal_inclination)
	var rotation_applied: float = deg_to_rad(rotation_speed) * delta
	
	mesh.rotation.x = move_toward(current_pitch, target_pitch + pitch_offset, rotation_applied)
	mesh.rotation.z = move_toward(current_roll, target_roll, rotation_applied)

func process_subtle_movement(delta) -> void:
	time_counter += delta * subtle_time_mod
	pitch_offset = deg_to_rad(sin(time_counter) * subtle_rotation)
