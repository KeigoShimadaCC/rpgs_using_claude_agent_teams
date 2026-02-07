extends Node

## Test Game State
## Automated tests for GameState singleton

var tests_passed = 0
var tests_failed = 0

func _ready() -> void:
	print("=== GAME STATE TESTS ===\n")
	
	# Save original state
	var original_hp = GameState.player_hp
	var original_mp = GameState.player_mp
	var original_gold = GameState.player_gold
	var original_exp = GameState.player_exp
	
	# Run all tests
	test_hp_management()
	test_mp_management()
	test_gold_management()
	test_exp_and_leveling()
	test_quest_flags()
	test_inventory()
	
	# Restore original state
	GameState.player_hp = original_hp
	GameState.player_mp = original_mp
	GameState.player_gold = original_gold
	GameState.player_exp = original_exp
	
	# Print summary
	print_summary()
	
	# Exit
	get_tree().quit()

func test_hp_management() -> void:
	print("TEST: HP Management")
	
	var initial_hp = GameState.player_hp
	
	# Test damage
	GameState.damage_player(10)
	assert_equal(GameState.player_hp, initial_hp - 10, "Damage reduces HP")
	
	# Test heal
	GameState.heal_player(5)
	assert_equal(GameState.player_hp, initial_hp - 5, "Heal increases HP")
	
	# Test max HP cap
	GameState.heal_player(1000)
	assert_equal(GameState.player_hp, GameState.player_hp_max, "HP capped at max")
	
	pass_test("HP management works correctly")

func test_mp_management() -> void:
	print("TEST: MP Management")
	
	var initial_mp = GameState.player_mp
	
	# Test MP consumption
	var consumed = GameState.consume_mp(5)
	assert_true(consumed, "MP consumed successfully")
	assert_equal(GameState.player_mp, initial_mp - 5, "MP reduced")
	
	# Test insufficient MP
	GameState.player_mp = 2
	var failed = GameState.consume_mp(10)
	assert_false(failed, "Cannot consume more MP than available")
	
	pass_test("MP management works correctly")

func test_gold_management() -> void:
	print("TEST: Gold Management")
	
	var initial_gold = GameState.player_gold
	
	# Test adding gold
	GameState.add_gold(100)
	assert_equal(GameState.player_gold, initial_gold + 100, "Gold added")
	
	# Test spending gold
	var spent = GameState.spend_gold(50)
	assert_true(spent, "Gold spent successfully")
	assert_equal(GameState.player_gold, initial_gold + 50, "Gold reduced")
	
	# Test insufficient gold
	GameState.player_gold = 10
	var failed = GameState.spend_gold(100)
	assert_false(failed, "Cannot spend more gold than available")
	
	pass_test("Gold management works correctly")

func test_exp_and_leveling() -> void:
	print("TEST: Experience and Leveling")
	
	var initial_level = GameState.player_level
	var initial_exp = GameState.player_exp
	
	# Add some exp (not enough to level)
	GameState.add_exp(10)
	assert_true(GameState.player_exp > initial_exp, "EXP increased")
	
	pass_test("Experience system works")

func test_quest_flags() -> void:
	print("TEST: Quest Flags")
	
	# Set a flag
	GameState.set_flag("test_flag")
	assert_true(GameState.has_flag("test_flag"), "Flag was set")
	
	# Check non-existent flag
	assert_false(GameState.has_flag("nonexistent_flag"), "Non-existent flag returns false")
	
	pass_test("Quest flags work correctly")

func test_inventory() -> void:
	print("TEST: Inventory System")
	
	# Add item
	GameState.add_item("potion", 3)
	assert_true(GameState.has_item("potion"), "Item added to inventory")
	
	# Use item
	var used = GameState.use_item("potion")
	assert_true(used, "Item used successfully")
	
	pass_test("Inventory system works")

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
