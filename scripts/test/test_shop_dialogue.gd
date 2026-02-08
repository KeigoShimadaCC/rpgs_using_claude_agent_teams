extends SceneTree

## Integration test for Dialogue Commands and Shop opening

var tests_passed = 0
var tests_failed = 0
var GameState
var DialogueManager
var ShopUI

func _init() -> void:
	# Load singletons manually if not present
	if root.has_node("GameState"):
		GameState = root.get_node("GameState")
	else:
		GameState = load("res://scripts/core/game_state.gd").new()
		GameState.name = "GameState"
		root.add_child(GameState)
		
	if root.has_node("DialogueManager"):
		DialogueManager = root.get_node("DialogueManager")
	else:
		DialogueManager = load("res://scripts/core/dialogue_manager.gd").new()
		DialogueManager.name = "DialogueManager"
		DialogueManager._gs_override = GameState
		root.add_child(DialogueManager)
		
	# ShopUI is a scene
	if root.has_node("ShopUI"):
		ShopUI = root.get_node("ShopUI")
	else:
		var ShopUIScene = load("res://scenes/ui/shop_menu.tscn")
		ShopUI = ShopUIScene.instantiate()
		ShopUI.name = "ShopUI"
		ShopUI._gs_override = GameState
		DialogueManager._shop_ui_override = ShopUI
		root.add_child(ShopUI)
		# Mock some UI nodes if needed (since it's headless)
		# But we mainly want to check if open_shop() is called

	print("=== DIALOGUE & SHOP INTEGRATION TESTS ===\n")
	
	test_quest_accept_via_dialogue()
	test_shop_open_via_dialogue()
	
	print("\nSummary: %d passed, %d failed" % [tests_passed, tests_failed])
	if tests_failed == 0:
		print("✓ ALL INTEGRATION TESTS PASSED")
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

func test_quest_accept_via_dialogue() -> void:
	print("TEST: Accept Quest via Dialogue Command")
	GameState.active_quests.clear()
	GameState.completed_quests.clear()
	
	# Start healer quest dialogue
	DialogueManager.start_dialogue("healer_quest")
	
	# Current node is 'start'
	# Select choice 0: "How can I help?" -> explain_problem
	DialogueManager.select_choice(0)
	assert_true(DialogueManager.current_node_id == "explain_problem", "Should move to explain_problem")
	
	# Advance to offer_quest
	DialogueManager.advance()
	assert_true(DialogueManager.current_node_id == "offer_quest", "Should move to offer_quest")
	
	# Select choice 0: "I'll do it!" -> accept (Command ACCEPT_QUEST:q_collect_herbs)
	DialogueManager.select_choice(0)
	assert_true(GameState.is_quest_active("q_collect_herbs"), "Quest q_collect_herbs should be active")
	assert_true(DialogueManager.current_node_id == "accept", "Should move to accept node")

func test_shop_open_via_dialogue() -> void:
	print("TEST: Open Shop via Dialogue Command")
	
	# Start merchant dialogue
	DialogueManager.start_dialogue("village_merchant")
	
	# Select choice 0: "Show me your wares" -> open_shop (Command OPEN_SHOP:village_general_store)
	# We want to verify that ShopUI.open_shop was called.
	# Since we're headless and it's a real script, let's check ShopUI state if possible
	# or just verify the command execution didn't crash and DialogueManager logic worked.
	
	# Note: ShopUI.open_shop() sets visible = true on its 'Panel'
	var panel = ShopUI.get_node_or_null("Panel")
	if panel:
		panel.visible = false
	
	DialogueManager.select_choice(0)
	
	if panel:
		assert_true(panel.visible == true, "ShopUI Panel should be visible after command")
	assert_true(ShopUI.current_shop_id == "village_general_store", "ShopUI should have correct shop_id")
