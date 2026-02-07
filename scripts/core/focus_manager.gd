extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("FocusManager initialized.")

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			print("Window lost focus. Pausing game...")
			# Optional: Automatically pause the game
			# get_tree().paused = true
			
			# Or just limit CPU usage if pause is not desired
			# OS.low_processor_usage_mode = true
			
		NOTIFICATION_APPLICATION_FOCUS_IN:
			print("Window gained focus. Resuming game...")
			# get_tree().paused = false
			# OS.low_processor_usage_mode = false
