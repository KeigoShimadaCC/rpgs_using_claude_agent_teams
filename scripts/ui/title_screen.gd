extends Control

## Title Screen
## Main menu with New Game and Quit buttons

@onready var new_game_button: Button = $MarginContainer/VBoxContainer/NewGameButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/QuitButton

func _ready() -> void:
	# Connect button signals
	if new_game_button:
		new_game_button.pressed.connect(_on_new_game_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

	# Focus on New Game button for keyboard navigation
	if new_game_button:
		new_game_button.grab_focus()

func _on_new_game_pressed() -> void:
	print("Starting new game...")

	# Reset game state
	if has_node("/root/GameState"):
		var game_state = get_node("/root/GameState")
		if game_state.has_method("reset_player"):
			game_state.reset_player()

	# Load first map
	get_tree().change_scene_to_file("res://scenes/overworld/map_a_village.tscn")

func _on_quit_pressed() -> void:
	print("Quitting game...")
	get_tree().quit()
