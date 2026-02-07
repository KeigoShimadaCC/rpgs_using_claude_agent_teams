extends Node2D
class_name EnemyBattler

## Enemy Battler
## Represents an enemy in battle with AI logic

signal died(enemy: EnemyBattler)
signal action_decided(action: Dictionary)

# Enemy data
var enemy_id: String = ""
var enemy_name: String = ""
var max_hp: int = 30
var current_hp: int = 30
var atk: int = 5
var def: int = 2
var agi: int = 3
var exp_reward: int = 10
var gold_reward: int = 5
var skills: Array = []

# Visual components
@onready var sprite: ColorRect = $Sprite
@onready var hp_bar: ProgressBar = $HPBar
@onready var name_label: Label = $NameLabel

func _ready() -> void:
	if sprite:
		sprite.visible = true
	update_hp_bar()

## Initialize enemy with data from enemies.json
func setup(enemy_data: Dictionary) -> void:
	enemy_id = enemy_data.get("id", "unknown")
	enemy_name = enemy_data.get("name", "Enemy")
	max_hp = enemy_data.get("hp", 30)
	current_hp = max_hp
	atk = enemy_data.get("atk", 5)
	def = enemy_data.get("def", 2)
	agi = enemy_data.get("agi", 3)
	exp_reward = enemy_data.get("exp_reward", 10)
	gold_reward = enemy_data.get("gold_reward", 5)
	skills = enemy_data.get("skills", [])

	# Update UI
	if name_label:
		name_label.text = enemy_name

	update_hp_bar()

## Take damage
func take_damage(amount: int) -> int:
	var actual_damage = max(amount, 1)
	current_hp = max(current_hp - actual_damage, 0)
	update_hp_bar()

	if current_hp <= 0:
		die()

	return actual_damage

## Heal HP
func heal(amount: int) -> void:
	current_hp = min(current_hp + amount, max_hp)
	update_hp_bar()

## Check if enemy is alive
func is_alive() -> bool:
	return current_hp > 0

## Update HP bar display
func update_hp_bar() -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp

## Enemy death
func die() -> void:
	died.emit(self)
	# Play death animation (fade out)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	# Do not queue_free here, so we can access rewards at end of battle
	# The BattleScene will cleanup everything when we leave
	visible = false

## AI Decision Making
## Returns action dictionary: { "type": "attack"|"defend"|"skill", "skill_id": String }
func decide_action() -> Dictionary:
	var action = {}

	# Simple AI logic:
	# - If has skills: 20% chance to use skill, 60% attack, 20% defend
	# - If no skills: 70% attack, 30% defend

	var roll = randf()

	if not skills.is_empty():
		if roll < 0.2:
			# Use skill
			action.type = "skill"
			action.skill_id = skills.pick_random()
		elif roll < 0.8:
			# Attack
			action.type = "attack"
		else:
			# Defend
			action.type = "defend"
	else:
		if roll < 0.7:
			# Attack
			action.type = "attack"
		else:
			# Defend
			action.type = "defend"

	action_decided.emit(action)
	return action

## Get enemy info for display
func get_info() -> Dictionary:
	return {
		"id": enemy_id,
		"name": enemy_name,
		"hp": current_hp,
		"max_hp": max_hp,
		"atk": atk,
		"def": def,
		"exp_reward": exp_reward,
		"gold_reward": gold_reward
	}
