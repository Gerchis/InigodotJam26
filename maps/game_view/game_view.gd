class_name GameView
extends Control

const GAME_MAP = preload("uid://cbvfkykjbkaje")

@onready var sub_viewport: SubViewport = %SubViewport
@onready var menu: Menu = %Menu
@onready var ui: UiController = %UI

func _ready() -> void:
	GameManagers.return_to_menu.connect(reset_game)
	UiSignals.start_game.connect(show_ui)

func reset_game() -> void:
	sub_viewport.get_child(0).queue_free()
	await  sub_viewport.get_child(0).tree_exited
	var game_instance: Node3D = GAME_MAP.instantiate()
	sub_viewport.add_child(game_instance)
	
	menu.show()
	ui.modulate = Color.TRANSPARENT

func show_ui() -> void:
	await get_tree().create_timer(1.0).timeout
	create_tween().tween_property(ui, "modulate", Color.WHITE, 0.5)
