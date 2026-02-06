extends Area2D

## Boss Trigger
## Checks quest flag, triggers boss intro dialogue, then starts boss battle

@export var boss_intro_dialogue_id: String = "boss_intro"
@export var boss_enemy_id: String = "archivist_shade"
@export var required_flag: String = "accepted_quest"
@export var blocked_message: String = "The path is blocked by an invisible force."

var player_in_area: bool = false
var can_trigger: bool = true
var dialogue_triggered: bool = false

func _ready() -> void:
	# Set up collision layers
	collision_layer = 16  # Trigger layer
	collision_mask = 2    # Detect player layer

	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if not can_trigger:
		return

	# Check if it's the player
	if body.name == "Player" or body.is_in_group("player"):
		player_in_area = true
		_try_trigger_boss(body)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		player_in_area = false

func _try_trigger_boss(player: Node2D) -> void:
	# Check quest flag
	if required_flag != "" and not GameState.has_flag(required_flag):
		_show_blocked_message()
		return

	# Prevent re-triggering
	can_trigger = false

	# Trigger boss intro dialogue if not already triggered
	if not dialogue_triggered:
		dialogue_triggered = true
		_trigger_boss_intro_dialogue()
	else:
		# If dialogue already shown, start battle directly
		_start_boss_battle()

func _trigger_boss_intro_dialogue() -> void:
	# Check if DialogueManager exists
	if has_node("/root/DialogueManager"):
		var dialogue_manager = get_node("/root/DialogueManager")
		if dialogue_manager.has_method("start_dialogue"):
			# Connect to dialogue ended signal
			if not dialogue_manager.dialogue_ended.is_connected(_on_dialogue_ended):
				dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)

			dialogue_manager.start_dialogue(boss_intro_dialogue_id)
			return

	# Fallback: if no dialogue manager, start battle directly
	print("DialogueManager not found. Starting boss battle directly.")
	_start_boss_battle()

func _on_dialogue_ended() -> void:
	# After dialogue ends, start the boss battle
	_start_boss_battle()

func _start_boss_battle() -> void:
	# Check if BattleManager exists
	if has_node("/root/BattleManager"):
		var battle_manager = get_node("/root/BattleManager")
		if battle_manager.has_method("start_battle"):
			# Start boss battle (is_boss_battle = true to prevent running)
			battle_manager.start_battle(
				[boss_enemy_id],
				_on_boss_victory,
				_on_boss_defeat,
				true  # is_boss_battle
			)
	else:
		print("BattleManager not found! Cannot start boss battle.")

func _on_boss_victory(exp_gained: int, gold_gained: int) -> void:
	print("Boss defeated! Gained ", exp_gained, " EXP and ", gold_gained, " gold")
	GameState.add_exp(exp_gained)
	GameState.add_gold(gold_gained)
	GameState.set_flag("defeated_boss", true)

	# Trigger ending sequence
	_trigger_ending()

func _on_boss_defeat() -> void:
	print("Defeated by boss!")
	get_tree().change_scene_to_file("res://scenes/main/game_over.tscn")

func _trigger_ending() -> void:
	# Give the player the bell clapper item
	GameState.add_item("bell_clapper", 1)
	GameState.set_flag("has_clapper", true)

	# Load the ending cutscene which handles the choice and resolution
	get_tree().change_scene_to_file("res://scenes/main/ending_cutscene.tscn")

func _show_blocked_message() -> void:
	print(blocked_message)
	# TODO: Show UI message box (will be implemented with dialogue box)
