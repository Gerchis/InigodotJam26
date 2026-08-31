class_name MapScroller
extends Node

const BUILDING_1 = preload("uid://c1wbr78i7pnj3")
const BUILDING_2 = preload("uid://8qpxbmbxv8np")
const BUILDING_3 = preload("uid://b4d0bj1ucwwfm")
const BUILDING_4 = preload("uid://bv5tfpcwpmod0")
const BUILDING_5 = preload("uid://bx02448onab6x")

const POWER_RING = preload("uid://cn2d67illxdd7")

const COMBATE_BSO = preload("uid://c73no6brq86d4")
const GAME_BSO = preload("uid://cmm13cwbdub7n")

@export var paralel_scroll: Node3D
@export var perpendicular_scroll: Node3D
@export var falling_scroll: Node3D
@export var plane: PlaneController
@export var particle_system: CPUParticles3D
@export var animation_player: AnimationPlayer

@export var building_spawner_x_range: float = 50.0
@export var building_spawner_outer_x_range: float = 180.0
@export var building_spawner_y: float = -60.0
@export var building_spawner_y_range: float = -70.0
@export var building_spawner_z: float = 390.0

@export var building_spawner_distance: float = 10.0
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

@export var boost_height_velocity: float = 12.0
@export var boost_velocity_mod: float = 2.0

@export var ring_spawn_distance: float = 120.0
@export var ring_spawn_horizontal_range: float = 5.0
@export var ring_spawn_vertical_range: float = 5.0
@export var ring_spawn_forward_point: float = 100.0

@export var assault_distance_trigger: float = 400.0

@export var fov_modification: float = 15.0
@export var cam_distance_offset: float = 0.2
@export var cam_speed: float = 10.0

@onready var audio_bso: AudioStreamPlayer = %AudioBSO
@onready var highscore_mesh: MeshInstance3D = %HighscoreMesh
@onready var camera: Camera3D = %Camera

var building_spawner_cooldown_timer: float = 0.0
var building_spawn_point: float = 0.0
var posible_buildings: Array[PackedScene] = [
	BUILDING_1,
	BUILDING_2,
	BUILDING_3,
	BUILDING_4,
	BUILDING_5,
]
var current_speed: float = initial_vertical_speed
var max_speed: float = 0.0
var min_speed: float = 0.0
var current_distance: float = 0.0
var current_height: float = 0.0
var ring_spawn_point: float = 50.0
var next_assault: float = 500.0
var assault_counter: int = 0

var bso_sound_point: float = 0.0

var base_fov: float = 75.0
var base_cam_distance: float = -1.65

func _ready() -> void:
	UiSignals.start_game.connect(transition_to_game)
	if GameManagers.highscore == 0.0: highscore_mesh.hide()

func _process(delta: float) -> void:
	if GameManagers.in_menu: return
	process_scroll_elements(delta)
	
	process_building_spawn()
	process_ring_spawn()
	process_asault()
	process_cam_effects(delta)
	
	update_ui_values()

func process_scroll_elements(delta) -> void:
	var plane_roll: float = plane.weight_vector.x
	var plane_pitch: float = plane.weight_vector.y
	
	var base_speed: float = initial_vertical_speed + (current_distance / 50.0)
	var speed_offset: float = base_speed * max_speed_mod * -plane_pitch
	if plane_pitch < 0.0:
		speed_offset = base_speed * min_speed_mod * -plane_pitch
	var target_speed: float = base_speed + speed_offset
	
	current_speed = move_toward(current_speed, target_speed, max_acceleration * delta)
	max_speed = base_speed * max_speed_mod
	min_speed = base_speed * min_speed_mod
	if plane.in_boost:
		current_speed = base_speed * max_speed_mod * boost_velocity_mod
	
	var horizontal_speed: float = -plane_roll * (current_speed)
	var new_offset: Vector2 = Vector2(horizontal_speed * delta, -current_speed * delta)
	
	paralel_scroll.global_position.x += new_offset.x
	
	for perpendicular_element in perpendicular_scroll.get_children() as Array[Node3D]:
		perpendicular_element.global_position.z += new_offset.y
		if perpendicular_element.global_position.z < -delete_threshold:
			perpendicular_element.queue_free()
	
	current_distance += abs(new_offset.y)
	
	
	var falling_rate: float = remap(plane_pitch, -1.0, 1.0, min_falling_rate, max_falling_rate)
	if plane.in_boost:
		falling_rate = -boost_height_velocity
	falling_scroll.global_position.y -= (falling_rate) * delta
	
	current_height = plane.global_position.y - bottom_point
	if current_height <= 0.0:
		plane.die()

func process_building_spawn() -> void: 
	if current_distance > building_spawn_point:
		building_spawn_point = current_distance + building_spawner_distance
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
	
	var random_y: float = randf()
	
	perpendicular_scroll.add_child(buiding_instance)
	buiding_instance.global_position = Vector3(x_pos, building_spawner_y + (random_y * building_spawner_y_range), building_spawner_z)

func update_ui_values() -> void:
	UiSignals.update_distance.emit(current_distance)
	UiSignals.update_height.emit(current_height)
	UiSignals.update_velocity.emit(current_speed, max_speed * 2.0, min_speed)
	if current_distance > GameManagers.highscore:
		GameManagers.highscore = floori(current_distance)

func transition_to_game() -> void:
	animation_player.play("transition")

func game_ready() -> void:
	GameManagers.in_menu = false
	plane.show_controls()
	%AudioViento.play()

func process_ring_spawn() -> void:
	if current_distance > ring_spawn_point:
		ring_spawn_point = current_distance + ring_spawn_distance
		spawn_ring()

func spawn_ring() -> void:
	var rand_h: float = (randf() * 2.0) - 1.0
	var rand_v: float = randf()
	var position_offset: Vector3 = Vector3(rand_h * ring_spawn_horizontal_range, -(rand_v * ring_spawn_vertical_range) - 2, ring_spawn_forward_point)
	var ring_instance: Node3D = POWER_RING.instantiate()
	perpendicular_scroll.add_child(ring_instance)
	ring_instance.global_position = plane.global_position + position_offset

func process_asault() -> void:
	if current_distance > next_assault:
		next_assault = current_distance + assault_distance_trigger
		var rand: float = randf()
		
		if rand < 0.5:
			assault_right()
		else:
			assault_left()
		
		add_assault_counter()

func assault_right() -> void:
	animation_player.play("right_assault")

func assault_left() -> void:
	animation_player.play("left_assault")

func add_assault_counter() -> void:
	if assault_counter <= 0:
		swap_to_combat_music()
	
	assault_counter += 1

func end_assault_counter() -> void:
	assault_counter -= 1
	if assault_counter <= 0:
		swap_to_game_music()

func swap_to_combat_music() -> void:
	bso_sound_point = audio_bso.get_playback_position()
	await create_tween().tween_property(audio_bso, "volume_linear", 0.0, 0.2).finished
	audio_bso.stream = COMBATE_BSO
	audio_bso.play()
	create_tween().tween_property(audio_bso, "volume_db", -20.0, 0.2)

func swap_to_game_music() -> void:
	await create_tween().tween_property(audio_bso, "volume_linear", 0.0, 0.2).finished
	audio_bso.stream = GAME_BSO
	audio_bso.play(bso_sound_point)
	create_tween().tween_property(audio_bso, "volume_db", -20.0, 0.2)

func process_cam_effects(delta: float) -> void:
	var cam_effects_mod: float = remap(current_speed, max_speed, max_speed * 2.0, 0.0, 1.0)
	cam_effects_mod = clampf(cam_effects_mod, 0.0, 1.0)
	var fov_offset: float = cam_effects_mod * fov_modification
	
	var current_fov: float = move_toward(camera.fov, base_fov + fov_offset, cam_speed * delta)
	camera.fov = current_fov
	var dist_offset: float = remap(current_fov, base_fov, base_fov + fov_modification, 0.0, 1.0) * cam_distance_offset
	camera.global_position.z = base_cam_distance + dist_offset
