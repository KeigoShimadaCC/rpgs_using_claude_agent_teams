# Ending Sequence Documentation

## Overview

The ending sequence is the narrative climax of "The Silent Bell" MVP. It presents the player with a meaningful choice that affects the resolution and provides a satisfying conclusion to the 15-20 minute experience.

---

## Ending Flow

### 1. Boss Victory Trigger
**Location**: Map B - Boss Trigger Area
**Script**: `scripts/overworld/boss_trigger.gd`

When the player defeats the Archivist Shade boss:

```gdscript
func _on_boss_victory(exp_gained: int, gold_gained: int) -> void:
    GameState.add_exp(exp_gained)
    GameState.add_gold(gold_gained)
    GameState.set_flag("defeated_boss", true)
    GameState.add_item("bell_clapper", 1)
    GameState.set_flag("has_clapper", true)

    # Trigger ending sequence
    get_tree().change_scene_to_file("res://scenes/main/ending_cutscene.tscn")
```

**Flags Set**:
- `defeated_boss`: true
- `has_clapper`: true

**Item Granted**:
- `bell_clapper` (key item)

---

### 2. Ending Cutscene Controller
**Scene**: `scenes/main/ending_cutscene.tscn`
**Script**: `scripts/ui/ending_cutscene.gd`

The ending cutscene orchestrates a multi-stage dialogue sequence:

#### Stage 1: Aftermath (AFTERMATH state)
- Fade in from black
- Show `boss_defeat` dialogue (Archivist's final words)
- "The choice is yours now. I can no longer decide."

#### Stage 2: The Choice (CHOICE state)
- Show `ending_choice` dialogue
- Companion appears and explains the two paths
- Player chooses between:
  - **"Return the clapper to the Elder"** → Sets `returned_memory` flag
  - **"Break the seal and free the memory"** → Sets `freed_memory` flag

#### Stage 3: Resolution (RESOLUTION state)
- Sets `made_choice` flag
- Fade to black transition
- Shows appropriate ending dialogue:
  - If `returned_memory` → `ending_return` dialogue
  - If `freed_memory` → `ending_free` dialogue

#### Stage 4: Credits (CREDITS state)
- Fade to black
- Loads `victory_screen.tscn`

---

## Dialogue Files

### boss_defeat.json
**Dialogue ID**: `boss_defeat`
**Purpose**: Archivist Shade's final words after defeat

**Flow**:
- Archivist acknowledges player's strength
- Explains duty is ending after centuries
- Passes burden of choice to player
- Fades away, leaving clapper behind

**Nodes**: 4 (start → release → final_words → fade)

---

### ending_choice.json
**Dialogue ID**: `ending_choice`
**Purpose**: Present the critical choice to the player

**Flow**:
- Player holds the clapper (narration)
- Companion appears and asks what player will do
- Companion explains both options
- Player makes the choice (branching dialogue)
- Companion reacts to choice

**Key Nodes**:
- `the_choice`: Presents two choice buttons
  - Choice 1: "Return the clapper to the Elder" → Sets `returned_memory`
  - Choice 2: "Break the seal and free the memory" → Sets `freed_memory`

**Nodes**: 10 (linear → branch → 2 endings)

---

### ending_return.json
**Dialogue ID**: `ending_return`
**Purpose**: Ending A - Player chose to return the clapper

**Tone**: Bittersweet relief, safety through ignorance

**Flow**:
- Player returns to village
- Elder receives clapper, installs it
- Bell rings, time flows correctly again
- Elder thanks player: "The past is buried, as it should be"
- Companion is quiet, knowing what was sacrificed
- Final reflection: "You know the silence beneath the sound"

**Themes**:
- Order preserved through control of knowledge
- Peace maintained but truth suppressed
- Hero carries burden of knowing what others don't

**Nodes**: 11 (linear narrative)

---

### ending_free.json
**Dialogue ID**: `ending_free`
**Purpose**: Ending B - Player chose to free the memory

**Tone**: Uncertain hope, freedom through truth

**Flow**:
- Seal breaks, memory floods back to all villagers
- Everyone remembers the founders' crime
- Elder confronts player: "You've doomed us to division"
- Companion defends choice: "We can be better than our founders"
- Bell rings with different, clearer sound
- Villagers react with shock, anger, but also gratitude
- Time flows again, cycle restored
- Final reflection: "The truth is free. The future is uncertain. But it is yours."

**Themes**:
- Truth over comfort
- Growth requires facing the past
- Freedom comes with responsibility
- Uncertain but authentic future

**Nodes**: 14 (linear narrative)

---

## Victory Screen

**Scene**: `scenes/main/victory_screen.tscn`
**Script**: `scripts/ui/victory_screen.gd`

### Display Content

**Title**: "The Silent Bell"

**Ending Message** (changes based on choice):
- If `returned_memory`: "The bell rings once more. The past remains sealed. Order is preserved, but the truth stays hidden."
- If `freed_memory`: "The bell rings with a new voice. The truth is free. The future is uncertain, but it is yours to shape."

**Credits**:
```
— Credits —

Story & Dialogue: Agent C
Gameplay Systems: Agent A
Battle System: Agent B
Maps & UI: Agent D
Project Lead: Team Lead

Thank you for playing!
```

**Buttons**:
- "Return to Title" → Returns to `title_screen.tscn`
- "Quit" → Exits game

### Visual Effects
- Fade in from black (1.5 seconds)
- Dark blue background (0.08, 0.1, 0.15)
- Golden title text
- White message text
- Gray credits text

---

## Quest Flags Reference

### Flags Set During Ending Sequence

| Flag Name | When Set | Purpose |
|-----------|----------|---------|
| `defeated_boss` | Boss victory | Marks boss completion |
| `has_clapper` | Boss victory | Player obtained key item |
| `returned_memory` | Player choice A | Ending A selected |
| `freed_memory` | Player choice B | Ending B selected |
| `made_choice` | After choice dialogue | Player has made final decision |

---

## Scene Flow Diagram

```
Boss Battle Victory
        ↓
boss_trigger.gd (_trigger_ending)
        ↓
ending_cutscene.tscn [Fade in]
        ↓
DialogueManager.start_dialogue("boss_defeat")
  → Archivist's final words
        ↓
DialogueManager.start_dialogue("ending_choice")
  → Companion explains choice
  → Player selects choice
  → Set flag: "returned_memory" OR "freed_memory"
        ↓
[Fade to black, fade in]
        ↓
DialogueManager.start_dialogue("ending_return" OR "ending_free")
  → Show consequence of choice
  → Bell rings, time restored
  → Village/world reacts
        ↓
[Fade to black]
        ↓
victory_screen.tscn
  → Credits
  → Ending message (based on choice)
  → Return to Title or Quit
```

---

## Design Philosophy

### Meaningful Choice
The choice is designed to have **no objectively "correct" answer**:

**Return Memory (A)**:
- ✅ Peace and stability
- ✅ Elder maintains order
- ✅ Village functions normally
- ❌ Truth suppressed
- ❌ History repeats?
- ❌ Hero carries burden alone

**Free Memory (B)**:
- ✅ Truth revealed
- ✅ Village can grow from past
- ✅ Honesty and transparency
- ❌ Division and conflict
- ❌ Painful reckoning
- ❌ Uncertain future

### Emotional Resolution
Both endings provide closure:
- **Time bell rings again** → Core problem solved
- **Cycle restored** → World returns to balance
- **Consequence shown** → Player sees impact of choice
- **Reflection moment** → Player considers what was gained/lost

### Playtime Target
Total ending sequence: **5-7 minutes**
- Boss defeat dialogue: 30 seconds
- Choice presentation: 1-2 minutes
- Resolution dialogue: 2-3 minutes
- Victory screen: 1-2 minutes

---

## Testing Checklist

### Ending Sequence Flow
- [ ] Boss victory triggers ending cutscene
- [ ] Fade in effect works
- [ ] boss_defeat dialogue displays correctly
- [ ] ending_choice dialogue displays correctly
- [ ] Choice buttons appear and are functional
- [ ] Selecting choice A sets `returned_memory` flag
- [ ] Selecting choice B sets `freed_memory` flag
- [ ] Fade transition between choice and resolution
- [ ] ending_return displays if choice A selected
- [ ] ending_free displays if choice B selected
- [ ] Final fade to black works
- [ ] Victory screen loads correctly

### Victory Screen
- [ ] Correct ending message displays based on choice
- [ ] Credits display properly
- [ ] "Return to Title" button works
- [ ] "Quit" button works
- [ ] Fade in effect works
- [ ] Text is readable and properly aligned

### Quest Flags
- [ ] `defeated_boss` set after boss victory
- [ ] `has_clapper` set after boss victory
- [ ] `returned_memory` set when choice A selected
- [ ] `freed_memory` set when choice B selected
- [ ] `made_choice` set before resolution dialogue
- [ ] No flags overwrite each other incorrectly

### Edge Cases
- [ ] No softlock if player closes game during ending
- [ ] Both endings feel complete and satisfying
- [ ] Text doesn't overflow UI boundaries
- [ ] Dialogues can be advanced at appropriate pace
- [ ] Buttons respond to keyboard and mouse input

---

## Future Enhancements (Post-MVP)

- **Music**: Add emotional music for ending sequences
- **Sound effects**: Bell ringing sound, seal breaking sound
- **Visual effects**: Particle effects for seal breaking, light effects
- **Illustrations**: Character portraits or ending artwork
- **Extended credits**: Scrolling credits with music
- **Save ending choice**: Track which ending player achieved
- **Replay option**: Allow replaying from title with different choice
- **Stat summary**: Show playtime, battles won, level reached

---

## Integration Notes

### For Other Agents

**Agent B (Battle System)**:
- Boss victory already calls `boss_trigger._on_boss_victory()`
- No changes needed to battle system

**Agent D (Maps/UI)**:
- Victory screen uses same visual style as other UI screens
- No map integration needed for ending

**Agent A (Gameplay)**:
- No overworld interaction during ending
- Player movement disabled during cutscene (handled by DialogueBox)

### For Team Lead

The ending sequence is **self-contained** and requires no additional integration. Once the boss is defeated, the ending_cutscene takes full control until returning to title screen.

---

## Known Limitations

- **No save system**: Player cannot save during ending (acceptable for MVP)
- **No skip option**: Player must watch full ending (appropriate for short game)
- **Single playthrough**: No easy way to replay for other ending (acceptable for MVP)
- **No branching earlier**: Choice only affects ending, not earlier story (by design)

---

## Conclusion

The ending sequence provides a satisfying, emotionally resonant conclusion to "The Silent Bell" that:
- Gives player meaningful agency through choice
- Shows clear consequences of that choice
- Maintains thematic consistency (truth vs. order)
- Delivers complete story arc within 15-20 minute playtime
- Feels appropriate for MVP scope while being production-ready

Both endings are **complete, polished, and ready to play**.
