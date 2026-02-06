extends CanvasLayer

## Dialogue Box UI
## Displays dialogue text with typewriter effect and choice buttons
## Connects to DialogueManager singleton

@onready var panel: Panel = $Panel
@onready var speaker_label: Label = $Panel/MarginContainer/VBoxContainer/SpeakerLabel
@onready var dialogue_label: RichTextLabel = $Panel/MarginContainer/VBoxContainer/DialogueLabel
@onready var continue_prompt: Label = $Panel/MarginContainer/VBoxContainer/ContinuePrompt
@onready var choices_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ChoicesContainer

# Typewriter effect settings
@export var characters_per_second: float = 40.0
@export var skip_typewriter_on_input: bool = true

var is_typing: bool = false
var current_text: String = ""
var visible_characters: int = 0
var typewriter_timer: float = 0.0
var is_waiting_for_input: bool = false
var current_choices: Array = []

# Choice button scene
var choice_button_scene: PackedScene = null

signal choice_selected(choice_index: int)

func _ready() -> void:
	# Hide dialogue box initially
	hide_dialogue()

	# Connect to DialogueManager if it exists
	if has_node("/root/DialogueManager"):
		var dialogue_manager = get_node("/root/DialogueManager")
		if dialogue_manager.has_signal("dialogue_node_changed"):
			dialogue_manager.dialogue_node_changed.connect(_on_dialogue_node_changed)
		if dialogue_manager.has_signal("dialogue_ended"):
			dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)

func _process(delta: float) -> void:
	if is_typing:
		_update_typewriter(delta)

func _unhandled_input(event: InputEvent) -> void:
	if not panel.visible:
		return

	# Handle continue/skip input
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		if is_typing and skip_typewriter_on_input:
			# Skip typewriter effect
			_finish_typewriter()
			get_viewport().set_input_as_handled()
		elif is_waiting_for_input and current_choices.is_empty():
			# Continue to next dialogue node
			_continue_dialogue()
			get_viewport().set_input_as_handled()

func show_dialogue() -> void:
	panel.visible = true

	# Disable player movement (if player exists)
	_set_player_movement_enabled(false)

func hide_dialogue() -> void:
	panel.visible = false
	is_typing = false
	is_waiting_for_input = false

	# Re-enable player movement
	_set_player_movement_enabled(true)

func display_text(speaker: String, text: String) -> void:
	# Set speaker name
	speaker_label.text = speaker if speaker != "" else "???"

	# Start typewriter effect
	current_text = text
	visible_characters = 0
	typewriter_timer = 0.0
	is_typing = true
	is_waiting_for_input = false

	# Reset dialogue label
	dialogue_label.text = current_text
	dialogue_label.visible_characters = 0

	# Hide continue prompt while typing
	continue_prompt.visible = false

func display_choices(choices: Array) -> void:
	current_choices = choices

	# Clear existing choice buttons
	for child in choices_container.get_children():
		child.queue_free()

	# Create choice buttons
	for i in range(choices.size()):
		var choice = choices[i]
		var button = Button.new()
		button.text = choice.text if choice.has("text") else "Choice " + str(i + 1)
		button.custom_minimum_size = Vector2(0, 40)
		button.add_theme_font_size_override("font_size", 18)

		# Connect button press
		var choice_index = i
		button.pressed.connect(func(): _on_choice_pressed(choice_index))

		choices_container.add_child(button)

	# Focus first choice button
	if choices_container.get_child_count() > 0:
		choices_container.get_child(0).grab_focus()

	# Show choices container
	choices_container.visible = true
	continue_prompt.visible = false

func _update_typewriter(delta: float) -> void:
	typewriter_timer += delta

	var chars_to_show = int(typewriter_timer * characters_per_second)
	visible_characters = min(chars_to_show, current_text.length())

	dialogue_label.visible_characters = visible_characters

	# Check if finished typing
	if visible_characters >= current_text.length():
		_finish_typewriter()

func _finish_typewriter() -> void:
	is_typing = false
	visible_characters = current_text.length()
	dialogue_label.visible_characters = -1  # Show all characters

	# Show continue prompt if no choices
	if current_choices.is_empty():
		continue_prompt.visible = true
		is_waiting_for_input = true

func _continue_dialogue() -> void:
	# Tell DialogueManager to continue
	if has_node("/root/DialogueManager"):
		var dialogue_manager = get_node("/root/DialogueManager")
		if dialogue_manager.has_method("continue_dialogue"):
			dialogue_manager.continue_dialogue()

func _on_choice_pressed(choice_index: int) -> void:
	# Tell DialogueManager about the choice
	if has_node("/root/DialogueManager"):
		var dialogue_manager = get_node("/root/DialogueManager")
		if dialogue_manager.has_method("select_choice"):
			dialogue_manager.select_choice(choice_index)

	# Hide choices
	choices_container.visible = false
	current_choices.clear()

func _on_dialogue_node_changed(speaker: String, text: String, choices: Array) -> void:
	# Update dialogue display
	display_text(speaker, text)

	# Wait for typewriter to finish before showing choices
	if not choices.is_empty():
		await get_tree().create_timer(0.1).timeout
		while is_typing:
			await get_tree().process_frame
		display_choices(choices)
	else:
		# Clear choices if there are none
		for child in choices_container.get_children():
			child.queue_free()
		choices_container.visible = false
		current_choices.clear()

func _on_dialogue_ended() -> void:
	hide_dialogue()

func _set_player_movement_enabled(enabled: bool) -> void:
	# Find player and disable/enable movement
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_physics_process"):
		player.set_physics_process(enabled)
		# Also disable input processing
		if player.has_method("set_process_unhandled_input"):
			player.set_process_unhandled_input(enabled)
