extends StaticBody2D

# NPC properties
@export var npc_name: String = "NPC"
@export var dialogue_id: String = ""
@export var interactable: bool = true

# Visual
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

# Signals
signal npc_interacted(npc: Node)

func _ready() -> void:
	# Set up collision layers
	collision_layer = 8  # NPC layer (layer 4)
	collision_mask = 0   # NPCs don't need to collide with anything

func interact() -> void:
	if not interactable:
		return

	print("Interacting with ", npc_name)

	# Emit signal for external systems to handle
	npc_interacted.emit(self)

	# Trigger dialogue if dialogue_id is set
	if dialogue_id != "":
		_trigger_dialogue()

func _trigger_dialogue() -> void:
	# Check if DialogueManager exists (will be implemented by Agent C)
	if Engine.has_singleton("DialogueManager"):
		var dialogue_manager = Engine.get_singleton("DialogueManager")
		if dialogue_manager.has_method("start_dialogue"):
			dialogue_manager.start_dialogue(dialogue_id)
	elif has_node("/root/DialogueManager"):
		var dialogue_manager = get_node("/root/DialogueManager")
		if dialogue_manager.has_method("start_dialogue"):
			dialogue_manager.start_dialogue(dialogue_id)
	else:
		print("DialogueManager not found. Dialogue ID: ", dialogue_id)

func set_interactable(value: bool) -> void:
	interactable = value

func get_npc_name() -> String:
	return npc_name
