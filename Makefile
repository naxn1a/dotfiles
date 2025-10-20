# Naxn1a Nix Configuration Makefile
# Optimized for 2025 - Supports macOS and Linux

.PHONY: help install install-darwin install-linux update switch clean check doctor backup restore format

# Default target
.DEFAULT_GOAL := help

# Variables
SHELL := /bin/bash
UNAME_S := $(shell uname -s)
FLAKE_DIR := $(shell pwd)
BACKUP_DIR := $(HOME)/.nix-backup-$(shell date +%Y%m%d-%H%M%S)
COLOR_GREEN := \033[0;32m
COLOR_BLUE := \033[0;34m
COLOR_YELLOW := \033[0;33m
COLOR_RED := \033[0;31m
COLOR_RESET := \033[0m

# Detect platform
ifeq ($(UNAME_S),Darwin)
	PLATFORM := darwin
	HOSTNAME := $(shell scutil --get LocalHostName)
else ifeq ($(UNAME_S),Linux)
	PLATFORM := linux
	HOSTNAME := $(shell hostname)
else
	$(error Unsupported platform: $(UNAME_S))
endif

# Help target
help: ## Show this help message
	@echo "$(COLOR_BLUE)🚀 Naxn1a Nix Configuration Manager$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)=====================================$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_YELLOW)Platform detected: $(PLATFORM) ($(HOSTNAME))$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_GREEN)Available targets:$(COLOR_RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(COLOR_BLUE)%-20s$(COLOR_RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(COLOR_YELLOW)Quick start:$(COLOR_RESET)"
	@echo "  make install-$(PLATFORM)    # Install for current platform"
	@echo "  make switch                 # Apply configuration"
	@echo "  make update                 # Update packages"

# Installation targets
install: ## Install configuration for detected platform
	@echo "$(COLOR_BLUE)🔍 Detecting platform...$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Platform: $(PLATFORM)$(COLOR_RESET)"
	@sleep 1
	@$(MAKE) install-$(PLATFORM)

install-darwin: ## Install Nix-Darwin configuration (macOS)
	@echo "$(COLOR_GREEN)🍎 Installing Nix-Darwin configuration...$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)⚠️  This will replace your current system configuration$(COLOR_RESET)"
	@read -p "Continue? (y/N) " confirm && [ "$$confirm" = "y" ] || exit 1
	@$(MAKE) backup
	@$(MAKE) check
	@echo "$(COLOR_BLUE)📦 Building configuration...$(COLOR_RESET)"
	nix build .#darwinConfigurations.$(HOSTNAME).system
	@echo "$(COLOR_BLUE)🔄 Switching to new configuration...$(COLOR_RESET)"
	./result/sw/bin/darwin-rebuild switch --flake .#$(HOSTNAME)
	@echo "$(COLOR_GREEN)✅ Installation complete!$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)🔄 Please restart your shell to see changes$(COLOR_RESET)"

install-linux: ## Install Home-Manager configuration (Linux)
	@echo "$(COLOR_GREEN)🐧 Installing Home-Manager configuration...$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)⚠️  This will replace your current home configuration$(COLOR_RESET)"
	@read -p "Continue? (y/N) " confirm && [ "$$confirm" = "y" ] || exit 1
	@$(MAKE) backup
	@$(MAKE) check
	@echo "$(COLOR_BLUE)📦 Building configuration...$(COLOR_RESET)"
	nix build .#homeConfigurations.$(USER).activationPackage
	@echo "$(COLOR_BLUE)🔄 Activating new configuration...$(COLOR_RESET)"
	./result/activate
	@echo "$(COLOR_GREEN)✅ Installation complete!$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)🔄 Please restart your shell to see changes$(COLOR_RESET)"

# Management targets
switch: ## Apply configuration without rebuilding
	@echo "$(COLOR_BLUE)🔄 Switching to current configuration...$(COLOR_RESET)"
	@if [ "$(PLATFORM)" = "darwin" ]; then \
		darwin-rebuild switch --flake .#$(HOSTNAME); \
	else \
		home-manager switch --flake .#$(USER); \
	fi
	@echo "$(COLOR_GREEN)✅ Configuration updated!$(COLOR_RESET)"

update: ## Update packages and rebuild
	@echo "$(COLOR_BLUE)📦 Updating packages...$(COLOR_RESET)"
	@if [ "$(PLATFORM)" = "darwin" ]; then \
		nix flake update && darwin-rebuild switch --flake .#$(HOSTNAME) --upgrade; \
	else \
		nix flake update && home-manager switch --flake .#$(USER) --upgrade; \
	fi
	@echo "$(COLOR_GREEN)✅ Update complete!$(COLOR_RESET)"

# Maintenance targets
clean: ## Clean Nix store and build artifacts
	@echo "$(COLOR_BLUE)🧹 Cleaning Nix store...$(COLOR_RESET)"
	nix store gc --verbose
	nix store optimise
	@echo "$(COLOR_BLUE)🗑️  Removing build artifacts...$(COLOR_RESET)"
	rm -f result
	@echo "$(COLOR_GREEN)✅ Cleanup complete!$(COLOR_RESET)"

clean-all: ## Deep clean including old generations
	@echo "$(COLOR_YELLOW)⚠️  This will remove old system generations$(COLOR_RESET)"
	@read -p "Continue? (y/N) " confirm && [ "$$confirm" = "y" ] || exit 1
	@echo "$(COLOR_BLUE)🧹 Deep cleaning...$(COLOR_RESET)"
	nix-collect-garbage -d
	@echo "$(COLOR_GREEN)✅ Deep cleanup complete!$(COLOR_RESET)"

# Development targets
build: ## Build configuration without activating
	@echo "$(COLOR_BLUE)📦 Building configuration...$(COLOR_RESET)"
	@if [ "$(PLATFORM)" = "darwin" ]; then \
		nix build .#darwinConfigurations.$(HOSTNAME).system; \
	else \
		nix build .#homeConfigurations.$(USER).activationPackage; \
	fi
	@echo "$(COLOR_GREEN)✅ Build complete!$(COLOR_RESET)"

test: ## Test configuration syntax
	@echo "$(COLOR_BLUE)🧪 Testing configuration...$(COLOR_RESET)"
	nix flake check --all-systems
	@echo "$(COLOR_GREEN)✅ Configuration test passed!$(COLOR_RESET)"

dev-shell: ## Enter development shell
	@echo "$(COLOR_BLUE)🛠️  Entering development shell...$(COLOR_RESET)"
	nix develop

# Utility targets
check: ## Check system requirements
	@echo "$(COLOR_BLUE)🔍 Checking system requirements...$(COLOR_RESET)"
	@command -v nix >/dev/null 2>&1 || { echo "$(COLOR_RED)❌ Nix is not installed$(COLOR_RESET)"; exit 1; }
	@echo "$(COLOR_GREEN)✅ Nix found: $(shell nix --version)$(COLOR_RESET)"
	@if [ "$(PLATFORM)" = "darwin" ]; then \
		command -v darwin-rebuild >/dev/null 2>&1 || { echo "$(COLOR_RED)❌ darwin-rebuild not found$(COLOR_RESET)"; exit 1; }; \
		echo "$(COLOR_GREEN)✅ darwin-rebuild found$(COLOR_RESET)"; \
	else \
		command -v home-manager >/dev/null 2>&1 || { echo "$(COLOR_RED)❌ home-manager not found$(COLOR_RESET)"; exit 1; }; \
		echo "$(COLOR_GREEN)✅ home-manager found$(COLOR_RESET)"; \
	fi
	@echo "$(COLOR_GREEN)✅ System requirements met$(COLOR_RESET)"

doctor: ## Diagnose common issues
	@echo "$(COLOR_BLUE)🩺 Running system diagnostics...$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Platform: $(PLATFORM)$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Nix version:$(COLOR_RESET)"
	@nix --version
	@echo "$(COLOR_YELLOW)Flake directory: $(FLAKE_DIR)$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Free disk space:$(COLOR_RESET)"
	@df -h . | tail -1
	@if [ -d "$(HOME)/.nix-profile" ]; then \
		echo "$(COLOR_YELLOW)Profile size:$(COLOR_RESET)"; \
		du -sh "$(HOME)/.nix-profile" 2>/dev/null || echo "Cannot determine"; \
	fi
	@echo "$(COLOR_GREEN)✅ Diagnostics complete$(COLOR_RESET)"

backup: ## Backup current configuration
	@echo "$(COLOR_BLUE)💾 Creating backup...$(COLOR_RESET)"
	@mkdir -p "$(BACKUP_DIR)"
	@if [ -d "$(HOME)/.nix-profile" ]; then \
		cp -r "$(HOME)/.nix-profile" "$(BACKUP_DIR)/"; \
	fi
	@if [ -f "$(HOME)/.zshrc" ]; then \
		cp "$(HOME)/.zshrc" "$(BACKUP_DIR)/"; \
	fi
	@if [ -d "$(HOME)/.config/nixpkgs" ]; then \
		cp -r "$(HOME)/.config/nixpkgs" "$(BACKUP_DIR)/"; \
	fi
	@echo "$(COLOR_GREEN)✅ Backup created at: $(BACKUP_DIR)$(COLOR_RESET)"

restore: ## Restore from backup (interactive)
	@echo "$(COLOR_BLUE)📂 Available backups:$(COLOR_RESET)"
	@ls -la "$(HOME)/.nix-backup-*" 2>/dev/null || echo "$(COLOR_RED)No backups found$(COLOR_RESET)"
	@read -p "Enter backup directory (or 'cancel'): " backup; \
	if [ "$$backup" != "cancel" ] && [ -d "$$backup" ]; then \
		echo "$(COLOR_YELLOW)⚠️  This will replace current configuration$(COLOR_RESET)"; \
		read -p "Continue? (y/N) " confirm && [ "$$confirm" = "y" ] || exit 1; \
		cp -r "$$backup"/* "$(HOME)/"; \
		echo "$(COLOR_GREEN)✅ Restore complete!$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_RED)Restore cancelled$(COLOR_RESET)"; \
	fi

format: ## Format Nix files
	@echo "$(COLOR_BLUE)🎨 Formatting Nix files...$(COLOR_RESET)"
	@find . -name "*.nix" -exec nixfmt {} \; 2>/dev/null || echo "$(COLOR_YELLOW)nixfmt not available, install with: nix-env -iA nixpkgs.nixfmt$(COLOR_RESET)"
	@echo "$(COLOR_GREEN)✅ Formatting complete!$(COLOR_RESET)"

# Info targets
info: ## Show configuration information
	@echo "$(COLOR_BLUE)📋 Configuration Information$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)===========================$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Platform:$(COLOR_RESET) $(PLATFORM)"
	@echo "$(COLOR_YELLOW)Hostname:$(COLOR_RESET) $(HOSTNAME)"
	@echo "$(COLOR_YELLOW)User:$(COLOR_RESET) $(USER)"
	@echo "$(COLOR_YELLOW)Flake directory:$(COLOR_RESET) $(FLAKE_DIR)"
	@echo "$(COLOR_YELLOW)Nix version:$(COLOR_RESET)"
	@nix --version | head -1
	@echo "$(COLOR_YELLOW)Available configurations:$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)  darwinConfigurations:$(COLOR_RESET)"
	@nix flake show --json | jq -r '.darwinConfigurations | keys[]' 2>/dev/null || echo "  No darwin configurations"
	@echo "$(COLOR_BLUE)  homeConfigurations:$(COLOR_RESET)"
	@nix flake show --json | jq -r '.homeConfigurations | keys[]' 2>/dev/null || echo "  No home configurations"

# Quick install shortcuts
quick-install: ## Quick install (skip backup)
	@echo "$(COLOR_YELLOW)⚡ Quick install (no backup)...$(COLOR_RESET)"
	@echo "$(COLOR_RED)⚠️  This will replace your configuration without backup$(COLOR_RESET)"
	@read -p "Continue? (y/N) " confirm && [ "$$confirm" = "y" ] || exit 1
	@$(MAKE) check
	@if [ "$(PLATFORM)" = "darwin" ]; then \
		darwin-rebuild switch --flake .#$(HOSTNAME); \
	else \
		home-manager switch --flake .#$(USER); \
	fi
	@echo "$(COLOR_GREEN)✅ Quick install complete!$(COLOR_RESET)"

# Version targets
version: ## Show version information
	@echo "$(COLOR_BLUE)🔢 Version Information$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)====================$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Nix:$(COLOR_RESET)"
	@nix --version
	@if command -v darwin-rebuild >/dev/null 2>&1; then \
		echo "$(COLOR_YELLOW)Darwin-rebuild:$(COLOR_RESET)"; \
		darwin-rebuild --version; \
	fi
	@if command -v home-manager >/dev/null 2>&1; then \
		echo "$(COLOR_YELLOW)Home-manager:$(COLOR_RESET)"; \
		home-manager --version; \
	fi
	@echo "$(COLOR_YELLOW)Make:$(COLOR_RESET)"
	@make --version | head -1

# Uninstall target
uninstall: ## Uninstall Nix configuration
	@echo "$(COLOR_RED)⚠️  This will remove all Nix configurations$(COLOR_RESET)"
	@echo "$(COLOR_RED)⚠️  This is a destructive operation$(COLOR_RESET)"
	@read -p "Type 'uninstall' to confirm: " confirm && [ "$$confirm" = "uninstall" ] || exit 1
	@$(MAKE) backup
	@if [ "$(PLATFORM)" = "darwin" ]; then \
		darwin-rebuild switch --flake .#$(HOSTNAME) --rollback 2>/dev/null || true; \
	else \
		home-manager switch --flake .#$(USER) --rollback 2>/dev/null || true; \
	fi
	@echo "$(COLOR_YELLOW)🗑️  Removing profiles...$(COLOR_RESET)"
	@rm -rf "$(HOME)/.nix-profile" "$(HOME)/.config/nixpkgs"
	@echo "$(COLOR_GREEN)✅ Uninstall complete$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)📁 Backup available at: $(BACKUP_DIR)$(COLOR_RESET)"