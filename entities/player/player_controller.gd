class_name PlayerController
extends CharacterBody3D

signal boost

const ATACAR = preload("uid://355pctvq1pre")
const SALTAR = preload("uid://dmvkvhkh65q5")

@export var speed: float = 1.0
@export var accel: float = 10.0
@export var gravity: float = 4.0
@export var jump_force: float = 2.0
@export var push_force: float = 3.0

var move_input: Vector2 = Vector2.ZERO
var face_vector: Vector2 = Vector2.DOWN

var can_move: bool = true
var pushed_bodies: Array[Node3D] = []

@onready var animation_tree: AnimationTree = %AnimationTree
@onready var bump_area: Area3D = %BumpArea
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

func _process(delta: float) -> void:
	if GameManagers.in_menu: return
	process_inputs()
	process_facing()
	process_animations()

func _physics_process(delta: float) -> void:
	process_movement(delta)
	process_gravity(delta)
	
	move_and_slide()

func process_inputs() -> void:
	move_input = Input.get_vector("move_right", "move_left", "move_down", "move_up")
	
	if Input.is_action_just_pressed("attack") and can_move:
		attack()

func process_movement(delta: float) -> void:
	var target_velocity: Vector2 = move_input * speed
	if not can_move: target_velocity = Vector2.ZERO
	var actual_velocity: Vector2 = Vector2(velocity.x, velocity.z).move_toward(target_velocity, accel * delta)
	
	velocity.x = actual_velocity.x
	velocity.z = actual_velocity.y

func process_gravity(delta: float) -> void:
	velocity.y -= gravity * delta

func process_facing() -> void:
	if move_input == Vector2.ZERO: return
	face_vector = move_input

func jump() -> void:
	velocity.y = jump_force
	play_jump_sound()
	boost.emit()

func attack() -> void:
	animation_tree.set("parameters/conditions/is_attacking", true)
	animation_tree.set.call_deferred("parameters/conditions/is_attacking", false)
	await get_tree().create_timer(0.5).timeout
	continue_moving()

func stop_moving() -> void:
	can_move = false

func continue_moving() -> void:
	can_move = true

func process_animations() -> void:
	animation_tree.set("parameters/conditions/is_idle", velocity.x == 0.0 and velocity.z == 0.0)
	animation_tree.set("parameters/conditions/is_walking", velocity.x != 0.0 or velocity.z != 0.0)
	animation_tree.set("parameters/walk/blend_position", face_vector)
	if face_vector.x != 0.0:
		animation_tree.set("parameters/bump/blend_position", -face_vector.x)

func die() -> void:
	animation_tree.set("parameters/conditions/is_dead", true)
	jump()

func push() -> void:
	for body in bump_area.get_overlapping_bodies():
		if not body is CharacterBody3D or body in pushed_bodies: continue
		var push_direction: Vector3 = global_position.direction_to(body.global_position)
		push_direction.y = 0.0
		push_direction = push_direction.normalized()
		body.velocity = push_direction * push_force
		pushed_bodies.append(body)

func clean_bodies() -> void:
	pushed_bodies.clear()

func play_attack_sound() -> void:
	audio_stream_player.stream = ATACAR
	audio_stream_player.play()

func play_jump_sound() -> void:
	audio_stream_player.stream = SALTAR
	audio_stream_player.play()
