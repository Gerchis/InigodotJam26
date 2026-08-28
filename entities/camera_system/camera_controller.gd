class_name CameraController
extends Camera3D

@export var plane: PlaneController

@export var roll_rate: float = 0.3

func _process(delta: float) -> void:
	if plane.in_boost: return
	process_camera_movement()

func process_camera_movement() -> void:
	rotation.z = plane.mesh.rotation.z * roll_rate
