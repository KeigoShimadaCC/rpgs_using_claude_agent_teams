extends Node2D

## Map Controller
## Handles player spawn position when entering a map

@export var default_spawn_marker: String = "PlayerSpawn"

func _ready() -> void:
	# Check for spawn metadata set by transition trigger
	var spawn_marker_name = get_tree().root.get_meta("spawn_marker", "")
	var spawn_position = get_tree().root.get_meta("spawn_position", Vector2.ZERO)

	# Clear metadata
	get_tree().root.remove_meta("spawn_marker")
	get_tree().root.remove_meta("spawn_position")

	# Find player
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("MapController: No player found in scene!")
		return

	# Set player position based on spawn marker or position
	if spawn_marker_name != "":
		var spawn_marker = find_child(spawn_marker_name, true, false)
		if spawn_marker and spawn_marker is Node2D:
			player.global_position = spawn_marker.global_position
			print("MapController: Spawned player at marker: ", spawn_marker_name)
		else:
			print("MapController: Spawn marker not found: ", spawn_marker_name)
			_use_default_spawn(player)
	elif spawn_position != Vector2.ZERO:
		player.global_position = spawn_position
		print("MapController: Spawned player at position: ", spawn_position)
	else:
		_use_default_spawn(player)

func _use_default_spawn(player: Node2D) -> void:
	var default_marker = find_child(default_spawn_marker, true, false)
	if default_marker and default_marker is Node2D:
		player.global_position = default_marker.global_position
		print("MapController: Using default spawn marker: ", default_spawn_marker)
