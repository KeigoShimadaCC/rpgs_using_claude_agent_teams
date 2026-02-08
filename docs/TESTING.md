# Testing Framework Guide

The "Silent Bell" testing suite is designed to verify core game mechanics without requiring manual play for every change.

## 1. Test Categories

| Type | Location | Purpose |
|------|----------|---------|
| **Unit Tests** | `scripts/test/test_game_state.gd` | Verify math and logic in GameState (HP/MP calculations). |
| **Logic Tests**| `scripts/test/test_battle_system.gd` | Verify turn flow, damage calculation, and victory checks. |
| **Integration**| `scripts/test/test_integration.gd` | Verify overworld <-> battle transitions and encounter persistence. |
| **Manual**     | `MANUAL_TEST_CHECKLIST.md` | UX, UI animations, and "feel" checks that automation can't catch. |

## 2. Running Tests

### Standalone (Recommended)
You can run any test file directly from the terminal.

```bash
godot --headless --script scripts/test/test_integration.gd
```

### In-Editor
Open the test scene/script in Godot and press **F6** (Run Current Scene).

## 3. The "GameState Problem" (Technical Note)

When running Godot scripts via `--script`, the project's **Autoloads** (Singletons like `GameState`) are **not automatically loaded**.

### The Solution (Manual Loading)
All test scripts should include this block in `_ready()` to handle both standalone and in-editor execution:

```gdscript
var GameState # Manual reference

func _ready():
    if has_node("/root/GameState"):
        # Running in-editor (properly initialized)
        GameState = get_node("/root/GameState")
    else:
        # Running standalone via CLI
        var GS = load("res://scripts/core/game_state.gd")
        GameState = GS.new()
        add_child(GameState)
```

## 4. How to Add a New Test

1. Create a new file `scripts/test/test_[name].gd`.
2. Inherit from `Node`.
3. Copy the manual `GameState` loading block (shwon above).
4. Implement your test functions.
5. In `_ready()`, call `get_tree().quit()` after tests finish to close the headless runner.

### Example Assertion Pattern
```gdscript
func test_something():
    var actual = system.calculate(10)
    var expected = 20
    if actual != expected:
        print("✗ FAIL: Expected ", expected, " but got ", actual)
        test_passed = false
    else:
        print("✓ PASS: Calculation works")
```

## 5. Maintenance Checklist

When adding new features, you MUST update the tests if:
- You add a new variable to `GameState`.
- You change the encounter rate or grace period logic.
- You change how damage is calculated in `BattleSystem`.
- You add new skill targeting types.
