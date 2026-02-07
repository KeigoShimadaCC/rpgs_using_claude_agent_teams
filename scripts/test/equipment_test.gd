extends Node

## Equipment System Test Script
## Tests equipment loading, equipping, and stat calculations

func _ready() -> void:
	print("=== Equipment System Test ===\n")

	# Test 1: Load equipment data
	print("Test 1: Loading equipment data...")
	GameState.load_equipment_data()
	if not GameState.equipment_data.is_empty():
		print("✓ Equipment data loaded successfully")
		print("  - Weapons: ", GameState.equipment_data.get("weapons", []).size())
		print("  - Armor: ", GameState.equipment_data.get("armor", []).size())
		print("  - Accessories: ", GameState.equipment_data.get("accessories", []).size())
	else:
		print("✗ Failed to load equipment data")
	print()

	# Test 2: Get equipment by ID
	print("Test 2: Getting equipment by ID...")
	var iron_sword = GameState.get_equipment("iron_sword")
	if not iron_sword.is_empty():
		print("✓ Found Iron Sword")
		print("  - Name: ", iron_sword.name)
		print("  - ATK Bonus: ", iron_sword.atk_bonus)
	else:
		print("✗ Failed to get Iron Sword")
	print()

	# Test 3: Base stats (no equipment)
	print("Test 3: Base stats (no equipment)...")
	print("  - Base ATK: ", GameState.player_atk)
	print("  - Total ATK: ", GameState.get_total_atk())
	print("  - Base DEF: ", GameState.player_def)
	print("  - Total DEF: ", GameState.get_total_def())
	if GameState.get_total_atk() == GameState.player_atk:
		print("✓ Total stats match base stats (no equipment)")
	else:
		print("✗ Total stats don't match base stats")
	print()

	# Test 4: Equip weapon
	print("Test 4: Equipping Iron Sword...")
	var equip_result = GameState.equip_item("iron_sword")
	if equip_result:
		print("✓ Iron Sword equipped")
		print("  - Equipped weapon: ", GameState.equipped_weapon)
		print("  - New Total ATK: ", GameState.get_total_atk())
		print("  - Expected: ", GameState.player_atk + 8)
		if GameState.get_total_atk() == GameState.player_atk + 8:
			print("✓ ATK bonus applied correctly")
		else:
			print("✗ ATK bonus incorrect")
	else:
		print("✗ Failed to equip Iron Sword")
	print()

	# Test 5: Equip armor
	print("Test 5: Equipping Leather Armor...")
	equip_result = GameState.equip_item("leather_armor")
	if equip_result:
		print("✓ Leather Armor equipped")
		print("  - Equipped armor: ", GameState.equipped_armor)
		print("  - New Total DEF: ", GameState.get_total_def())
		print("  - Expected: ", GameState.player_def + 6)
		if GameState.get_total_def() == GameState.player_def + 6:
			print("✓ DEF bonus applied correctly")
		else:
			print("✗ DEF bonus incorrect")
	else:
		print("✗ Failed to equip Leather Armor")
	print()

	# Test 6: Equip accessory
	print("Test 6: Equipping HP Ring...")
	equip_result = GameState.equip_item("hp_ring")
	if equip_result:
		print("✓ HP Ring equipped")
		print("  - Equipped accessory: ", GameState.equipped_accessory)
		print("  - Base HP Max: ", GameState.player_hp_max)
		print("  - Total HP Max: ", GameState.get_total_hp_max())
		print("  - Expected: ", GameState.player_hp_max + 20)
		if GameState.get_total_hp_max() == GameState.player_hp_max + 20:
			print("✓ HP bonus applied correctly")
		else:
			print("✗ HP bonus incorrect")
	else:
		print("✗ Failed to equip HP Ring")
	print()

	# Test 7: Full stats with all equipment
	print("Test 7: Full stats with all equipment...")
	print("  - Total ATK: ", GameState.get_total_atk(), " (base: ", GameState.player_atk, " + weapon: 8)")
	print("  - Total DEF: ", GameState.get_total_def(), " (base: ", GameState.player_def, " + armor: 6)")
	print("  - Total HP Max: ", GameState.get_total_hp_max(), " (base: ", GameState.player_hp_max, " + ring: 20)")
	print()

	# Test 8: Unequip
	print("Test 8: Unequipping weapon...")
	GameState.unequip_slot("weapon")
	print("  - Equipped weapon: '", GameState.equipped_weapon, "'")
	print("  - Total ATK: ", GameState.get_total_atk())
	if GameState.equipped_weapon == "" and GameState.get_total_atk() == GameState.player_atk:
		print("✓ Weapon unequipped correctly")
	else:
		print("✗ Weapon unequip failed")
	print()

	# Test 9: Multi-stat equipment
	print("Test 9: Testing multi-stat equipment (Guardian's Blade)...")
	equip_result = GameState.equip_item("guardian_blade")
	if equip_result:
		print("✓ Guardian's Blade equipped")
		print("  - Total ATK: ", GameState.get_total_atk(), " (should add +30)")
		print("  - Total DEF: ", GameState.get_total_def(), " (should add +5)")
	print()

	# Test 10: Special effect check
	print("Test 10: Testing special effects (Clockwork Heart)...")
	GameState.unequip_slot("accessory")
	equip_result = GameState.equip_item("clockwork_heart")
	if equip_result:
		var has_regen = GameState.has_equipment_effect("auto_regen")
		var regen_amount = GameState.get_equipment_effect_value("auto_regen", "regen_amount")
		print("✓ Clockwork Heart equipped")
		print("  - Has auto_regen: ", has_regen)
		print("  - Regen amount: ", regen_amount)
		if has_regen and regen_amount == 5:
			print("✓ Special effect detected correctly")
		else:
			print("✗ Special effect detection failed")
	print()

	print("=== Equipment System Test Complete ===")

	# Exit after 2 seconds
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()
