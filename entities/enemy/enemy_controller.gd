class_name EnemyController
extends CharacterBody3D

@onready var animation_tree: AnimationTree = %AnimationTree
@onready var weight_system: WeightSystem = $weight_system
@onready var enemy_sprite: Sprite3D = %EnemySprite
@onready var col: CollisionShape3D = %Col

@export var gravity: float = 4.0
@export var jump_force: float = 2.0
@export var jump_speed: float = 0.75
@export var walk_speed: float = 0.5
@export var accel: float = 10.0

@export var attack_range: float = 0.15
@export var push_force: float = 3.0

var is_jumping: bool = true
var direction: Vector2 = Vector2.ZERO
var player: PlayerController
@export var can_move: bool = true

func _process(delta: float) -> void:
	if just_landed():
		enemy_sprite.rotation = Vector3.ZERO
		enemy_sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		is_jumping = false
		animation_tree.set("parameters/conditions/is_walking", true)
		animation_tree.set("parameters/conditions/jump_right", false)
		animation_tree.set("parameters/conditions/jump_left", false)
		player.boost.connect(die)
	
	process_push()
	if abs(global_position.y - player.global_position.y) > 5.0:
		queue_free()


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
		if not can_move:
			target_vel = Vector3.ZERO
		var actual_vel: Vector3 = Vector3(velocity.x, 0.0, velocity.z).move_toward(target_vel, accel*delta)
		
		velocity.x = actual_vel.x
		velocity.z = actual_vel.z
		
		animation_tree.set("parameters/walk/blend_position", -chase_dir.x)
		animation_tree.set("parameters/bump/blend_position", -chase_dir.x)

func process_gravity(delta: float) -> void:
	velocity.y -= gravity * delta

func jump(dir: float = 0.0) -> void:
	velocity.y = jump_force
	direction = Vector2.RIGHT * dir
	if dir >= 0.0:
		animation_tree.set("parameters/conditions/jump_right", true)
	else:
		animation_tree.set("parameters/conditions/jump_left", true)

func process_push() -> void:
	if (global_position - player.global_position).length() < attack_range:
		if animation_tree.get("parameters/conditions/is_attacking"):
			return
		animation_tree.set("parameters/conditions/is_walking", false)
		animation_tree.set("parameters/conditions/is_attacking", true)
		await get_tree().create_timer(0.5).timeout
		animation_tree.set("parameters/conditions/is_walking", true)
		animation_tree.set("parameters/conditions/is_attacking", false)

func push() -> void:
	if (global_position - player.global_position).length() > attack_range: return
	var push_direction: Vector3 = global_position.direction_to(player.global_position)
	push_direction.y = 0.0
	push_direction = push_direction.normalized()
	player.velocity = push_direction * push_force

func die() -> void:
	can_move = false
	animation_tree.set("parameters/conditions/is_walking", false)
	jump()
	col.disabled = true
