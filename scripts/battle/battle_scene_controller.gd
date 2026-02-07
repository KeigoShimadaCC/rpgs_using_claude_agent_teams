extends Node2D

## BattleSceneController
## Main controller for the battle scene, coordinates BattleSystem and BattleUI

@onready var battle_system = $BattleSystem
@onready var battle_ui = $BattleUI
@onready var enemy_container = $EnemyContainer

var enemy_positions: Array = []

func _ready() -> void:
	# Get enemy positions
	enemy_positions = [
		$EnemyContainer/EnemyPosition1,
		$EnemyContainer/EnemyPosition2,
		$EnemyContainer/EnemyPosition3
	]

	# Connect battle system to UI
	if battle_system and battle_ui:
		battle_ui.battle_system = battle_system
		battle_system.ui_controller = battle_ui

		# Connect turn indicator
		battle_system.turn_started.connect(battle_ui.set_turn_indicator)

	# Get battle configuration from BattleManager
	var config = BattleManager.get_battle_config()
	if config.has("enemy_ids") and not config.enemy_ids.is_empty():
		initialize_battle(config.enemy_ids)

func initialize_battle(enemy_ids: Array) -> void:
	print("Initializing battle with enemy IDs: ", enemy_ids)
	# Load and spawn enemies
	for i in range(min(enemy_ids.size(), 3)):
		var enemy_id = enemy_ids[i]
		var enemy_data = battle_system.get_enemy_data(enemy_id)

		if not enemy_data.is_empty():
			print("Spawning enemy: ", enemy_data.get("name", "Unknown"))
			# Create enemy instance
			var enemy_instance = battle_system.enemy_scene.instantiate()
			enemy_instance.setup(enemy_data)

			# Position enemy
			if i < enemy_positions.size():
				enemy_container.add_child(enemy_instance)
				enemy_instance.global_position = enemy_positions[i].global_position
			else:
				enemy_container.add_child(enemy_instance)

			# Add to battle system enemies array
			battle_system.enemies.append(enemy_instance)
		else:
			print("ERROR: Could not find enemy data for: ", enemy_id)
	
	print("Total enemies spawned: ", battle_system.enemies.size())
	# Initialize battle system
	battle_system.start_battle()
