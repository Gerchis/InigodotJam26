class_name UiController
extends Control

@onready var distance: Label = %Distance
@onready var height: Label = %Height
@onready var velocity: Label = %Velocity

func _ready() -> void:
	subscribe_to_signals()

func subscribe_to_signals() -> void:
	UiSignals.update_distance.connect(update_distance_label)
	UiSignals.update_height.connect(update_height_label)
	UiSignals.update_velocity.connect(update_velocity_label)

func update_distance_label(new_value: float) -> void:
	distance.text = str(floor(new_value)).pad_decimals(0) + "m"

func update_height_label(new_value: float) -> void:
	height.text = str(new_value) + "m"

func update_velocity_label(new_value: float) -> void:
	velocity.text = str(new_value).pad_decimals(2) + "m/s"
