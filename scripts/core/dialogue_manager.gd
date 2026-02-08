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
var _gs_override = null
var _shop_ui_override = null

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
		_get_gs().set_flag(selected_choice.set_flag, true)
		print("DialogueManager: Set flag '" + selected_choice.set_flag + "' to true")

	# Apply command if present
	if selected_choice.has("command") and selected_choice.command != "":
		_execute_command(selected_choice.command)

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
	
	# Execute command on entry if present
	if current_node.has("command") and current_node.command != "":
		_execute_command(current_node.command)

# Filter choices based on check_flag requirements
func get_available_choices(choices: Array) -> Array:
	var available = []
	for choice in choices:
		var is_available = true
		
		# Check flag requirement
		if choice.has("check_flag") and choice.check_flag != "":
			if not _get_gs().has_flag(choice.check_flag):
				is_available = false
		
		# Check quest requirement
		if is_available and choice.has("check_quest") and choice.check_quest != "":
			if not _check_quest_condition(choice.check_quest):
				is_available = false
				
		if is_available:
			available.append(choice)
			
	return available

func _get_gs():
	if _gs_override: return _gs_override
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root.has_node("GameState"):
		return tree.root.get_node("GameState")
	return null

func _get_shop_ui():
	if _shop_ui_override: return _shop_ui_override
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		if tree.root.has_node("ShopUI"):
			return tree.root.get_node("ShopUI")
		return tree.root.find_child("ShopUI", true, false)
	return null

func _check_quest_condition(condition: String) -> bool:
	# Format: "quest_id:status" 
	# Status can be: active, completed, ready (to turn in), not_started
	var parts = condition.split(":")
	if parts.size() < 2:
		return false
		
	var id = parts[0]
	var status = parts[1]
	
	match status:
		"active":
			return _get_gs().is_quest_active(id)
		"completed":
			return _get_gs().is_quest_completed(id)
		"ready":
			return _get_gs().can_turn_in_quest(id)
		"not_started":
			return not _get_gs().is_quest_active(id) and not _get_gs().is_quest_completed(id)
			
	return false

func _execute_command(command: String) -> void:
	print("DialogueManager: Executing command: " + command)
	var parts = command.split(":")
	var cmd = parts[0]
	var arg = parts[1] if parts.size() > 1 else ""
	
	match cmd:
		"ACCEPT_QUEST":
			_get_gs().accept_quest(arg)
		"COMPLETE_QUEST":
			_get_gs().complete_quest(arg)
		"OPEN_SHOP":
			_open_shop_ui(arg)
		"GIVE_ITEM":
			var sub_parts = arg.split(",")
			if sub_parts.size() >= 2:
				_get_gs().add_item(sub_parts[0], int(sub_parts[1]))
		"SET_FLAG":
			_get_gs().set_flag(arg, true)

func _open_shop_ui(shop_id: String) -> void:
	# Find ShopUI in the current scene tree
	var shop_ui = _get_shop_ui()
	
	if shop_ui:
		if shop_ui.has_method("open_shop"):
			shop_ui.open_shop(shop_id)
			print("DialogueManager: Opened shop: " + shop_id)
		else:
			push_error("DialogueManager: ShopUI found but missing open_shop method")
	else:
		push_error("DialogueManager: ShopUI not found in scene tree for command OPEN_SHOP:" + shop_id)
