extends Area2D

# Trigger types
enum TriggerType {
	MAP_TRANSITION,
	BATTLE,
	CUTSCENE,
	CUSTOM
}

# Properties
@export var trigger_type: TriggerType = TriggerType.MAP_TRANSITION
@export var trigger_enabled: bool = true

# Map transition properties
@export_file("*.tscn") var target_scene: String = ""
@export var spawn_position: Vector2 = Vector2.ZERO
@export var spawn_marker_name: String = ""  # Alternative: use a marker node name

# Battle trigger properties
@export var enemy_ids: Array[String] = []

# Quest gating
@export var required_flag: String = ""
@export var blocked_message: String = "The path is blocked."

# Fade transition
@export var use_fade_transition: bool = true
@export var fade_duration: float = 0.3

# Signals
signal trigger_activated(trigger: Area2D)
signal transition_started()
signal transition_completed()

var player_in_area: bool = false
var can_trigger: bool = true

func _ready() -> void:
	# Set up collision layers
	collision_layer = 16  # Trigger layer (layer 5)
	collision_mask = 2    # Detect player layer

	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if not trigger_enabled or not can_trigger:
		return

	# Check if it's the player
	if body.name == "Player" or body.is_in_group("player"):
		player_in_area = true
		_activate_trigger(body)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		player_in_area = false

func _activate_trigger(player: Node2D) -> void:
	# Check quest gating
	if required_flag != "" and not GameState.has_flag(required_flag):
		_show_blocked_message()
		return

	# Emit signal
	trigger_activated.emit(self)

	match trigger_type:
		TriggerType.MAP_TRANSITION:
			_handle_map_transition(player)
		TriggerType.BATTLE:
			_handle_battle_trigger()
		TriggerType.CUTSCENE:
			_handle_cutscene_trigger()
		TriggerType.CUSTOM:
			# Custom triggers should connect to trigger_activated signal
			pass

func _handle_map_transition(player: Node2D) -> void:
	if target_scene == "":
		print("Map transition trigger has no target scene set!")
		return

	can_trigger = false  # Prevent double-triggering
	transition_started.emit()

	if use_fade_transition:
		await _fade_transition(player)
	else:
		_change_scene()

func _fade_transition(player: Node2D) -> void:
	# Create fade overlay
	var fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.color.a = 0.0
	fade_rect.z_index = 100

	# Add to viewport as canvas layer
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	get_tree().root.add_child(canvas_layer)
	canvas_layer.add_child(fade_rect)

	# Match viewport size
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Fade out
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, fade_duration)
	await tween.finished

	# Change scene (this node is freed after change; do not use get_tree() after)
	_change_scene()
	# Note: Fade-in can be done by the new scene's MapController when ready

func _change_scene() -> void:
	# Store spawn position for the new scene
	if spawn_marker_name != "":
		get_tree().root.set_meta("spawn_marker", spawn_marker_name)
	else:
		get_tree().root.set_meta("spawn_position", spawn_position)

	# Change to target scene
	get_tree().change_scene_to_file(target_scene)

func _handle_battle_trigger() -> void:
	if enemy_ids.is_empty():
		print("Battle trigger has no enemy IDs set!")
		return

	# Check if BattleManager exists
	if has_node("/root/BattleManager"):
		var battle_manager = get_node("/root/BattleManager")
		if battle_manager.has_method("start_battle"):
			can_trigger = false  # Prevent retriggering
			battle_manager.call_deferred("start_battle", enemy_ids, _on_battle_victory, _on_battle_defeat, false)
		else:
			print("BattleManager does not have start_battle method!")
	else:
		print("BattleManager not found! Cannot start battle.")

func _handle_cutscene_trigger() -> void:
	print("Cutscene trigger activated (not yet implemented)")
	# Agent C will implement cutscene system

func _on_battle_victory(exp_gained: int, gold_gained: int) -> void:
	print("Battle victory! Gained ", exp_gained, " EXP and ", gold_gained, " gold")
	GameState.add_exp(exp_gained)
	GameState.add_gold(gold_gained)

	# Disable trigger after battle
	trigger_enabled = false
	can_trigger = false

func _on_battle_defeat() -> void:
	print("Battle defeat!")
	get_tree().change_scene_to_file("res://scenes/main/game_over.tscn")

func _show_blocked_message() -> void:
	print(blocked_message)
	# TODO: Show UI message box (will be implemented by Agent D)

func set_enabled(enabled: bool) -> void:
	trigger_enabled = enabled
	can_trigger = enabled
