extends SceneTree

## Unit test for Quest System

var tests_passed = 0
var tests_failed = 0
var GameState # Manual reference for testing

func _init() -> void:
	# Handle missing GameState singleton
	if root.has_node("GameState"):
		GameState = root.get_node("GameState")
	else:
		var GS = load("res://scripts/core/game_state.gd")
		GameState = GS.new()
		root.add_child(GameState)
	
	print("=== QUEST SYSTEM TESTS ===\n")
	
	# Run tests
	print("Running test_quest_loading...")
	test_quest_loading()
	print("Running test_quest_acceptance...")
	test_quest_acceptance()
	print("Running test_quest_progress_item...")
	test_quest_progress_item()
	print("Running test_quest_progress_kill...")
	test_quest_progress_kill()
	print("Running test_quest_completion_rewards...")
	test_quest_completion_rewards()
	
	print("All tests finished execution.")
	
	# Summary
	print("\nSummary: %d passed, %d failed" % [tests_passed, tests_failed])
	if tests_failed == 0:
		print("✓ ALL QUEST TESTS PASSED")
	else:
		print("✗ SOME TESTS FAILED")
	
	quit()

func assert_true(condition: bool, message: String) -> void:
	if condition:
		tests_passed += 1
		print("  ✓ " + message)
	else:
		tests_failed += 1
		print("  ✗ FAIL: " + message)

func test_quest_loading() -> void:
	print("TEST: Quest Data Loading")
	GameState.load_quests_data()
	assert_true(GameState.quests_data.size() > 0, "Quests data should be loaded")
	assert_true(GameState.quests_data.has("q_collect_herbs"), "Should have 'q_collect_herbs' quest")

func test_quest_acceptance() -> void:
	print("TEST: Quest Acceptance")
	# Reset state
	GameState.active_quests.clear()
	GameState.completed_quests.clear()
	
	var success = GameState.accept_quest("q_collect_herbs")
	assert_true(success, "Should successfully accept quest")
	assert_true(GameState.is_quest_active("q_collect_herbs"), "Quest should be active")
	
	var progress = GameState.active_quests["q_collect_herbs"].objectives
	assert_true(progress.size() == 1, "Should have 1 objective")
	assert_true(progress[0] == 0, "Objective progress should start at 0")
	
	var fail_accept = GameState.accept_quest("q_collect_herbs")
	assert_true(!fail_accept, "Should not accept already active quest")

func test_quest_progress_item() -> void:
	print("TEST: Quest Progress (Item)")
	# Quest q_collect_herbs needs 3 medicinal_herb
	GameState.update_quest_progress("item", "medicinal_herb", 1)
	var progress = GameState.active_quests["q_collect_herbs"].objectives[0]
	assert_true(progress == 1, "Progress should be 1 after updating")
	
	GameState.update_quest_progress("item", "medicinal_herb", 2)
	progress = GameState.active_quests["q_collect_herbs"].objectives[0]
	assert_true(progress == 3, "Progress should be 3 (capped)")
	
	assert_true(GameState.can_turn_in_quest("q_collect_herbs"), "Quest should be ready to turn in")

func test_quest_progress_kill() -> void:
	print("TEST: Quest Progress (Kill)")
	GameState.accept_quest("q_slime_hunt")
	GameState.update_quest_progress("kill", "slime", 2)
	var progress = GameState.active_quests["q_slime_hunt"].objectives[0]
	assert_true(progress == 2, "Progress should be 2 for kill objective")
	
	GameState.update_quest_progress("kill", "slime", 10) # Overkill
	progress = GameState.active_quests["q_slime_hunt"].objectives[0]
	assert_true(progress == 5, "Progress should be capped at 5")

func test_quest_completion_rewards() -> void:
	print("TEST: Quest Completion Rewards")
	var initial_gold = GameState.player_gold
	var initial_exp = GameState.player_exp
	
	# Complete q_collect_herbs (already has 3 herbs from previous test)
	var success = GameState.complete_quest("q_collect_herbs")
	assert_true(success, "Should successfully complete quest")
	assert_true(!GameState.is_quest_active("q_collect_herbs"), "Quest should no longer be active")
	assert_true(GameState.is_quest_completed("q_collect_herbs"), "Quest should be in completed list")
	assert_true(GameState.quest_flags.get("quest_herbs_complete") == true, "Completion flag should be set")
	
	assert_true(GameState.player_gold == initial_gold + 50, "Gold should increase by 50")
	# Exp check
	print("DEBUG: initial_exp = ", initial_exp, ", player_exp = ", GameState.player_exp, ", initial_level = 1, current_level = ", GameState.player_level)
	assert_true(GameState.player_exp > 0 or GameState.player_level > 1, "Exp should have increased or leveled up")
