extends Node

signal return_to_menu
signal start_transition

var in_menu: bool = true
var highscore: int = 0:
	set(new_value):
		UiSignals.update_highscore.emit(new_value)
		highscore = new_value
