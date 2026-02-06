# JRPG MVP Project Specification

**Version**: 1.0
**Date**: 2026-02-06
**Team Lead**: Claude Team Lead

---

## Technical Decisions

### Engine & Platform
- **Engine**: Godot 4.x
- **Language**: GDScript
- **Target Platform**: Desktop (Windows/macOS)
- **Resolution**: 1280x720 (16:9), windowed mode
- **Web Export**: Optional (post-MVP)

### Visual Style
- **Map Style**: Top-down 2D (like classic JRPG)
- **Art**: 16x16 pixel sprites or simple colored geometric shapes (placeholders acceptable)
- **UI**: Clean, pixel-art inspired or flat design
- **Animations**: Minimal (idle, walk cycle, attack frame)

### Gameplay Decisions
- **Encounter Style**: Visible encounter triggers (for player control and testing ease)
- **Battle Turn Order**: Simple alternating turns (Player → Enemy → Player...)
- **Party Size**: 1 hero (expandable post-MVP)
- **Save System**: Optional for MVP (respawn at last map entry if not implemented)

---

## Core System Interfaces

### 1. PlayerState (GameState Singleton)

```gdscript
# Autoload: res://scripts/core/game_state.gd

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

var inventory: Dictionary = {
    "healing_potion": 3
}

var quest_flags: Dictionary = {
    # "talked_to_elder": false,
    # "has_elder_pass": false,
    # "defeated_boss": false
}

func add_exp(amount: int) -> void
func level_up() -> void
func add_gold(amount: int) -> void
func add_item(item_id: String, quantity: int) -> void
func use_item(item_id: String) -> bool
func set_flag(flag_name: String, value: bool) -> void
func has_flag(flag_name: String) -> bool
```

### 2. EnemyDef Schema (data/enemies.json)

```json
{
  "enemies": [
    {
      "id": "slime",
      "name": "Slime",
      "hp": 30,
      "atk": 5,
      "def": 2,
      "agi": 3,
      "exp_reward": 10,
      "gold_reward": 5,
      "sprite_path": "res://sprites/enemies/slime.png",
      "skills": []
    }
  ]
}
```

### 3. SkillDef Schema (data/skills.json)

```json
{
  "skills": [
    {
      "id": "fire_bolt",
      "name": "Fire Bolt",
      "mp_cost": 8,
      "power": 25,
      "target_type": "single_enemy",
      "description": "A bolt of flame strikes the enemy"
    }
  ]
}
```

### 4. ItemDef Schema (data/items.json)

```json
{
  "items": [
    {
      "id": "healing_potion",
      "name": "Healing Potion",
      "type": "consumable",
      "effect": "heal",
      "power": 40,
      "description": "Restores 40 HP"
    }
  ]
}
```

### 5. Dialogue Schema (data/dialogues/*.json)

```json
{
  "dialogue_id": "elder_intro",
  "nodes": [
    {
      "id": "start",
      "speaker": "Elder",
      "text": "The time bell has stopped ringing. Darkness grows.",
      "choices": null,
      "next": "node_2"
    },
    {
      "id": "node_2",
      "speaker": "Elder",
      "text": "Will you retrieve the clapper from the ruins?",
      "choices": [
        {
          "text": "I will help",
          "next": "accept",
          "set_flag": "accepted_quest"
        },
        {
          "text": "Tell me more first",
          "next": "more_info"
        }
      ]
    }
  ]
}
```

---

## Folder Structure

```
/Users/keigoshimada/Documents/agentteam-rpg/
├── project.godot
├── CLAUDE.md
├── README.md
├── scenes/
│   ├── main/
│   │   ├── title_screen.tscn
│   │   ├── game_over.tscn
│   │   └── pause_menu.tscn
│   ├── overworld/
│   │   ├── map_a_village.tscn
│   │   ├── map_b_field.tscn
│   │   ├── player.tscn
│   │   └── npc.tscn
│   ├── battle/
│   │   ├── battle_scene.tscn
│   │   ├── battle_ui.tscn
│   │   ├── enemy.tscn
│   │   └── hero_sprite.tscn
│   └── dialogue/
│       └── dialogue_box.tscn
├── scripts/
│   ├── core/
│   │   ├── game_state.gd (autoload)
│   │   ├── battle_manager.gd
│   │   └── dialogue_manager.gd
│   ├── overworld/
│   │   ├── player_controller.gd
│   │   ├── npc.gd
│   │   ├── map_trigger.gd
│   │   └── map_controller.gd
│   ├── battle/
│   │   ├── battle_system.gd
│   │   ├── turn_queue.gd
│   │   └── enemy_ai.gd
│   └── ui/
│       ├── title_screen.gd
│       ├── pause_menu.gd
│       ├── dialogue_box.gd
│       └── game_over.gd
├── sprites/
│   ├── player/
│   ├── enemies/
│   ├── npcs/
│   ├── ui/
│   └── tilesets/
├── data/
│   ├── enemies.json
│   ├── skills.json
│   ├── items.json
│   └── dialogues/
│       ├── elder.json
│       ├── companion.json
│       └── ending.json
└── docs/
    ├── project_spec.md (this file)
    ├── architecture.md (Agent deliverable)
    └── content_schemas.md (Agent deliverable)
```

---

## Narrative Premise

**Title**: "The Silent Bell"

**Hook**: The village's ancient time bell has stopped. Days lengthen, nights grow darker and colder. The Elder reveals that the bell's clapper was stolen and hidden in the nearby field ruins.

**Inciting Incident**: The hero agrees to retrieve the clapper. The Elder gives a cryptic warning about "sealed memories."

**Midpoint Twist**: In the ruins, a companion/NPC reveals they know more than they let on—the bell is powered by a sealed memory of the village's founding. The clapper was hidden to suppress a truth.

**Boss Climax**: The Archivist Shade, guardian of the memory, challenges the hero. It doesn't want the memory destroyed or misused.

**Resolution**: Upon victory, the hero faces a choice:
- **Choice A**: Return the memory to the village (Elder controls knowledge, maintains order)
- **Choice B**: Free the memory (truth becomes public, uncertainty but freedom)

The ending changes dialogue/cutscene based on choice. Time bell rings again, day/night cycle restored.

---

## Vertical Slice Milestone

**Goal**: Playable loop demonstrating core systems integration

**Scope**:
1. Map A (Village) with movable player
2. One NPC (Elder) with simple dialogue
3. One battle trigger leading to battle scene
4. Battle with one enemy type, Attack action only
5. Victory awards EXP, returns to Map A

**Acceptance**:
- Player moves with arrow keys/WASD, collides with map boundaries
- Interact key (E/Space) triggers Elder dialogue
- Encounter trigger starts battle
- Battle: can Attack, enemy attacks back, HP decreases, victory/defeat works
- Victory: shows EXP gained, returns to overworld

**Timeline**: Complete by end of Agent A + Agent B initial implementations

---

## Agent Workstream Assignments

### Agent A — Gameplay/Systems Engineer
**Focus**: Overworld, interaction, integration glue
**Tasks**: #3
**Key Deliverables**:
- Player controller (8-direction movement, collision)
- Interaction system (detect NPC/trigger, show prompt, activate)
- Map transition triggers (change scene with position preservation)
- Item system integration with GameState
- Pause menu with Status/Items screens

### Agent B — Battle/System Designer-Engineer
**Focus**: Turn-based combat, progression math
**Tasks**: #4
**Key Deliverables**:
- Battle scene loop (turn order, action selection, execution)
- Battle UI (HP bars, action menu, damage numbers)
- Enemy definitions (3 types + boss)
- Skill system (1-2 skills for hero)
- EXP/level formula (document: `EXP_to_next = base * level^1.5`, HP/ATK/DEF = base + level * growth)
- Victory/defeat transitions

### Agent C — Scenario/Content Designer
**Focus**: Story, dialogue, content writing
**Tasks**: #5
**Key Deliverables**:
- Complete scenario beat sheet with "Silent Bell" premise (or improved alternative)
- Dialogue scripts: Elder, companion, boss intro, ending (2 variants based on choice)
- NPC personality and quest context
- Item flavor descriptions
- Dialogue data JSON files

### Agent D — Map/UX Implementer
**Focus**: Level design, UI screens, visual polish
**Tasks**: #6
**Key Deliverables**:
- Map A: Village (20x15 tiles, Elder + companion placement)
- Map B: Field/Ruins (25x20 tiles, encounter zones, boss area)
- Trigger volumes: transitions, encounters, quest gate
- Title screen, Game Over screen
- Battle transition animations
- Placeholder art pack (recommend: Kenney.nl pixel pack or simple shapes)

---

## Inter-System Communication

### Overworld → Battle
```gdscript
# In map trigger script
var enemy_ids = ["slime", "goblin"]
BattleManager.start_battle(enemy_ids, _on_battle_victory, _on_battle_defeat)

func _on_battle_victory(exp_gained: int, gold_gained: int):
    GameState.add_exp(exp_gained)
    GameState.add_gold(gold_gained)
    # Return to overworld

func _on_battle_defeat():
    get_tree().change_scene_to_file("res://scenes/main/game_over.tscn")
```

### Dialogue → Quest Flags
```gdscript
# In dialogue system
if choice.has("set_flag"):
    GameState.set_flag(choice.set_flag, true)
```

### Quest Gating
```gdscript
# In trigger script
if not GameState.has_flag("has_elder_pass"):
    # Show message: "The path is blocked"
    return
# else: allow passage
```

---

## Acceptance Criteria (Final MVP)

1. **Exploration**: Move freely on both maps, interact with NPCs, transition between maps
2. **Quest Gating**: Boss area inaccessible until Elder dialogue complete
3. **Battle**: All actions work (Attack/Defend/Skill/Item/Run), no softlocks, victory/defeat functional
4. **Progression**: EXP accumulates, level-up increases stats, boss is beatable with skill
5. **Narrative**: Reach ending, player choice visibly affects ending dialogue/scene

---

## Next Steps After Spec

1. Task #2: Set up Godot project structure (Team Lead)
2. Spawn Agent A, B, C, D and assign tasks #3, #4, #5, #6
3. Monitor progress and resolve interface conflicts
4. Integration milestone: Task #7 (vertical slice)
5. Expansion: Task #8 (full MVP features)
6. Polish: Task #9 (ending), Task #10 (docs)

---

## Naming Conventions

- **Scenes**: snake_case (e.g., `map_a_village.tscn`)
- **Scripts**: snake_case (e.g., `player_controller.gd`)
- **Node names**: PascalCase (e.g., `PlayerSprite`, `EnemyContainer`)
- **Variables/functions**: snake_case (e.g., `player_hp`, `add_exp()`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `MAX_HP`, `EXP_BASE`)
- **Signals**: snake_case with past tense (e.g., `dialogue_ended`, `battle_won`)
