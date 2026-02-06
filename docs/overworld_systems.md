# Overworld Systems Documentation

**Author**: Agent A - Gameplay/Systems Engineer
**Date**: 2026-02-06
**Status**: Complete

## Overview

This document describes the overworld exploration, interaction, and integration systems implemented for the JRPG MVP.

---

## 1. Player Controller

**Location**: `/Users/keigoshimada/Documents/agentteam-rpg/scripts/overworld/player_controller.gd`
**Scene**: `/Users/keigoshimada/Documents/agentteam-rpg/scenes/overworld/player.tscn`

### Features
- 8-direction movement using WASD or arrow keys
- Movement speed: 150 pixels/second
- Collision detection with world (layer 1)
- Interaction range detection via Area2D child node
- Camera following player with 2x zoom

### Collision Layers
- Player: Layer 2
- Collides with: Layer 1 (World)
- Interaction area detects: Layers 4 and 5 (NPCs and Triggers)

### Input Actions
- Movement: `ui_left`, `ui_right`, `ui_up`, `ui_down`
- Interaction: `interact` (E or Space)
- Pause: `ui_cancel` (Escape)

### Signals
```gdscript
signal interacted_with(target: Node)
```
Emitted when player interacts with an object.

### Public Methods
```gdscript
func has_nearby_interactables() -> bool
func get_nearby_interactables() -> Array[Node]
```

### Animation Support
The player controller checks for an AnimationPlayer node and will play animations if available:
- `walk_up`, `walk_down`, `walk_left`, `walk_right`
- `idle_up`, `idle_down`, `idle_left`, `idle_right`

**Note**: Currently uses a simple colored square placeholder. Agent D can replace with sprite animations.

---

## 2. Interaction System

### How It Works
1. Player has an InteractionArea (Area2D) that detects nearby interactables
2. When player presses interact key, finds closest interactable
3. Calls `interact()` method on the interactable if it exists
4. Emits `interacted_with` signal for external systems

### Making Objects Interactable
Any node can be interactable by:
1. Having a collision area/body that overlaps with player's InteractionArea
2. Implementing an `interact()` method

Example:
```gdscript
extends Area2D

func interact() -> void:
    print("Player interacted with me!")
    # Trigger dialogue, open chest, etc.
```

---

## 3. NPC Base

**Location**: `/Users/keigoshimada/Documents/agentteam-rpg/scripts/overworld/npc.gd`
**Scene**: `/Users/keigoshimada/Documents/agentteam-rpg/scenes/overworld/npc.tscn`

### Properties
```gdscript
@export var npc_name: String = "NPC"
@export var dialogue_id: String = ""
@export var interactable: bool = true
```

### Features
- StaticBody2D on layer 4 (NPC layer)
- Automatically triggers dialogue via DialogueManager if `dialogue_id` is set
- Emits `npc_interacted` signal for custom logic
- Can be enabled/disabled via `set_interactable(bool)`

### Signals
```gdscript
signal npc_interacted(npc: Node)
```

### Integration with Dialogue System (Agent C)
When an NPC is interacted with and has a `dialogue_id` set, it will automatically call:
```gdscript
DialogueManager.start_dialogue(dialogue_id)
```

**For Agent C**: Ensure DialogueManager is registered as an autoload singleton at `/root/DialogueManager`.

### Example Usage in Map
```gdscript
# In map scene (Agent D)
var elder = preload("res://scenes/overworld/npc.tscn").instantiate()
elder.npc_name = "Elder"
elder.dialogue_id = "elder_intro"
elder.position = Vector2(300, 200)
add_child(elder)
```

---

## 4. Map Transition System

**Location**: `/Users/keigoshimada/Documents/agentteam-rpg/scripts/overworld/map_trigger.gd`

### Trigger Types
```gdscript
enum TriggerType {
    MAP_TRANSITION,  # Change scenes
    BATTLE,          # Start battle encounter
    CUTSCENE,        # Trigger cutscene
    CUSTOM           # Custom logic via signals
}
```

### Properties
```gdscript
@export var trigger_type: TriggerType
@export var trigger_enabled: bool = true

# Map transition
@export_file("*.tscn") var target_scene: String
@export var spawn_position: Vector2
@export var spawn_marker_name: String

# Battle trigger
@export var enemy_ids: Array[String]

# Quest gating
@export var required_flag: String
@export var blocked_message: String

# Transition effect
@export var use_fade_transition: bool = true
@export var fade_duration: float = 0.3
```

### How to Use

#### Map Transition Trigger
```gdscript
# Create Area2D node in your map
# Attach map_trigger.gd script
# Set properties:
trigger_type = TriggerType.MAP_TRANSITION
target_scene = "res://scenes/overworld/map_b_field.tscn"
spawn_position = Vector2(100, 300)
use_fade_transition = true
```

#### Battle Trigger
```gdscript
trigger_type = TriggerType.BATTLE
enemy_ids = ["slime", "goblin"]
```

The trigger will automatically call `BattleManager.start_battle()` and handle victory/defeat callbacks.

#### Quest Gating
```gdscript
required_flag = "has_elder_pass"
blocked_message = "The ruins are sealed. You need the Elder's permission."
```

If the player doesn't have the required flag, the trigger won't activate and will print the blocked message.

### Signals
```gdscript
signal trigger_activated(trigger: Area2D)
signal transition_started()
signal transition_completed()
```

### Integration with Battle System (Agent B)
Battle triggers expect BattleManager to be available at `/root/BattleManager` with:
```gdscript
func start_battle(enemy_ids: Array[String], on_victory: Callable, on_defeat: Callable) -> void
```

**For Agent B**: Implement BattleManager as an autoload singleton.

---

## 5. Pause Menu System

**Location**: `/Users/keigoshimada/Documents/agentteam-rpg/scripts/ui/pause_menu.gd`
**Scene**: `/Users/keigoshimada/Documents/agentteam-rpg/scenes/main/pause_menu.tscn`

### Features
- Toggle with Escape key
- Pauses game tree when active
- Three screens: Status, Items, and main menu
- Automatically syncs with GameState signals

### Status Screen
Displays:
- Player name, level
- HP, MP (current/max)
- EXP (current/next level)
- Gold
- ATK, DEF

### Items Screen
- Lists all items in GameState.inventory
- Shows item descriptions
- "Use Item" button to consume items
- Automatically updates when items change

### Integration with GameState
The pause menu connects to GameState signals:
```gdscript
GameState.hp_changed.connect(_on_hp_changed)
GameState.mp_changed.connect(_on_mp_changed)
GameState.gold_changed.connect(_on_gold_changed)
GameState.item_changed.connect(_on_item_changed)
```

### How to Add to Maps (Agent D)
Simply instantiate the pause menu scene in your map:
```gdscript
var pause_menu = preload("res://scenes/main/pause_menu.tscn").instantiate()
add_child(pause_menu)
```

The pause menu is a CanvasLayer, so it will always appear on top.

---

## 6. Item System Integration

All item operations go through GameState singleton:

```gdscript
# Add items
GameState.add_item("healing_potion", 1)

# Use items (automatically applies effect and removes from inventory)
var success = GameState.use_item("healing_potion")

# Check items
var has_key = GameState.has_item("rusty_key")
var potion_count = GameState.get_item_count("healing_potion")
```

### Item Effects
GameState.use_item() reads item data from `res://data/items.json` and applies effects:
- `"heal"`: Restores HP
- `"restore_mp"`: Restores MP

**For Agent B**: Battle system can call `GameState.use_item()` directly during item action.

---

## 7. Spawn Position Handling

When transitioning between maps, the spawn position can be set two ways:

### Method 1: Direct Position
```gdscript
get_tree().root.set_meta("spawn_position", Vector2(100, 200))
```

In the new scene's `_ready()`:
```gdscript
if get_tree().root.has_meta("spawn_position"):
    player.position = get_tree().root.get_meta("spawn_position")
    get_tree().root.remove_meta("spawn_position")
```

### Method 2: Spawn Marker
```gdscript
get_tree().root.set_meta("spawn_marker", "entrance_from_village")
```

In the new scene:
```gdscript
if get_tree().root.has_meta("spawn_marker"):
    var marker_name = get_tree().root.get_meta("spawn_marker")
    var marker = get_node_or_null(marker_name)
    if marker:
        player.position = marker.global_position
    get_tree().root.remove_meta("spawn_marker")
```

**For Agent D**: Place Marker2D nodes in your maps named "entrance_from_village", "entrance_from_field", etc.

---

## 8. Collision Layer Reference

| Layer | Name    | Used By           | Collides With |
|-------|---------|-------------------|---------------|
| 1     | World   | Walls, obstacles  | Player        |
| 2     | Player  | Player character  | World         |
| 3     | NPC     | NPCs              | None          |
| 4     | Trigger | Trigger areas     | Player        |

Player InteractionArea detects layers 4 and 5 (NPCs and Triggers).

---

## 9. Testing

### Test Map
A test map is available at `/Users/keigoshimada/Documents/agentteam-rpg/scenes/overworld/test_map.tscn`

Features:
- Simple bounded area with walls
- One test NPC
- Player with camera
- Pause menu

### How to Test
1. Open project in Godot
2. Set test_map.tscn as main scene (or run it directly)
3. Move with WASD or arrows
4. Press E near NPC to interact
5. Press Escape to open pause menu

### Expected Behavior
- Player moves smoothly
- Player collides with walls
- Player can interact with NPC (prints "Interacting with Test NPC")
- Pause menu shows correct GameState data
- Items can be used from pause menu

---

## 10. Integration Checklist for Other Agents

### Agent B (Battle System)
- [ ] Create BattleManager autoload singleton
- [ ] Implement `start_battle(enemy_ids, on_victory, on_defeat)` method
- [ ] Call victory callback with (exp_gained, gold_gained)
- [ ] Call defeat callback on player defeat
- [ ] Support `GameState.use_item()` during battle

### Agent C (Dialogue System)
- [ ] Create DialogueManager autoload singleton
- [ ] Implement `start_dialogue(dialogue_id: String)` method
- [ ] Create dialogue data files in `res://data/dialogues/`
- [ ] Test with NPC dialogue_id property

### Agent D (Maps/UI)
- [ ] Use player.tscn in all maps
- [ ] Place Marker2D nodes for spawn points
- [ ] Add pause_menu.tscn to maps (or as autoload)
- [ ] Create battle trigger areas with enemy_ids
- [ ] Create map transition triggers between scenes
- [ ] Set up quest gates with required_flag

---

## 11. Known Issues / TODO

- Animation system is stubbed (AnimationPlayer exists but no animations created)
- Interaction prompt UI ("Press E") not implemented (Agent D can add)
- Fade transition happens but doesn't clean up properly if scene changes fail
- No visual feedback for quest-gated triggers (just prints message)

---

## 12. File Locations Summary

**Scripts**:
- `/Users/keigoshimada/Documents/agentteam-rpg/scripts/overworld/player_controller.gd`
- `/Users/keigoshimada/Documents/agentteam-rpg/scripts/overworld/npc.gd`
- `/Users/keigoshimada/Documents/agentteam-rpg/scripts/overworld/map_trigger.gd`
- `/Users/keigoshimada/Documents/agentteam-rpg/scripts/ui/pause_menu.gd`

**Scenes**:
- `/Users/keigoshimada/Documents/agentteam-rpg/scenes/overworld/player.tscn`
- `/Users/keigoshimada/Documents/agentteam-rpg/scenes/overworld/npc.tscn`
- `/Users/keigoshimada/Documents/agentteam-rpg/scenes/main/pause_menu.tscn`
- `/Users/keigoshimada/Documents/agentteam-rpg/scenes/overworld/test_map.tscn` (for testing)

**Dependencies**:
- GameState singleton (already exists)
- DialogueManager singleton (Agent C to implement)
- BattleManager singleton (Agent B to implement)
