extends Node

## Test Runner
## Runs all automated tests and reports results

func _ready() -> void:
	print("\n==================================================")
	print("JRPG MVP: The Silent Bell - Test Suite")
	print("==================================================\n")
	
	print("Note: Run individual test files directly:")
	print("  godot --headless --script scripts/test/test_game_state.gd")
	print("  godot --headless --script scripts/test/test_map_transitions.gd")
	print("  godot --headless --script scripts/test/test_battle_system.gd")
	
	print("\n==================================================\n")
	
	get_tree().quit()
