class_name WeightSystem
extends Node3D

@export var detection_radius: float = 0.1
@export var weight: float = 1.0

@onready var detector: ShapeCast3D = %Detector

var plane: PlaneController = null

func _ready() -> void:
	setup_detector()

func _process(delta: float) -> void:
	if is_colliding() and plane == null:
		apply_weight()
	elif not is_colliding() and plane != null:
		release_weight()

func setup_detector() -> void:
	detector.shape.radius = detection_radius

func is_colliding() -> bool: 
	return detector.is_colliding()

func get_plane() -> PlaneController:
	var col: Node3D = null
	
	if detector.is_colliding():
		col = detector.get_collider(0)
	
	if col == null: return null
	var plane_controller: PlaneController = col.get_owner() as PlaneController
	return plane_controller

func apply_weight() -> void:
	plane = get_plane()
	if plane == null: return
	if not self in plane.weights:
		plane.weights.append(self)

func release_weight() -> void:
	if plane == null: return
	plane.weights.erase(self)
	plane = null
