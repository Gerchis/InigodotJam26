class_name Menu
extends Control

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var highscore: Label = %Highscore

var all_disabled: bool = false

func _ready() -> void:
	UiSignals.start_game.connect(hide_menu)
	UiSignals.update_highscore.connect(update_highscore)

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
	highscore.text = str(new_value).pad_decimals(0) + "m"
