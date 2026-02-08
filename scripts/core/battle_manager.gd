extends Node

## BattleManager Singleton
## Handles battle scene transitions and coordinates between overworld and battle

signal battle_started(enemy_ids: Array)
signal battle_ended(victory: bool)

# Battle state
var current_enemy_ids: Array = []
var on_victory_callback: Callable
var on_defeat_callback: Callable
var is_boss_battle: bool = false
var previous_scene_path: String = ""
var return_spawn_position: Vector2 = Vector2.ZERO

const BATTLE_SCENE_PATH: String = "res://scenes/battle/battle_scene.tscn"

## Start a battle with the given enemy IDs
## @param enemy_ids: Array of enemy ID strings (e.g., ["slime", "goblin"])
## @param on_victory: Callable to execute on battle victory (receives exp: int, gold: int)
## @param on_defeat: Callable to execute on battle defeat (no params)
## @param boss_battle: Set to true to prevent running from battle
## @param player_position: Optional Vector2 for where to return the player after battle
func start_battle(enemy_ids: Array, on_victory: Callable, on_defeat: Callable, boss_battle: bool = false, player_position: Vector2 = Vector2.ZERO) -> void:
	if enemy_ids.is_empty():
		push_error("BattleManager: Cannot start battle with empty enemy list")
		return

	# Store battle configuration
	current_enemy_ids = enemy_ids.duplicate()
	on_victory_callback = on_victory
	on_defeat_callback = on_defeat
	is_boss_battle = boss_battle
	return_spawn_position = player_position

	# Store current scene path for returning later
	var current_scene = get_tree().current_scene
	if current_scene:
		previous_scene_path = current_scene.scene_file_path
		
		# If player position wasn't explicitly provided, try to find player node
		if return_spawn_position == Vector2.ZERO:
			var player = current_scene.find_child("Player", true, false)
			if player:
				return_spawn_position = player.global_position

	battle_started.emit(enemy_ids)

	# Transition to battle scene
	get_tree().change_scene_to_file(BATTLE_SCENE_PATH)

## Called by BattleSystem when battle is won
func _on_battle_victory(exp_gained: int, gold_gained: int) -> void:
	battle_ended.emit(true)

	# Execute victory callback
	if on_victory_callback.is_valid():
		on_victory_callback.call(exp_gained, gold_gained)

	# Return to previous scene
	_return_to_overworld()

## Called by BattleSystem when battle is lost
func _on_battle_defeat() -> void:
	battle_ended.emit(false)

	# Execute defeat callback
	if on_defeat_callback.is_valid():
		on_defeat_callback.call()

	# Defeat callback should handle scene transition (usually to game over)
	# But as fallback, return to overworld
	if get_tree().current_scene != null:
		_return_to_overworld()

## Return to the overworld scene
func _return_to_overworld() -> void:
	if return_spawn_position != Vector2.ZERO:
		get_tree().root.set_meta("spawn_position", return_spawn_position)
		
	if previous_scene_path != "":
		get_tree().call_deferred("change_scene_to_file", previous_scene_path)
	else:
		# Fallback to village map
		get_tree().change_scene_to_file("res://scenes/overworld/map_a_village.tscn")

	# Clear battle state
	current_enemy_ids.clear()
	on_victory_callback = Callable()
	on_defeat_callback = Callable()
	is_boss_battle = false
	previous_scene_path = ""
	
	# Reset step counter for grace period after battle
	GameState.steps_since_battle = 0

## Get the current battle configuration
func get_battle_config() -> Dictionary:
	return {
		"enemy_ids": current_enemy_ids,
		"is_boss_battle": is_boss_battle
	}
