.PHONY: help lint format check install-deps

# Default target
help:
	@echo "Available commands:"
	@echo "  make lint          - Run linter on all GDScript files"
	@echo "  make format        - Format all GDScript files"
	@echo "  make check         - Check formatting without modifying files"
	@echo "  make install-deps  - Install Python dependencies"

# Install Python dependencies
install-deps:
	pip install -r requirements.txt

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
