class_name MapScroller
extends Node

@export var environment_root: Node3D
@export var plane: PlaneController

@export var max_horizontal_speed: float = 10.0

func _process(delta: float) -> void:
	process_scroll_elements(delta)

func process_scroll_elements(delta) -> void:
	var plane_roll: float = plane.weight_vector.x
	var horizontal_speed: float = plane_roll * max_horizontal_speed
	
	var new_offset: Vector2 = Vector2(horizontal_speed * delta, 0.0)
	
	for element in environment_root.get_children() as Array[Node3D]:
		element.global_position += Vector3(new_offset.x, 0.0, new_offset.y)
