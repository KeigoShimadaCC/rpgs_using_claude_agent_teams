@tool
extends SceneTree

func _init():
	print("Resaving scenes to fix UIDs...")
	var scenes = [
		"res://scenes/overworld/map_a_village.tscn",
		"res://scenes/overworld/map_b_field.tscn", 
		"res://scenes/overworld/player.tscn",
		"res://scenes/overworld/npc.tscn"
	]
	
	for path in scenes:
		var scene = load(path)
		if scene:
			var pack_result = ResourceSaver.save(scene, path)
			if pack_result == OK:
				print("Resaved: ", path)
			else:
				print("Failed to save: ", path)
		else:
			print("Failed to load: ", path)
	
	print("Done.")
	quit()
