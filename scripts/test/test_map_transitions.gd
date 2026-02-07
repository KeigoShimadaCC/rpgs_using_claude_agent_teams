extends Node

## Test Map Transitions
## Automated tests for map system and player spawning

var tests_passed = 0
var tests_failed = 0

func _ready() -> void:
	print("=== MAP TRANSITION TESTS ===\n")
	
	# Run all tests
	test_spawn_marker_metadata()
	test_spawn_position_metadata()
	test_map_controller_logic()
	
	# Print summary
	print_summary()
	
	# Exit
	get_tree().quit()

func test_spawn_marker_metadata() -> void:
	print("TEST: Spawn Marker Metadata")
	
	# Set spawn marker metadata
	get_tree().root.set_meta("spawn_marker", "TestMarker")
	
	# Verify it was set
	assert_true(get_tree().root.has_meta("spawn_marker"), "Metadata was set")
	assert_equal(get_tree().root.get_meta("spawn_marker"), "TestMarker", "Marker name correct")
	
	# Clean up
	get_tree().root.remove_meta("spawn_marker")
	
	pass_test("Spawn marker metadata works")

func test_spawn_position_metadata() -> void:
	print("TEST: Spawn Position Metadata")
	
	var test_pos = Vector2(100, 200)
	
	# Set spawn position metadata
	get_tree().root.set_meta("spawn_position", test_pos)
	
	# Verify it was set
	assert_true(get_tree().root.has_meta("spawn_position"), "Metadata was set")
	assert_equal(get_tree().root.get_meta("spawn_position"), test_pos, "Position correct")
	
	# Clean up
	get_tree().root.remove_meta("spawn_position")
	
	pass_test("Spawn position metadata works")

func test_map_controller_logic() -> void:
	print("TEST: Map Controller Logic")
	
	# Test that MapController script exists and can be loaded
	var map_controller_script = load("res://scripts/overworld/map_controller.gd")
	assert_true(map_controller_script != null, "MapController script loads")
	
	pass_test("Map controller can be loaded")

# Helper functions
func assert_true(condition: bool, message: String) -> void:
	if not condition:
		fail(message + " (expected true, got false)")

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
