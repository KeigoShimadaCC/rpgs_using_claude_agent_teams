extends CanvasLayer

# UI References
@onready var menu_container: Control = $MenuContainer
@onready var status_panel: Panel = $MenuContainer/StatusPanel
@onready var items_panel: Panel = $MenuContainer/ItemsPanel

# Status labels
@onready var name_label: Label = $MenuContainer/StatusPanel/VBoxContainer/NameLabel
@onready var level_label: Label = $MenuContainer/StatusPanel/VBoxContainer/LevelLabel
@onready var hp_label: Label = $MenuContainer/StatusPanel/VBoxContainer/HPLabel
@onready var mp_label: Label = $MenuContainer/StatusPanel/VBoxContainer/MPLabel
@onready var exp_label: Label = $MenuContainer/StatusPanel/VBoxContainer/EXPLabel
@onready var gold_label: Label = $MenuContainer/StatusPanel/VBoxContainer/GoldLabel
@onready var atk_label: Label = $MenuContainer/StatusPanel/VBoxContainer/ATKLabel
@onready var def_label: Label = $MenuContainer/StatusPanel/VBoxContainer/DEFLabel

# Items list
@onready var items_list: ItemList = $MenuContainer/ItemsPanel/VBoxContainer/ItemsList
@onready var use_button: Button = $MenuContainer/ItemsPanel/VBoxContainer/UseButton
@onready var item_description: Label = $MenuContainer/ItemsPanel/VBoxContainer/DescriptionLabel

# Buttons
@onready var resume_button: Button = $MenuContainer/ButtonsPanel/VBoxContainer/ResumeButton
@onready var status_button: Button = $MenuContainer/ButtonsPanel/VBoxContainer/StatusButton
@onready var items_button: Button = $MenuContainer/ButtonsPanel/VBoxContainer/ItemsButton
@onready var equipment_button: Button = $MenuContainer/ButtonsPanel/VBoxContainer/EquipmentButton
@onready var quit_button: Button = $MenuContainer/ButtonsPanel/VBoxContainer/QuitButton

# Equipment menu scene
const EQUIPMENT_MENU_SCENE = preload("res://scenes/ui/equipment_menu.tscn")

var is_paused: bool = false
var current_panel: String = "status"

func _ready() -> void:
	# Initially hide the menu
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # Continue processing when paused

	# Connect buttons (if they exist)
	_connect_buttons()

	# Connect to GameState signals
	_connect_game_state_signals()

func _connect_buttons() -> void:
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if status_button:
		status_button.pressed.connect(_on_status_pressed)
	if items_button:
		items_button.pressed.connect(_on_items_pressed)
	if equipment_button:
		equipment_button.pressed.connect(_on_equipment_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	if use_button:
		use_button.pressed.connect(_on_use_item_pressed)
	if items_list:
		items_list.item_selected.connect(_on_item_selected)

func _connect_game_state_signals() -> void:
	GameState.hp_changed.connect(_on_hp_changed)
	GameState.mp_changed.connect(_on_mp_changed)
	GameState.gold_changed.connect(_on_gold_changed)
	GameState.item_changed.connect(_on_item_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # Escape key
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	is_paused = not is_paused

	if is_paused:
		_open_menu()
	else:
		_close_menu()

func _open_menu() -> void:
	visible = true
	get_tree().paused = true
	_refresh_status()
	_refresh_items()
	_show_panel("status")

func _close_menu() -> void:
	visible = false
	get_tree().paused = false

func _show_panel(panel_name: String) -> void:
	current_panel = panel_name

	if status_panel:
		status_panel.visible = (panel_name == "status")
	if items_panel:
		items_panel.visible = (panel_name == "items")

func _refresh_status() -> void:
	if not status_panel:
		return

	# Update all status labels with GameState data
	if name_label:
		name_label.text = "Name: " + GameState.player_name
	if level_label:
		level_label.text = "Level: " + str(GameState.player_level)
	if hp_label:
		hp_label.text = "HP: %d / %d" % [GameState.player_hp, GameState.player_hp_max]
	if mp_label:
		mp_label.text = "MP: %d / %d" % [GameState.player_mp, GameState.player_mp_max]
	if exp_label:
		exp_label.text = "EXP: %d / %d" % [GameState.player_exp, GameState.player_exp_to_next]
	if gold_label:
		gold_label.text = "Gold: " + str(GameState.player_gold)
	if atk_label:
		var total_atk = GameState.get_total_atk()
		if total_atk != GameState.player_atk:
			atk_label.text = "ATK: %d (+%d)" % [total_atk, total_atk - GameState.player_atk]
		else:
			atk_label.text = "ATK: " + str(GameState.player_atk)
	if def_label:
		var total_def = GameState.get_total_def()
		if total_def != GameState.player_def:
			def_label.text = "DEF: %d (+%d)" % [total_def, total_def - GameState.player_def]
		else:
			def_label.text = "DEF: " + str(GameState.player_def)

func _refresh_items() -> void:
	if not items_list:
		return

	items_list.clear()

	# Add all items from inventory
	for item_id in GameState.inventory:
		var quantity = GameState.inventory[item_id]
		var item_data = GameState.load_item_data(item_id)
		var item_name = item_data.get("name", item_id)
		items_list.add_item("%s x%d" % [item_name, quantity])
		items_list.set_item_metadata(items_list.item_count - 1, item_id)

	if use_button:
		use_button.disabled = items_list.item_count == 0

	if item_description:
		item_description.text = "Select an item to see details."

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_status_pressed() -> void:
	_show_panel("status")
	_refresh_status()

func _on_items_pressed() -> void:
	_show_panel("items")
	_refresh_items()

func _on_equipment_pressed() -> void:
	# Open equipment menu as popup
	var equipment_menu = EQUIPMENT_MENU_SCENE.instantiate()
	add_child(equipment_menu)

func _on_quit_pressed() -> void:
	# Return to title screen
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/title_screen.tscn")

func _on_item_selected(index: int) -> void:
	if not items_list or index < 0:
		return

	var item_id = items_list.get_item_metadata(index)
	var item_data = GameState.load_item_data(item_id)

	if item_description and item_data.has("description"):
		item_description.text = item_data.description

	if use_button:
		use_button.disabled = false

func _on_use_item_pressed() -> void:
	if not items_list:
		return

	var selected_items = items_list.get_selected_items()
	if selected_items.is_empty():
		return

	var index = selected_items[0]
	var item_id = items_list.get_item_metadata(index)

	# Use the item
	var success = GameState.use_item(item_id)

	if success:
		print("Used item: ", item_id)
		_refresh_items()
		_refresh_status()
	else:
		print("Failed to use item: ", item_id)
		if item_description:
			item_description.text = "Cannot use this item right now."

func _on_hp_changed(_current: int, _maximum: int) -> void:
	if visible and current_panel == "status":
		_refresh_status()

func _on_mp_changed(_current: int, _maximum: int) -> void:
	if visible and current_panel == "status":
		_refresh_status()

func _on_gold_changed(_new_amount: int) -> void:
	if visible and current_panel == "status":
		_refresh_status()

func _on_item_changed(_item_id: String, _new_quantity: int) -> void:
	if visible and current_panel == "items":
		_refresh_items()
