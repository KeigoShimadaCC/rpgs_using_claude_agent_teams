# Maps and UI Documentation

## Maps

### Map A - Village Hub
**Scene**: `res://scenes/overworld/map_a_village.tscn`
**Size**: 320x240 pixels (20x16 tiles at 16px)

**Layout**:
- Ground: Green grass color (0.4, 0.6, 0.3)
- Paths: Brown dirt paths crossing the village
- Buildings: 4 houses (brown rectangles) placed at corners
- Walls: Gray boundary walls around entire map

**NPCs**:
1. **Elder NPC** - Position: (160, 60)
   - Color: Gray (0.8, 0.8, 0.8)
   - Dialogue ID: `elder_intro`
   - Central NPC for quest

2. **Companion NPC** - Position: (160, 180)
   - Color: Green (0.4, 0.8, 0.4)
   - Dialogue ID: `companion_intro`

**Triggers**:
- **ToMapB** - Position: (280, 120)
  - Type: MAP_TRANSITION
  - Target: `res://scenes/overworld/map_b_field.tscn`
  - Spawn marker: "FromMapA"
  - Visual: Yellow transparent rectangle

**Spawn Points**:
- **PlayerSpawn**: (40, 120) - Default spawn
- **FromMapB**: (260, 120) - When returning from Map B

---

### Map B - Field/Ruins
**Scene**: `res://scenes/overworld/map_b_field.tscn`
**Size**: 400x320 pixels (25x20 tiles at 16px)

**Layout**:
- Ground: Darker green field (0.35, 0.5, 0.25)
- Path: Brown dirt path running horizontally
- Ruins Area: Gray stone area (0.4, 0.4, 0.45) in southeast
- Obstacles: Rocks and ruin pillars for visual interest
- Walls: Gray boundary walls around entire map

**Encounter Zones** (3 total):
1. **EncounterZone1** - Position: (100, 80)
   - Size: 80x60 area
   - Enemy pool: ["slime", "slime"] or ["goblin"]
   - Difficulty: Easy
   - Visual: Red transparent overlay

2. **EncounterZone2** - Position: (200, 160)
   - Size: 100x80 area
   - Enemy pool: ["goblin", "slime"] or ["goblin", "goblin"]
   - Difficulty: Medium
   - Visual: Red transparent overlay

3. **EncounterZone3** - Position: (180, 260)
   - Size: 120x70 area
   - Enemy pool: ["shadow_wolf"] or ["shadow_wolf", "goblin"]
   - Difficulty: Hard
   - Visual: Red transparent overlay

**Triggers**:
- **ToMapA** - Position: (20, 160)
  - Type: MAP_TRANSITION
  - Target: `res://scenes/overworld/map_a_village.tscn`
  - Spawn marker: "FromMapB"
  - Visual: Yellow transparent rectangle

- **BossTrigger** - Position: (340, 270)
  - Type: Custom (boss_trigger.gd)
  - Required flag: "accepted_quest"
  - Boss dialogue: "boss_intro"
  - Boss enemy: "archivist_shade"
  - Blocked message: "The path to the ruins is blocked by an invisible force. Perhaps the Elder knows more..."
  - Visual: Red transparent overlay (larger)

**Spawn Points**:
- **PlayerSpawn**: (40, 160) - Default spawn
- **FromMapA**: (40, 160) - When entering from Map A

---

## UI Screens

### Title Screen
**Scene**: `res://scenes/main/title_screen.tscn`
**Script**: `res://scripts/ui/title_screen.gd`

**Features**:
- Game title: "The Silent Bell"
- Background: Dark blue gradient (0.1, 0.15, 0.25)
- New Game button - Resets GameState and loads Map A
- Quit button - Exits game
- Version label in corner
- Keyboard navigation supported

**Behavior**:
- On New Game: Calls `GameState.reset_player()` then loads map_a_village.tscn
- On Quit: Calls `get_tree().quit()`

---

### Game Over Screen
**Scene**: `res://scenes/main/game_over.tscn`
**Script**: `res://scripts/ui/game_over.gd`

**Features**:
- "Game Over" title in red (1, 0.3, 0.3)
- Background: Dark red (0.15, 0.05, 0.05)
- Message: "You have been defeated..."
- Return to Title button - Goes back to title screen
- Quit button - Exits game
- Keyboard navigation supported

**Behavior**:
- Triggered when player is defeated in battle
- Restart button returns to title_screen.tscn

---

### Dialogue Box
**Scene**: `res://scenes/dialogue/dialogue_box.tscn` (Autoloaded as "DialogueBox")
**Script**: `res://scripts/ui/dialogue_box.gd`

**Features**:
- Panel anchored to bottom of screen
- Speaker name label (yellow/gold color)
- Dialogue text (RichTextLabel with BBCode support)
- Typewriter effect (40 characters per second)
- Continue prompt: "▼ Press Space to continue"
- Choice buttons container (VBoxContainer)
- Blocks player movement while active

**Integration with DialogueManager**:
- Connects to `dialogue_node_changed` signal
- Connects to `dialogue_ended` signal
- Calls `DialogueManager.continue_dialogue()` on advance
- Calls `DialogueManager.select_choice(index)` on choice selection

**Behavior**:
- Shows dialogue with typewriter effect
- Pressing Space/E skips typewriter or advances dialogue
- Displays choice buttons when dialogue has choices
- Hides when dialogue ends
- Re-enables player movement on close

---

## Supporting Scripts

### map_controller.gd
**Path**: `res://scripts/overworld/map_controller.gd`

**Purpose**: Handles player spawn positioning when entering maps

**How it works**:
1. Checks for spawn metadata set by transition triggers
2. Looks for spawn marker name or spawn position
3. Positions player at correct location
4. Falls back to default "PlayerSpawn" marker if no metadata

**Used by**: Both Map A and Map B

---

### boss_trigger.gd
**Path**: `res://scripts/overworld/boss_trigger.gd`

**Purpose**: Specialized trigger for boss encounter

**Features**:
- Quest flag checking (blocks access until flag is set)
- Triggers boss intro dialogue before battle
- Starts boss battle with `is_boss_battle = true` (prevents running)
- Handles boss victory (sets "defeated_boss" flag, triggers ending)
- Handles boss defeat (game over screen)

**Used by**: Map B boss area

---

## Visual Style

All maps and UI use a consistent simple geometric art style:

**Colors**:
- Player: Blue square (0.2, 0.6, 1)
- NPCs: Yellow square (1, 0.8, 0.2)
  - Elder: Gray variant (0.8, 0.8, 0.8)
  - Companion: Green variant (0.4, 0.8, 0.4)
- Ground: Green/brown tones
- Buildings: Brown (0.6, 0.4, 0.2)
- Walls: Gray (0.3, 0.3, 0.3)
- Obstacles: Gray (0.5, 0.5, 0.5)
- Ruins: Darker gray (0.6, 0.6, 0.65)

**Shapes**: All visual elements use Polygon2D nodes with simple rectangles or polygons

---

## Collision Layers

- Layer 1 (World): Walls, buildings, obstacles
- Layer 2 (Player): Player character
- Layer 3 (NPC): NPC characters
- Layer 4 (Trigger): Interaction and map transition triggers

---

## Testing Checklist

### Map A - Village
- [ ] Player spawns at correct position
- [ ] Can walk around village
- [ ] Collides with walls and buildings
- [ ] Can interact with Elder NPC
- [ ] Can interact with Companion NPC
- [ ] Transition to Map B works
- [ ] Returns to correct position when coming back from Map B

### Map B - Field
- [ ] Player spawns at correct position
- [ ] Can walk around field
- [ ] Collides with walls and obstacles
- [ ] Encounter Zone 1 triggers battle with slimes
- [ ] Encounter Zone 2 triggers battle with goblins
- [ ] Encounter Zone 3 triggers battle with shadow wolf
- [ ] Transition back to Map A works
- [ ] Boss area is blocked without quest flag
- [ ] Boss area is accessible with quest flag
- [ ] Boss dialogue triggers before battle
- [ ] Boss battle starts correctly

### Title Screen
- [ ] Displays correctly
- [ ] New Game button works
- [ ] Quit button works
- [ ] Game state resets on New Game

### Game Over Screen
- [ ] Displays when player is defeated
- [ ] Return to Title button works
- [ ] Quit button works

### Dialogue Box
- [ ] Shows at bottom of screen
- [ ] Typewriter effect works
- [ ] Can skip typewriter with Space
- [ ] Continue prompt appears
- [ ] Choice buttons display correctly
- [ ] Player movement blocked during dialogue
- [ ] Player movement restored after dialogue
