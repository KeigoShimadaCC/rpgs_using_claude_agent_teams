# Manual Test Checklist for JRPG Game

## Pre-Test Setup
- [ ] Launch Godot
- [ ] Start new game
- [ ] Verify player spawns in village

## Test 1: Basic Movement
- [ ] Move player with arrow keys
- [ ] Verify smooth movement
- [ ] Verify animations play correctly
- [ ] Walk to right edge of village

## Test 2: Map Transition
- [ ] Walk right to trigger map transition
- [ ] Verify fade transition occurs
- [ ] Verify player spawns at correct position on field map
- [ ] Walk left to return to village
- [ ] Verify player spawns at correct position

## Test 3: First Encounter
- [ ] On field map, walk around in grass
- [ ] Verify encounter triggers (should happen within ~20 steps)
- [ ] Verify battle scene loads
- [ ] Verify 2 enemies appear (Goblin + Slime)
- [ ] Verify enemy HP bars visible
- [ ] Verify player stats visible

## Test 4: Manual Battle Actions
- [ ] Click "Attack" button
- [ ] Select an enemy
- [ ] Verify damage dealt
- [ ] Verify enemy HP decreases
- [ ] Wait for enemy turn
- [ ] Verify enemy attacks
- [ ] Verify player HP decreases

## Test 5: Auto-Battle Toggle
- [ ] Click "Auto" button
- [ ] Verify button changes to "Auto: ON"
- [ ] Verify turn executes automatically
- [ ] Wait for next turn
- [ ] Verify turn auto-executes again
- [ ] Click "Auto" button again
- [ ] Verify button changes to "Auto: OFF"
- [ ] Verify manual control returns

## Test 6: Battle Victory
- [ ] Defeat all enemies (use Auto mode for speed)
- [ ] Verify victory message
- [ ] Verify EXP and gold gained
- [ ] Verify return to overworld
- [ ] Verify player at same position as before battle

## Test 7: Grace Period
- [ ] After winning battle, walk around
- [ ] Count steps (should be able to take 5 steps)
- [ ] Verify NO encounters during first 5 steps
- [ ] Continue walking
- [ ] Verify encounters CAN trigger after 5 steps

## Test 8: Encounter Rate
- [ ] Walk around field for ~50 steps
- [ ] Count number of encounters
- [ ] Should be approximately 7-8 encounters (15% rate)
- [ ] Should feel moderate, not too frequent

## Test 9: Keyboard Navigation (if implemented)
- [ ] Enter battle
- [ ] Use arrow keys to navigate menu
- [ ] Press Enter to select
- [ ] Verify all menus respond to keyboard

## Test 10: Skills and Items
- [ ] In battle, click "Skill"
- [ ] Verify skill menu shows Fire Bolt and Heal
- [ ] Select Fire Bolt
- [ ] Select enemy target
- [ ] Verify skill executes and costs MP
- [ ] Click "Item" (if you have items)
- [ ] Verify item menu shows
- [ ] Use item
- [ ] Verify effect applies

## Bug Tracking
Record any issues found:
- [ ] Issue 1: ___________________________
- [ ] Issue 2: ___________________________
- [ ] Issue 3: ___________________________

## Test Results
- Total tests: 10
- Passed: ___
- Failed: ___
- Bugs found: ___
