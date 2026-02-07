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

## Project Structure

```
├── scenes/          # Godot scene files (.tscn)
│   ├── main/       # Title, game over, pause menu
│   ├── overworld/  # Maps and player scenes
│   ├── battle/     # Battle system scenes
│   └── dialogue/   # Dialogue UI scenes
├── scripts/        # GDScript files
│   ├── core/       # Core systems (GameState, managers)
│   ├── overworld/  # Overworld gameplay scripts
│   ├── battle/     # Battle system scripts
│   └── ui/         # UI controller scripts
├── sprites/        # Art assets
├── data/           # JSON data files (enemies, items, skills, dialogues)
└── docs/           # Documentation
```

## Controls

- **Movement**: WASD or Arrow Keys
- **Interact**: E or Space
- **Pause**: Escape
- **Accept/Advance**: Space or Enter
- **Cancel**: Escape

## Game Features (MVP)

### Core Systems
- ✅ Top-down exploration across 2 maps (Village Hub + Field/Ruins)
- ✅ Turn-based battle system (Final Fantasy/Dragon Quest-style)
- ✅ Complete combat actions: Attack, Defend, Skill, Item, Run
- ✅ 4 enemy types (Slime, Goblin, Shadow Wolf, Archivist Shade boss)
- ✅ Character progression (EXP, leveling L1→L3, stat growth)
- ✅ Inventory system (Healing Potion, Ether, quest items)

### Narrative & Progression
- ✅ Quest system with flag-based gating
- ✅ Interactive NPCs (Elder, Companion) with branching dialogue
- ✅ Complete story arc: Hook → Twist → Boss → Choice → Resolution
- ✅ Meaningful player choice affecting ending
- ✅ Two distinct ending paths (Return Memory / Free Memory)
- ✅ Victory screen with credits

### Polish
- ✅ Title screen with New Game option
- ✅ Pause menu with Status & Inventory
- ✅ Game Over screen on defeat
- ✅ Dialogue system with typewriter effect
- ✅ Smooth scene transitions
- ✅ Consistent visual style (geometric placeholders)

## Documentation

### Project Overview
- [CLAUDE.md](CLAUDE.md) - Development guide for AI assistants
- [docs/project_spec.md](docs/project_spec.md) - Technical specification
- [docs/NEXT_STEPS.md](docs/NEXT_STEPS.md) - Enhancement roadmap

### System Documentation
- [docs/battle_system_architecture.md](docs/battle_system_architecture.md) - Battle system design
- [docs/battle_system_integration.md](docs/battle_system_integration.md) - Battle integration guide
- [docs/overworld_systems.md](docs/overworld_systems.md) - Overworld API reference
- [docs/maps_and_ui.md](docs/maps_and_ui.md) - Map layout and UI guide
- [docs/content_schemas.md](docs/content_schemas.md) - Data format reference
- [docs/dialogue_ui_spec.md](docs/dialogue_ui_spec.md) - Dialogue system spec

### Content & Story
- [docs/scenario_outline.md](docs/scenario_outline.md) - Complete narrative structure
- [docs/character_notes.md](docs/character_notes.md) - NPC profiles and motivations

### Testing & Integration
- [docs/vertical_slice_test_report.md](docs/vertical_slice_test_report.md) - Integration test results
- [docs/mvp_integration_checklist.md](docs/mvp_integration_checklist.md) - Final QA checklist

## Team

Built by a coordinated team of AI agents:
- **Team Lead**: Project coordination and integration
- **Agent A**: Overworld systems and interaction
- **Agent B**: Battle system and progression
- **Agent C**: Scenario and dialogue
- **Agent D**: Maps and UI implementation

## License

This is an MVP demonstration project.
