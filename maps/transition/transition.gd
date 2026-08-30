class_name Transition
extends Control

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	GameManagers.start_transition.connect(transition)

func transition() -> void:
	animation_player.play("transition")

func apply_transition() -> void:
	GameManagers.return_to_menu.emit()
