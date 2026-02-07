# Next Steps Roadmap

**Current Status**: MVP Complete ✅
**Version**: 1.0.0
**Date**: 2026-02-06

This document outlines potential enhancements beyond the MVP, ranked by impact and effort.

---

## 🚀 High Priority (High Impact, Low-Medium Effort)

### 1. Save/Load System
**Impact**: ⭐⭐⭐⭐⭐ | **Effort**: ⭐⭐⭐

Allow players to save progress and continue later.

**Implementation**:
- Add save/load methods to GameState
- Save player stats, quest flags, inventory, current map
- Add "Continue" button to title screen
- Use JSON or ConfigFile for save data
- Auto-save on map transitions (optional)

**Files to modify**:
- `scripts/core/game_state.gd`
- `scenes/main/title_screen.tscn` + script

---

### 2. Sound Effects & Music
**Impact**: ⭐⭐⭐⭐⭐ | **Effort**: ⭐⭐

Add audio to enhance atmosphere and feedback.

**Key Audio Needs**:
- **BGM**: Title theme, village music, field music, battle theme, boss theme, ending theme
- **SFX**: Footsteps, dialogue beep, menu navigation, attack sounds, skill effects, item use, level up fanfare, victory jingle

**Implementation**:
- Add AudioStreamPlayer nodes to scenes
- Find royalty-free music (e.g., OpenGameArt, incompetech)
- Add sound effects for key actions
- Add volume controls to pause menu

**Files to create/modify**:
- `audio/` folder with music and sfx
- All scene files (add AudioStreamPlayer nodes)
- `scenes/main/pause_menu.tscn` (add audio settings)

---

### 3. Battle Animations
**Impact**: ⭐⭐⭐⭐ | **Effort**: ⭐⭐⭐

Animate attacks and skills for visual feedback.

**Features**:
- Attack: sprite shake + slash effect
- Defend: shield icon appears
- Skills: particle effects (fire bolt = flame particle, heal = sparkle effect)
- Damage: enemy flashes red, player sprite shakes
- Critical hit: special effect + "Critical!" text

**Implementation**:
- Use AnimationPlayer nodes in battle scene
- Add simple particle effects (Godot CPUParticles2D)
- Tween enemy sprites for hit reaction

**Files to modify**:
- `scenes/battle/battle_scene.tscn`
- `scripts/battle/battle_system.gd`

---

### 4. Improved Visual Style
**Impact**: ⭐⭐⭐⭐ | **Effort**: ⭐⭐⭐

Replace geometric placeholders with pixel art sprites.

**Assets Needed**:
- Player character sprite (16x16 with walk animation)
- NPC sprites (Elder, Companion)
- Enemy sprites (slime, goblin, wolf, shade)
- Tileset for village and field maps
- UI icons (potions, skills)

**Sources**:
- Commission pixel artist
- Use free asset packs (Kenney.nl, itch.io)
- Generate with AI tools (spritely, pixelart generator)

**Files to modify**:
- Replace ColorRect placeholders in all scenes
- Add sprite sheets to `sprites/` folder
- Update AnimatedSprite2D nodes

---

### 5. More Enemy Variety
**Impact**: ⭐⭐⭐⭐ | **Effort**: ⭐⭐

Add 3-5 more enemy types with unique skills.

**New Enemies Ideas**:
- **Ruins Guardian** (tanky, high DEF)
- **Will-o-Wisp** (fast, magic attacks)
- **Corrupted Memory** (status effects)
- **Time Wraith** (drains MP)
- **Mini-boss**: Lieutenant Shade (before final boss)

**Implementation**:
- Add entries to `data/enemies.json`
- Create enemy sprites
- Add new skills to `data/skills.json`
- Place in Map B encounter zones

**Files to modify**:
- `data/enemies.json`
- `data/skills.json`
- `scenes/overworld/map_b_field.tscn` (add encounters)

---

## 🌟 Medium Priority (Medium Impact, Medium Effort)

### 6. Equipment System
**Impact**: ⭐⭐⭐⭐ | **Effort**: ⭐⭐⭐⭐

Add weapons and armor for stat customization.

**Features**:
- Weapon slot (increases ATK)
- Armor slot (increases DEF)
- Accessory slot (special effects: +HP, +MP, resist status)
- Equipment screen in pause menu
- Equipment drops from enemies or found in chests

**Implementation**:
- Add equipment data file (`data/equipment.json`)
- Add slots to GameState
- Update battle damage calculations
- Add equipment shop or chests in maps

**Files to create/modify**:
- `data/equipment.json`
- `scripts/core/game_state.gd` (equipment slots)
- `scenes/main/pause_menu.tscn` (equipment screen)
- `scripts/battle/battle_system.gd` (stat calculations)

---

### 7. Status Effects
**Impact**: ⭐⭐⭐ | **Effort**: ⭐⭐⭐

Add poison, stun, buff/debuff mechanics.

**Status Effects**:
- **Poison**: Take damage each turn
- **Stun**: Skip next turn
- **ATK Up**: Increase attack temporarily
- **DEF Up**: Increase defense temporarily
- **Slow**: Reduce turn frequency

**Implementation**:
- Add status tracking to GameState and enemies
- Add status check/tick in battle turn loop
- Add visual indicators (icons above character)
- Add skills that inflict status

**Files to modify**:
- `scripts/core/game_state.gd` (status tracking)
- `scripts/battle/battle_system.gd` (status effects logic)
- `scripts/battle/enemy_ai.gd` (AI use status skills)
- `data/skills.json` (status-inflicting skills)

---

### 8. Multiple Party Members
**Impact**: ⭐⭐⭐⭐ | **Effort**: ⭐⭐⭐⭐

Add Companion as playable second party member.

**Features**:
- Companion joins party after certain dialogue
- Turn queue alternates: Hero → Companion → Enemies
- Each member has own HP/MP/skills
- Party screen shows all members
- Target selection for healing skills

**Implementation**:
- Expand GameState to track party array
- Update battle system for multi-character turns
- Add party management UI
- Add Companion skills and stats

**Files to modify**:
- `scripts/core/game_state.gd` (party management)
- `scripts/battle/battle_system.gd` (multi-char turn queue)
- `scenes/main/pause_menu.tscn` (party screen)
- `data/skills.json` (companion skills)

---

### 9. Additional Maps
**Impact**: ⭐⭐⭐ | **Effort**: ⭐⭐⭐⭐

Expand world with 2-3 more locations.

**New Map Ideas**:
- **Map C: Deep Ruins** (harder enemies, treasure)
- **Map D: Hidden Grove** (optional healing area, rare items)
- **Map E: Time Bell Tower** (final area, epilogue)

**Implementation**:
- Design map layouts in Godot
- Create new tilesets or reuse existing
- Add transitions from Map B
- Populate with encounters and NPCs
- Add optional quests or secrets

**Files to create**:
- `scenes/overworld/map_c_*.tscn`
- Tileset assets
- New dialogue files for NPCs

---

### 10. Side Quests
**Impact**: ⭐⭐⭐ | **Effort**: ⭐⭐⭐

Add 2-3 optional quests for replay value.

**Quest Ideas**:
- **Lost Item**: Companion's pendant hidden in ruins (reward: accessory)
- **Monster Hunt**: Defeat 5 shadow wolves (reward: skill scroll)
- **Fetch Quest**: Gather herbs for healer (reward: healing items)

**Implementation**:
- Add quest tracking to GameState
- Create quest giver NPCs
- Add quest log to pause menu
- Add quest rewards

**Files to modify**:
- `scripts/core/game_state.gd` (quest tracking)
- `data/dialogues/*.json` (quest dialogues)
- `scenes/main/pause_menu.tscn` (quest log)
- Maps (add quest items/objectives)

---

## 💡 Low Priority (Nice to Have, Higher Effort)

### 11. New Game+ Mode
**Impact**: ⭐⭐ | **Effort**: ⭐⭐

Replay with stats/items carried over, harder enemies.

**Features**:
- Keep level, equipment, gold on new game
- Enemies have 1.5x HP/ATK
- Unlock secret boss or alternate ending
- Add "New Game+" button after completing once

---

### 12. Mini-Games
**Impact**: ⭐⭐ | **Effort**: ⭐⭐⭐

Add optional mini-game for variety.

**Ideas**:
- **Puzzle**: Tile-matching or slider puzzle
- **Card Game**: Simple battle card game with NPC
- **Rhythm Game**: Bell-ringing timing challenge

---

### 13. Achievements System
**Impact**: ⭐⭐ | **Effort**: ⭐⭐

Track player accomplishments.

**Achievement Ideas**:
- Complete game without dying
- Defeat boss at level 2
- Collect all items
- Talk to all NPCs
- Choose each ending path

---

### 14. Localization
**Impact**: ⭐⭐ | **Effort**: ⭐⭐⭐⭐

Translate to other languages.

**Implementation**:
- Use Godot's localization system (CSV files)
- Translate dialogue JSON content
- Add language selector to title screen
- Test with non-English fonts

---

### 15. Mobile/Web Export
**Impact**: ⭐⭐⭐ | **Effort**: ⭐⭐⭐

Export to mobile or web platforms.

**Requirements**:
- Touch controls for mobile
- Optimize for smaller screens
- Test performance on web (HTML5 export)
- Add virtual D-pad for mobile

---

## 🔧 Technical Debt & Polish

### Performance Optimization
- Profile frame rate in battle and large maps
- Optimize particle effects if needed
- Cache loaded dialogue JSON files

### Code Refactoring
- Extract magic numbers to constants
- Add more inline documentation
- Write unit tests for GameState methods

### Bug Fixes
- Test edge cases (e.g., running out of MP in battle)
- Handle rare softlock scenarios
- Improve error messages for missing data files

### Accessibility
- Add text size options
- Add colorblind mode
- Add subtitle/dialogue speed controls
- Add key rebinding

---

## 📊 Recommended Implementation Order

**Phase 1 (Quick Wins)**:
1. Sound Effects & Music
2. Battle Animations
3. Improved Visual Style

**Phase 2 (Core Enhancements)**:
4. Save/Load System
5. More Enemy Variety
6. Equipment System

**Phase 3 (Content Expansion)**:
7. Additional Maps
8. Side Quests
9. Multiple Party Members

**Phase 4 (Polish & Extras)**:
10. Status Effects
11. New Game+
12. Achievements
13. Localization

---

## 🎯 Success Metrics

Track these metrics to measure improvement:

- **Player Retention**: % of players who complete the game
- **Session Length**: Average playtime per session
- **Replay Rate**: % of players who start New Game+
- **Bug Reports**: Track and reduce critical bugs

---

## 📝 Notes

- **MVP is Complete**: All core features work end-to-end
- **Focus on Polish**: Visual and audio improvements have high impact
- **Data-Driven**: Most enhancements can reuse existing JSON format
- **Modular Design**: Systems are independent and easy to expand
- **Community Feedback**: Consider player feedback for priority adjustments

---

**Last Updated**: 2026-02-06
**Maintainer**: Team Lead

For questions or suggestions, see project documentation in `/docs/`
