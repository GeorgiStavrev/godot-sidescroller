# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Work process
Always follow a strict 3-step loop:
PLAN: Analyze the request, list affected files, and outline steps. Ask for approval.
IMPLEMENT: Implement the changes, aiming for minimum viable code.
VALIDATE: Run tests. If tests fail, fix them before finalizing.
Do not skip steps.

## Development process
Always write tests as part of the implementation. You will use them in the VALIDATE step later.

## Project Overview

A 2D sidescroller game built with Godot 4.5 featuring Mario-style movement physics with acceleration, inertia, and momentum-based mechanics.

## Commands

```bash
make install-deps   # Install Python dependencies (gdformat)
make lint           # Check GDScript formatting (exits with error if issues found)
make format         # Auto-format all GDScript files
make check          # Check formatting without modifying files
```

To run the game, open the project in Godot 4.5 and press F5, or run via CLI:
```bash
godot --path . scenes/game.tscn
```

## Architecture

### Autoload Singleton
- **GameManager** (`scripts/game_manager.gd`): Global singleton for game state. Tracks coins and emits signals (`coin_collected`, `coins_changed`) that other nodes connect to.

### Scene/Script Pairs
Each gameplay entity has a corresponding `.tscn` scene and `.gd` script in parallel directories:
- `scenes/player.tscn` + `scripts/player.gd` - CharacterBody2D with Mario-like physics
- `scenes/coin.tscn` + `scripts/coin.gd` - Area2D collectible that notifies GameManager
- `scenes/slime.tscn` + `scripts/slime.gd` - Enemy that patrols using RayCast2D for edge/wall detection
- `scenes/killzone.tscn` + `scripts/killzone.gd` - Area2D hazard that resets the scene
- `scenes/hud.tscn` + `scripts/hud.gd` - CanvasLayer UI that subscribes to GameManager signals

### Player Physics Constants
The player script uses tuned constants for Mario-style feel:
- Ground acceleration/friction differs from air control
- Sprint mode (`Shift`) increases max speed and jump height
- Inertia threshold determines when reduced friction applies

### Input Actions
Defined in `project.godot`: `jump` (Space), `run_left`/`run_right` (Arrow keys), `sprint` (Shift)
