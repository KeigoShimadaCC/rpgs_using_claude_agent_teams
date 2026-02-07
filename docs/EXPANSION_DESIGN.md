# Expansion Content Design Document

**Game**: The Silent Bell - Expanded Edition
**Date**: 2026-02-06
**Version**: 2.0 Design Spec

---

## 🗺️ **NEW MAPS** (3 Additional + 2 Secret)

### Map C: Deep Ruins
**Theme**: Ancient underground dungeon
**Size**: 30x25 tiles (larger than current maps)
**Purpose**: Mid-game challenge area, story progression

**Layout**:
- Multiple interconnected rooms
- Puzzle element: Switch doors (pull levers to open paths)
- Treasure chests with equipment
- Save point midway through

**Enemies**:
- Ruins Guardian (tanky)
- Stone Golem (high DEF)
- Cursed Armor (undead type)
- Mini-boss: **Forgotten Sentinel** (guarding memory fragment)

**NPCs**:
- Ghost Scholar (lore about the past)
- Trapped Adventurer (gives quest: escort out)

**Connections**:
- Entrance from Map B (Field) - northern ruins area
- Exit to Map D (Bell Tower) after clearing

**Rewards**:
- Iron Sword (weapon, +8 ATK)
- Leather Armor (armor, +6 DEF)
- Memory Fragment (quest item)
- Skill Scroll: "Shield Bash" (defensive skill)

---

### Map D: Time Bell Tower
**Theme**: Clockwork tower, frozen in time
**Size**: 20x40 tiles (vertical tower, 3 floors)
**Purpose**: Final main story area, post-boss exploration

**Layout**:
- Floor 1: Entrance, clock mechanisms
- Floor 2: Library with lore books
- Floor 3: Bell chamber (original ending location)
- Rooftop: Secret area (superboss)

**Enemies**:
- Time Wraith (drains MP)
- Clockwork Soldier (mechanical)
- Echo Phantom (illusion, high evasion)

**NPCs**:
- Time Keeper (mysterious figure, explains deeper lore)
- Companion (joins party here!)

**Connections**:
- From Map C (Deep Ruins)
- Roof access: after defeating superboss

**Special Features**:
- Can re-ring bell after ending to see alternate cutscene
- Library has lore books (readable flavor text)

**Rewards**:
- Steel Sword (weapon, +15 ATK)
- Time Crystal (accessory, +20 MP)
- Skill Scroll: "Time Stop" (boss-tier skill)

---

### Map E: Hidden Grove (Secret Area)
**Theme**: Mystical healing garden
**Size**: 25x20 tiles
**Purpose**: Optional area, rest spot, rare items

**Layout**:
- Peaceful garden with glowing plants
- Healing spring (full restore for free)
- Herb gathering spots (crafting materials)
- Secret treasure room (requires puzzle solving)

**Enemies**:
- None (safe zone) - BUT:
- Optional Superboss: **Forest Guardian** (very hard, optional)

**NPCs**:
- Healer NPC (sells potions, accepts herb trade)
- Forest Spirit (gives side quest)

**Connections**:
- Hidden entrance in Map B (Field) - requires finding secret path
- One-way fast travel to Village after discovering

**Rewards**:
- Superior Healing Potion (restores 80 HP)
- Ether Plus (restores 40 MP)
- Mystic Amulet (accessory, +10 HP/MP regen)
- Herb Bundle (crafting material)

**Side Quest**: "The Healer's Garden"
- Gather 5 rare herbs for Healer
- Reward: Mega Potion (full HP restore)

---

### Map F: Underground Caverns (Optional Extension)
**Theme**: Dark caves with crystals
**Size**: 35x30 tiles
**Purpose**: Optional late-game dungeon, rare loot

**Layout**:
- Maze-like cave system
- Dark (requires torch or light spell)
- Crystal formations (visual landmarks)
- Hidden paths behind fake walls

**Enemies**:
- Cave Bat (fast, low HP)
- Crystal Golem (very tanky, slow)
- Shadow Stalker (ambush enemy)

**Boss**: **Crystal Titan** (optional superboss)

**Connections**:
- Hidden entrance in Map C (Deep Ruins) - requires key item
- Exit to Map A (Village) via secret tunnel

**Rewards**:
- Mythril Sword (weapon, +25 ATK)
- Dragon Scale Armor (armor, +20 DEF)
- Rare gems (sellable for 500G each)

---

### Map G: Ancient Library (Lore Area)
**Theme**: Dusty old library, knowledge vault
**Size**: 20x15 tiles
**Purpose**: Lore expansion, secret ending hints

**Layout**:
- Bookshelves everywhere
- Reading desks
- Restricted section (requires high level)

**Enemies**:
- Possessed Book (magic attacks)
- Ink Demon (status effects)

**NPCs**:
- Librarian Ghost (quest giver)
- Scholar (sells skill scrolls)

**Connections**:
- Hidden door in Map D (Bell Tower) Floor 2

**Special**:
- Readable books with deep lore
- Hints for secret ending unlock
- Skill scrolls for sale (expensive)

---

## 👾 **NEW ENEMIES** (12 Additional)

### Regular Enemies (5)

#### 1. **Ruins Guardian**
- **Type**: Tank
- **HP**: 80 | **ATK**: 10 | **DEF**: 12 | **AGI**: 2
- **Skills**: Heavy Slam (high damage, low accuracy)
- **Rewards**: 25 EXP, 15 Gold
- **Location**: Map C (Deep Ruins)
- **AI**: Defend 40%, Attack 60%

#### 2. **Time Wraith**
- **Type**: Magic/Debuffer
- **HP**: 60 | **ATK**: 12 | **DEF**: 6 | **AGI**: 8
- **Skills**: Mana Drain (steals MP), Time Slow (reduces AGI)
- **Rewards**: 30 EXP, 20 Gold, chance for Ether
- **Location**: Map D (Bell Tower)
- **AI**: 50% skill, 30% attack, 20% defend

#### 3. **Stone Golem**
- **Type**: High Defense
- **HP**: 100 | **ATK**: 8 | **DEF**: 15 | **AGI**: 1
- **Skills**: Rock Throw (ranged attack)
- **Rewards**: 35 EXP, 25 Gold, chance for Iron Ore
- **Location**: Map C (Deep Ruins)
- **AI**: Very defensive, counter-attacks when hit

#### 4. **Cave Bat**
- **Type**: Fast/Evasive
- **HP**: 40 | **ATK**: 15 | **DEF**: 3 | **AGI**: 12
- **Skills**: Swift Strike (guaranteed hit)
- **Rewards**: 20 EXP, 10 Gold
- **Location**: Map F (Caverns)
- **AI**: Hit and run, tries to escape if low HP

#### 5. **Possessed Book**
- **Type**: Magic
- **HP**: 50 | **ATK**: 18 | **DEF**: 5 | **AGI**: 6
- **Skills**: Paper Cut (multi-hit), Knowledge Blast (magic)
- **Rewards**: 28 EXP, 18 Gold, chance for Skill Scroll
- **Location**: Map G (Library)
- **AI**: Prefers magic skills

### Elite Enemies (4)

#### 6. **Cursed Armor**
- **Type**: Undead Elite
- **HP**: 120 | **ATK**: 20 | **DEF**: 10 | **AGI**: 5
- **Skills**: Soul Drain (HP steal), Curse (ATK down)
- **Rewards**: 50 EXP, 40 Gold, chance for Steel Armor
- **Location**: Map C (Deep Ruins), rare spawn
- **AI**: Aggressive, uses status effects

#### 7. **Crystal Golem**
- **Type**: Tank Elite
- **HP**: 150 | **ATK**: 12 | **DEF**: 20 | **AGI**: 1
- **Skills**: Crystal Barrier (absorbs damage), Shatter (AoE)
- **Rewards**: 60 EXP, 50 Gold, Crystal Shard (material)
- **Location**: Map F (Caverns)
- **AI**: Extremely defensive, counter-attacks

#### 8. **Shadow Stalker**
- **Type**: Assassin Elite
- **HP**: 80 | **ATK**: 25 | **DEF**: 8 | **AGI**: 14
- **Skills**: Backstab (critical hit), Vanish (evasion buff)
- **Rewards**: 55 EXP, 45 Gold, Assassin's Dagger
- **Location**: Map F (Caverns), ambush spawn
- **AI**: High damage burst, retreats when damaged

#### 9. **Echo Phantom**
- **Type**: Illusion Elite
- **HP**: 90 | **ATK**: 16 | **DEF**: 6 | **AGI**: 10
- **Skills**: Mirror Image (creates copies), Confusion (debuff)
- **Rewards**: 48 EXP, 38 Gold
- **Location**: Map D (Bell Tower)
- **AI**: Summons copies, high evasion

### Mini-Bosses (2)

#### 10. **Forgotten Sentinel**
- **Type**: Mini-Boss (guards memory fragment)
- **HP**: 200 | **ATK**: 22 | **DEF**: 12 | **AGI**: 6
- **Skills**: Guardian Strike (heavy), Protective Barrier, Regenerate
- **Rewards**: 100 EXP, 100 Gold, Memory Fragment (key item), Iron Sword
- **Location**: Map C (Deep Ruins), boss room
- **Phases**: At 50% HP, enters defensive mode
- **AI**: Balanced, uses all skills strategically

#### 11. **Clockwork Sentinel**
- **Type**: Mini-Boss (mechanical guardian)
- **HP**: 180 | **ATK**: 24 | **DEF**: 10 | **AGI**: 8
- **Skills**: Gear Spin (multi-hit), Overheat (self-buff), Repair (heal)
- **Rewards**: 110 EXP, 120 Gold, Clockwork Heart (accessory)
- **Location**: Map D (Bell Tower) Floor 2
- **Phases**: Speeds up as HP decreases
- **AI**: Aggressive, uses repair at low HP

### Superbosses (Optional, Very Hard) (2)

#### 12. **Forest Guardian** (Optional)
- **Type**: Superboss (nature deity)
- **HP**: 350 | **ATK**: 30 | **DEF**: 18 | **AGI**: 10
- **Skills**: Nature's Wrath (AoE), Vine Whip, Photosynthesis (heal), Enrage
- **Rewards**: 250 EXP, 300 Gold, Guardian's Blade (+30 ATK weapon)
- **Location**: Map E (Hidden Grove)
- **Requires**: Level 8+, good equipment
- **Phases**: 3 phases (defensive → balanced → aggressive)

#### 13. **Crystal Titan** (Optional)
- **Type**: Superboss (ultimate challenge)
- **HP**: 400 | **ATK**: 35 | **DEF**: 22 | **AGI**: 7
- **Skills**: Crystal Storm (AoE), Earthquake, Titan's Roar (full party debuff), Harden
- **Rewards**: 300 EXP, 500 Gold, Titan's Edge (+40 ATK weapon), Achievement
- **Location**: Map F (Caverns), deepest chamber
- **Requires**: Level 10, best equipment, strategy
- **Phases**: Gets stronger each phase

---

## 🎭 **STORY EXPANSION**

### Main Story Extension

**Post-Boss Content**: "Echoes of Memory"

After defeating the Archivist Shade and making your choice, new content unlocks:

1. **Companion Joins Party**
   - Companion reveals they can help stabilize the time flow
   - Joins as playable party member
   - New dialogue about their mysterious past

2. **Deep Ruins Discovery**
   - Ruins react to the restored bell
   - Deeper areas become accessible
   - Quest: Find memory fragments to understand full truth

3. **Tower Ascension**
   - Time Bell Tower becomes explorable
   - Each floor reveals more about the village's founding
   - Time Keeper NPC provides context

4. **Secret Ending Path**
   - Collect all 5 memory fragments
   - Unlock "True Ending" third option
   - Requires defeating Forest Guardian
   - Reveals complete truth about the bell and village

### Character Development

**Hero** (Player Character):
- Silent protagonist
- Growth shown through choices
- Equipment/level progression shows physical growth

**Companion** (Joins Party in Tower):
- **Name**: Aria
- **Class**: Healer/Support
- **Starting Level**: Same as player (scales)
- **Skills**: Heal, Protect, Cleanse, Revive (late game)
- **Story**: Revealed to be descendant of original bell keeper
- **Arc**: From mysterious helper → trusted ally → key to truth

**Elder** (Village Leader):
- Expanded dialogue post-ending
- Can reveal regrets if pressed
- Optional quest: redemption arc

**Time Keeper** (New NPC):
- Mysterious figure in the tower
- Knows the full truth
- Gives cryptic hints
- Final conversation reveals they're the original bell keeper's spirit

---

## 🎯 **SIDE QUESTS** (5 Total)

### 1. "Lost Memories" (Main Side Quest)
**Giver**: Elder (post-main story)
**Objective**: Collect 5 Memory Fragments scattered across maps
**Locations**:
- Fragment 1: Deep Ruins (from Forgotten Sentinel)
- Fragment 2: Bell Tower Library
- Fragment 3: Hidden Grove (requires puzzle)
- Fragment 4: Caverns (guarded by Crystal Golem)
- Fragment 5: Reward from completing other side quests

**Reward**:
- Memory Crystal (key item)
- Unlocks True Ending path
- 150 EXP, 200 Gold

**Impact**: Required for 100% completion

---

### 2. "Monster Hunt: Shadow Menace"
**Giver**: Village Guard NPC (new, added to Map A)
**Objective**: Defeat 10 Shadow Wolves in Map B
**Tracking**: Quest log shows 0/10 progress

**Reward**:
- Hunter's Badge (accessory, +5 ATK)
- 80 EXP, 150 Gold
- Memory Fragment (counts for Quest #1)

**Impact**: Encourages exploration and grinding

---

### 3. "The Healer's Garden"
**Giver**: Healer NPC (Map E - Hidden Grove)
**Objective**: Gather 5 Rare Herbs from specific locations
**Locations**:
- Luminous Herb: Map B, glowing spot
- Crystal Herb: Map F, near crystals
- Memory Herb: Map C, near memory stones
- Time Herb: Map D, growing on clocks
- Ancient Herb: Map G, in restricted section

**Reward**:
- Mega Potion (full HP restore, unlimited uses in field)
- Recipe: Can craft potions from herbs
- 100 EXP, 100 Gold

**Impact**: Introduces gathering/crafting mechanic

---

### 4. "Escort Mission: Lost Adventurer"
**Giver**: Trapped Adventurer (Map C - Deep Ruins)
**Objective**: Escort NPC safely out of ruins to village
**Mechanic**: NPC follows player, ambush battles on the way
**Difficulty**: Must protect NPC (if their HP hits 0, quest fails)

**Reward**:
- Escape Rope (item, instant teleport to village)
- 70 EXP, 120 Gold
- Adventurer opens shop in village (sells rare items)

**Impact**: Adds escort gameplay, unlocks shop

---

### 5. "Forbidden Knowledge"
**Giver**: Librarian Ghost (Map G - Ancient Library)
**Objective**: Find 3 Lost Tomes hidden in dangerous areas
**Locations**:
- Tome 1: Caverns, behind secret wall
- Tome 2: Deep Ruins, puzzle chest
- Tome 3: Hidden Grove, superboss area

**Reward**:
- Skill Scroll: "Ultima" (ultimate skill, 99 MP, massive damage)
- Scholar's Robe (armor, +15 DEF, +30 MP)
- 120 EXP, 180 Gold
- Memory Fragment (counts for Quest #1)

**Impact**: Rewards exploration, unlocks best skill

---

## ⚔️ **EQUIPMENT SYSTEM** (30 Items)

### Weapons (10)

| Name | ATK Bonus | Price | Location |
|------|-----------|-------|----------|
| Wooden Stick | +2 | 50 | Shop (starting) |
| Iron Sword | +8 | 200 | Deep Ruins chest |
| Steel Sword | +15 | 500 | Bell Tower reward |
| Assassin's Dagger | +12 | - | Shadow Stalker drop |
| Guardian's Blade | +30 | - | Forest Guardian (superboss) |
| Titan's Edge | +40 | - | Crystal Titan (superboss) |
| Fire Brand | +20 | 800 | Shop (late game) |
| Ice Rapier | +22 | 900 | Caverns chest |
| Thunder Spear | +25 | 1200 | Shop (end game) |
| Chrono Blade | +35 | - | Secret ending reward |

### Armor (10)

| Name | DEF Bonus | Price | Location |
|------|-----------|-------|----------|
| Cloth Tunic | +2 | 50 | Shop (starting) |
| Leather Armor | +6 | 180 | Deep Ruins chest |
| Steel Armor | +12 | 450 | Cursed Armor drop |
| Dragon Scale | +20 | - | Caverns rare chest |
| Crystal Mail | +16 | 700 | Shop (late) |
| Guardian Plate | +25 | - | Tower superboss |
| Time Weave | +18 | 1000 | Bell Tower shop |
| Scholar's Robe | +15, +30 MP | - | Library quest reward |
| Shadow Cloak | +14, +5 AGI | - | Stalker rare drop |
| Mythril Armor | +22 | 1500 | Shop (end game) |

### Accessories (10)

| Name | Effect | Price | Location |
|------|--------|-------|----------|
| HP Ring | +20 HP | 100 | Shop |
| MP Ring | +20 MP | 100 | Shop |
| Power Band | +5 ATK | 150 | Shop |
| Guard Ring | +5 DEF | 150 | Shop |
| Speed Boots | +3 AGI | 200 | Rare drop |
| Hunter's Badge | +5 ATK | - | Monster hunt quest |
| Clockwork Heart | Auto-Regen 5HP/turn | - | Clockwork Sentinel drop |
| Time Crystal | +20 MP, +2 AGI | - | Tower reward |
| Mystic Amulet | +10 HP, +10 MP regen | - | Grove reward |
| Phoenix Feather | Auto-Revive once | 3000 | Shop (secret) |

---

## 🎪 **NEW SKILLS** (10 Additional)

### Hero Skills (5)

| Skill | MP Cost | Power | Effect | Learn |
|-------|---------|-------|--------|-------|
| Shield Bash | 10 | 20 | Damage + stun chance | Scroll (Deep Ruins) |
| Flame Strike | 12 | 35 | Fire damage | Scroll (shop, 500G) |
| Thunder Bolt | 15 | 40 | Lightning damage | Level 6 |
| Ice Shard | 12 | 35 | Ice damage, slow | Scroll (Caverns) |
| Ultima | 99 | 150 | Ultimate attack | Library quest |

### Companion (Aria) Skills (5)

| Skill | MP Cost | Power | Effect | Learn |
|-------|---------|-------|--------|-------|
| Heal | 8 | 40 | Restore ally HP | Start |
| Protect | 10 | - | +DEF buff, one ally | Start |
| Cleanse | 5 | - | Remove status effects | Level 5 |
| Holy Light | 15 | 30 | Light damage, heal self | Level 7 |
| Revive | 20 | - | Revive fallen ally, 50% HP | Level 9 |

---

## 🏆 **ACHIEVEMENTS** (15 Optional Goals)

1. **Silent Hero**: Complete main story
2. **Memory Keeper**: Collect all memory fragments
3. **True Ending**: Unlock and see secret ending
4. **Monster Slayer**: Defeat 100 enemies
5. **Boss Hunter**: Defeat all mini-bosses
6. **Titan Slayer**: Defeat Crystal Titan superboss
7. **Guardian's Trial**: Defeat Forest Guardian
8. **Quest Master**: Complete all side quests
9. **Treasure Hunter**: Open all treasure chests
10. **Bookworm**: Read all books in the library
11. **Max Level**: Reach Level 10
12. **Fully Equipped**: Obtain best weapon, armor, accessory
13. **Rich**: Accumulate 5000 Gold
14. **Speedrunner**: Complete game in under 2 hours
15. **Pacifist**: Complete game with minimal battles (hard mode)

---

## 🎮 **NEW GAMEPLAY FEATURES**

### 1. Party System
- Companion (Aria) joins after Bell Tower
- Switch active party member in menu (if more added later)
- Each member has unique skills
- Turn-based with both characters

### 2. Equipment System
- 3 slots: Weapon, Armor, Accessory
- Stat bonuses apply in battle
- Some accessories have special effects
- Can buy, find, or earn equipment

### 3. Quest Log
- New menu: "Quests"
- Shows active, completed quests
- Objective tracking (e.g., "Defeat Shadow Wolves: 3/10")
- Quest markers on map (optional)

### 4. Crafting (Simple)
- Healer NPC can craft potions from herbs
- Recipe: 2 Herbs → 1 Potion
- Optional system for resource management

### 5. Fast Travel
- Unlock after discovering maps
- Use from world map (new menu)
- Can teleport to any visited map entrance
- Costs 50 Gold per use (balancing)

### 6. Difficulty Modes (Optional)
- Normal: Current balance
- Hard: Enemies have 1.5x HP/ATK, lower rewards
- Easy: Player has 1.5x stats, higher rewards

---

## 📊 **PROGRESSION CURVE** (Expanded)

### Level Progression (L1 → L10)

| Level | EXP Required | HP | MP | ATK | DEF |
|-------|--------------|----|----|-----|-----|
| 1 | - | 100 | 30 | 10 | 5 |
| 2 | 100 | 115 | 35 | 13 | 7 |
| 3 | 180 | 131 | 41 | 16 | 9 |
| 4 | 280 | 149 | 47 | 20 | 11 |
| 5 | 400 | 168 | 54 | 24 | 13 |
| 6 | 550 | 189 | 61 | 28 | 16 |
| 7 | 730 | 211 | 69 | 33 | 18 |
| 8 | 950 | 235 | 77 | 38 | 21 |
| 9 | 1210 | 260 | 86 | 43 | 24 |
| 10 | 1500 | 287 | 95 | 49 | 27 |

### Map Progression Path

```
Start: Map A (Village) - Tutorial, L1
  ↓
Map B (Field) - Early battles, L1-2
  ↓
Map C (Deep Ruins) - Challenge dungeon, L3-4
  ↓
Map D (Bell Tower) - Story climax, L4-5
  ↓
Map E (Hidden Grove) - Optional, L5-6
  ↓
Map F (Caverns) - Hard optional, L6-8
  ↓
Map G (Library) - Lore, L7-9
  ↓
Secret Ending - Final challenge, L10
```

---

## 🎬 **EXPANDED ENDINGS**

### Ending 1: Return Memory (Original)
- Memory returned to Elder
- Order preserved
- Village continues with secret hidden

### Ending 2: Free Memory (Original)
- Memory freed to public
- Truth revealed
- Uncertain but honest future

### Ending 3: True Ending (NEW - Secret)
- **Requirements**: Collect all memory fragments, defeat Forest Guardian, Level 10
- **Unlock**: Time Keeper dialogue option appears
- **Story**: Discover that the bell can be permanently fixed with all memories
- **Result**: Bell rings with full power, time flows naturally, truth is shared wisely
- **Reward**: Best ending, special cutscene, Chrono Blade weapon

---

## ✅ **IMPLEMENTATION CHECKLIST**

### Maps (3 core + 2 optional)
- [ ] Map C - Deep Ruins
- [ ] Map D - Bell Tower
- [ ] Map E - Hidden Grove
- [ ] Map F - Caverns (optional)
- [ ] Map G - Library (optional)

### Enemies (13 total)
- [ ] 5 regular enemies
- [ ] 4 elite enemies
- [ ] 2 mini-bosses
- [ ] 2 superbosses

### Systems
- [ ] Equipment system (30 items)
- [ ] Party system (Companion joins)
- [ ] Quest log UI
- [ ] Side quest tracking (5 quests)
- [ ] Crafting system (herbs → potions)
- [ ] Fast travel
- [ ] Achievement tracking

### Content
- [ ] 10 new skills
- [ ] Extended story dialogues
- [ ] Secret ending path
- [ ] Lore books (readable)

---

**Design Complete! Ready for implementation phase.** 🚀

---

**Next Steps**: Begin implementation with Task #17 (new maps), #18 (enemies), #19 (systems).
