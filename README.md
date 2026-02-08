# JRPG MVP: The Silent Bell

A turn-based JRPG-style RPG built with Godot 4, featuring exploration, combat, and a narrative-driven experience.

## Project Status

✅ **MVP COMPLETE** - Fully playable from start to finish!

## Requirements

- Godot 4.3 or later
- Platform: Windows, macOS, or Linux

## Quick Start

### Running the Game

1. Download and install [Godot 4.3+](https://godotengine.org/download)
2. Open Godot and import this project
3. Press F5 or click "Run Project" to start

### Development

- **Main Scene**: `res://scenes/main/title_screen.tscn`
- **Game State**: Managed by `GameState` singleton (autoloaded)
- **Data Files**: JSON-based content in `data/` directory
- **Testing**: Automated suites in `scripts/test/`

## Project Structure

```
├── scenes/          # Godot scene files (.tscn)
├── scripts/        # GDScript files
│   ├── core/       # Core systems (GameState, managers)
│   ├── overworld/  # Overworld gameplay scripts
│   ├── battle/     # Battle system scripts
│   ├── ui/         # UI controller scripts
│   └── test/       # Automated test suites (Unit, Integration)
├── docs/           # System documentation
```

## Controls

- **Movement**: WASD or Arrow Keys
- **Interact**: E or Space
- **Pause**: Escape
- **Battle Auto**: A (Toggle)
- **Accept/Advance**: Space or Enter

## Game Features (MVP)

### Core Systems
- ✅ Top-down exploration across 2 maps
- ✅ Turn-based battle system (Attack, Defend, Skill, Item, Run)
- ✅ **New: Persistent Auto-Battle** - AI takes over turns until toggled off
- ✅ **New: Refined Encounter Logic** - Distance-based step counting with 5-step post-battle grace period
- ✅ Character progression (EXP, leveling L1→L3, stat growth)
- ✅ Inventory system (Healing Potion, Ether, quest items)

## Documentation

### Developer Guides
- [docs/GODOT_PATTERNS.md](docs/GODOT_PATTERNS.md) - **Recommended Reading**: Core architecture and Godot-specific patterns
- [docs/TESTING.md](docs/TESTING.md) - How to run and maintain automated tests
- [CLAUDE.md](CLAUDE.md) - Development guide for AI assistants

### System Documentation
- [docs/battle_system_architecture.md](docs/battle_system_architecture.md) - Battle system design
- [docs/overworld_systems.md](docs/overworld_systems.md) - Overworld API reference
- [docs/content_schemas.md](docs/content_schemas.md) - Data format reference

### Testing & Quality Assurance
- [scripts/test/run_tests.gd](scripts/test/run_tests.gd) - CLI test runner
- [MANUAL_TEST_CHECKLIST.md](MANUAL_TEST_CHECKLIST.md) - Step-by-step manual QA guide

## Team

Built by a coordinated team of AI agents:
- **Team Lead**: Project coordination and integration
- **Agent A**: Overworld systems and interaction
- **Agent B**: Battle system and progression
- **Agent C**: Scenario and dialogue
- **Agent D**: Maps and UI implementation

## License

This is an MVP demonstration project.
