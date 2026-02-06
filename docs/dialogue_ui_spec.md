# Dialogue Box UI Implementation Specification

## For Agent D (Map/UX Implementer)

This document specifies how to build the DialogueBox UI that integrates with the DialogueManager singleton.

---

## Scene File

**Path**: `/scenes/dialogue/dialogue_box.tscn`

**Root Node**: CanvasLayer (so it always renders on top of gameplay)

---

## Node Structure

```
CanvasLayer (DialogueBox)
└── Panel (Background)
    ├── MarginContainer (Padding)
    │   └── VBoxContainer (Layout)
    │       ├── Label (SpeakerNameLabel)
    │       ├── RichTextLabel (DialogueTextLabel)
    │       ├── Label (ContinuePrompt)
    │       └── VBoxContainer (ChoicesContainer)
```

---

## Component Details

### 1. Panel (Background)

**Purpose**: Visual background for the dialogue box

**Properties**:
- Anchors: Bottom-left and bottom-right (stretch horizontally at bottom of screen)
- Size: Full width, ~200-250px height
- Custom StyleBox: Semi-transparent dark panel with border
- Position: Bottom of screen with small margin

**Recommended Style**:
- Background color: Black with 80% opacity
- Border: 2px white or light gray
- Padding: 10-15px on all sides

---

### 2. MarginContainer

**Purpose**: Add padding inside the panel

**Properties**:
- Margin: 15px on all sides (top, bottom, left, right)
- Anchor: Fill parent

---

### 3. VBoxContainer (Main Layout)

**Purpose**: Arrange dialogue components vertically

**Properties**:
- Separation: 8px between children
- Anchor: Fill parent

---

### 4. SpeakerNameLabel (Label)

**Purpose**: Display the name of the character speaking

**Properties**:
- Name: `SpeakerNameLabel`
- Custom font (optional): Bold, slightly larger than body text
- Font size: 18-20px
- Color: White or yellow (for emphasis)
- Autowrap: Off
- Visible by default: true

**Script Behavior**:
- Hide this label when speaker is null or empty (for narration)
- Update text when node changes

**Example Text**: "Elder", "Companion", "Archivist Shade"

---

### 5. DialogueTextLabel (RichTextLabel)

**Purpose**: Display the dialogue text with typewriter effect

**Properties**:
- Name: `DialogueTextLabel`
- Fit Content Height: On (expands to fit text)
- BBCode Enabled: true (allows bold, italic, color tags)
- Font size: 16px
- Color: White
- Autowrap: On
- Visible_characters: 0 (for typewriter effect)

**Script Behavior**:
- Implement typewriter effect using `visible_characters` property
- Reveal characters gradually over time (e.g., 2-3 characters per frame at 60 FPS)
- Allow player to skip typewriter by pressing Space/Enter (show all text immediately)
- Update text when node changes

**Typewriter Effect Example**:
```gdscript
var text_speed = 2  # characters per frame
var current_visible = 0
var total_characters = 0
var typewriter_finished = false

func start_typewriter(text: String):
    DialogueTextLabel.text = text
    total_characters = text.length()
    current_visible = 0
    typewriter_finished = false
    DialogueTextLabel.visible_characters = 0

func _process(delta):
    if not typewriter_finished:
        current_visible += text_speed
        DialogueTextLabel.visible_characters = current_visible
        if current_visible >= total_characters:
            typewriter_finished = true
            ContinuePrompt.visible = true

func skip_typewriter():
    DialogueTextLabel.visible_characters = total_characters
    current_visible = total_characters
    typewriter_finished = true
    ContinuePrompt.visible = true
```

---

### 6. ContinuePrompt (Label)

**Purpose**: Show a prompt to continue when text is fully displayed

**Properties**:
- Name: `ContinuePrompt`
- Text: "[Space/Enter to continue]" or "▼" (down arrow)
- Font size: 12-14px
- Color: Light gray or white
- Horizontal alignment: Right or Center
- Visible by default: false

**Script Behavior**:
- Show only when typewriter effect is finished AND there are no choices
- Hide when choices are displayed
- Optional: Add blinking animation using AnimationPlayer

**Alternative**: Use a TextureRect with a blinking arrow sprite instead of text

---

### 7. ChoicesContainer (VBoxContainer)

**Purpose**: Hold dynamically created choice buttons

**Properties**:
- Name: `ChoicesContainer`
- Separation: 5-8px between buttons
- Visible by default: false

**Script Behavior**:
- Clear all children when new node is displayed
- Create Button nodes dynamically when choices are presented
- Connect each button's `pressed` signal to `_on_choice_selected(index)`
- Hide when there are no choices (linear dialogue)

**Choice Button Creation**:
```gdscript
func display_choices(choices: Array):
    # Clear existing buttons
    for child in ChoicesContainer.get_children():
        child.queue_free()

    # Create new buttons
    for i in range(choices.size()):
        var button = Button.new()
        button.text = choices[i].text
        button.pressed.connect(_on_choice_selected.bind(i))
        ChoicesContainer.add_child(button)

    # Show choices, hide continue prompt
    ChoicesContainer.visible = true
    ContinuePrompt.visible = false

func _on_choice_selected(choice_index: int):
    DialogueManager.select_choice(choice_index)
```

---

## Script File

**Path**: `/scripts/ui/dialogue_box.gd`

**Extends**: CanvasLayer (or the root node type of the scene)

---

## Script Structure

### Variables

```gdscript
@onready var speaker_label = $Panel/MarginContainer/VBoxContainer/SpeakerNameLabel
@onready var dialogue_label = $Panel/MarginContainer/VBoxContainer/DialogueTextLabel
@onready var continue_prompt = $Panel/MarginContainer/VBoxContainer/ContinuePrompt
@onready var choices_container = $Panel/MarginContainer/VBoxContainer/ChoicesContainer

var text_speed = 2  # characters per frame
var current_visible = 0
var total_characters = 0
var typewriter_finished = false
```

---

### Methods

#### `_ready()`

Connect to DialogueManager signals:

```gdscript
func _ready():
    # Hide dialogue box initially
    hide()

    # Connect to DialogueManager signals
    DialogueManager.dialogue_started.connect(_on_dialogue_started)
    DialogueManager.node_changed.connect(_on_node_changed)
    DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
    DialogueManager.choices_presented.connect(_on_choices_presented)
```

---

#### `_on_dialogue_started(dialogue_id: String)`

Show the dialogue box and disable player movement:

```gdscript
func _on_dialogue_started(dialogue_id: String):
    show()
    # Disable player input (optional, handled by player script checking DialogueManager.is_active())
```

---

#### `_on_node_changed(node_data: Dictionary)`

Update UI with new dialogue node:

```gdscript
func _on_node_changed(node_data: Dictionary):
    # Update speaker name
    var speaker = node_data.get("speaker", "")
    if speaker == "" or speaker == null:
        speaker_label.visible = false
    else:
        speaker_label.visible = true
        speaker_label.text = speaker

    # Start typewriter effect for dialogue text
    var text = node_data.get("text", "")
    start_typewriter(text)

    # Hide choices (will be shown if choices_presented is emitted)
    choices_container.visible = false
    for child in choices_container.get_children():
        child.queue_free()

    # Hide continue prompt (will be shown when typewriter finishes)
    continue_prompt.visible = false
```

---

#### `_on_dialogue_ended()`

Hide the dialogue box and re-enable player movement:

```gdscript
func _on_dialogue_ended():
    hide()
    # Re-enable player input (optional, player script checks DialogueManager.is_active())
```

---

#### `_on_choices_presented(choices: Array)`

Display choice buttons:

```gdscript
func _on_choices_presented(choices: Array):
    # Clear existing buttons
    for child in choices_container.get_children():
        child.queue_free()

    # Create new buttons for each choice
    for i in range(choices.size()):
        var button = Button.new()
        button.text = choices[i].text
        button.pressed.connect(_on_choice_selected.bind(i))
        choices_container.add_child(button)

    # Show choices, hide continue prompt
    choices_container.visible = true
    continue_prompt.visible = false
```

---

#### `_on_choice_selected(choice_index: int)`

Handle choice button press:

```gdscript
func _on_choice_selected(choice_index: int):
    DialogueManager.select_choice(choice_index)
```

---

#### `start_typewriter(text: String)`

Begin typewriter effect:

```gdscript
func start_typewriter(text: String):
    dialogue_label.text = text
    total_characters = text.length()
    current_visible = 0
    typewriter_finished = false
    dialogue_label.visible_characters = 0
```

---

#### `_process(delta)`

Update typewriter effect:

```gdscript
func _process(delta):
    if not typewriter_finished and visible:
        current_visible += text_speed
        dialogue_label.visible_characters = current_visible

        if current_visible >= total_characters:
            typewriter_finished = true
            # Show continue prompt only if no choices
            if not choices_container.visible:
                continue_prompt.visible = true
```

---

#### `_unhandled_input(event)`

Handle player input for advancing dialogue:

```gdscript
func _unhandled_input(event):
    if not DialogueManager.is_active():
        return

    if event.is_action_pressed("ui_accept"):  # Space/Enter
        if not typewriter_finished:
            # Skip typewriter effect
            skip_typewriter()
        elif typewriter_finished and not choices_container.visible:
            # Advance to next node
            DialogueManager.advance()

func skip_typewriter():
    dialogue_label.visible_characters = total_characters
    current_visible = total_characters
    typewriter_finished = true
    continue_prompt.visible = true
```

---

## Input Actions

Make sure these input actions are defined in Project Settings:

- `ui_accept`: Space, Enter, Gamepad A button (for advancing dialogue)

---

## Integration with Player Controller

The player controller should check if dialogue is active before accepting movement input:

```gdscript
# In player_controller.gd or player.gd
func _process(delta):
    if DialogueManager.is_active():
        # Disable movement during dialogue
        return

    # Normal movement code...
```

---

## Visual Style Recommendations

### Font

Use a pixel art font or a clean sans-serif font:
- Recommended: Press Start 2P (free pixel font)
- Alternative: Liberation Sans, Roboto

### Colors

- Background: Black (#000000) with 80% opacity
- Border: White (#FFFFFF) or light gray (#CCCCCC)
- Speaker name: Yellow (#FFFF00) or cyan (#00FFFF)
- Dialogue text: White (#FFFFFF)
- Continue prompt: Light gray (#AAAAAA)

### Sizing

- Dialogue box height: 200-250px
- Speaker name font: 18-20px
- Dialogue text font: 16px
- Continue prompt font: 12-14px
- Button font: 14-16px

---

## Testing Checklist

- [ ] Dialogue box appears when DialogueManager.start_dialogue() is called
- [ ] Speaker name updates correctly for each node
- [ ] Typewriter effect reveals text gradually
- [ ] Pressing Space/Enter skips typewriter effect
- [ ] Continue prompt appears when text is fully displayed
- [ ] Pressing Space/Enter advances to next node (when no choices)
- [ ] Choice buttons appear when choices are presented
- [ ] Clicking a choice button triggers DialogueManager.select_choice()
- [ ] Dialogue box hides when dialogue ends
- [ ] Player movement is disabled during dialogue
- [ ] Player movement is re-enabled when dialogue ends
- [ ] Text wraps correctly within dialogue box bounds
- [ ] Long speaker names don't overflow
- [ ] Choice button text doesn't overflow

---

## Optional Enhancements (Post-MVP)

- **Sound effects**: Play sound on text reveal, button press, dialogue end
- **Character portraits**: Show character image next to dialogue
- **Text animations**: Shake text for emphasis, color tags for mood
- **Name box**: Separate panel for speaker name (like classic JRPGs)
- **Dialogue history**: Log of previous dialogue lines
- **Fast-forward**: Hold Space to speed up typewriter effect
- **Auto-advance**: Option to automatically advance after delay

---

## Reference Dialogue Scenes

For inspiration, look at these classic JRPG dialogue systems:
- Final Fantasy (separate name box, centered text)
- Dragon Quest (full-width box at bottom)
- Earthbound (speech bubbles for NPCs)
- Undertale (border animations, character sounds)

For this MVP, keep it simple: a clean box at the bottom with clear text and functional buttons.

---

## Questions?

If you need clarification on any part of this spec, contact Agent C (Scenario/Content Designer) or refer to `/docs/content_schemas.md` for the full dialogue system specification.
