# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Turn-based JRPG-style RPG MVP (Final Fantasy/Dragon Quest-inspired) built with Godot 4. Focus: playable end-to-end experience with movement, battles, narrative, and clear completion state.

**Engine**: Godot 4.x (GDScript)
**Target**: Desktop (Windows/macOS)
**Art Style**: Simple pixel art or consistent flat shapes (placeholders acceptable)

## Project Structure

```
/
├── project.godot           # Godot project file
├── scenes/
│   ├── main/
│   │   ├── title_screen.tscn
│   │   ├── game_over.tscn
│   │   └── pause_menu.tscn
│   ├── overworld/
│   │   ├── map_a_village.tscn    # Hub/Village map
│   │   ├── map_b_field.tscn      # Field/Dungeon map
│   │   └── player.tscn
│   ├── battle/
│   │   ├── battle_scene.tscn
│   │   ├── battle_ui.tscn
│   │   └── enemy.tscn
│   └── dialogue/
│       └── dialogue_box.tscn
├── scripts/
│   ├── core/
│   │   ├── game_state.gd         # Singleton: PlayerState management
│   │   ├── battle_manager.gd
│   │   └── dialogue_manager.gd
│   ├── overworld/
│   │   ├── player_controller.gd
│   │   ├── npc.gd
│   │   └── map_trigger.gd
│   └── battle/
│       ├── battle_system.gd
│       └── turn_queue.gd
├── data/
│   ├── enemies.json              # Enemy definitions
│   ├── skills.json               # Skill/ability definitions
│   ├── items.json                # Item definitions
│   └── dialogues/
│       ├── npc_elder.json
│       └── cutscene_*.json
└── docs/
    ├── architecture.md           # System architecture
    └── content_schemas.md        # Data format specifications
```

## Core Systems Architecture

### 1. Game State (Singleton: GameState)
Central authority for persistent data:
- Player stats: HP, MP, Level, EXP, Gold
- Inventory: items and quantities
- Quest flags: dictionary of completed events
- Party members (currently 1 hero)

### 2. Scene Flow
```
TitleScreen → MapA (Village) ⇄ MapB (Field)
                ↓ trigger
            BattleScene → Victory/Defeat
                ↓
            Back to Overworld
```

### 3. Battle System
- Turn-based with simple turn order (alternating or AGI-based)
- Actions: Attack, Defend, Skill, Item, Run
- Victory: Award EXP, Gold, optional item drops
- Defeat: Game Over screen with reload option

### 4. Dialogue System
- JSON-driven dialogue trees
- Format: nodes with speaker, text, choices, next_node_id
- Supports branching choices (at least 1 meaningful choice in game)

### 5. Quest/Trigger System
- Map triggers check GameState flags
- Example: `has_elder_pass` flag unlocks path to boss area

## Data Schemas

### Enemy Definition (data/enemies.json)
```json
{
  "enemy_id": "slime",
  "name": "Slime",
  "hp": 30,
  "atk": 5,
  "def": 2,
  "exp_reward": 10,
  "gold_reward": 5,
  "sprite": "res://sprites/enemies/slime.png"
}
```

### Skill Definition (data/skills.json)
```json
{
  "skill_id": "fire_bolt",
  "name": "Fire Bolt",
  "mp_cost": 8,
  "power": 25,
  "target": "single_enemy",
  "description": "A bolt of flame"
}
```

### Dialogue Definition (data/dialogues/*.json)
```json
{
  "dialogue_id": "elder_intro",
  "nodes": [
    {
      "id": "start",
      "speaker": "Elder",
      "text": "The time bell has stopped...",
      "choices": [
        {"text": "I'll investigate", "next": "accept"},
        {"text": "Tell me more", "next": "info"}
      ]
    }
  ]
}
```

## Development Commands

### Running the Project
```bash
# Open in Godot Editor
godot project.godot

# Run directly (after setting main scene)
godot --path . res://scenes/main/title_screen.tscn
```

### Testing
- Manual playthrough: Start → Village → Talk to Elder → Get quest → Field → Battle → Boss → Ending
- Edge cases: Run from battle, use item in battle, defeat state, invalid transitions

## Adding Content

### New Map
1. Create scene in `scenes/overworld/map_*.tscn`
2. Add TileMap with collision layer
3. Place trigger areas (Area2D nodes) for transitions/encounters
4. Connect trigger signals to map controller script

### New Enemy
1. Add entry to `data/enemies.json`
2. Create or reuse enemy sprite
3. Configure encounter rate/location in map triggers

### New Dialogue
1. Create JSON file in `data/dialogues/`
2. Reference dialogue_id in NPC script or cutscene trigger
3. Use DialogueManager.start_dialogue("dialogue_id")

### New Skill
1. Add to `data/skills.json`
2. Implement skill logic in `battle_system.gd` if special behavior needed
3. Add to hero's available skills list

## Key Interfaces

### PlayerState API
```gdscript
GameState.player_hp
GameState.player_level
GameState.add_exp(amount)
GameState.add_gold(amount)
GameState.set_flag(flag_name, value)
GameState.has_flag(flag_name)
```

### Battle Initialization
```gdscript
BattleManager.start_battle(enemy_ids: Array, on_victory: Callable, on_defeat: Callable)
```

### Dialogue System
```gdscript
DialogueManager.start_dialogue(dialogue_id: String)
DialogueManager.connect("dialogue_ended", on_dialogue_end)
```

## Scope Control

**In Scope (MVP)**:
- 2 maps (Village + Field)
- 1 hero, 3 enemy types + 1 boss
- 1-2 skills, 1 item (healing potion)
- Basic Attack/Defend/Item/Run actions
- Simple level-up (HP/ATK/DEF scaling)
- Quest gating (flag-based progression)
- One meaningful player choice in narrative

**Out of Scope (Post-MVP)**:
- Equipment system
- Multiple party members
- Complex status effects
- Crafting
- Complex AI/tactics
- Save system (optional for MVP)

## Narrative Structure

MVP scenario follows: Hook → Midpoint Twist → Boss Climax → Resolution

**Current Premise**: Village time bell stops → Retrieve clapper from ruins → Discover sealed memory → Face Archivist Shade → Restore cycle with choice consequence

## Acceptance Tests

1. **Exploration**: Move in all directions, collide with walls, interact with NPCs, transition between maps
2. **Quest Gating**: Cannot access boss area until Elder dialogue complete
3. **Battle**: All actions (Attack/Defend/Skill/Item/Run) work; no softlocks; victory returns to map
4. **Progression**: EXP accumulates, level-up applies stat increases, boss is beatable
5. **Narrative**: Can reach ending scene; player choice affects later content

## Common Issues

- **Trigger not firing**: Check collision layers/masks on Area2D and player CharacterBody2D
- **Battle softlock**: Ensure all actions call `end_turn()` and victory/defeat transitions are connected
- **Dialogue not advancing**: Verify next_node_id exists and DialogueManager state machine is correct
- **Stats not persisting**: All stat changes must go through GameState singleton, not local variables
