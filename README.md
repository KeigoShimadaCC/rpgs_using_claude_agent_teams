# JRPG MVP: The Silent Bell

A turn-based JRPG-style RPG built with Godot 4, featuring exploration, combat, and a narrative-driven experience.

## Project Status

🚧 **In Development** - MVP in progress

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

- ✅ Top-down exploration across 2 maps
- ✅ Turn-based battle system (FF/DQ-style)
- ✅ NPC interactions and quest gating
- ✅ Character progression (EXP, leveling)
- ✅ Narrative with player choice
- ✅ Boss encounter with unique mechanics

## Documentation

- [CLAUDE.md](CLAUDE.md) - Development guide for AI assistants
- [docs/project_spec.md](docs/project_spec.md) - Technical specification
- [docs/architecture.md](docs/architecture.md) - System architecture (coming soon)
- [docs/content_schemas.md](docs/content_schemas.md) - Data format reference (coming soon)

## Team

Built by a coordinated team of AI agents:
- **Team Lead**: Project coordination and integration
- **Agent A**: Overworld systems and interaction
- **Agent B**: Battle system and progression
- **Agent C**: Scenario and dialogue
- **Agent D**: Maps and UI implementation

## License

This is an MVP demonstration project.
