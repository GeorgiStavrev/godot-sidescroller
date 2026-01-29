.PHONY: help lint format check install-deps install-addons test test-verbose

# Godot executable path (override with GODOT=/path/to/godot)
GODOT ?= /Applications/Godot.app/Contents/MacOS/Godot

# Default target
help:
	@echo "Available commands:"
	@echo "  make lint           - Run linter on all GDScript files"
	@echo "  make format         - Format all GDScript files"
	@echo "  make check          - Check formatting without modifying files"
	@echo "  make install-deps   - Install Python dependencies"
	@echo "  make install-addons - Install Godot addons (GUT)"
	@echo "  make test           - Run unit tests with GUT"
	@echo "  make test-verbose   - Run tests with verbose output"

# Install Python dependencies
install-deps:
	pip install -r requirements.txt

# Install Godot addons
install-addons:
	@echo "Installing GUT v9.5.1..."
	@mkdir -p addons
	@rm -rf addons/gut
	@curl -sL https://github.com/bitwes/Gut/archive/refs/tags/v9.5.1.tar.gz | tar -xz -C addons
	@mv addons/Gut-9.5.1 addons/gut
	@echo "Addons installed!"

# Find all GDScript files recursively (excluding .godot and .git directories)
GDFILES := $(shell find . -name "*.gd" -not -path "./.godot/*" -not -path "./.git/*" 2>/dev/null || find . -name "*.gd" -type f 2>/dev/null)

# Lint all GDScript files
lint:
	@echo "Running linter on GDScript files..."
	@if [ -z "$(GDFILES)" ]; then \
		echo "No GDScript files found."; \
	else \
		gdformat --check $(GDFILES) || (echo "Linting failed. Run 'make format' to auto-fix." && exit 1); \
	fi

# Format all GDScript files
format:
	@echo "Formatting GDScript files..."
	@if [ -z "$(GDFILES)" ]; then \
		echo "No GDScript files found."; \
	else \
		gdformat $(GDFILES); \
		echo "Formatting complete!"; \
	fi

# Check formatting without modifying files
check:
	@echo "Checking GDScript formatting..."
	@if [ -z "$(GDFILES)" ]; then \
		echo "No GDScript files found."; \
	else \
		gdformat --check $(GDFILES); \
	fi

# Run unit tests with GUT
test:
	@echo "Importing project scripts..."
	$(GODOT) --headless --path . --import
	@echo "Running GUT tests..."
	$(GODOT) --headless --path . -s addons/gut/gut_cmdln.gd -gconfig=.gutconfig.json

# Run tests with verbose output
test-verbose:
	@echo "Importing project scripts..."
	$(GODOT) --headless --path . --import
	@echo "Running GUT tests (verbose)..."
	$(GODOT) --headless --path . -s addons/gut/gut_cmdln.gd -gconfig=.gutconfig.json -glog=2
