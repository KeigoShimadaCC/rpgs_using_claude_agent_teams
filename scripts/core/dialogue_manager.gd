extends Node

# DialogueManager
# Singleton for managing dialogue trees, branching, and quest flags
# Loads dialogue JSON files and controls dialogue flow

## Signals
signal dialogue_started(dialogue_id: String)
signal node_changed(node_data: Dictionary)
signal dialogue_node_changed(speaker: String, text: String, choices: Array)  # For DialogueBox compatibility
signal dialogue_ended()
signal choices_presented(choices: Array)

## State
var current_dialogue: Dictionary = {}
var current_node_id: String = ""
var is_dialogue_active: bool = false

## Constants
const DIALOGUE_PATH = "res://data/dialogues/"

func _ready():
	# Initialize singleton
	pass

## Public Methods

# Start a dialogue tree by loading its JSON file
func start_dialogue(dialogue_id: String) -> void:
	if is_dialogue_active:
		push_warning("Dialogue already active. Ending previous dialogue.")
		end_dialogue()

	# Load dialogue JSON
	current_dialogue = load_dialogue_file(dialogue_id)
	if current_dialogue.is_empty():
		push_error("Failed to start dialogue: " + dialogue_id)
		return

	# Find start node
	var start_node = find_node_by_id("start")
	if start_node == null:
		push_error("No 'start' node found in dialogue: " + dialogue_id)
		return

	# Initialize state
	is_dialogue_active = true
	current_node_id = "start"

	# Emit signals
	dialogue_started.emit(dialogue_id)
	display_current_node()

# Advance to the next node (for linear dialogue with no choices)
func advance() -> void:
	if not is_dialogue_active:
		push_warning("No active dialogue to advance.")
		return

	var current_node = get_current_node()
	if current_node == null:
		push_error("Current node not found: " + current_node_id)
		end_dialogue()
		return

	# Check if this node has choices (should not advance if choices are present)
	if current_node.has("choices") and current_node.choices != null:
		push_warning("Cannot advance: current node has choices. Use select_choice() instead.")
		return

	# Get next node ID
	var next_id = current_node.get("next", null)
	if next_id == null or next_id == "":
		# End of dialogue
		end_dialogue()
		return

	# Move to next node
	current_node_id = next_id
	display_current_node()

# Alias for advance() - for DialogueBox compatibility
func continue_dialogue() -> void:
	advance()

# Select a choice (for branching dialogue)
func select_choice(choice_index: int) -> void:
	if not is_dialogue_active:
		push_warning("No active dialogue to select choice from.")
		return

	var current_node = get_current_node()
	if current_node == null:
		push_error("Current node not found: " + current_node_id)
		end_dialogue()
		return

	# Get choices array
	var choices = current_node.get("choices", [])
	if choices == null or choices.is_empty():
		push_warning("Current node has no choices.")
		return

	# Filter choices by check_flag (only show choices whose flags are met)
	var available_choices = get_available_choices(choices)

	if choice_index < 0 or choice_index >= available_choices.size():
		push_error("Invalid choice index: " + str(choice_index))
		return

	var selected_choice = available_choices[choice_index]

	# Apply set_flag if present
	if selected_choice.has("set_flag") and selected_choice.set_flag != "":
		GameState.set_flag(selected_choice.set_flag, true)
		print("DialogueManager: Set flag '" + selected_choice.set_flag + "' to true")

	# Get next node ID
	var next_id = selected_choice.get("next", null)
	if next_id == null or next_id == "":
		# End of dialogue
		end_dialogue()
		return

	# Move to next node
	current_node_id = next_id
	display_current_node()

# Check if dialogue is currently active
func is_active() -> bool:
	return is_dialogue_active

# Get current node data
func get_current_node() -> Dictionary:
	if not is_dialogue_active:
		return {}
	return find_node_by_id(current_node_id)

# End the current dialogue
func end_dialogue() -> void:
	if not is_dialogue_active:
		return

	is_dialogue_active = false
	current_dialogue = {}
	current_node_id = ""
	dialogue_ended.emit()

## Private Methods

# Load dialogue JSON file by ID
func load_dialogue_file(dialogue_id: String) -> Dictionary:
	var path = DIALOGUE_PATH + dialogue_id + ".json"

	# Check if file exists
	if not FileAccess.file_exists(path):
		push_error("Dialogue file not found: " + path)
		return {}

	# Open file
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open dialogue file: " + path)
		return {}

	# Read and parse JSON
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse dialogue JSON: " + path + " (Error: " + str(parse_result) + ")")
		return {}

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Dialogue JSON root is not a dictionary: " + path)
		return {}

	return data

# Find a node by its ID in the current dialogue
func find_node_by_id(node_id: String) -> Dictionary:
	if current_dialogue.is_empty():
		return {}

	var nodes = current_dialogue.get("nodes", [])
	if nodes == null:
		return {}

	for node in nodes:
		if node.get("id", "") == node_id:
			return node

	return {}

# Display the current node (emit signals for UI to handle)
func display_current_node() -> void:
	var current_node = get_current_node()
	if current_node.is_empty():
		push_error("Failed to display node: " + current_node_id)
		end_dialogue()
		return

	# Extract node data
	var speaker = current_node.get("speaker", "")
	var text = current_node.get("text", "")
	var choices = current_node.get("choices", null)

	# Filter choices by check_flag
	var available_choices = []
	if choices != null and not choices.is_empty():
		available_choices = get_available_choices(choices)
		if available_choices.is_empty():
			push_warning("No available choices (all filtered by flags). Auto-advancing.")
			# If all choices are filtered out, try to advance to next (fallback)
			if current_node.has("next") and current_node.next != null:
				current_node_id = current_node.next
				display_current_node()
			else:
				end_dialogue()
			return

	# Emit both signal formats for compatibility
	node_changed.emit(current_node)  # Original format
	dialogue_node_changed.emit(speaker, text, available_choices)  # DialogueBox format

	# Also emit choices_presented for backward compatibility
	if not available_choices.is_empty():
		choices_presented.emit(available_choices)

# Filter choices based on check_flag requirements
func get_available_choices(choices: Array) -> Array:
	var available = []
	for choice in choices:
		# Check if this choice has a flag requirement
		if choice.has("check_flag") and choice.check_flag != "":
			# Only include if flag is set
			if GameState.has_flag(choice.check_flag):
				available.append(choice)
		else:
			# No flag requirement, always available
			available.append(choice)
	return available
