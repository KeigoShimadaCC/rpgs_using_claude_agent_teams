# Godot Development Patterns & Best Practices

This document outlines the core coding patterns used in "The Silent Bell" to ensure scalability and maintainability.

## 1. Async Operations & Flow Control

Most game events (battles, dialogues, transitions) are asynchronous. We use Godot's `await` keyword extensively.

### Correct Await Pattern
When calling a function that performs an animation or timer, always `await` it if the sequence of events matters.

```gdscript
# PREFERRED: Sequence is clear
await play_animation()
await display_text("Hello")
transition_to_next_state()

# AVOID: text might overlap with animation
play_animation()
display_text("Hello") 
```

### Timer Usage
Using `get_tree().create_timer()` is the preferred way to add delays during logic flow.

```gdscript
await get_tree().create_timer(0.5).timeout
```

## 2. State Persistence (GameState)

The `GameState` singleton is the source of truth for the player's progress. 

### Rules for GameState
1. **Don't store local system state**: Local UI state or battle-only variables should stay in their respective controllers.
2. **Persistence**: Only variables that need to persist across scenes or save files belong in `GameState` (HP, MP, Level, Steps, Flags).
3. **Signals**: `GameState` should emit signals when important values change so UIs can update reactively.

## 3. Encounter System (Distance-Based)

To ensure encounters feel consistent regardless of frame rate or movement speed, we use a distance-based step counter.

### Implementation Detail
Instead of checking "did the player move this frame?", we accumulate distance.

```gdscript
# In player_controller.gd
distance_accumulator += global_position.distance_to(previous_position)
if distance_accumulator >= STEP_DISTANCE:
    var steps = int(distance_accumulator / STEP_DISTANCE)
    GameState.steps_since_battle += steps
    distance_accumulator -= steps * STEP_DISTANCE
```

*   `STEP_DISTANCE` is set to 32.0 (the size of a standard tile).
*   Encounters are prevented for 5 steps after a battle via `GameState.grace_period_steps`.

## 4. Battle System Flow

The battle system uses a state machine logic. One of the most critical patterns is the turn continuation check.

### Turn Continuation Pattern
Every player action (Attack, Skill, Item, Auto) must eventually call the continuation check.

```gdscript
func _check_victory_and_continue() -> void:
    if all_enemies_defeated():
        trigger_victory()
        return
    
    # Otherwise, proceed to enemy turn
    start_enemy_turn()
```

When implementing new actions, ensure you `await` the action execution before checking for victory.

## 5. Metadata for Transitions

We use Godot's `meta` system to pass data between scenes (like spawn positions).

```gdscript
# Before transition
get_tree().root.set_meta("spawn_position", Vector2(100, 200))

# After transition (in map_controller.gd)
if get_tree().root.has_meta("spawn_position"):
    player.global_position = get_tree().root.get_meta("spawn_position")
```

## ⚠️ Things to be Careful About

1. **Standalone Scripts**: Running scripts via `godot --script` does NOT load singletons (Autoloads). See `TESTING.md` for how to handle this.
2. **Duplicate Awaits**: Be careful not to `await` twice on the same signal if it can be emitted multiple times unexpectedly.
3. **UI/Logic Coupling**: Keep battle logic in `battle_system.gd` and UI in `battle_ui.gd`. Communicate via signals or direct method calls from Logic -> UI.
