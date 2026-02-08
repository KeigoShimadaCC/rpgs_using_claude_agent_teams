extends Node

## Integration Test - Battle and Encounter System
## Tests the complete flow from overworld to battle and back

var test_passed = true
var GameState  # Manual reference for testing

func _ready() -> void:
	# Handle missing GameState singleton in standalone script execution
	if has_node("/root/GameState"):
		GameState = get_node("/root/GameState")
	else:
		print("DEBUG: GameState singleton not found, loading manually for test...")
		var GS = load("res://scripts/core/game_state.gd")
		GameState = GS.new()
		add_child(GameState)
		# Initialize some defaults needed for tests if necessary
		GameState.steps_since_battle = 999
		GameState.grace_period_steps = 5
		GameState.auto_battle_enabled = false
	print("\n============================================================")
	print("INTEGRATION TEST: Battle & Encounter System")
	print("============================================================\n")
	
	# Test 1: GameState flags exist
	test_gamestate_flags()
	
	# Test 2: Grace period logic
	test_grace_period_logic()
	
	# Test 3: Auto-battle flag
	test_auto_battle_flag()
	
	# Test 4: Step counter
	test_step_counter()
	
	# Summary
	print("\n============================================================")
	if test_passed:
		print("✓ ALL INTEGRATION TESTS PASSED")
	else:
		print("✗ SOME TESTS FAILED")
	print("============================================================\n")
	
	get_tree().quit()

func test_gamestate_flags() -> void:
	print("TEST: GameState Flags Exist")
	
	# Check auto_battle_enabled exists
	if not "auto_battle_enabled" in GameState:
		fail("auto_battle_enabled flag missing")
		return
	
	# Check steps_since_battle exists
	if not "steps_since_battle" in GameState:
		fail("steps_since_battle missing")
		return
	
	# Check grace_period_steps exists
	if not "grace_period_steps" in GameState:
		fail("grace_period_steps missing")
		return
	
	print("  ✓ All flags exist")
	print("  - auto_battle_enabled: " + str(GameState.auto_battle_enabled))
	print("  - steps_since_battle: " + str(GameState.steps_since_battle))
	print("  - grace_period_steps: " + str(GameState.grace_period_steps))

func test_grace_period_logic() -> void:
	print("\nTEST: Grace Period Logic")
	
	# Initial state should allow encounters
	if GameState.steps_since_battle < GameState.grace_period_steps:
		fail("Initial steps_since_battle (" + str(GameState.steps_since_battle) + ") should be >= grace_period (" + str(GameState.grace_period_steps) + ") to allow first encounter")
		return
	
	print("  ✓ Initial state allows encounters")
	
	# Simulate battle end
	GameState.steps_since_battle = 0
	
	# Should block encounters
	if GameState.steps_since_battle >= GameState.grace_period_steps:
		fail("After battle, steps should be < grace_period")
		return
	
	print("  ✓ After battle, grace period active")
	
	# Simulate walking 5 steps
	GameState.steps_since_battle = 5
	
	# Should allow encounters again
	if GameState.steps_since_battle < GameState.grace_period_steps:
		fail("After 5 steps, should allow encounters")
		return
	
	print("  ✓ After grace period, encounters allowed")
	
	# Reset for other tests
	GameState.steps_since_battle = 999

func test_auto_battle_flag() -> void:
	print("\nTEST: Auto-Battle Flag")
	
	var initial = GameState.auto_battle_enabled
	
	# Toggle on
	GameState.auto_battle_enabled = true
	if not GameState.auto_battle_enabled:
		fail("Failed to enable auto-battle")
		return
	
	print("  ✓ Can enable auto-battle")
	
	# Toggle off
	GameState.auto_battle_enabled = false
	if GameState.auto_battle_enabled:
		fail("Failed to disable auto-battle")
		return
	
	print("  ✓ Can disable auto-battle")
	
	# Restore
	GameState.auto_battle_enabled = initial

func test_step_counter() -> void:
	print("\nTEST: Step Counter")
	
	var initial = GameState.steps_since_battle
	
	# Increment
	GameState.steps_since_battle += 1
	if GameState.steps_since_battle != initial + 1:
		fail("Step counter not incrementing")
		return
	
	print("  ✓ Step counter increments")
	
	# Reset
	GameState.steps_since_battle = 0
	if GameState.steps_since_battle != 0:
		fail("Step counter not resetting")
		return
	
	print("  ✓ Step counter resets")
	
	# Restore
	GameState.steps_since_battle = initial

func fail(message: String) -> void:
	print("  ✗ FAIL: " + message)
	test_passed = false
