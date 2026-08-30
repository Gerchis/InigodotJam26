class_name EnemyController
extends CharacterBody3D

@onready var animation_tree: AnimationTree = %AnimationTree
@onready var weight_system: WeightSystem = $weight_system
@onready var enemy_sprite: Sprite3D = %EnemySprite

@export var gravity: float = 4.0
@export var jump_force: float = 2.0
@export var jump_speed: float = 0.75
@export var walk_speed: float = 0.5
@export var accel: float = 1.0

var is_jumping: bool = true
var direction: Vector2 = Vector2.ZERO
var player: PlayerController

func _process(delta: float) -> void:
	if just_landed():
		enemy_sprite.rotation = Vector3.ZERO
		enemy_sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		is_jumping = false
		animation_tree.set("parameters/conditions/is_walking", true)

func _physics_process(delta: float) -> void:
	process_movement(delta)
	
	process_gravity(delta)
	
	move_and_slide()

func just_landed() -> bool:
	if not is_jumping: return false
	return weight_system.is_colliding()

func process_movement(delta: float) -> void:
	if is_jumping:
		velocity.x = jump_speed * direction.x
	else:
		var chase_dir: Vector3 = global_position.direction_to(player.global_position)
		var target_vel: Vector3 = Vector3(chase_dir.x, 0.0, chase_dir.z).normalized() * walk_speed
		var actual_vel: Vector3 = Vector3(velocity.x, 0.0, velocity.z).move_toward(target_vel, accel*delta)
		
		velocity.x = actual_vel.x
		velocity.z = actual_vel.z
		
		animation_tree.set("parameters/walk/blend_position", -chase_dir.x)

func process_gravity(delta: float) -> void:
	velocity.y -= gravity * delta

func jump(dir: float = 0.0) -> void:
	velocity.y = jump_force
	direction = Vector2.RIGHT * dir
	if dir >= 0.0:
		animation_tree.set("parameters/conditions/jump_right", true)
	else:
		animation_tree.set("parameters/conditions/jump_left", true)
