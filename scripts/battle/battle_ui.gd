extends CanvasLayer

## BattleUI
## Handles battle user interface (HP/MP bars, action menus, battle log)

# UI Node references
@onready var player_hp_bar: ProgressBar = $UI/PlayerStats/VBox/HPBar
@onready var player_mp_bar: ProgressBar = $UI/PlayerStats/VBox/MPBar
@onready var player_hp_label: Label = $UI/PlayerStats/VBox/HPLabel
@onready var player_mp_label: Label = $UI/PlayerStats/VBox/MPLabel
@onready var player_level_label: Label = $UI/PlayerStats/VBox/LevelLabel

@onready var action_menu: VBoxContainer = $UI/ActionMenu
@onready var skill_menu: VBoxContainer = $UI/SkillMenu
@onready var item_menu: VBoxContainer = $UI/ItemMenu
@onready var target_select: VBoxContainer = $UI/TargetSelect

@onready var battle_log: RichTextLabel = $UI/BattleLog
@onready var turn_indicator: Label = $UI/TurnIndicator

# Menu buttons
var action_buttons: Array = []
var skill_buttons: Array = []
var item_buttons: Array = []
var target_buttons: Array = []

# Current menu state
var current_menu: String = "action"  # "action", "skill", "item", "target"
var selected_skill: String = ""
var selected_item: String = ""
var pending_action: Dictionary = {}

# Reference to battle system
var battle_system = null

func _ready() -> void:
	# Create action menu buttons
	create_action_menu()

	# Connect to GameState signals for HP/MP updates
	GameState.hp_changed.connect(_on_hp_changed)
	GameState.mp_changed.connect(_on_mp_changed)

	# Initial update
	update_player_stats()

	# Hide submenus initially
	if skill_menu:
		skill_menu.visible = false
	if item_menu:
		item_menu.visible = false
	if target_select:
		target_select.visible = false

## Create action menu buttons
func create_action_menu() -> void:
	if not action_menu:
		return

	# Clear existing buttons
	for child in action_menu.get_children():
		child.queue_free()
	action_buttons.clear()

	var actions = ["Attack", "Defend", "Skill", "Item", "Run"]
	for action_name in actions:
		var button = Button.new()
		button.text = action_name
		button.pressed.connect(_on_action_button_pressed.bind(action_name))
		action_menu.add_child(button)
		action_buttons.append(button)

## Handle action button press
func _on_action_button_pressed(action_name: String) -> void:
	match action_name:
		"Attack":
			# Select target
			show_target_select("attack")
		"Defend":
			send_action({"type": "defend"})
		"Skill":
			show_skill_menu()
		"Item":
			show_item_menu()
		"Run":
			send_action({"type": "run"})

## Show skill menu
func show_skill_menu() -> void:
	if not skill_menu:
		return

	current_menu = "skill"
	action_menu.visible = false
	skill_menu.visible = true

	# Clear existing buttons
	for child in skill_menu.get_children():
		child.queue_free()
	skill_buttons.clear()

	# Get player skills
	var player_skills = battle_system.get_player_skills() if battle_system else []

	for skill_id in player_skills:
		var skill_data = battle_system.skills_data.get(skill_id) if battle_system else null
		if skill_data:
			var button = Button.new()
			button.text = skill_data.name + " (MP: " + str(skill_data.mp_cost) + ")"
			button.pressed.connect(_on_skill_button_pressed.bind(skill_id))

			# Disable if not enough MP
			if GameState.player_mp < skill_data.mp_cost:
				button.disabled = true

			skill_menu.add_child(button)
			skill_buttons.append(button)

	# Add back button
	var back_btn = Button.new()
	back_btn.text = "Back"
	back_btn.pressed.connect(_on_back_to_action_menu)
	skill_menu.add_child(back_btn)

## Handle skill button press
func _on_skill_button_pressed(skill_id: String) -> void:
	selected_skill = skill_id

	var skill_data = battle_system.skills_data.get(skill_id) if battle_system else null
	if not skill_data:
		return

	# Check target type
	if skill_data.target_type == "self":
		# Self-target, execute immediately
		send_action({"type": "skill", "skill_id": skill_id})
	else:
		# Need to select enemy target
		show_target_select("skill")

## Show item menu
func show_item_menu() -> void:
	if not item_menu:
		return

	current_menu = "item"
	action_menu.visible = false
	item_menu.visible = true

	# Clear existing buttons
	for child in item_menu.get_children():
		child.queue_free()
	item_buttons.clear()

	# Get inventory items
	for item_id in GameState.inventory.keys():
		var count = GameState.inventory[item_id]
		if count > 0:
			var item_data = GameState.load_item_data(item_id)
			if not item_data.is_empty():
				var button = Button.new()
				button.text = item_data.name + " x" + str(count)
				button.pressed.connect(_on_item_button_pressed.bind(item_id))
				item_menu.add_child(button)
				item_buttons.append(button)

	# Add back button
	var back_btn = Button.new()
	back_btn.text = "Back"
	back_btn.pressed.connect(_on_back_to_action_menu)
	item_menu.add_child(back_btn)

## Handle item button press
func _on_item_button_pressed(item_id: String) -> void:
	send_action({"type": "item", "item_id": item_id})

## Show target selection
func show_target_select(action_type: String) -> void:
	if not target_select or not battle_system:
		return

	current_menu = "target"
	action_menu.visible = false
	skill_menu.visible = false
	target_select.visible = true

	# Clear existing buttons
	for child in target_select.get_children():
		child.queue_free()
	target_buttons.clear()

	# Get alive enemies
	var enemies = battle_system.get_alive_enemies()
	for i in range(enemies.size()):
		var enemy = enemies[i]
		var button = Button.new()
		button.text = enemy.enemy_name + " (" + str(enemy.current_hp) + "/" + str(enemy.max_hp) + " HP)"
		
		# Find the original index of this enemy in the battle_system.enemies array
		var original_index = battle_system.enemies.find(enemy)
		
		button.pressed.connect(_on_target_button_pressed.bind(original_index, action_type))
		target_select.add_child(button)
		target_buttons.append(button)

	# Add back button
	var back_btn = Button.new()
	back_btn.text = "Back"
	back_btn.pressed.connect(_on_back_to_action_menu)
	target_select.add_child(back_btn)

## Handle target button press
func _on_target_button_pressed(target_index: int, action_type: String) -> void:
	if action_type == "attack":
		send_action({"type": "attack", "target_index": target_index})
	elif action_type == "skill":
		send_action({"type": "skill", "skill_id": selected_skill, "target_index": target_index})

## Back to action menu
func _on_back_to_action_menu() -> void:
	current_menu = "action"
	action_menu.visible = true
	skill_menu.visible = false
	item_menu.visible = false
	target_select.visible = false

## Send action to battle system
func send_action(action: Dictionary) -> void:
	if battle_system:
		battle_system.execute_player_action(action)

	# Hide all menus during action processing
	enable_action_menu(false)

## Enable/disable action menu
func enable_action_menu(enabled: bool) -> void:
	if enabled:
		_on_back_to_action_menu()
		action_menu.visible = true
	else:
		action_menu.visible = false
		skill_menu.visible = false
		item_menu.visible = false
		target_select.visible = false

## Update player stat displays
func update_player_stats() -> void:
	if player_hp_bar:
		player_hp_bar.max_value = GameState.player_hp_max
		player_hp_bar.value = GameState.player_hp

	if player_mp_bar:
		player_mp_bar.max_value = GameState.player_mp_max
		player_mp_bar.value = GameState.player_mp

	if player_hp_label:
		player_hp_label.text = "HP: " + str(GameState.player_hp) + "/" + str(GameState.player_hp_max)

	if player_mp_label:
		player_mp_label.text = "MP: " + str(GameState.player_mp) + "/" + str(GameState.player_mp_max)

	if player_level_label:
		player_level_label.text = "Lv " + str(GameState.player_level)

## HP changed handler
func _on_hp_changed(current: int, maximum: int) -> void:
	update_player_stats()

## MP changed handler
func _on_mp_changed(current: int, maximum: int) -> void:
	update_player_stats()

## Add message to battle log
func add_battle_log(message: String) -> void:
	if battle_log:
		battle_log.add_text(message + "\n")
		# Auto-scroll to bottom
		battle_log.scroll_to_line(battle_log.get_line_count())

## Show damage number with animation
func show_damage_number(damage: int, position: Vector2, is_critical: bool) -> void:
	# Create floating damage label
	var damage_label = Label.new()
	damage_label.text = str(damage)
	damage_label.position = position
	damage_label.z_index = 100

	if is_critical:
		damage_label.add_theme_color_override("font_color", Color.ORANGE_RED)
		damage_label.text += "!"
	else:
		damage_label.add_theme_color_override("font_color", Color.WHITE)

	add_child(damage_label)

	# Animate upward and fade
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(damage_label, "position:y", position.y - 50, 1.0)
	tween.tween_property(damage_label, "modulate:a", 0.0, 1.0)
	await tween.finished
	damage_label.queue_free()

## Update turn indicator
func set_turn_indicator(is_player_turn: bool) -> void:
	if turn_indicator:
		if is_player_turn:
			turn_indicator.text = "YOUR TURN"
			turn_indicator.add_theme_color_override("font_color", Color.GREEN)
		else:
			turn_indicator.text = "ENEMY TURN"
			turn_indicator.add_theme_color_override("font_color", Color.RED)
