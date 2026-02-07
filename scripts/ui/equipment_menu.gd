extends Control

## Equipment Menu UI
## Allows player to view and equip items

@onready var weapon_label: Label = $VBoxContainer/WeaponSlot/WeaponLabel
@onready var armor_label: Label = $VBoxContainer/ArmorSlot/ArmorLabel
@onready var accessory_label: Label = $VBoxContainer/AccessorySlot/AccessoryLabel
@onready var stats_label: Label = $VBoxContainer/StatsPanel/StatsLabel

func _ready() -> void:
	refresh_display()

## Refresh equipment display
func refresh_display() -> void:
	# Update equipment slots
	weapon_label.text = get_equipment_display_name(GameState.equipped_weapon, "weapon")
	armor_label.text = get_equipment_display_name(GameState.equipped_armor, "armor")
	accessory_label.text = get_equipment_display_name(GameState.equipped_accessory, "accessory")

	# Update stats display
	update_stats_display()

## Get display name for equipped item
func get_equipment_display_name(equipment_id: String, slot_type: String) -> String:
	if equipment_id == "":
		return "(Empty)"

	var equipment = GameState.get_equipment(equipment_id)
	if equipment.is_empty():
		return "(Empty)"

	return equipment.name

## Update stats display with equipment bonuses
func update_stats_display() -> void:
	var base_atk = GameState.player_atk
	var total_atk = GameState.get_total_atk()
	var base_def = GameState.player_def
	var total_def = GameState.get_total_def()
	var base_hp = GameState.player_hp_max
	var total_hp = GameState.get_total_hp_max()
	var base_mp = GameState.player_mp_max
	var total_mp = GameState.get_total_mp_max()

	var stats_text = ""
	stats_text += "ATK: %d" % base_atk
	if total_atk != base_atk:
		stats_text += " → %d (+%d)" % [total_atk, total_atk - base_atk]
	stats_text += "\n"

	stats_text += "DEF: %d" % base_def
	if total_def != base_def:
		stats_text += " → %d (+%d)" % [total_def, total_def - base_def]
	stats_text += "\n"

	stats_text += "HP Max: %d" % base_hp
	if total_hp != base_hp:
		stats_text += " → %d (+%d)" % [total_hp, total_hp - base_hp]
	stats_text += "\n"

	stats_text += "MP Max: %d" % base_mp
	if total_mp != base_mp:
		stats_text += " → %d (+%d)" % [total_mp, total_mp - base_mp]

	stats_label.text = stats_text

## Close equipment menu
func _on_close_button_pressed() -> void:
	queue_free()
