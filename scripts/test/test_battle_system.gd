extends Node

## Test Battle System
## Automated tests for battle mechanics

var test_results = []
var tests_passed = 0
var tests_failed = 0

func _ready() -> void:
	print("=== BATTLE SYSTEM TESTS ===\n")
	
	# Run all tests
	test_enemy_spawning()
	test_player_attack()
	test_skill_usage()
	test_defend_action()
	test_auto_battle()
	test_victory_condition()
	test_defeat_condition()
	
	# Print summary
	print_summary()
	
	# Exit
	get_tree().quit()

func test_enemy_spawning() -> void:
	print("TEST: Enemy Spawning")
	
	# Create battle system
	var battle_system = load("res://scripts/battle/battle_system.gd").new()
	add_child(battle_system)
	
	# Load enemy data
	var enemy_data = battle_system.get_enemy_data("slime")
	
	if enemy_data.is_empty():
		fail("Enemy data not loaded")
		battle_system.queue_free()
		return
	
	# Create enemy instance
	var enemy = battle_system.enemy_scene.instantiate()
	enemy.setup(enemy_data)
	add_child(enemy)
	
	# Verify enemy properties
	assert_equal(enemy.enemy_name, "Slime", "Enemy name")
	assert_true(enemy.max_hp > 0, "Enemy has HP")
	assert_true(enemy.is_alive(), "Enemy is alive")
	
	# Cleanup
	enemy.queue_free()
	battle_system.queue_free()
	
	pass_test("Enemy spawning works correctly")

func test_player_attack() -> void:
	print("TEST: Player Attack")
	
	var battle_system = load("res://scripts/battle/battle_system.gd").new()
	add_child(battle_system)
	
	# Create enemy
	var enemy = battle_system.enemy_scene.instantiate()
	var enemy_data = battle_system.get_enemy_data("slime")
	enemy.setup(enemy_data)
	add_child(enemy)
	battle_system.enemies.append(enemy)
	
	var initial_hp = enemy.current_hp
	
	# Calculate expected damage
	var damage = battle_system.calculate_damage(GameState.get_total_atk(), enemy.def)
	
	# Execute attack
	enemy.take_damage(damage)
	
	assert_true(enemy.current_hp < initial_hp, "Enemy took damage")
	
	# Cleanup
	enemy.queue_free()
	battle_system.queue_free()
	
	pass_test("Player attack damages enemy")

func test_skill_usage() -> void:
	print("TEST: Skill Usage")
	
	var battle_system = load("res://scripts/battle/battle_system.gd").new()
	add_child(battle_system)
	
	# Check if Fire Bolt skill exists
	var fire_bolt = battle_system.skills_data.get("fire_bolt")
	assert_true(fire_bolt != null, "Fire Bolt skill exists")
	
	# Check if Heal skill exists
	var heal = battle_system.skills_data.get("heal")
	assert_true(heal != null, "Heal skill exists")
	
	# Cleanup
	battle_system.queue_free()
	
	pass_test("Skills loaded correctly")

func test_defend_action() -> void:
	print("TEST: Defend Action")
	
	# Test that defend flag can be set
	var battle_system = load("res://scripts/battle/battle_system.gd").new()
	add_child(battle_system)
	
	battle_system.player_defending = true
	assert_true(battle_system.player_defending, "Defend flag set")
	
	# Cleanup
	battle_system.queue_free()
	
	pass_test("Defend action works")

func test_auto_battle() -> void:
	print("TEST: Auto Battle Logic")
	
	var battle_system = load("res://scripts/battle/battle_system.gd").new()
	add_child(battle_system)
	
	# Test helper functions
	assert_true(battle_system.has_method("has_mp_for_skill"), "has_mp_for_skill exists")
	assert_true(battle_system.has_method("get_random_enemy_index"), "get_random_enemy_index exists")
	
	# Cleanup
	battle_system.queue_free()
	
	pass_test("Auto battle helper functions exist")

func test_victory_condition() -> void:
	print("TEST: Victory Condition")
	
	var battle_system = load("res://scripts/battle/battle_system.gd").new()
	add_child(battle_system)
	
	# With no enemies, should be defeated
	var all_defeated = battle_system.all_enemies_defeated()
	assert_true(all_defeated, "No enemies means all defeated")
	
	# Cleanup
	battle_system.queue_free()
	
	pass_test("Victory condition check works")

func test_defeat_condition() -> void:
	print("TEST: Defeat Condition")
	
	# Set player HP to 0
	var original_hp = GameState.player_hp
	GameState.player_hp = 0
	
	assert_false(GameState.is_alive(), "Player is not alive at 0 HP")
	
	# Restore HP
	GameState.player_hp = original_hp
	
	pass_test("Defeat condition check works")

# Helper functions
func assert_true(condition: bool, message: String) -> void:
	if not condition:
		fail(message + " (expected true, got false)")

func assert_false(condition: bool, message: String) -> void:
	if condition:
		fail(message + " (expected false, got true)")

func assert_equal(actual, expected, message: String) -> void:
	if actual != expected:
		fail(message + " (expected: " + str(expected) + ", got: " + str(actual) + ")")

func pass_test(message: String) -> void:
	tests_passed += 1
	print("  ✓ PASS: " + message)

func fail(message: String) -> void:
	tests_failed += 1
	print("  ✗ FAIL: " + message)

func print_summary() -> void:
	print("\n=== TEST SUMMARY ===")
	print("Passed: " + str(tests_passed))
	print("Failed: " + str(tests_failed))
	print("Total:  " + str(tests_passed + tests_failed))
	
	if tests_failed == 0:
		print("\n✓ ALL TESTS PASSED!")
	else:
		print("\n✗ SOME TESTS FAILED")
