extends Control

## Ending Cutscene Controller
## Orchestrates the ending dialogue sequence:
## 1. Boss defeat aftermath (show clapper obtained)
## 2. Present choice to player (return vs free memory)
## 3. Show appropriate ending based on choice
## 4. Display credits/victory screen

enum EndingState {
	AFTERMATH,
	CHOICE,
	RESOLUTION,
	CREDITS
}

var current_state: EndingState = EndingState.AFTERMATH
var choice_made: bool = false

@onready var background: ColorRect = $Background
@onready var fade_overlay: ColorRect = $FadeOverlay

func _ready() -> void:
	# Set up background
	background.color = Color(0.1, 0.1, 0.15, 1.0)

	# Start with fade in
	fade_overlay.color = Color.BLACK
	_fade_from_black()

	# Wait a moment, then start the ending sequence
	await get_tree().create_timer(1.0).timeout
	_start_ending_sequence()

func _start_ending_sequence() -> void:
	# Connect to DialogueManager
	if has_node("/root/DialogueManager"):
		var dialogue_manager = get_node("/root/DialogueManager")
		dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)

	# Start with the boss defeat aftermath dialogue
	_start_aftermath_dialogue()

func _start_aftermath_dialogue() -> void:
	current_state = EndingState.AFTERMATH

	if has_node("/root/DialogueManager"):
		var dialogue_manager = get_node("/root/DialogueManager")
		dialogue_manager.start_dialogue("boss_defeat")

func _start_choice_dialogue() -> void:
	current_state = EndingState.CHOICE

	if has_node("/root/DialogueManager"):
		var dialogue_manager = get_node("/root/DialogueManager")
		dialogue_manager.start_dialogue("ending_choice")

func _on_dialogue_ended() -> void:
	match current_state:
		EndingState.AFTERMATH:
			# Boss defeat dialogue ended, now present the choice
			_start_choice_dialogue()

		EndingState.CHOICE:
			# Choice dialogue ended, now show resolution
			_start_resolution_dialogue()

		EndingState.RESOLUTION:
			# Resolution dialogue ended, show credits
			_show_credits()

func _start_resolution_dialogue() -> void:
	current_state = EndingState.RESOLUTION

	# Set made_choice flag
	GameState.set_flag("made_choice", true)

	# Check which choice was made
	var dialogue_id = ""
	if GameState.has_flag("returned_memory"):
		dialogue_id = "ending_return"
	elif GameState.has_flag("freed_memory"):
		dialogue_id = "ending_free"
	else:
		# Fallback if no choice was made somehow
		push_error("No ending choice flag set!")
		_show_credits()
		return

	# Fade to black, then show resolution
	await _fade_to_black()
	await get_tree().create_timer(0.5).timeout
	await _fade_from_black()

	# Start resolution dialogue
	if has_node("/root/DialogueManager"):
		var dialogue_manager = get_node("/root/DialogueManager")
		dialogue_manager.start_dialogue(dialogue_id)

func _show_credits() -> void:
	current_state = EndingState.CREDITS

	# Fade to black
	await _fade_to_black()

	# Load victory screen
	get_tree().change_scene_to_file("res://scenes/main/victory_screen.tscn")

func _fade_to_black() -> void:
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color.BLACK, 1.0)
	await tween.finished

func _fade_from_black() -> void:
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), 1.0)
	await tween.finished
