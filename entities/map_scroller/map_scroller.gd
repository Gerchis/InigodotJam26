class_name MapScroller
extends Node

const BUILDING_1 = preload("uid://c1wbr78i7pnj3")
const BUILDING_2 = preload("uid://8qpxbmbxv8np")
const BUILDING_3 = preload("uid://b4d0bj1ucwwfm")
const BUILDING_4 = preload("uid://bv5tfpcwpmod0")
const BUILDING_5 = preload("uid://bx02448onab6x")

@export var environment_root: Node3D
@export var plane: PlaneController

@export var building_spawner_x_range: float = 30.0
@export var building_spawner_outer_x_range: float = 180.0
@export var building_spawner_y: float = -60.0
@export var building_spawner_z: float = 390.0

@export var building_spawner_try_time: float = 0.5
@export var building_spawner_cooldown: float = 2.0
@export var building_spawner_chance: float = 25.0
@export var building_spawner_max_tries: int = 8

@export var max_horizontal_speed: float = 10.0

var building_spawner_cooldown_timer: float = 0.0
var building_spawner_timer: float = 0.0
var building_spawner_tries: int = 0
var posible_buildings: Array[PackedScene] = [
	BUILDING_1,
	BUILDING_2,
	BUILDING_3,
	BUILDING_4,
	BUILDING_5,
]

func _process(delta: float) -> void:
	process_scroll_elements(delta)
	
	process_building_spawn(delta)

func process_scroll_elements(delta) -> void:
	var plane_roll: float = plane.weight_vector.x
	var horizontal_speed: float = plane_roll * max_horizontal_speed
	
	var new_offset: Vector2 = Vector2(horizontal_speed * delta, -10 * delta)
	
	for element in environment_root.get_children() as Array[Node3D]:
		element.global_position += Vector3(new_offset.x, 0.0, new_offset.y)

func process_building_spawn(delta: float) -> void: 
	building_spawner_cooldown_timer += delta
	if building_spawner_cooldown_timer < 0.0: return
	
	building_spawner_timer += delta
	if building_spawner_timer > 0.0:
		building_spawner_timer = -building_spawner_try_time
		var chance: float = randf()
		building_spawner_tries += 1
		if chance > (building_spawner_chance / 100.0) or building_spawner_tries >= building_spawner_max_tries:
			building_spawner_tries = 0
			spawn_building()
			building_spawner_cooldown_timer = -building_spawner_cooldown
		else:
			spawn_building(false)

func spawn_building(in_range: bool = true) -> void:
	var choosen_building: PackedScene = posible_buildings.pick_random()
	var buiding_instance: Node3D = choosen_building.instantiate()
	var random_x: float = (randf() * 2.0) - 1.0
	var x_pos: float = random_x * building_spawner_x_range
	if not in_range:
		x_pos = random_x * building_spawner_outer_x_range
	
	buiding_instance.global_position = Vector3(x_pos, building_spawner_y, building_spawner_z)
	environment_root.add_child(buiding_instance)
