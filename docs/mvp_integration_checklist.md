# MVP Integration Checklist (Task #8)

**Status**: In Progress
**Owner**: Team Lead
**Date**: 2026-02-06

## Objective

Expand from vertical slice to complete MVP with:
- Full quest progression (start → boss → ending)
- All dialogue sequences properly linked
- Quest flag gating verified
- Balance testing and adjustments
- Edge case handling

---

## 1. NPC Dialogue Assignment

### Map A - Village

**Elder NPC** (scenes/overworld/map_a_village.tscn):
- [x] NPC instance placed ✅
- [x] dialogue_id = "elder_intro" ✅
- [x] npc_name = "Elder" ✅
- [x] Quest flag: Sets "accepted_quest" when player agrees ✅

**Companion NPC** (scenes/overworld/map_a_village.tscn):
- [x] NPC instance placed ✅
- [x] dialogue_id = "companion_intro" ✅
- [x] npc_name = "Companion" ✅
- [ ] Progressive dialogue: Changes based on quest progress (optional for MVP)

### Map B - Field/Ruins

**Boss Trigger** (scenes/overworld/map_b_field.tscn):
- [x] Boss area trigger placed ✅
- [x] required_flag = "accepted_quest" ✅
- [x] Triggers "boss_intro" dialogue before battle ✅
- [ ] Victory triggers ending sequence (Task #9 - Agent C)

---

## 2. Quest Flag Progression

### Flag Flow:
1. **Start**: No flags set
2. **Elder dialogue**: Player choice sets `accepted_quest = true`
3. **Boss area**: Checks `accepted_quest`, allows entry if true
4. **Boss defeat**: Triggers ending sequence
5. **Ending choice**: Sets `memory_returned` OR `memory_freed`
6. **Resolution**: Shows appropriate ending based on choice

### Verification:
- [x] GameState.quest_flags dictionary initialized ✅
- [x] Elder dialogue sets flag correctly ✅
- [x] Boss trigger checks flag correctly ✅
- [ ] Ending choice sets final flags (Task #9)
- [ ] No orphaned flags or unreachable states

---

## 3. Battle Balance Testing

### Enemy Progression:

**Level 1 (Starting)**:
- HP: 100, ATK: 10, DEF: 5
- Can defeat: 1-2 slimes
- Challenging: goblin

**Level 2** (after ~30 EXP):
- HP: 115, ATK: 13, DEF: 7
- Can defeat: goblins, shadow wolves
- Challenging: boss (needs strategy)

**Level 3** (after ~100 EXP total):
- HP: 130, ATK: 16, DEF: 9
- Can defeat: boss with skill usage

### Encounter Balance:

**Map B Zone 1** (Early):
- [ ] Verify: 1-2 slimes (10-20 EXP each)
- [ ] Result: Level up to 2 after 2-3 battles

**Map B Zone 2** (Mid):
- [ ] Verify: goblins (18 EXP each)
- [ ] Result: Prepare player for zone 3

**Map B Zone 3** (Hard):
- [ ] Verify: shadow wolves (30 EXP each)
- [ ] Result: Level up to 3 before boss

**Boss Battle** (archivist_shade):
- [ ] Verify: HP 150, ATK 18, DEF 8
- [ ] Test: Beatable at level 2 with skill usage
- [ ] Test: Comfortable at level 3

### Consumable Balance:
- Starting: 3 healing potions
- [ ] Test: Are 3 potions enough to reach boss?
- [ ] Consider: Adding potion drops from battles (optional)

---

## 4. Scene Transitions Verification

### All Transitions Working:
- [x] Title → Map A (New Game) ✅
- [x] Map A ↔ Map B (bidirectional) ✅
- [x] Map → Battle → Map (all encounter types) ✅
- [x] Battle defeat → Game Over → Title ✅
- [ ] Boss victory → Ending sequence (Task #9)
- [ ] Ending → Credits → Title (Task #9)

---

## 5. Edge Case Testing

### Battle System:
- [x] Player defeats all enemies → Victory works ✅
- [x] All enemies defeat player → Defeat works ✅
- [ ] Run from regular battle → Works, returns to map
- [ ] Run from boss battle → Blocked, message shown
- [ ] Use healing potion at full HP → Allowed but wasted
- [ ] Use skill with insufficient MP → Blocked, message shown
- [ ] Defend then get attacked → Damage reduced by 50%

### Dialogue System:
- [ ] Interact with Elder multiple times → Works consistently
- [ ] Choices lead to correct next nodes → No broken paths
- [ ] Dialogue flags persist → Can't reset quest accidentally

### Map System:
- [ ] Map transitions preserve player state → HP/MP/inventory intact
- [ ] Boss area before quest → Blocked with message
- [ ] Boss area after quest → Access granted

### Inventory:
- [ ] Use all potions → Inventory empty, no crashes
- [ ] Gain items from battles → Inventory updates
- [ ] Pause menu shows correct inventory → Always synced

---

## 6. Quest Flow Testing (Full Playthrough)

### Test Path 1: Normal Progression
1. [ ] Start new game
2. [ ] Talk to Elder, accept quest
3. [ ] Talk to Companion (optional)
4. [ ] Go to Map B
5. [ ] Fight encounters, level up
6. [ ] Reach boss area (allowed with flag)
7. [ ] Boss dialogue plays
8. [ ] Defeat boss
9. [ ] Ending sequence triggers
10. [ ] Make choice, see resolution
11. [ ] Credits roll, return to title

### Test Path 2: Early Boss Attempt
1. [ ] Start new game
2. [ ] Skip Elder, go straight to Map B
3. [ ] Try to enter boss area
4. [ ] Should be blocked (no flag)
5. [ ] Return to Elder, accept quest
6. [ ] Boss area now accessible

### Test Path 3: Multiple Defeats
1. [ ] Start new game
2. [ ] Accept quest
3. [ ] Fight battles, intentionally lose
4. [ ] Game Over → Return to Title
5. [ ] Start again, verify state reset

---

## 7. Polish Items

### UI Polish:
- [x] Title screen functional ✅
- [x] Game Over screen functional ✅
- [x] Pause menu functional ✅
- [x] Dialogue box with typewriter effect ✅
- [ ] Battle UI shows all info clearly
- [ ] HP/MP bars update smoothly

### Visual Polish:
- [x] Consistent placeholder art (geometric shapes) ✅
- [x] Player, NPCs, enemies distinguishable ✅
- [ ] Map layouts clear and navigable
- [ ] Collision boundaries intuitive

### Feedback Polish:
- [ ] Battle damage numbers visible
- [ ] EXP gain message shown
- [ ] Level up notification appears
- [ ] Item use confirmation shown
- [ ] Quest flag messages (optional)

---

## 8. Documentation Updates

### Required Docs:
- [x] project_spec.md ✅
- [x] architecture.md (battle_system_architecture.md) ✅
- [x] content_schemas.md ✅
- [x] overworld_systems.md ✅
- [x] battle_system_integration.md ✅
- [x] maps_and_ui.md ✅
- [x] scenario_outline.md ✅
- [x] character_notes.md ✅
- [x] dialogue_ui_spec.md ✅
- [x] vertical_slice_test_report.md ✅
- [ ] README.md (update with final status) (Task #10)
- [ ] CHANGELOG.md or final notes (Task #10)

---

## 9. Known Issues & Fixes

### Critical (Must Fix):
- None identified yet

### Minor (Nice to Have):
- [ ] Add fade transitions between scenes (optional)
- [ ] Add battle victory fanfare (optional, no audio yet)
- [ ] Add EXP bar visualization (optional)

### Out of Scope:
- Save/load system (optional for MVP)
- Equipment system (post-MVP)
- Multiple party members (post-MVP)
- Complex status effects (post-MVP)

---

## 10. Acceptance Criteria (Final MVP)

From original specification:

✅ **Exploration**:
- [x] Move in all directions
- [x] Collide with walls
- [x] Interact with NPCs
- [x] Transition between maps

✅ **Quest Gating**:
- [x] Boss area inaccessible until Elder dialogue complete

⏳ **Battle** (Verify):
- [ ] All actions work (Attack/Defend/Skill/Item/Run)
- [ ] No softlocks
- [ ] Victory/defeat returns to correct state

⏳ **Progression** (Verify):
- [ ] EXP accumulates correctly
- [ ] Level-up applies stat increases
- [ ] Boss is beatable with reasonable play

⏳ **Narrative** (Task #9):
- [ ] Can reach ending scene
- [ ] Player choice affects ending dialogue/scene

---

## Sign-Off

**Vertical Slice**: ✅ PASSED (Task #7)
**Full MVP**: ⏳ IN PROGRESS (Task #8)
**Ending**: ⏳ ASSIGNED (Task #9)
**Documentation**: ⏳ PENDING (Task #10)

**Estimated Completion**: Pending Agent C completion of ending sequence

---

## Next Actions

1. **Team Lead** (Task #8):
   - [x] Create integration checklist
   - [ ] Verify NPC dialogue IDs in map scenes
   - [ ] Test battle balance with multiple playthroughs
   - [ ] Run edge case tests
   - [ ] Coordinate final integration

2. **Agent C** (Task #9):
   - [ ] Implement ending sequence
   - [ ] Create ending_screen.tscn
   - [ ] Test both ending paths
   - [ ] Report completion

3. **All Agents** (Stand by for Task #10):
   - Final documentation and "Next Steps" roadmap
