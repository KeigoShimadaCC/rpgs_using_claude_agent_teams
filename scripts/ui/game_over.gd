extends Control

## Game Over Screen
## Shown when player is defeated in battle

@onready var restart_button: Button = $MarginContainer/VBoxContainer/RestartButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/QuitButton

func _ready() -> void:
	# Connect button signals
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

	# Focus on Restart button for keyboard navigation
	if restart_button:
		restart_button.grab_focus()

func _on_restart_pressed() -> void:
	print("Restarting game...")
	# Return to title screen
	get_tree().change_scene_to_file("res://scenes/main/title_screen.tscn")

func _on_quit_pressed() -> void:
	print("Quitting game...")
	get_tree().quit()
