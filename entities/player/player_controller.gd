class_name PlayerController
extends CharacterBody3D

@export var speed: float = 1.0
@export var gravity: float = 4.0

var move_input: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	process_inputs()

func _physics_process(delta: float) -> void:
	process_movement(delta)
	process_gravity(delta)
	
	move_and_slide()

func process_inputs() -> void:
	move_input = Input.get_vector("move_right", "move_left", "move_down", "move_up")

func process_movement(delta: float) -> void:
	var target_velocity: Vector2 = move_input * speed
	
	velocity.x = target_velocity.x
	velocity.z = target_velocity.y

func process_gravity(delta: float) -> void:
	velocity.y -= gravity * delta
