extends Node

## BattleSystem
## Manages turn-based combat flow, actions, and state

signal turn_started(is_player_turn: bool)
signal action_selected(action: Dictionary)
signal damage_dealt(target: String, amount: int, is_critical: bool)
signal battle_won(exp_gained: int, gold_gained: int)
signal battle_lost()
signal message_logged(text: String)

enum BattleState {
	INITIALIZING,
	PLAYER_TURN,
	ENEMY_TURN,
	PROCESSING_ACTION,
	VICTORY,
	DEFEAT
}

# Battle state
var current_state: BattleState = BattleState.INITIALIZING
var is_player_turn: bool = true
var player_defending: bool = false
var current_enemy_index: int = 0

# Enemy data
var enemies: Array = []  # Array of EnemyBattler nodes
var enemy_scene = preload("res://scenes/battle/enemy.tscn")

# Skill/Item data cache
var skills_data: Dictionary = {}
var items_data: Dictionary = {}

# UI references (set by battle scene)
var ui_controller = null

func _ready() -> void:
	load_data()

## Start battle (assumes enemies are already populated)
func start_battle() -> void:
	current_state = BattleState.INITIALIZING
	current_enemy_index = 0
	
	log_message("Battle started!")
	start_player_turn()

## Load skill and item data from JSON files
func load_data() -> void:
	# Load skills
	var skills_path = "res://data/skills.json"
	if FileAccess.file_exists(skills_path):
		var file = FileAccess.open(skills_path, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		if json.parse(json_string) == OK:
			var data = json.get_data()
			if data.has("skills"):
				for skill in data.skills:
					skills_data[skill.id] = skill

	# Items data is loaded via GameState.load_item_data when needed

## Get enemy data by ID
func get_enemy_data(enemy_id: String) -> Dictionary:
	var file_path = "res://data/enemies.json"
	if not FileAccess.file_exists(file_path):
		push_error("Enemy data file not found: " + file_path)
		return {}

	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(json_string) != OK:
		push_error("Failed to parse enemies.json")
		return {}

	var data = json.get_data()
	if data.has("enemies"):
		for enemy in data.enemies:
			if enemy.id == enemy_id:
				return enemy

	return {}

## Start player turn
func start_player_turn() -> void:
	current_state = BattleState.PLAYER_TURN
	is_player_turn = true
	player_defending = false
	turn_started.emit(true)
	log_message("Your turn!")

	# Enable player action UI
	if ui_controller and ui_controller.has_method("enable_action_menu"):
		ui_controller.enable_action_menu(true)

## Start enemy turn
func start_enemy_turn() -> void:
	current_state = BattleState.ENEMY_TURN
	is_player_turn = false
	turn_started.emit(false)

	# Disable player action UI
	if ui_controller and ui_controller.has_method("enable_action_menu"):
		ui_controller.enable_action_menu(false)

	# Process all living enemies' turns
	await get_tree().create_timer(0.5).timeout
	await process_all_enemy_turns()

	# Check if player is alive
	if not GameState.is_alive():
		trigger_defeat()
		return

	# Return to player turn
	start_player_turn()

## Process all enemy turns sequentially
func process_all_enemy_turns() -> void:
	for enemy in enemies:
		if enemy and enemy.is_alive():
			await process_enemy_turn(enemy)
			await get_tree().create_timer(0.3).timeout

## Process single enemy turn
func process_enemy_turn(enemy) -> void:
	var action = enemy.decide_action()
	log_message(enemy.enemy_name + " is acting...")

	match action.type:
		"attack":
			await execute_enemy_attack(enemy)
		"defend":
			log_message(enemy.enemy_name + " is defending!")
		"skill":
			await execute_enemy_skill(enemy, action.skill_id)

## Execute player action
func execute_player_action(action: Dictionary) -> void:
	if current_state != BattleState.PLAYER_TURN:
		return

	current_state = BattleState.PROCESSING_ACTION
	action_selected.emit(action)

	match action.type:
		"attack":
			await execute_player_attack(action.get("target_index", 0))
		"defend":
			execute_player_defend()
		"skill":
			await execute_player_skill(action.skill_id, action.get("target_index", 0))
		"item":
			execute_player_item(action.item_id)
		"run":
			attempt_run()
		"auto":
			await perform_auto_action()
	
	# Check victory condition and continue to enemy turn
	_check_victory_and_continue()

## Execute auto action for player
func perform_auto_action() -> void:
	log_message("Auto-Battle...")
	await get_tree().create_timer(0.5).timeout
	
	# Decision logic
	var hp_percent = float(GameState.player_hp) / float(GameState.player_hp_max)
	
	# 1. Critical Health -> Heal
	if hp_percent < 0.3:
		if has_mp_for_skill("heal"):
			await execute_player_skill("heal", 0)
			return
		elif GameState.has_item("potion"):
			execute_player_item("potion")
			return
		else:
			# Can't heal, defend
			execute_player_defend()
			return
			
	# 2. Attack or Skill
	# Simple strategy: Attack most of the time, use offensive skill sometimes
	if randf() < 0.3 and has_mp_for_skill("fire_bolt"):
		# Use Fire Bolt on random enemy
		var target_idx = get_random_enemy_index()
		await execute_player_skill("fire_bolt", target_idx)
	else:
		# Attack random enemy
		var target_idx = get_random_enemy_index()
		await execute_player_attack(target_idx)

## Helper to check if player has skill and enough MP
func has_mp_for_skill(skill_id: String) -> bool:
	var skill = skills_data.get(skill_id)
	if skill and GameState.player_mp >= skill.mp_cost:
		return true
	return false
	
## Helper to get random alive enemy index
func get_random_enemy_index() -> int:
	var alive_indices = []
	for i in range(enemies.size()):
		if enemies[i] and enemies[i].is_alive():
			alive_indices.append(i)
	
	if alive_indices.is_empty():
		return 0
	return alive_indices.pick_random()

# Check victory condition
func _check_victory_and_continue() -> void:
	if all_enemies_defeated():
		trigger_victory()
		return

	# End player turn, start enemy turn
	start_enemy_turn()

## Player attacks enemy
func execute_player_attack(target_index: int) -> void:
	if target_index >= enemies.size():
		target_index = 0

	var target = enemies[target_index]
	if not target or not target.is_alive():
		# Find first alive enemy
		target = get_first_alive_enemy()
		if not target:
			return

	var damage = calculate_damage(GameState.get_total_atk(), target.def)
	log_message("You attack " + target.enemy_name + "!")

	var actual_damage = target.take_damage(damage)
	damage_dealt.emit("enemy", actual_damage, false)

	if ui_controller and ui_controller.has_method("show_damage_number"):
		ui_controller.show_damage_number(actual_damage, target.global_position, false)

	await get_tree().create_timer(0.5).timeout

## Player defends
func execute_player_defend() -> void:
	player_defending = true
	log_message("You brace for impact!")
	await get_tree().create_timer(0.3).timeout

## Player uses skill
func execute_player_skill(skill_id: String, target_index: int) -> void:
	var skill = skills_data.get(skill_id)
	if not skill:
		log_message("Unknown skill!")
		return

	# Check MP
	if not GameState.consume_mp(skill.mp_cost):
		log_message("Not enough MP!")
		return

	log_message("You use " + skill.name + "!")

	match skill.target_type:
		"single_enemy":
			var target = enemies[target_index] if target_index < enemies.size() else get_first_alive_enemy()
			if target and target.is_alive():
				var damage = calculate_damage(skill.power, target.def)
				var actual_damage = target.take_damage(damage)
				damage_dealt.emit("enemy", actual_damage, false)

				if ui_controller and ui_controller.has_method("show_damage_number"):
					ui_controller.show_damage_number(actual_damage, target.global_position, false)

		"self":
			# Heal skill
			GameState.heal_player(skill.power)
			log_message("Restored " + str(skill.power) + " HP!")

	await get_tree().create_timer(0.5).timeout

## Player uses item
func execute_player_item(item_id: String) -> void:
	if GameState.use_item(item_id):
		var item_data = GameState.load_item_data(item_id)
		log_message("Used " + item_data.get("name", "item") + "!")
	else:
		log_message("Cannot use item!")

	await get_tree().create_timer(0.3).timeout

## Attempt to run from battle
func attempt_run() -> void:
	var config = BattleManager.get_battle_config()
	if config.is_boss_battle:
		log_message("Cannot escape!")
		await get_tree().create_timer(0.5).timeout
		return

	# 50% chance to escape
	if randf() < 0.5:
		log_message("Escaped successfully!")
		await get_tree().create_timer(0.5).timeout
		BattleManager._return_to_overworld()
	else:
		log_message("Could not escape!")
		await get_tree().create_timer(0.5).timeout

## Enemy attacks player
func execute_enemy_attack(enemy) -> void:
	log_message(enemy.enemy_name + " attacks!")

	var damage = calculate_damage(enemy.atk, GameState.get_total_def())

	# Apply defense reduction if defending
	if player_defending:
		damage = int(damage * 0.5)
		log_message("You block some of the damage!")

	GameState.damage_player(damage)
	damage_dealt.emit("player", damage, false)

	if ui_controller and ui_controller.has_method("show_damage_number"):
		# Show damage on player position (will need to get from UI)
		ui_controller.show_damage_number(damage, Vector2(300, 360), false)

	await get_tree().create_timer(0.5).timeout

## Enemy uses skill
func execute_enemy_skill(enemy, skill_id: String) -> void:
	var skill = skills_data.get(skill_id)
	if not skill:
		# Fallback to attack
		await execute_enemy_attack(enemy)
		return

	log_message(enemy.enemy_name + " uses " + skill.name + "!")

	var damage = calculate_damage(skill.power, GameState.get_total_def())

	if player_defending:
		damage = int(damage * 0.5)

	GameState.damage_player(damage)
	damage_dealt.emit("player", damage, false)

	if ui_controller and ui_controller.has_method("show_damage_number"):
		ui_controller.show_damage_number(damage, Vector2(300, 360), false)

	await get_tree().create_timer(0.5).timeout

## Calculate damage with variance
func calculate_damage(attack: int, defense: int) -> int:
	var base_damage = max(attack - defense, 1)

	# 10% chance for critical hit
	var is_crit = randf() < 0.1
	if is_crit:
		base_damage = int(base_damage * 1.5)

	# Random variance (0.9 to 1.1)
	var variance = randf_range(0.9, 1.1)
	return max(int(base_damage * variance), 1)

## Check if all enemies are defeated
func all_enemies_defeated() -> bool:
	for enemy in enemies:
		if enemy and enemy.is_alive():
			return false
	return true

## Get first alive enemy
func get_first_alive_enemy():
	for enemy in enemies:
		if enemy and enemy.is_alive():
			return enemy
	return null

## Trigger victory
func trigger_victory() -> void:
	current_state = BattleState.VICTORY

	# Calculate rewards
	var exp_total = 0
	var gold_total = 0
	for enemy in enemies:
		exp_total += enemy.exp_reward
		gold_total += enemy.gold_reward

	log_message("Victory!")
	log_message("Gained " + str(exp_total) + " EXP and " + str(gold_total) + " Gold!")

	battle_won.emit(exp_total, gold_total)

	# Award EXP and gold
	var old_level = GameState.player_level
	GameState.add_exp(exp_total)
	GameState.add_gold(gold_total)

	# Check for level up
	if GameState.player_level > old_level:
		log_message("Level up! Now level " + str(GameState.player_level))

	await get_tree().create_timer(2.0).timeout

	# Return to overworld via BattleManager
	BattleManager._on_battle_victory(exp_total, gold_total)

## Trigger defeat
func trigger_defeat() -> void:
	current_state = BattleState.DEFEAT
	log_message("You were defeated...")
	battle_lost.emit()

	await get_tree().create_timer(2.0).timeout

	# Call BattleManager defeat
	BattleManager._on_battle_defeat()

## Log message to battle log
func log_message(text: String) -> void:
	message_logged.emit(text)
	if ui_controller and ui_controller.has_method("add_battle_log"):
		ui_controller.add_battle_log(text)

## Get list of alive enemies (for UI)
func get_alive_enemies() -> Array:
	var alive = []
	for enemy in enemies:
		if enemy and enemy.is_alive():
			alive.append(enemy)
	return alive

## Get player available skills
func get_player_skills() -> Array:
	# Return hero skills (fire_bolt and heal)
	return ["fire_bolt", "heal"]
