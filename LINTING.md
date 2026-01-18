# GDScript Linting Setup

This project uses `gdformat` for GDScript code formatting and linting.

## Installation

### 1. Install Python dependencies

```bash
make install-deps
```

Or manually:
```bash
pip install -r requirements.txt
```

### 2. Install pre-commit hooks (optional but recommended)

```bash
pip install pre-commit
pre-commit install
```

## Usage

### Format all GDScript files
```bash
make format
```

### Check formatting (without modifying files)
```bash
make check
```

### Lint files (same as check, but exits with error code)
```bash
make lint
```

## Pre-commit Hooks

If you've installed pre-commit hooks, they will automatically run `gdformat` on all `.gd` files before each commit. The hooks will:
- Format files automatically
- Prevent commit if formatting fails (unless you use `--no-verify`)

## Manual Usage

You can also run gdformat directly:

```bash
# Format a specific file
gdformat scripts/player.gd

# Check formatting without modifying
gdformat --check scripts/player.gd

# Format all files in scripts directory
gdformat scripts/*.gd
```

## CI/CD Integration

To use in CI/CD pipelines, add this to your workflow:

```yaml
- name: Check GDScript formatting
  run: |
    pip install -r requirements.txt
    make lint
```
