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
var player_agi: int = 5
var player_gold: int = 50

# Player name
var player_name: String = "Hero"

# Equipment slots
var equipped_weapon: String = ""
var equipped_armor: String = ""
var equipped_accessory: String = ""

# Equipment data cache
var equipment_data: Dictionary = {}

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

# Quest System
var active_quests: Dictionary = {} # quest_id -> { "objectives": [current_counts] }
var completed_quests: Array = []
var quests_data: Dictionary = {}

# Shop System
var shops_data: Dictionary = {}

# Battle settings
var auto_battle_enabled: bool = false

# Encounter system
var steps_since_battle: int = 999  # Start high to allow first encounter
var grace_period_steps: int = 5

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
const AGI_BASE: int = 5
const AGI_GROWTH: int = 2

# Signals
signal exp_gained(amount: int)
signal level_up(new_level: int)
signal gold_changed(new_amount: int)
signal item_changed(item_id: String, new_quantity: int)
signal hp_changed(current: int, maximum: int)
signal mp_changed(current: int, maximum: int)
signal flag_changed(flag_name: String, value: bool)

func _ready() -> void:
	# Load equipment data on startup
	load_equipment_data()
	load_quests_data()
	load_shops_data()

# Experience and Leveling
func add_exp(amount: int) -> void:
	player_exp += amount
	exp_gained.emit(amount)

	# Check for level up
	while player_exp >= player_exp_to_next:
		_apply_level_up()

func _apply_level_up() -> void:
	player_level += 1
	player_exp -= player_exp_to_next

	# Recalculate stats
	player_hp_max = HP_BASE + (player_level * HP_GROWTH)
	player_mp_max = MP_BASE + (player_level * MP_GROWTH)
	player_atk = ATK_BASE + (player_level * ATK_GROWTH)
	player_def = DEF_BASE + (player_level * DEF_GROWTH)
	player_agi = AGI_BASE + (player_level * AGI_GROWTH)

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
	player_agi = 5
	player_gold = 50

	equipped_weapon = ""
	equipped_armor = ""
	equipped_accessory = ""

	inventory = {
		"healing_potion": 3
	}

	quest_flags = {}

	hp_changed.emit(player_hp, player_hp_max)
	mp_changed.emit(player_mp, player_mp_max)
	gold_changed.emit(player_gold)

# Equipment System Functions

## Load equipment data from JSON file
func load_equipment_data() -> void:
	var file_path = "res://data/equipment.json"
	if not FileAccess.file_exists(file_path):
		print("Equipment data file not found: ", file_path)
		return

	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Failed to parse equipment.json")
		return

	equipment_data = json.get_data()

## Get equipment by ID
func get_equipment(equipment_id: String) -> Dictionary:
	if equipment_data.is_empty():
		load_equipment_data()

	# Search in weapons
	if equipment_data.has("weapons"):
		for weapon in equipment_data.weapons:
			if weapon.id == equipment_id:
				return weapon

	# Search in armor
	if equipment_data.has("armor"):
		for armor_piece in equipment_data.armor:
			if armor_piece.id == equipment_id:
				return armor_piece

	# Search in accessories
	if equipment_data.has("accessories"):
		for accessory in equipment_data.accessories:
			if accessory.id == equipment_id:
				return accessory

	return {}

## Equip an item to the appropriate slot
func equip_item(equipment_id: String) -> bool:
	var equipment = get_equipment(equipment_id)
	if equipment.is_empty():
		return false

	# Determine equipment type and equip to correct slot
	if equipment_data.has("weapons"):
		for weapon in equipment_data.weapons:
			if weapon.id == equipment_id:
				equipped_weapon = equipment_id
				return true

	if equipment_data.has("armor"):
		for armor_piece in equipment_data.armor:
			if armor_piece.id == equipment_id:
				equipped_armor = equipment_id
				return true

	if equipment_data.has("accessories"):
		for accessory in equipment_data.accessories:
			if accessory.id == equipment_id:
				equipped_accessory = equipment_id
				return true

	return false

## Unequip item from a slot
func unequip_slot(slot: String) -> void:
	match slot:
		"weapon":
			equipped_weapon = ""
		"armor":
			equipped_armor = ""
		"accessory":
			equipped_accessory = ""

## Get total ATK including equipment bonuses
func get_total_atk() -> int:
	var total = player_atk

	# Add weapon bonus
	if equipped_weapon != "":
		var weapon = get_equipment(equipped_weapon)
		total += weapon.get("atk_bonus", 0)

	# Add armor bonus (some armor may have ATK)
	if equipped_armor != "":
		var armor = get_equipment(equipped_armor)
		total += armor.get("atk_bonus", 0)

	# Add accessory bonus
	if equipped_accessory != "":
		var accessory = get_equipment(equipped_accessory)
		total += accessory.get("atk_bonus", 0)

	return total

## Get total DEF including equipment bonuses
func get_total_def() -> int:
	var total = player_def

	# Add weapon bonus (some weapons may have DEF)
	if equipped_weapon != "":
		var weapon = get_equipment(equipped_weapon)
		total += weapon.get("def_bonus", 0)

	# Add armor bonus
	if equipped_armor != "":
		var armor = get_equipment(equipped_armor)
		total += armor.get("def_bonus", 0)

	# Add accessory bonus
	if equipped_accessory != "":
		var accessory = get_equipment(equipped_accessory)
		total += accessory.get("def_bonus", 0)

	return total

## Get total AGI including equipment bonuses
func get_total_agi() -> int:
	var total = player_agi

	# Add weapon bonus
	if equipped_weapon != "":
		var weapon = get_equipment(equipped_weapon)
		total += weapon.get("agi_bonus", 0)

	# Add armor bonus
	if equipped_armor != "":
		var armor = get_equipment(equipped_armor)
		total += armor.get("agi_bonus", 0)

	# Add accessory bonus
	if equipped_accessory != "":
		var accessory = get_equipment(equipped_accessory)
		total += accessory.get("agi_bonus", 0)

	return total

## Get total HP max including equipment bonuses
func get_total_hp_max() -> int:
	var total = player_hp_max

	# Add weapon bonus
	if equipped_weapon != "":
		var weapon = get_equipment(equipped_weapon)
		total += weapon.get("hp_bonus", 0)

	# Add armor bonus
	if equipped_armor != "":
		var armor = get_equipment(equipped_armor)
		total += armor.get("hp_bonus", 0)

	# Add accessory bonus
	if equipped_accessory != "":
		var accessory = get_equipment(equipped_accessory)
		total += accessory.get("hp_bonus", 0)

	return total

## Get total MP max including equipment bonuses
func get_total_mp_max() -> int:
	var total = player_mp_max

	# Add weapon bonus
	if equipped_weapon != "":
		var weapon = get_equipment(equipped_weapon)
		total += weapon.get("mp_bonus", 0)

	# Add armor bonus
	if equipped_armor != "":
		var armor = get_equipment(equipped_armor)
		total += armor.get("mp_bonus", 0)

	# Add accessory bonus
	if equipped_accessory != "":
		var accessory = get_equipment(equipped_accessory)
		total += accessory.get("mp_bonus", 0)

	return total

## Check if equipment has special effect
func has_equipment_effect(effect_name: String) -> bool:
	# Check weapon
	if equipped_weapon != "":
		var weapon = get_equipment(equipped_weapon)
		if weapon.get("special", "") == effect_name:
			return true

	# Check armor
	if equipped_armor != "":
		var armor = get_equipment(equipped_armor)
		if armor.get("special", "") == effect_name:
			return true

	# Check accessory
	if equipped_accessory != "":
		var accessory = get_equipment(equipped_accessory)
		if accessory.get("special", "") == effect_name:
			return true

	return false

## Get equipment special effect value (e.g., regen_amount)
func get_equipment_effect_value(effect_name: String, value_key: String) -> int:
	var total = 0

	# Check weapon
	if equipped_weapon != "":
		var weapon = get_equipment(equipped_weapon)
		if weapon.get("special", "") == effect_name:
			total += weapon.get(value_key, 0)

	# Check armor
	if equipped_armor != "":
		var armor = get_equipment(equipped_armor)
		if armor.get("special", "") == effect_name:
			total += armor.get(value_key, 0)

	# Check accessory
	if equipped_accessory != "":
		var accessory = get_equipment(equipped_accessory)
		if accessory.get("special", "") == effect_name:
			total += accessory.get(value_key, 0)

	return total

# --- Quest System Logic ---

func load_quests_data() -> void:
	var path = "res://data/quests.json"
	if not FileAccess.file_exists(path):
		print("DEBUG: Quests data file not found: " + path)
		return
		
	var file = FileAccess.open(path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data = json.get_data()
		if data.has("quests"):
			for quest in data.quests:
				quests_data[quest.id] = quest
		print("DEBUG: Loaded " + str(quests_data.size()) + " quests")
	else:
		push_error("Failed to parse quests.json: " + json.get_error_message())

func get_quest_data(quest_id: String) -> Dictionary:
	if quests_data.is_empty():
		load_quests_data()
	return quests_data.get(quest_id, {})

func is_quest_active(quest_id: String) -> bool:
	return active_quests.has(quest_id)

func is_quest_completed(quest_id: String) -> bool:
	return quest_id in completed_quests

func accept_quest(quest_id: String) -> bool:
	if is_quest_active(quest_id) or is_quest_completed(quest_id):
		return false
	
	var data = get_quest_data(quest_id)
	if data.is_empty():
		push_error("Cannot accept unknown quest: " + quest_id)
		return false
		
	# Initialize objective tracking
	var objective_progress = []
	for obj in data.objectives:
		objective_progress.append(0)
		
	active_quests[quest_id] = {
		"objectives": objective_progress
	}
	print("Quest accepted: " + data.title)
	return true

func update_quest_progress(type: String, target: String, amount: int = 1) -> void:
	# Check all active quests for matching objectives
	for quest_id in active_quests.keys():
		var data = get_quest_data(quest_id)
		var progress = active_quests[quest_id].objectives
		var updated = false
		
		for i in range(data.objectives.size()):
			var obj = data.objectives[i]
			if obj.type == type and obj.target == target:
				# Don't update if already complete
				if progress[i] < obj.count:
					progress[i] = min(progress[i] + amount, obj.count)
					updated = true
					print("Quest update [" + data.title + "]: " + obj.description + " (" + str(progress[i]) + "/" + str(obj.count) + ")")
		
		if updated:
			check_quest_completion(quest_id)

func check_quest_completion(quest_id: String) -> void:
	if not is_quest_active(quest_id):
		return
		
	var data = get_quest_data(quest_id)
	var progress = active_quests[quest_id].objectives
	var all_complete = true
	
	for i in range(data.objectives.size()):
		if progress[i] < data.objectives[i].count:
			all_complete = false
			break
			
	if all_complete:
		print("Quest objectives complete: " + data.title)

func complete_quest(quest_id: String) -> bool:
	if not is_quest_active(quest_id):
		return false
		
	var data = get_quest_data(quest_id)
	
	# Verify objectives are met
	var progress = active_quests[quest_id].objectives
	for i in range(data.objectives.size()):
		if progress[i] < data.objectives[i].count:
			print("DEBUG: Quest " + quest_id + " not yet complete")
			return false
			
	# Apply Rewards
	add_gold(data.rewards.get("gold", 0))
	add_exp(data.rewards.get("exp", 0)) # Fixed to add_exp instead of add_experience
	
	if data.rewards.has("items"):
		for item in data.rewards.items:
			add_item(item.id, item.count)
			
	# Set flags
	if data.has("completed_flag"):
		set_flag(data.completed_flag, true)
		
	# Move to completed
	active_quests.erase(quest_id)
	completed_quests.append(quest_id)
	
	print("Quest Completed: " + data.title)
	return true

func can_turn_in_quest(quest_id: String) -> bool:
	if not is_quest_active(quest_id):
		return false
		
	var data = get_quest_data(quest_id)
	var progress = active_quests[quest_id].objectives
	
	for i in range(data.objectives.size()):
		if progress[i] < data.objectives[i].count:
			return false
			
	return true

# --- Shop System Logic ---

func load_shops_data() -> void:
	var path = "res://data/shops.json"
	if not FileAccess.file_exists(path):
		print("DEBUG: Shops data file not found: " + path)
		return
		
	var file = FileAccess.open(path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data = json.get_data()
		if data.has("shops"):
			for shop in data.shops:
				shops_data[shop.id] = shop
		print("DEBUG: Loaded " + str(shops_data.size()) + " shops")
	else:
		push_error("Failed to parse shops.json: " + json.get_error_message())

func get_shop_data(shop_id: String) -> Dictionary:
	if shops_data.is_empty():
		load_shops_data()
	return shops_data.get(shop_id, {})

func buy_item(item_id: String, price: int) -> bool:
	if player_gold >= price:
		player_gold -= price
		add_item(item_id, 1)
		gold_changed.emit(player_gold)
		print("Bought " + item_id + " for " + str(price) + "g")
		return true
	else:
		print("Not enough gold to buy " + item_id)
		return false

func sell_item(item_id: String, price: int) -> bool:
	if use_item(item_id): # use_item removes 1 quantity
		player_gold += price
		gold_changed.emit(player_gold)
		print("Sold " + item_id + " for " + str(price) + "g")
		return true
	else:
		print("No " + item_id + " to sell")
		return false
