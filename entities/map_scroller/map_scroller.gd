class_name MapScroller
extends Node

const BUILDING_1 = preload("uid://c1wbr78i7pnj3")
const BUILDING_2 = preload("uid://8qpxbmbxv8np")
const BUILDING_3 = preload("uid://b4d0bj1ucwwfm")
const BUILDING_4 = preload("uid://bv5tfpcwpmod0")
const BUILDING_5 = preload("uid://bx02448onab6x")

@export var paralel_scroll: Node3D
@export var perpendicular_scroll: Node3D
@export var falling_scroll: Node3D
@export var plane: PlaneController
@export var particle_system: CPUParticles3D
@export var animation_player: AnimationPlayer

@export var building_spawner_x_range: float = 50.0
@export var building_spawner_outer_x_range: float = 180.0
@export var building_spawner_y: float = -60.0
@export var building_spawner_z: float = 390.0

@export var building_spawner_try_time: float = 2.0
@export var building_spawner_close_chance: float = 20.0

@export var initial_horizontal_speed: float = 10.0
@export var initial_vertical_speed: float = 10.0
@export var max_speed_mod: float = 1.0
@export var min_speed_mod: float = 0.2
@export var max_acceleration: float = 1.0

@export var bottom_point: float = -50.0

@export var max_falling_rate: float = 1.0
@export var min_falling_rate: float = 0.25

@export var delete_threshold: float = 10.0

var building_spawner_cooldown_timer: float = 0.0
var building_spawner_timer: float = 0.0
var posible_buildings: Array[PackedScene] = [
	BUILDING_1,
	BUILDING_2,
	BUILDING_3,
	BUILDING_4,
	BUILDING_5,
]
var current_speed: float = initial_vertical_speed
var current_distance: float = 0.0
var current_height: float = 0.0

func _ready() -> void:
	UiSignals.start_game.connect(transition_to_game)

func _process(delta: float) -> void:
	if GameManagers.in_menu: return
	process_scroll_elements(delta)
	
	process_building_spawn(delta)
	
	update_ui_values()

func process_scroll_elements(delta) -> void:
	var plane_roll: float = plane.weight_vector.x
	var plane_pitch: float = plane.weight_vector.y
	
	var base_speed: float = initial_vertical_speed + (current_distance / 100.0)
	var speed_offset: float = base_speed * max_speed_mod * -plane_pitch
	if plane_pitch < 0.0:
		speed_offset = base_speed * min_speed_mod * -plane_pitch
	var target_speed: float = base_speed + speed_offset
	
	current_speed = move_toward(current_speed, target_speed, max_acceleration * delta)
	
	var horizontal_speed: float = -plane_roll * (current_speed)
	var new_offset: Vector2 = Vector2(horizontal_speed * delta, -current_speed * delta)
	
	paralel_scroll.global_position.x += new_offset.x
	
	for perpendicular_element in perpendicular_scroll.get_children() as Array[Node3D]:
		perpendicular_element.global_position.z += new_offset.y
		if perpendicular_element.global_position.z < -delete_threshold:
			perpendicular_element.queue_free()
	
	current_distance += abs(new_offset.y)
	current_height = plane.global_position.y - bottom_point
	
	var falling_rate: float = remap(plane_pitch, -1.0, 1.0, min_falling_rate, max_falling_rate)
	falling_scroll.global_position.y -= (falling_rate) * delta

func process_building_spawn(delta: float) -> void: 
	building_spawner_timer += delta
	if building_spawner_timer > 0.0:
		building_spawner_timer = -building_spawner_try_time
		var chance: float = randf()
		if chance > building_spawner_close_chance:
			spawn_building()
		else:
			spawn_building(false)

func spawn_building(in_range: bool = true) -> void:
	var choosen_building: PackedScene = posible_buildings.pick_random()
	var buiding_instance: Node3D = choosen_building.instantiate()
	var random_x: float = (randf() * 2.0) - 1.0
	var x_pos: float = random_x * building_spawner_x_range
	if not in_range:
		x_pos = random_x * building_spawner_outer_x_range
	
	perpendicular_scroll.add_child(buiding_instance)
	buiding_instance.global_position = Vector3(x_pos, building_spawner_y, building_spawner_z)

func update_ui_values() -> void:
	UiSignals.update_distance.emit(current_distance)
	UiSignals.update_height.emit(current_height)
	UiSignals.update_velocity.emit(current_speed)

func transition_to_game() -> void:
	animation_player.play("transition")

func game_ready() -> void:
	GameManagers.in_menu = false
