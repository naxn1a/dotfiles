# Cross-platform Makefile for Nix Environment Management
# Supports macOS, Linux, and Windows (WSL2)

.PHONY: help install update switch clean doctor build check test format lint devenv

# Default target
.DEFAULT_GOAL := help

# Detect operating system
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

# Determine system configuration
ifeq ($(UNAME_S),Darwin)
	ifeq ($(UNAME_M),arm64)
		SYSTEM := aarch64-darwin
		CONFIG := naxn1a-darwin
		BUILD_CMD := darwin-rebuild
		SWITCH_CMD := sudo darwin-rebuild switch
	else
		SYSTEM := x86_64-darwin
		CONFIG := naxn1a-darwin-intel
		BUILD_CMD := darwin-rebuild
		SWITCH_CMD := sudo darwin-rebuild switch
	endif
	INSTALL_DEPS := brew install nix
else ifeq ($(UNAME_S),Linux)
	# Default Linux configuration
	SYSTEM := x86_64-linux
	CONFIG := naxn1a-linux
	BUILD_CMD := home-manager build
	SWITCH_CMD := home-manager switch
	INSTALL_DEPS := curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
	# Check if WSL2 at runtime (not in Make variables)
	WSL_CHECK := $(shell grep -qi microsoft /proc/version 2>/dev/null && echo "wsl" || echo "linux")
	ifeq ($(WSL_CHECK),wsl)
		CONFIG := naxn1a-wsl
	endif
else
	$(error Unsupported system: $(UNAME_S))
endif

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[0;37m
RESET := \033[0m

# Help target
help: ## Show this help message
	@echo "$(CYAN)Nix Environment Management Makefile$(RESET)"
	@echo "$(YELLOW)Detected System: $(SYSTEM) ($(CONFIG))$(RESET)"
	@echo ""
	@echo "$(GREEN)Available targets:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(CYAN)%-15s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Installation targets
install-deps: ## Install Nix and dependencies for current platform
	@echo "$(YELLOW)Installing Nix and dependencies for $(SYSTEM)...$(RESET)"
	@if command -v nix >/dev/null 2>&1; then \
		echo "$(GREEN)✅ Nix is already installed$(RESET)"; \
	else \
		echo "$(BLUE)📦 Installing Nix...$(RESET)"; \
		$(INSTALL_DEPS); \
	fi

install: install-deps ## Install the complete Nix environment
	@echo "$(YELLOW)🚀 Installing Nix Environment for $(SYSTEM)...$(RESET)"
	@echo "$(CYAN)Configuration: $(CONFIG)$(RESET)"
	@echo ""
	@echo "$(BLUE)🔨 Updating flake...$(RESET)"
	nix flake update
	@echo ""
	@echo "$(GREEN)🔄 Switching to new configuration...$(RESET)"
ifeq ($(UNAME_S),Darwin)
	sudo nix build .#darwinConfigurations.$(CONFIG).system
	sudo ./result/sw/bin/darwin-rebuild switch --flake .#$(CONFIG)
	@echo "$(BLUE)🧹 Cleaning up build artifacts...$(RESET)"
	rm -rf result
else
	@if command -v home-manager >/dev/null 2>&1; then \
		home-manager switch --flake .#$(CONFIG); \
	else \
		echo "$(YELLOW)🔧 home-manager not found in PATH, using nix run...$(RESET)"; \
		nix run nixpkgs#home-manager -- switch --flake .#$(CONFIG); \
	fi
endif
	@echo ""
	@echo "$(GREEN)✅ Installation complete!$(RESET)"
	@echo "$(YELLOW)📝 Please restart your shell or run 'source ~/.zshrc' to load changes$(RESET)"

# Update and switch targets
update: ## Update flake inputs and rebuild configuration
	@echo "$(YELLOW)🔄 Updating Nix Environment...$(RESET)"
	nix flake update
	$(MAKE) switch
	@echo "$(GREEN)✅ Update complete!$(RESET)"

switch: ## Switch to current configuration (no update)
	@echo "$(YELLOW)🔄 Switching to configuration...$(RESET)"
ifeq ($(UNAME_S),Darwin)
	sudo $(SWITCH_CMD) --flake .#$(CONFIG)
else
	@if command -v home-manager >/dev/null 2>&1; then \
		$(SWITCH_CMD) --flake .#$(CONFIG); \
	else \
		echo "$(YELLOW)🔧 home-manager not found in PATH, using nix run...$(RESET)"; \
		nix run nixpkgs#home-manager -- switch --flake .#$(CONFIG); \
	fi
endif
	@echo "$(GREEN)✅ Switch complete!$(RESET)"

build: ## Build configuration without switching
	@echo "$(YELLOW)🔨 Building configuration...$(RESET)"
	$(BUILD_CMD) --flake .#$(CONFIG)
	@echo "$(GREEN)✅ Build complete!$(RESET)"

# Maintenance targets
clean: ## Clean Nix store and old generations
	@echo "$(YELLOW)🧹 Cleaning Nix store...$(RESET)"
	nix store gc --delete-older-than 30d
	@echo "$(BLUE)🧹 Removing build artifacts...$(RESET)"
	rm -rf result
	@echo "$(GREEN)✅ Cleanup complete!$(RESET)"

clean-all: ## Aggressive cleanup (removes old generations)
	@echo "$(RED)⚠️  This will remove old generations. Continue? [y/N]$(RESET)$(RESET)"
	@read -r confirm && [ "$$confirm" = "y" ] || exit 1
	nix-collect-garbage -d
	@echo "$(BLUE)🧹 Removing build artifacts...$(RESET)"
	rm -rf result
	@echo "$(GREEN)✅ Aggressive cleanup complete!$(RESET)"

# Development targets
doctor: ## Check system health and configuration
	@echo "$(CYAN)🔍 System Health Check$(RESET)"
	@echo "$(YELLOW)System: $(SYSTEM) ($(CONFIG))$(RESET)"
	@echo ""
	@echo "$(BLUE)🔧 Nix Information:$(RESET)"
	@command -v nix >/dev/null 2>&1 && echo "✅ Nix: $$(nix --version)" || echo "❌ Nix: Not found"
	@command -v home-manager >/dev/null 2>&1 && echo "✅ Home Manager: $$(home-manager --version)" || echo "❌ Home Manager: Not found"
	@echo ""
	@echo "$(BLUE)📊 Disk Usage:$(RESET)"
	@echo "Nix store: $$(du -sh ~/.nix/store 2>/dev/null || echo 'Not found')"
	@echo "Profiles: $$(du -sh ~/.nix/profile 2>/dev/null || echo 'Not found')"
	@echo ""
	@echo "$(BLUE)🔗 Flake Information:$(RESET)"
	@if [ -f flake.nix ]; then \
		echo "✅ Flake found"; \
		nix flake metadata 2>/dev/null || echo "❌ Cannot read flake metadata"; \
	else \
		echo "❌ No flake.nix found"; \
	fi

check: ## Check flake configuration for errors
	@echo "$(YELLOW)🔍 Checking flake configuration...$(RESET)"
	nix flake check --all-systems
	@echo "$(GREEN)✅ Configuration check passed!$(RESET)"

test: ## Run tests for the configuration
	@echo "$(YELLOW)🧪 Running configuration tests...$(RESET)"
	@echo "✅ Testing nix-darwin configuration..."
	@nix eval .#darwinConfigurations.naxn1a-darwin.config.system.build.toplevel
	@echo "✅ Testing home-manager configurations..."
	@nix eval .#homeConfigurations.naxn1a-linux.activationPackage
	@echo "✅ Testing development shells..."
	@nix eval .#devShells.$(SYSTEM).default
	@echo "$(GREEN)✅ All tests passed!$(RESET)"

# Development environment targets
devenv: ## Enter development environment
	@echo "$(YELLOW)🚀 Entering development environment...$(RESET)"
	nix develop --impure

# Code quality targets
format: ## Format Nix code
	@echo "$(YELLOW)🎨 Formatting Nix code...$(RESET)"
	nix fmt
	@echo "$(GREEN)✅ Code formatted!$(RESET)"

lint: ## Lint Nix configuration
	@echo "$(YELLOW)🔍 Linting Nix configuration...$(RESET)"
	@command -v statix >/dev/null 2>&1 || (echo "$(RED)❌ statix not found. Install with: nix profile install nixpkgs#statix$(RESET)" && exit 1)
	statix check
	@echo "$(GREEN)✅ Linting complete!$(RESET)"

lint-fix: ## Auto-fix linting issues
	@echo "$(YELLOW)🔧 Auto-fixing linting issues...$(RESET)"
	statix fix
	@echo "$(GREEN)✅ Issues fixed!$(RESET)"

# Utility targets
info: ## Show system and configuration information
	@echo "$(CYAN)📊 System Information$(RESET)"
	@echo "$(YELLOW)OS:$(RESET) $(UNAME_S)"
	@echo "$(YELLOW)Architecture:$(RESET) $(UNAME_M)"
	@echo "$(YELLOW)Nix System:$(RESET) $(SYSTEM)"
	@echo "$(YELLOW)Configuration:$(RESET) $(CONFIG)"
	@echo "$(YELLOW)Build Command:$(RESET) $(BUILD_CMD)"
	@echo "$(YELLOW)Switch Command:$(RESET) $(SWITCH_CMD)"
	@echo ""
	@echo "$(CYAN)🔧 Nix Version:$(RESET)"
	@nix --version
	@echo ""
	@echo "$(CYAN)🏠 Home Manager Version:$(RESET)"
	@if command -v home-manager >/dev/null 2>&1; then \
		home-manager --version; \
	else \
		echo "❌ Home Manager not found"; \
	fi

version: ## Show version information
	@echo "$(CYAN)📋 Nix Environment Version$(RESET)"
	@git log -1 --format="%H - %s (%cr)" 2>/dev/null || echo "Git information not available"
	@echo "$(YELLOW)Last modified:$(RESET) $$(stat -c %y flake.nix 2>/dev/null || stat -f %Sm flake.nix)"

# Backup and restore
backup: ## Backup current configuration
	@echo "$(YELLOW)💾 Creating backup...$(RESET)"
	@mkdir -p backups
	@tar -czf " backups/backup-$$(date +%Y%m%d-%H%M%S).tar.gz" \
		--exclude='backups' \
		--exclude='result' \
		--exclude='.git' \
		--exclude='*.tar.gz' \
		.
	@echo "$(GREEN)✅ Backup created!$(RESET)"

# Quick commands for common tasks
quick-install: ## Quick installation (minimal checks)
	@echo "$(YELLOW)🚀 Quick install for $(SYSTEM)...$(RESET)"
ifeq ($(UNAME_S),Darwin)
	sudo nix build .#darwinConfigurations.$(CONFIG).system
	sudo ./result/sw/bin/darwin-rebuild switch --flake .#$(CONFIG)
	@echo "$(BLUE)🧹 Cleaning up build artifacts...$(RESET)"
	rm -rf result
else
	@if command -v home-manager >/dev/null 2>&1; then \
		home-manager switch --flake .#$(CONFIG); \
	else \
		echo "$(YELLOW)🔧 home-manager not found in PATH, using nix run...$(RESET)"; \
		nix run nixpkgs#home-manager -- switch --flake .#$(CONFIG); \
	fi
endif
	@echo "$(GREEN)✅ Quick install complete!$(RESET)"

quick-update: ## Quick update (no full rebuild)
	@echo "$(YELLOW)🔄 Quick update...$(RESET)"
	nix flake update
ifeq ($(UNAME_S),Darwin)
	sudo darwin-rebuild switch --flake .
else
	@if command -v home-manager >/dev/null 2>&1; then \
		home-manager switch --flake .; \
	else \
		echo "$(YELLOW)🔧 home-manager not found in PATH, using nix run...$(RESET)"; \
		nix run nixpkgs#home-manager -- switch --flake .; \
	fi
endif
	@echo "$(GREEN)✅ Quick update complete!$(RESET)"

# Welcome message
welcome: ## Show welcome message and next steps
	@echo "$(CYAN)🎉 Welcome to Nix Environment Management!$(RESET)"
	@echo ""
	@echo "$(YELLOW)Detected System: $(SYSTEM) ($(CONFIG))$(RESET)"
	@echo ""
	@echo "$(GREEN)Quick Start:$(RESET)"
	@echo "  make install          # Install complete environment"
	@echo "  make update           # Update and rebuild"
	@echo "  make switch           # Switch to current config"
	@echo "  make doctor           # Check system health"
	@echo "  make devenv           # Enter dev environment"
	@echo ""
	@echo "$(PURPLE)Maintenance:$(RESET)"
	@echo "  make clean            # Clean old generations"
	@echo "  make check            # Validate configuration"
	@echo "  make format           # Format code"
	@echo "  make lint             # Lint configuration"
	@echo ""
	@echo "$(CYAN)Documentation:$(RESET)"
	@echo "  make help             # Show all commands"
	@echo "  make info             # System information"
