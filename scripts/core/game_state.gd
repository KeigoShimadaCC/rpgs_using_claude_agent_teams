extends Node

# Player Stats
var player_hp: int = 100
var player_hp_max: int = 100
var player_mp: int = 30
var player_mp_max: int = 30
var player_level: int = 1
var player_exp: int = 0
var player_exp_to_next: int = 100
var player_atk: int = 10
var player_def: int = 5
var player_gold: int = 50

# Player name
var player_name: String = "Hero"

# Inventory (item_id: quantity)
var inventory: Dictionary = {
	"healing_potion": 3
}

# Quest flags (flag_name: bool)
var quest_flags: Dictionary = {
	# Example flags (set by game events):
	# "talked_to_elder": false,
	# "accepted_quest": false,
	# "has_elder_pass": false,
	# "defeated_boss": false
}

# Level-up constants
const EXP_BASE: int = 100
const EXP_GROWTH: float = 1.5
const HP_BASE: int = 100
const HP_GROWTH: int = 15
const MP_BASE: int = 30
const MP_GROWTH: int = 5
const ATK_BASE: int = 10
const ATK_GROWTH: int = 3
const DEF_BASE: int = 5
const DEF_GROWTH: int = 2

# Signals
signal exp_gained(amount: int)
signal level_up(new_level: int)
signal gold_changed(new_amount: int)
signal item_changed(item_id: String, new_quantity: int)
signal hp_changed(current: int, maximum: int)
signal mp_changed(current: int, maximum: int)
signal flag_changed(flag_name: String, value: bool)

func _ready() -> void:
	# Initialize any startup state
	pass

# Experience and Leveling
func add_exp(amount: int) -> void:
	player_exp += amount
	exp_gained.emit(amount)

	# Check for level up
	while player_exp >= player_exp_to_next:
		level_up()

func level_up() -> void:
	player_level += 1
	player_exp -= player_exp_to_next

	# Recalculate stats
	player_hp_max = HP_BASE + (player_level * HP_GROWTH)
	player_mp_max = MP_BASE + (player_level * MP_GROWTH)
	player_atk = ATK_BASE + (player_level * ATK_GROWTH)
	player_def = DEF_BASE + (player_level * DEF_GROWTH)

	# Fully heal on level up
	player_hp = player_hp_max
	player_mp = player_mp_max

	# Calculate next level EXP requirement
	player_exp_to_next = int(EXP_BASE * pow(player_level, EXP_GROWTH))

	level_up.emit(player_level)
	hp_changed.emit(player_hp, player_hp_max)
	mp_changed.emit(player_mp, player_mp_max)

# Gold Management
func add_gold(amount: int) -> void:
	player_gold += amount
	gold_changed.emit(player_gold)

func remove_gold(amount: int) -> bool:
	if player_gold >= amount:
		player_gold -= amount
		gold_changed.emit(player_gold)
		return true
	return false

# Inventory Management
func add_item(item_id: String, quantity: int = 1) -> void:
	if inventory.has(item_id):
		inventory[item_id] += quantity
	else:
		inventory[item_id] = quantity
	item_changed.emit(item_id, inventory[item_id])

func remove_item(item_id: String, quantity: int = 1) -> bool:
	if inventory.has(item_id) and inventory[item_id] >= quantity:
		inventory[item_id] -= quantity
		if inventory[item_id] <= 0:
			inventory.erase(item_id)
		item_changed.emit(item_id, inventory.get(item_id, 0))
		return true
	return false

func has_item(item_id: String, quantity: int = 1) -> bool:
	return inventory.get(item_id, 0) >= quantity

func get_item_count(item_id: String) -> int:
	return inventory.get(item_id, 0)

# Use item (healing potion, etc.)
func use_item(item_id: String) -> bool:
	if not has_item(item_id):
		return false

	# Load item data to determine effect
	var item_data = load_item_data(item_id)
	if item_data == null:
		return false

	# Apply item effect
	match item_data.effect:
		"heal":
			heal_player(item_data.power)
		"restore_mp":
			restore_mp(item_data.power)
		_:
			print("Unknown item effect: ", item_data.effect)
			return false

	# Consume item
	remove_item(item_id)
	return true

# HP/MP Management
func heal_player(amount: int) -> void:
	player_hp = min(player_hp + amount, player_hp_max)
	hp_changed.emit(player_hp, player_hp_max)

func damage_player(amount: int) -> void:
	player_hp = max(player_hp - amount, 0)
	hp_changed.emit(player_hp, player_hp_max)

func restore_mp(amount: int) -> void:
	player_mp = min(player_mp + amount, player_mp_max)
	mp_changed.emit(player_mp, player_mp_max)

func consume_mp(amount: int) -> bool:
	if player_mp >= amount:
		player_mp -= amount
		mp_changed.emit(player_mp, player_mp_max)
		return true
	return false

func is_alive() -> bool:
	return player_hp > 0

# Quest Flag Management
func set_flag(flag_name: String, value: bool) -> void:
	quest_flags[flag_name] = value
	flag_changed.emit(flag_name, value)

func has_flag(flag_name: String) -> bool:
	return quest_flags.get(flag_name, false)

func get_flag(flag_name: String, default: bool = false) -> bool:
	return quest_flags.get(flag_name, default)

# Data Loading Helpers
func load_item_data(item_id: String) -> Dictionary:
	var file_path = "res://data/items.json"
	if not FileAccess.file_exists(file_path):
		print("Items data file not found: ", file_path)
		return {}

	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Failed to parse items.json")
		return {}

	var data = json.get_data()
	if data.has("items"):
		for item in data.items:
			if item.id == item_id:
				return item

	return {}

# Reset player state (for new game)
func reset_player() -> void:
	player_hp = 100
	player_hp_max = 100
	player_mp = 30
	player_mp_max = 30
	player_level = 1
	player_exp = 0
	player_exp_to_next = 100
	player_atk = 10
	player_def = 5
	player_gold = 50

	inventory = {
		"healing_potion": 3
	}

	quest_flags = {}

	hp_changed.emit(player_hp, player_hp_max)
	mp_changed.emit(player_mp, player_mp_max)
	gold_changed.emit(player_gold)
