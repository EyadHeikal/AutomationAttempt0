.PHONY: help setup setup-user update update-user clean-xcode all

# Default target
help:
	@echo "Mac Setup Scripts - Available targets:"
	@echo ""
	@echo "  make setup        - Run initial Mac setup (SetupMac.sh)"
	@echo "  make setup-user   - Run user-level setup (SetupMacUser.sh)"
	@echo "  make update       - Update all system packages (UpdateMac.sh)"
	@echo "  make update-user  - Update user-level tools (UpdateMacUser.sh)"
	@echo "  make clean-xcode  - Clear Xcode derived data (ClearDerivedData.sh)"
	@echo "  make all          - Run all setup tasks"
	@echo ""

setup:
	@echo "Running Mac setup..."
	@bash SetupMac.sh

setup-user:
	@echo "Running user-level setup..."
	@bash SetupMacUser.sh

update:
	@echo "Updating packages..."
	@bash UpdateMac.sh

update-user:
	@echo "Updating user-level tools..."
	@bash UpdateMacUser.sh

clean-xcode:
	@echo "Clearing Xcode derived data..."
	@bash ClearDerivedData.sh

all: setup setup-user
	@echo "All setup tasks completed!"



