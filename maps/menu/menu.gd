class_name Menu
extends Control

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var highscore: Label = %Highscore
@onready var higscore_title: Label = %HigscoreTitle

var all_disabled: bool = false

func _ready() -> void:
	UiSignals.start_game.connect(hide_menu)
	UiSignals.update_highscore.connect(update_highscore)
	AudioServer.set_bus_volume_linear(0, 0.5)
	
	if GameManagers.highscore == 0:
		higscore_title.hide()
		highscore.hide()

func hide_menu() -> void:
	all_disabled = true
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	await tween.finished
	hide()
	modulate = Color.WHITE


func _on_play_button_pressed() -> void:
	UiSignals.start_game.emit()
	audio_stream_player.play()

func update_highscore(new_value: int) -> void:
	higscore_title.show()
	highscore.show()
	highscore.text = str(new_value).pad_decimals(0) + "m"


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value)
