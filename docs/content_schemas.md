# Content Schemas and Dialogue System Specification

## Overview

This document defines the JSON schema for all content data files (dialogues, items, enemies, skills) and specifies how the dialogue system integrates with the game.

---

## Dialogue System Schema

### File Format

All dialogue files are stored in `/data/dialogues/` as JSON files. Each file represents a single dialogue tree (e.g., a conversation with an NPC or a cutscene).

### Root Structure

```json
{
  "dialogue_id": "unique_identifier",
  "nodes": [
    { /* node object */ }
  ]
}
```

**Fields**:
- `dialogue_id` (String, required): Unique identifier for this dialogue tree
- `nodes` (Array, required): Array of dialogue node objects

---

### Node Object Structure

A node represents a single moment in the dialogue (one character speaking one line).

```json
{
  "id": "node_identifier",
  "speaker": "Character Name",
  "text": "The dialogue text to display.",
  "choices": null,
  "next": "next_node_id"
}
```

**Fields**:
- `id` (String, required): Unique identifier for this node within the dialogue tree
- `speaker` (String, optional): Name of the character speaking. Use `null` or empty string for narration/system text
- `text` (String, required): The dialogue text to display. Keep individual lines to 1-2 sentences (max 120 characters recommended)
- `choices` (Array or null, optional): Array of choice objects if this node branches. Use `null` if there are no choices (auto-advance dialogue)
- `next` (String or null, optional): ID of the next node to advance to. Used when `choices` is null. Use `null` to end the dialogue

---

### Choice Object Structure

A choice represents a branching option the player can select.

```json
{
  "text": "Choice button text",
  "next": "node_to_jump_to",
  "set_flag": "quest_flag_name",
  "check_flag": "required_flag_name"
}
```

**Fields**:
- `text` (String, required): Text displayed on the choice button (max 40 characters recommended)
- `next` (String, required): ID of the node to jump to if this choice is selected
- `set_flag` (String, optional): Name of a quest flag to set to `true` in GameState when this choice is selected
- `check_flag` (String, optional): Name of a quest flag that must be `true` for this choice to be visible. If the flag is not set, this choice is hidden

---

### Example Dialogue Tree

#### Simple Linear Dialogue (no choices)

```json
{
  "dialogue_id": "elder_greeting",
  "nodes": [
    {
      "id": "start",
      "speaker": "Elder",
      "text": "Ah, you've come. Good.",
      "choices": null,
      "next": "line2"
    },
    {
      "id": "line2",
      "speaker": "Elder",
      "text": "The time bell has fallen silent. The village is in danger.",
      "choices": null,
      "next": "line3"
    },
    {
      "id": "line3",
      "speaker": "Elder",
      "text": "I need your help to restore it.",
      "choices": null,
      "next": null
    }
  ]
}
```

**Flow**: start → line2 → line3 → [dialogue ends]

---

#### Branching Dialogue (with choices and flags)

```json
{
  "dialogue_id": "elder_quest_offer",
  "nodes": [
    {
      "id": "start",
      "speaker": "Elder",
      "text": "The bell's clapper was hidden in the ruins beyond the fields.",
      "choices": null,
      "next": "offer"
    },
    {
      "id": "offer",
      "speaker": "Elder",
      "text": "Will you retrieve it and restore the cycle of time?",
      "choices": [
        {
          "text": "I'll help",
          "next": "accept",
          "set_flag": "accepted_quest"
        },
        {
          "text": "Tell me more",
          "next": "more_info"
        }
      ],
      "next": null
    },
    {
      "id": "accept",
      "speaker": "Elder",
      "text": "Thank you. Be careful in the ruins. Time is... unstable there.",
      "choices": null,
      "next": null
    },
    {
      "id": "more_info",
      "speaker": "Elder",
      "text": "The clapper guards a sealed memory. Do not pry into it. Just return it.",
      "choices": null,
      "next": "offer_again"
    },
    {
      "id": "offer_again",
      "speaker": "Elder",
      "text": "Now, will you help?",
      "choices": [
        {
          "text": "Yes, I will",
          "next": "accept",
          "set_flag": "accepted_quest"
        }
      ],
      "next": null
    }
  ]
}
```

**Flow**:
- start → offer
- **Choice 1**: "I'll help" → accept → [ends, flag "accepted_quest" set]
- **Choice 2**: "Tell me more" → more_info → offer_again → "Yes, I will" → accept → [ends, flag set]

---

#### Conditional Dialogue (check_flag)

```json
{
  "dialogue_id": "companion_hint",
  "nodes": [
    {
      "id": "start",
      "speaker": "Companion",
      "text": "Have you spoken to the Elder yet?",
      "choices": [
        {
          "text": "Not yet",
          "next": "not_yet"
        },
        {
          "text": "Yes, I have a quest",
          "next": "accepted",
          "check_flag": "accepted_quest"
        }
      ],
      "next": null
    },
    {
      "id": "not_yet",
      "speaker": "Companion",
      "text": "You should. The Elder seems worried about something.",
      "choices": null,
      "next": null
    },
    {
      "id": "accepted",
      "speaker": "Companion",
      "text": "The ruins, huh? I've heard strange things happen there. Be careful.",
      "choices": null,
      "next": null
    }
  ]
}
```

**Flow**:
- If `accepted_quest` flag is NOT set: only "Not yet" choice is visible
- If `accepted_quest` flag IS set: both choices visible

---

## Dialogue File Organization

### Naming Convention

- **NPC dialogues**: `{npc_name}.json` (e.g., `elder.json`, `companion.json`)
- **Cutscene dialogues**: `{scene_name}.json` (e.g., `boss_intro.json`, `ending_choice.json`)

### Directory Structure

```
/data/dialogues/
├── elder.json              # Elder NPC conversations (intro, quest, post-quest)
├── companion.json          # Companion NPC conversations
├── boss_intro.json         # Archivist Shade pre-battle cutscene
├── ending_choice.json      # Player choice cutscene (return vs. free memory)
├── ending_return.json      # Ending A: Returned the clapper
└── ending_free.json        # Ending B: Freed the memory
```

---

## Dialogue Manager API

### DialogueManager Singleton (scripts/core/dialogue_manager.gd)

The DialogueManager is responsible for loading, parsing, and controlling dialogue flow.

#### Signals

```gdscript
signal dialogue_started(dialogue_id: String)
signal node_changed(node_data: Dictionary)
signal dialogue_ended()
signal choices_presented(choices: Array)
```

#### Methods

```gdscript
# Load and start a dialogue tree by ID
func start_dialogue(dialogue_id: String) -> void:
    # Loads dialogue JSON from /data/dialogues/{dialogue_id}.json
    # Emits dialogue_started
    # Displays the first node

# Advance to the next node (for linear dialogue with no choices)
func advance() -> void:
    # Moves to node.next
    # Emits node_changed or dialogue_ended

# Select a choice (for branching dialogue)
func select_choice(choice_index: int) -> void:
    # Applies set_flag if present
    # Jumps to choice.next node
    # Emits node_changed or dialogue_ended

# Check if dialogue is currently active
func is_active() -> bool:
    # Returns true if a dialogue is currently running

# Get current node data
func get_current_node() -> Dictionary:
    # Returns current node dict (id, speaker, text, choices, next)
```

#### Internal State

```gdscript
var current_dialogue: Dictionary = {}  # Loaded dialogue tree
var current_node_id: String = ""       # Current node ID
var is_dialogue_active: bool = false   # Is dialogue running?
```

---

## Dialogue Box UI Integration

The DialogueBox UI (scenes/dialogue/dialogue_box.tscn) will be implemented by Agent D. This section specifies what the UI needs to display and how it integrates with DialogueManager.

### UI Components

The DialogueBox scene must include:

1. **Speaker Name Label** (Label node)
   - Displays the current speaker's name
   - Hide if speaker is null/empty (for narration)

2. **Dialogue Text Label** (RichTextLabel recommended)
   - Displays the current dialogue text
   - Supports typewriter effect (reveal text gradually)
   - Wraps text to fit container

3. **Continue Indicator** (Label, AnimatedSprite, or TextureRect)
   - Shows prompt when text is fully displayed (e.g., "[Space to continue]" or a blinking arrow)
   - Hidden when choices are presented

4. **Choice Buttons Container** (VBoxContainer)
   - Holds 2-3 Button nodes for choices
   - Hidden when there are no choices (linear dialogue)
   - Buttons are created dynamically based on current node's choices

### Signal Connections

The DialogueBox script should connect to DialogueManager signals:

```gdscript
func _ready():
    DialogueManager.dialogue_started.connect(_on_dialogue_started)
    DialogueManager.node_changed.connect(_on_node_changed)
    DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
    DialogueManager.choices_presented.connect(_on_choices_presented)

func _on_dialogue_started(dialogue_id: String):
    # Show dialogue box
    # Disable player movement

func _on_node_changed(node_data: Dictionary):
    # Update speaker name label
    # Start typewriter effect for dialogue text
    # Show/hide continue indicator
    # Clear choice buttons

func _on_dialogue_ended():
    # Hide dialogue box
    # Enable player movement

func _on_choices_presented(choices: Array):
    # Hide continue indicator
    # Create choice buttons dynamically
    # Connect button pressed signals to DialogueManager.select_choice(index)
```

### Player Input Handling

```gdscript
func _unhandled_input(event):
    if not DialogueManager.is_active():
        return

    if event.is_action_pressed("ui_accept"):  # Space/Enter
        if typewriter_finished and not has_choices:
            DialogueManager.advance()
        elif not typewriter_finished:
            # Skip typewriter effect, show full text immediately
```

---

## Quest Flag System

### Flag Names (Reserved)

The following flags are used in the MVP scenario:

- `accepted_quest`: Set when player accepts Elder's quest
- `knows_memory_secret`: Set when player learns about the sealed memory from companion
- `has_clapper`: Set when player defeats boss and obtains clapper (set by trigger, not dialogue)
- `made_choice`: Set when player makes the final choice
- `freed_memory`: Set if player chose to free the memory (mutually exclusive with returned_memory)
- `returned_memory`: Set if player chose to return the clapper (mutually exclusive with freed_memory)
- `defeated_boss`: Set when Archivist Shade is defeated (set by battle system)

### Usage in Dialogue

**Setting a flag**:
```json
{
  "text": "I'll help",
  "next": "accept",
  "set_flag": "accepted_quest"
}
```

**Checking a flag** (conditional choice):
```json
{
  "text": "I have the clapper",
  "next": "has_clapper_dialogue",
  "check_flag": "has_clapper"
}
```

If the flag is not set, the choice is not displayed to the player.

---

## Item Schema (data/items.json)

### Item Object Structure

```json
{
  "id": "item_unique_id",
  "name": "Display Name",
  "type": "consumable",
  "effect": "heal",
  "power": 40,
  "description": "Flavor text describing the item.",
  "usable_in_battle": true,
  "usable_in_field": false
}
```

**Fields**:
- `id` (String): Unique identifier
- `name` (String): Display name in inventory
- `type` (String): "consumable", "key_item", "equipment"
- `effect` (String): "heal", "restore_mp", "buff_atk", etc.
- `power` (Number): Magnitude of effect (e.g., 40 HP restored)
- `description` (String): Flavor text shown in inventory
- `usable_in_battle` (Boolean): Can be used in battle?
- `usable_in_field` (Boolean): Can be used in overworld?

---

## Enemy Schema (data/enemies.json)

### Enemy Object Structure

```json
{
  "id": "enemy_unique_id",
  "name": "Display Name",
  "hp": 100,
  "atk": 15,
  "def": 5,
  "agi": 10,
  "exp_reward": 50,
  "gold_reward": 20,
  "sprite_path": "res://sprites/enemies/enemy.png",
  "skills": ["skill_id_1", "skill_id_2"]
}
```

**Fields**:
- `id` (String): Unique identifier
- `name` (String): Display name in battle
- `hp` (Number): Base HP
- `atk` (Number): Attack stat
- `def` (Number): Defense stat
- `agi` (Number): Agility stat (turn order)
- `exp_reward` (Number): EXP awarded on defeat
- `gold_reward` (Number): Gold awarded on defeat
- `sprite_path` (String): Path to enemy sprite
- `skills` (Array): Array of skill IDs this enemy can use

---

## Skill Schema (data/skills.json)

### Skill Object Structure

```json
{
  "id": "skill_unique_id",
  "name": "Display Name",
  "mp_cost": 10,
  "power": 30,
  "target_type": "single_enemy",
  "element": "fire",
  "description": "Flavor text describing the skill.",
  "animation": "fire_effect"
}
```

**Fields**:
- `id` (String): Unique identifier
- `name` (String): Display name in battle menu
- `mp_cost` (Number): MP required to use
- `power` (Number): Base damage/effect magnitude
- `target_type` (String): "single_enemy", "all_enemies", "self", "single_ally"
- `element` (String): "physical", "fire", "ice", "lightning", etc.
- `description` (String): Flavor text shown in skill menu
- `animation` (String, optional): Animation to play on use

---

## Loading and Parsing JSON

All JSON files are loaded using Godot's `FileAccess` and `JSON` classes.

### Example Loading Code

```gdscript
func load_dialogue(dialogue_id: String) -> Dictionary:
    var path = "res://data/dialogues/" + dialogue_id + ".json"
    var file = FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Failed to load dialogue: " + dialogue_id)
        return {}

    var json_string = file.get_as_text()
    file.close()

    var json = JSON.new()
    var parse_result = json.parse(json_string)
    if parse_result != OK:
        push_error("Failed to parse dialogue JSON: " + dialogue_id)
        return {}

    return json.data
```

---

## Design Guidelines

### Dialogue Writing

- **Keep lines short**: 1-2 sentences per node (max 120 characters)
- **Use node chains**: Break long speeches into multiple nodes
- **Avoid walls of text**: Better to have more nodes than long paragraphs
- **Character voice**: Each character should have a distinct speaking style
  - Elder: Formal, cryptic, authoritative
  - Companion: Casual, curious, supportive
  - Archivist Shade: Philosophical, melancholic, formal

### Choice Design

- **Limit to 2-3 choices**: More than 3 can overwhelm the player
- **Make choices clear**: Each choice should have a distinct outcome
- **Use set_flag strategically**: Flags should gate meaningful content
- **Provide context**: Choices should be informed (player knows what they're choosing)

### Flag Naming

- Use `snake_case` for consistency
- Be descriptive: `accepted_quest` not `q1`
- Use past tense for completed actions: `defeated_boss`, `freed_memory`
- Use present tense for states: `has_clapper`, `knows_secret`

---

## Testing Checklist

- [ ] All dialogue JSON files parse without errors
- [ ] All node IDs are unique within their dialogue tree
- [ ] All `next` and `choice.next` references point to valid node IDs
- [ ] All `set_flag` and `check_flag` names match GameState flag dictionary
- [ ] Dialogue trees have clear end points (node with `next: null`)
- [ ] No orphaned nodes (nodes that can't be reached)
- [ ] Typewriter effect displays correctly for all text lengths
- [ ] Choice buttons fit within UI bounds (text not too long)
- [ ] Flags are set correctly when choices are selected
- [ ] Conditional choices appear/disappear based on flags
- [ ] Dialogue box hides correctly when dialogue ends
- [ ] Player movement is disabled during dialogue

---

## Future Expansion (Post-MVP)

Potential features for later versions:

- **Portraits**: Add `portrait` field to nodes for character images
- **Voice**: Add `voice_line` field for audio file paths
- **Camera control**: Add `camera_target` for cutscene camera movement
- **Character animation**: Add `speaker_anim` to trigger character expressions
- **Conditional text**: Use `{flag}` syntax to change text based on flags
- **Variables**: Support `{player_name}` or `{gold}` in dialogue text
- **Script hooks**: Add `on_enter_script` field to run custom code when node displays

---

## Revision History

- **v1.0** (2026-02-06): Initial specification
