# Battle System Integration Guide

## Overview
The battle system is implemented and ready for integration with the overworld. This guide explains how to trigger battles from the overworld.

## BattleManager API

The `BattleManager` singleton provides a simple API for starting battles:

```gdscript
BattleManager.start_battle(enemy_ids: Array, on_victory: Callable, on_defeat: Callable, boss_battle: bool = false)
```

### Parameters:
- **enemy_ids**: Array of enemy ID strings (e.g., `["slime"]`, `["goblin", "slime"]`, `["archivist_shade"]`)
- **on_victory**: Callable that receives `(exp_gained: int, gold_gained: int)` - called when battle is won
- **on_defeat**: Callable with no parameters - called when player is defeated
- **boss_battle**: Optional boolean, set to `true` to prevent running from battle (default: `false`)

## Available Enemies

From `data/enemies.json`:
- `"slime"` - Weak enemy (HP: 30, ATK: 5, DEF: 2, EXP: 10, Gold: 5)
- `"goblin"` - Medium enemy (HP: 45, ATK: 8, DEF: 3, EXP: 18, Gold: 10)
- `"shadow_wolf"` - Strong enemy (HP: 60, ATK: 12, DEF: 4, EXP: 30, Gold: 15)
- `"archivist_shade"` - Boss (HP: 150, ATK: 18, DEF: 8, EXP: 100, Gold: 50, has Memory Drain skill)

## Integration Example

### Map Trigger Script (Area2D)

```gdscript
extends Area2D

# Configure what enemies to spawn
@export var enemy_ids: Array[String] = ["slime"]
@export var is_boss_encounter: bool = false
@export var one_time_battle: bool = false  # For fixed encounters

var has_triggered: bool = false

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.name == "Player" and not has_triggered:
        if one_time_battle:
            has_triggered = true

        # Start battle
        BattleManager.start_battle(
            enemy_ids,
            _on_victory,
            _on_defeat,
            is_boss_encounter
        )

func _on_victory(exp: int, gold: int) -> void:
    # Battle automatically awards EXP and gold via GameState
    # Scene automatically returns to overworld
    # Add any additional victory logic here (e.g., unlock flags)

    if is_boss_encounter:
        GameState.set_flag("defeated_boss", true)

    print("Victory! Gained ", exp, " EXP and ", gold, " gold")

func _on_defeat() -> void:
    # Handle defeat - typically go to game over
    get_tree().change_scene_to_file("res://scenes/main/game_over.tscn")
```

### NPC/Event Trigger Script

```gdscript
# After dialogue or event, trigger a specific battle
func _on_dialogue_ended() -> void:
    if dialogue_id == "elder_quest_accept":
        # Start a scripted battle
        BattleManager.start_battle(
            ["slime", "goblin"],
            func(exp, gold):
                print("Tutorial battle won!")
                GameState.set_flag("tutorial_battle_complete", true),
            func():
                print("Tutorial battle lost"),
            false  # Can run from this battle
        )
```

### Boss Gate Example

```gdscript
extends Area2D

func _on_player_entered(body: Node2D) -> void:
    if body.name == "Player":
        # Check if player has the required flag
        if not GameState.has_flag("has_elder_pass"):
            show_message("The path is sealed. You need the Elder's blessing.")
            return

        # Start boss battle
        BattleManager.start_battle(
            ["archivist_shade"],
            _on_boss_victory,
            _on_boss_defeat,
            true  # Boss battle - cannot run
        )

func _on_boss_victory(exp: int, gold: int) -> void:
    GameState.set_flag("defeated_boss", true)
    # Transition to ending cutscene or unlock final area
    get_tree().change_scene_to_file("res://scenes/main/ending.tscn")

func _on_boss_defeat() -> void:
    # Return to last save point or game over
    get_tree().change_scene_to_file("res://scenes/main/game_over.tscn")
```

## Battle System Features

### Combat Actions
- **Attack**: Basic physical attack (damage = player_atk - enemy_def)
- **Defend**: Reduces incoming damage by 50% for one turn
- **Skill**: Use magic skills (Fire Bolt for damage, Heal for HP recovery)
  - Fire Bolt: 8 MP, 25 power, single enemy target
  - Heal: 10 MP, 35 HP restoration, self-target
- **Item**: Use items from inventory (Healing Potion restores 40 HP)
- **Run**: 50% chance to escape (disabled in boss battles)

### Enemy AI
- Simple AI: 70% attack, 30% defend for regular enemies
- Enemies with skills: 20% skill, 60% attack, 20% defend
- Boss uses Memory Drain skill

### Combat Math
- Damage = max(attacker_atk - defender_def, 1) * random(0.9, 1.1)
- 10% chance for critical hit (1.5x damage)
- Defending reduces damage by 50%

### Victory/Defeat Conditions
- **Victory**: All enemies HP = 0
  - Awards EXP and gold automatically via GameState
  - Returns to previous scene (stored by BattleManager)
  - Calls victory callback
- **Defeat**: Player HP = 0
  - Calls defeat callback
  - Defeat callback should handle scene transition

### Level-Up System
- EXP is automatically awarded via `GameState.add_exp()`
- GameState handles level-up calculations
- Level-up formula: EXP_to_next = 100 * (level^1.5)
- Stat growth per level:
  - HP: +15
  - MP: +5
  - ATK: +3
  - DEF: +2
- Full heal on level-up

## Testing the Battle System

You can test battles from any scene with this code:

```gdscript
# Test single slime battle
BattleManager.start_battle(
    ["slime"],
    func(exp, gold): print("Won! EXP:", exp, " Gold:", gold),
    func(): print("Lost!"),
    false
)

# Test multi-enemy battle
BattleManager.start_battle(
    ["slime", "goblin"],
    func(exp, gold): get_tree().change_scene_to_file("res://scenes/overworld/map_a_village.tscn"),
    func(): get_tree().change_scene_to_file("res://scenes/main/game_over.tscn")
)

# Test boss battle
BattleManager.start_battle(
    ["archivist_shade"],
    func(exp, gold): print("Boss defeated!"),
    func(): print("Game over"),
    true  # Cannot run
)
```

## Files Created

### Core
- `scripts/core/battle_manager.gd` - Singleton for battle transitions (autoloaded)

### Battle System
- `scripts/battle/battle_system.gd` - Turn-based combat logic
- `scripts/battle/battle_ui.gd` - Battle UI controller (menus, HP bars, damage numbers)
- `scripts/battle/battle_scene_controller.gd` - Main scene coordinator
- `scripts/battle/enemy_ai.gd` - Enemy battler class with AI

### Scenes
- `scenes/battle/battle_scene.tscn` - Main battle scene with UI
- `scenes/battle/enemy.tscn` - Enemy battler prefab

## Notes for Integration

1. **Scene Transitions**: BattleManager automatically stores the previous scene path and returns to it after victory
2. **State Persistence**: All player stats (HP, MP, Level, EXP, Gold, Inventory) persist through GameState singleton
3. **Battle Flow**: The battle scene is completely self-contained - just call `start_battle()` and handle the callbacks
4. **No Softlocks**: All actions properly advance turns, victory/defeat always trigger, Run has escape option
5. **Balance**: At level 1, player should be able to beat 1-2 slimes, struggle with goblin, and need level 2-3 for boss

## Recommended Encounter Placement (for Agent D)

### Map A (Village)
- Tutorial battle trigger near village exit: 1 slime
- Optional battles in outskirts: 1-2 slimes or 1 goblin

### Map B (Field/Ruins)
- Early area: slime, goblin (random or fixed)
- Mid area: goblin, shadow_wolf
- Boss area (requires flag): archivist_shade (boss battle)

### Suggested Progression
1. Player starts at level 1 (HP: 100, ATK: 10, DEF: 5)
2. Fight 1-2 slimes to reach level 2
3. Fight goblins to reach level 3
4. Shadow wolves for level 4
5. Boss fight at level 3-4 (challenging but beatable)

## Future Enhancements (Post-MVP)
- Enemy drops (items)
- Status effects (poison, stun, etc.)
- Multi-target skills
- Party members
- More complex AI patterns
- Battle animations and visual effects
