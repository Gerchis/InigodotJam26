class_name UiController
extends Control

@onready var distance: Label = %Distance
@onready var height: Label = %Height
@onready var velocity: Label = %Velocity
@onready var velocity_slider: HSlider = %VelocitySlider
@onready var height_slider: VSlider = %HeightSlider

func _ready() -> void:
	subscribe_to_signals()

func subscribe_to_signals() -> void:
	UiSignals.update_distance.connect(update_distance_label)
	UiSignals.update_height.connect(update_height_label)
	UiSignals.update_velocity.connect(update_velocity_label)

func update_distance_label(new_value: float) -> void:
	distance.text = str(floor(new_value)).pad_decimals(0) + "m"

func update_height_label(new_value: float) -> void:
	height.text = str(max(floor(new_value),0)).pad_decimals(0) + "m"
	height_slider.value = new_value

func update_velocity_label(new_value: float, max: float, min: float) -> void:
	velocity.text = str(new_value).pad_decimals(2) + "m/s"
	velocity_slider.max_value = max
	velocity_slider.min_value = min
	velocity_slider.value = new_value
