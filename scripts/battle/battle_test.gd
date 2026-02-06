extends Control

@onready var status_label = $VBoxContainer/StatusLabel

func _ready() -> void:
	update_status()

func update_status() -> void:
	status_label.text = "Lv %d | HP: %d/%d | MP: %d/%d | Gold: %d" % [
		GameState.player_level,
		GameState.player_hp,
		GameState.player_hp_max,
		GameState.player_mp,
		GameState.player_mp_max,
		GameState.player_gold
	]

func _on_slime_button_pressed() -> void:
	start_battle(["slime"])

func _on_goblin_button_pressed() -> void:
	start_battle(["goblin"])

func _on_multi_button_pressed() -> void:
	start_battle(["slime", "goblin"])

func _on_wolf_button_pressed() -> void:
	start_battle(["shadow_wolf"])

func _on_boss_button_pressed() -> void:
	start_battle(["archivist_shade"], true)

func start_battle(enemy_ids: Array, is_boss: bool = false) -> void:
	BattleManager.start_battle(
		enemy_ids,
		_on_victory,
		_on_defeat,
		is_boss
	)

func _on_victory(exp: int, gold: int) -> void:
	print("Victory! Gained ", exp, " EXP and ", gold, " gold")
	# Scene will automatically return here
	update_status()

func _on_defeat() -> void:
	print("Defeat!")
	# Reset player and return
	GameState.reset_player()
	update_status()
