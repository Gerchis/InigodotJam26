class_name DeadArea
extends Area3D

func _ready() -> void:
	body_entered.connect(on_body_entered)
	set_collision_layer_value(1,false)
	set_collision_layer_value(3, true)
	set_collision_mask_value(1, false)
	set_collision_mask_value(3, true)

func on_body_entered(body: Node3D) -> void:
	if body.get_owner() is PlaneController:
		var plane: PlaneController = body.get_owner()
		plane.die()
