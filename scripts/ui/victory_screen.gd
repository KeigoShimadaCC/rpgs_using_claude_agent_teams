extends Control

## Victory Screen
## Shows ending credits and allows player to return to title or quit

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var credits_label: Label = $MarginContainer/VBoxContainer/CreditsLabel
@onready var message_label: Label = $MarginContainer/VBoxContainer/MessageLabel
@onready var button_container: VBoxContainer = $MarginContainer/VBoxContainer/ButtonContainer
@onready var return_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/ReturnButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/QuitButton

func _ready() -> void:
	# Determine ending message based on choice
	var ending_message = ""
	if GameState.has_flag("returned_memory"):
		ending_message = "The bell rings once more. The past remains sealed.\nOrder is preserved, but the truth stays hidden."
	elif GameState.has_flag("freed_memory"):
		ending_message = "The bell rings with a new voice. The truth is free.\nThe future is uncertain, but it is yours to shape."
	else:
		ending_message = "The time cycle has been restored."

	message_label.text = ending_message

	# Connect buttons
	return_button.pressed.connect(_on_return_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Focus first button
	return_button.grab_focus()

	# Fade in effect
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.5)

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/title_screen.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
