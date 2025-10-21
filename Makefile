# Naxn1a Nix Configuration Makefile

.PHONY: help install install-darwin install-linux update clean check info

# Default target
.DEFAULT_GOAL := help

# Variables
SHELL := /bin/bash
UNAME_S := $(shell uname -s)
FLAKE_DIR := $(shell pwd)

# Color variables (cross-platform compatible)
ifeq ($(shell tput colors 2>/dev/null || echo 0), 0)
    # No color support
    COLOR_GREEN :=
    COLOR_BLUE :=
    COLOR_YELLOW :=
    COLOR_RED :=
    COLOR_BOLD :=
    COLOR_RESET :=
else
    # Use tput for better compatibility
    COLOR_GREEN := $(shell tput setaf 2 2>/dev/null || echo "")
    COLOR_BLUE := $(shell tput setaf 4 2>/dev/null || echo "")
    COLOR_YELLOW := $(shell tput setaf 3 2>/dev/null || echo "")
    COLOR_RED := $(shell tput setaf 1 2>/dev/null || echo "")
    COLOR_BOLD := $(shell tput bold 2>/dev/null || echo "")
    COLOR_RESET := $(shell tput sgr0 2>/dev/null || echo "")
endif

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

help: ## Show this help message
	@echo "$(COLOR_BLUE)🚀 Naxn1a Nix Configuration Manager$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)=====================================$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_YELLOW)Platform detected: $(PLATFORM) ($(HOSTNAME))$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_GREEN)Command:$(COLOR_RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(COLOR_BLUE)%-20s$(COLOR_RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install configuration for detected platform
	@echo "$(COLOR_BLUE)🔍 Detecting platform...$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Platform: $(PLATFORM)$(COLOR_RESET)"
	@sleep 1
	@$(MAKE) install-$(PLATFORM)

install-darwin: ## Install Nix-Darwin configuration (MacOS)
	@echo "$(COLOR_GREEN)🍎 Installing Nix-Darwin configuration...$(COLOR_RESET)"
	@if ! command -v darwin-rebuild >/dev/null 2>&1; then \
		echo "$(COLOR_BLUE)📦 Installing nix-darwin...$(COLOR_RESET)"; \
		sudo nix run nix-darwin --extra-experimental-features "nix-command flakes"  -- switch --flake .#naxn1a-darwin; \
	else \
		sudo darwin-rebuild switch --flake .#naxn1a-darwin; \
	fi
	@echo "$(COLOR_GREEN)✅ Installation complete!$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)🔄 Please restart your shell to see changes$(COLOR_RESET)"

install-linux: ## Install Home-Manager configuration (Linux)
	@echo "$(COLOR_GREEN)🐧 Installing Home-Manager configuration...$(COLOR_RESET)"
	@if ! command -v home-manager >/dev/null 2>&1; then \
		@echo "$(COLOR_BLUE)📦 Installing home-manager...$(COLOR_RESET)"; \
		nix run home-manager --extra-experimental-features "nix-command flakes"  -- switch --flake .#naxn1a-linux; \
	else \
		home-manager switch --flake .#naxn1a-linux; \
	fi
	@echo "$(COLOR_GREEN)✅ Installation complete!$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)🔄 Please restart your shell to see changes$(COLOR_RESET)"

update: ## Update packages and rebuild
	@echo "$(COLOR_BLUE)📦 Updating packages...$(COLOR_RESET)"
	@if [ "$(PLATFORM)" = "darwin" ]; then \
		sudo nix flake update && sudo darwin-rebuild switch --flake .#naxn1a-darwin; \
	else \
		sudo nix flake update && sudo home-manager switch --flake .#naxn1a-linux; \
	fi
	@echo "$(COLOR_GREEN)✅ Update complete!$(COLOR_RESET)"

clean: ## Clean Nix store and build artifacts
	@echo "$(COLOR_BLUE)🧹 Cleaning Nix store...$(COLOR_RESET)"
	sudo rm -rf /nix/var/nix/downloads
	sudo rm -rf /nix/var/nix/gcroots/auto
	sudo rm -rf /nix/var/nix/profiles/per-user/*/.nix-profile-*
	nix-collect-garbage -d
	nix store gc --verbose
	nix store optimise
	@echo "$(COLOR_GREEN)✅ Cleanup complete!$(COLOR_RESET)"

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
	@echo "$(COLOR_GREEN)🟢 Check passed!$(COLOR_RESET)"

info: ## Show configuration information
	@echo "$(COLOR_BLUE)📋 Configuration Information$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)===========================$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Platform:$(COLOR_RESET) $(PLATFORM)"
	@echo "$(COLOR_YELLOW)Hostname:$(COLOR_RESET) $(HOSTNAME)"
	@echo "$(COLOR_YELLOW)User:$(COLOR_RESET) $(USER)"
	@echo "$(COLOR_YELLOW)Flake directory:$(COLOR_RESET) $(FLAKE_DIR)"
	@echo "$(COLOR_YELLOW)Nix version: $(shell nix --version)$(COLOR_RESET)"
