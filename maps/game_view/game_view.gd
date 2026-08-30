class_name GameView
extends Control

const GAME_MAP = preload("uid://cbvfkykjbkaje")

@onready var sub_viewport: SubViewport = %SubViewport
@onready var menu: Menu = $Menu


func _ready() -> void:
	GameManagers.return_to_menu.connect(reset_game)

func reset_game() -> void:
	sub_viewport.get_child(0).queue_free()
	await  sub_viewport.get_child(0).tree_exited
	var game_instance: Node3D = GAME_MAP.instantiate()
	sub_viewport.add_child(game_instance)
	
	menu.show()
