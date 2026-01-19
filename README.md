# godot-sidescroller

A 2D sidescroller game built with Godot 4.5, featuring Mario-style movement physics.

## Features

- **Mario-like movement**: Acceleration, inertia, and momentum-based physics
- **Jump inertia**: Jump higher and further when running at speed
- **Collectibles**: Coins to collect throughout levels
- **Enemies**: Slimes that can hurt the player
- **Killzones**: Hazards that reset the player
- **HUD**: On-screen display for game information

## Controls

| Action | Key |
|--------|-----|
| Move Left | Left Arrow |
| Move Right | Right Arrow |
| Jump | Space |
| Run (sprint) | Shift |

## Project Structure

```
scenes/       # Game scenes (.tscn files)
scripts/      # GDScript files
assets/       # Sprites, audio, and other assets
```

## Development

### Requirements

- Godot 4.5
- Python 3 (for linting tools)

### Setup

```bash
make install-deps   # Install Python dependencies for linting
```

### Commands

```bash
make lint           # Run linter on all GDScript files
make format         # Format all GDScript files
make check          # Check formatting without modifying
```
