# Battle System Architecture

## System Overview

The battle system is a standalone, self-contained module that handles turn-based combat. It uses a clean separation between:
- **BattleManager**: Scene transition coordinator (singleton)
- **BattleSystem**: Core combat logic and state machine
- **BattleUI**: User interface and player input
- **EnemyBattler**: Enemy instances with AI

## Component Diagram

```
Overworld Scene
    ↓
BattleManager (Singleton)
    ↓ start_battle(enemy_ids, callbacks)
    ↓ change_scene_to_file("battle_scene.tscn")
    ↓
BattleScene
    ├── BattleSceneController (coordinates initialization)
    ├── BattleSystem (game logic)
    │   ├── Turn management
    │   ├── Action execution
    │   ├── Damage calculation
    │   └── Victory/defeat detection
    ├── BattleUI (player interface)
    │   ├── HP/MP display
    │   ├── Action menus
    │   └── Battle log
    └── EnemyContainer
        └── Enemy instances (1-3)
            └── AI decision making
    ↓
Victory/Defeat
    ↓
BattleManager (callbacks + return to overworld)
```

## State Machine

```
INITIALIZING
    ↓ spawn enemies
    ↓
PLAYER_TURN
    ↓ player selects action
    ↓
PROCESSING_ACTION
    ↓ execute action, animate
    ↓ check victory?
    ↓
ENEMY_TURN
    ↓ each enemy decides action
    ↓ execute enemy actions
    ↓ check defeat?
    ↓
PLAYER_TURN (loop)

Victory → VICTORY state → callbacks → return to overworld
Defeat → DEFEAT state → callbacks → game over
```

## Data Flow

### Battle Initialization
1. Overworld calls `BattleManager.start_battle(enemy_ids, on_victory, on_defeat, is_boss)`
2. BattleManager stores callbacks and previous scene path
3. Scene transitions to `battle_scene.tscn`
4. BattleSceneController reads config from BattleManager
5. Controller spawns enemies from enemy_ids
6. BattleSystem initializes combat state
7. BattleUI enables action menu

### Turn Flow
1. **Player Turn Start**
   - BattleSystem sets state to PLAYER_TURN
   - BattleUI enables action menu
   - Turn indicator shows "YOUR TURN"

2. **Player Action Selection**
   - Player clicks action button
   - BattleUI shows appropriate submenu (Skill/Item/Target)
   - Player confirms selection
   - BattleUI calls `BattleSystem.execute_player_action(action_dict)`

3. **Action Processing**
   - BattleSystem sets state to PROCESSING_ACTION
   - Action executes (damage calculation, HP/MP changes)
   - Animations play (damage numbers, effects)
   - GameState updates (HP, MP, inventory)
   - Victory check

4. **Enemy Turn Start**
   - BattleSystem sets state to ENEMY_TURN
   - BattleUI disables action menu
   - Turn indicator shows "ENEMY TURN"

5. **Enemy Actions**
   - For each alive enemy:
     - Enemy.decide_action() returns action dict
     - BattleSystem executes enemy action
     - Damage applied to player via GameState
     - Short delay between enemies
   - Defeat check

6. **Loop**
   - Return to Player Turn (unless victory/defeat)

### Victory Flow
1. All enemies HP = 0
2. BattleSystem calculates total EXP and gold
3. State changes to VICTORY
4. Awards applied: `GameState.add_exp()`, `GameState.add_gold()`
5. Level-up check (GameState handles this automatically)
6. Battle log shows rewards
7. Wait 2 seconds
8. Call `BattleManager._on_battle_victory(exp, gold)`
9. BattleManager calls user's victory callback
10. BattleManager returns to previous scene

### Defeat Flow
1. Player HP = 0
2. State changes to DEFEAT
3. Battle log shows defeat message
4. Wait 2 seconds
5. Call `BattleManager._on_battle_defeat()`
6. BattleManager calls user's defeat callback
7. Callback should handle scene transition (usually to game over)

## Key Classes

### BattleManager (Singleton)
**Responsibilities:**
- Store battle configuration (enemy IDs, callbacks, boss flag)
- Manage scene transitions
- Preserve previous scene path
- Execute victory/defeat callbacks

**API:**
- `start_battle(enemy_ids, on_victory, on_defeat, boss_battle)`
- `get_battle_config() -> Dictionary`
- `_on_battle_victory(exp, gold)` (called by BattleSystem)
- `_on_battle_defeat()` (called by BattleSystem)

### BattleSystem
**Responsibilities:**
- Turn-based state machine
- Action execution and damage calculation
- Enemy AI coordination
- Victory/defeat detection
- Battle log messaging

**Key Methods:**
- `initialize_battle(enemy_ids)`
- `execute_player_action(action)`
- `start_player_turn()`, `start_enemy_turn()`
- `calculate_damage(attack, defense) -> int`
- `trigger_victory()`, `trigger_defeat()`

**Signals:**
- `turn_started(is_player_turn: bool)`
- `damage_dealt(target: String, amount: int, is_critical: bool)`
- `battle_won(exp_gained: int, gold_gained: int)`
- `battle_lost()`
- `message_logged(text: String)`

### BattleUI
**Responsibilities:**
- Display player stats (HP, MP, Level)
- Action menu navigation
- Skill/Item/Target selection
- Battle log display
- Damage number animations
- Turn indicator

**Key Methods:**
- `enable_action_menu(enabled: bool)`
- `show_skill_menu()`, `show_item_menu()`, `show_target_select()`
- `send_action(action: Dictionary)` - sends to BattleSystem
- `add_battle_log(message: String)`
- `show_damage_number(damage, position, is_critical)`

**References:**
- `battle_system` - set by BattleSceneController
- Listens to GameState HP/MP signals for stat updates

### EnemyBattler
**Responsibilities:**
- Store enemy stats (HP, ATK, DEF, etc.)
- AI decision making
- HP tracking and death
- Visual representation

**Key Methods:**
- `setup(enemy_data: Dictionary)` - initialize from JSON
- `decide_action() -> Dictionary` - AI logic
- `take_damage(amount: int) -> int`
- `is_alive() -> bool`
- `die()` - death animation

**Signals:**
- `died(enemy: EnemyBattler)`
- `action_decided(action: Dictionary)`

## Combat Mechanics

### Damage Formula
```gdscript
base_damage = max(attacker_atk - defender_def, 1)
is_critical = randf() < 0.1  # 10% chance
if is_critical:
    base_damage *= 1.5
variance = randf_range(0.9, 1.1)
final_damage = max(int(base_damage * variance), 1)
```

### Defend Mechanic
- Player chooses "Defend" action
- `player_defending` flag set to true for current turn
- Incoming damage multiplied by 0.5
- Flag resets at start of next player turn

### Skill Execution
1. Check MP cost: `GameState.consume_mp(skill.mp_cost)`
2. If insufficient, action fails
3. Execute skill effect based on target_type:
   - `"single_enemy"`: Calculate damage, apply to selected enemy
   - `"self"`: Heal player via `GameState.heal_player()`
4. Skill data loaded from `data/skills.json`

### Item Usage
1. Check inventory: `GameState.has_item(item_id)`
2. Use item: `GameState.use_item(item_id)`
   - GameState loads item data from `data/items.json`
   - Applies effect (heal, restore_mp, etc.)
   - Consumes item from inventory
3. If successful, display message

### Run Mechanic
1. Check if boss battle: `BattleManager.get_battle_config().is_boss_battle`
2. If boss, display "Cannot escape!" and fail
3. Otherwise, 50% chance to escape
4. If successful, call `BattleManager._return_to_overworld()`
5. If failed, turn continues to enemy phase

### Enemy AI
```gdscript
if has_skills:
    20% chance: use random skill
    60% chance: attack
    20% chance: defend
else:
    70% chance: attack
    30% chance: defend
```

## Integration Points

### With GameState
- Reads: `player_hp`, `player_mp`, `player_atk`, `player_def`, `player_level`
- Writes: `damage_player()`, `heal_player()`, `consume_mp()`, `add_exp()`, `add_gold()`, `use_item()`
- Listens: `hp_changed`, `mp_changed` signals

### With Overworld
- Called via: `BattleManager.start_battle()`
- Returns via: Victory/defeat callbacks
- Scene preservation: BattleManager stores previous scene path

### With Data Files
- `data/enemies.json`: Enemy definitions
- `data/skills.json`: Skill definitions
- `data/items.json`: Item effects (via GameState)

## Testing Strategy

### Unit Testing (Manual)
1. Test scene: `scenes/battle/battle_test.tscn`
2. Buttons for each enemy type
3. Verify all actions work
4. Check EXP/gold awards
5. Verify level-up triggers
6. Test victory/defeat transitions

### Integration Testing
1. Create encounter trigger in overworld
2. Verify scene transition
3. Win battle, check return to overworld
4. Lose battle, check game over transition
5. Verify stat persistence (HP, EXP, gold)

### Balance Testing
- Level 1 vs 1 slime: Easy win
- Level 1 vs 1 goblin: Challenging
- Level 1 vs boss: Should lose
- Level 3 vs boss: Winnable with skill

## Extension Points (Post-MVP)

### Easy Extensions
- Add new enemies: Just add to `enemies.json`
- Add new skills: Add to `skills.json`, implement logic in BattleSystem
- Add new items: Add to `items.json`, implement effect in GameState

### Medium Extensions
- Status effects: Add status tracking to BattleSystem and EnemyBattler
- Multi-target skills: Modify skill execution logic
- Enemy drops: Add to victory rewards
- Battle animations: Replace ColorRects with sprites, add tweens

### Hard Extensions
- Party system: Multiple player characters, turn queue
- Complex AI: Behavior trees, target selection logic
- Battle backgrounds: Dynamic backgrounds per map
- Special battles: Unique mechanics for boss fights
