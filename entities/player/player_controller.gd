class_name PlayerController
extends CharacterBody3D

@export var speed: float = 1.0
@export var gravity: float = 4.0

var move_input: Vector2 = Vector2.ZERO
var face_vector: Vector2 = Vector2.DOWN

@onready var animation_tree: AnimationTree = %AnimationTree

func _process(delta: float) -> void:
	process_inputs()
	process_facing()
	process_animations()

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

func process_facing() -> void:
	if move_input == Vector2.ZERO: return
	face_vector = move_input

func process_animations() -> void:
	animation_tree.set("parameters/conditions/is_idle", velocity.x == 0.0 and velocity.z == 0.0)
	animation_tree.set("parameters/conditions/is_walking", velocity.x != 0.0 or velocity.z != 0.0)
	animation_tree.set("parameters/walk/blend_position", face_vector)
