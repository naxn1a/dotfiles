# Makefile for cross-platform Nix environment management
# Supports both MacOS and Linux

# System detection
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    SYSTEM = darwin
    ARCH = $(shell uname -m)
    NIX_SYSTEM = $(ARCH)-darwin
    CONFIG_NAME = $(shell hostname)
else ifeq ($(UNAME_S),Linux)
    SYSTEM = linux
    ARCH = $(shell uname -m)
    NIX_SYSTEM = $(ARCH)-linux
    CONFIG_NAME = $(shell whoami)@linux
else
    $(error Unsupported system: $(UNAME_S))
endif

# Nix configuration
FLAKE_FILE = flake.nix
FLAKE_DIR = $(shell pwd)
HOME_NIX = $(FLAKE_DIR)/home.nix

# Colors
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[0;34m
PURPLE = \033[0;35m
CYAN = \033[0;36m
NC = \033[0m # No Color

# Default target
.PHONY: help
help: ## Show this help message
	@echo "$(BLUE)Nix Environment Management Makefile$(NC)"
	@echo "$(CYAN)System: $(SYSTEM) ($(NIX_SYSTEM))$(NC)"
	@echo "$(CYAN)Configuration: $(CONFIG_NAME)$(NC)"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Check prerequisites
.PHONY: check-prereqs
check-prereqs: ## Check if Nix is installed
	@command -v nix >/dev/null 2>&1 || { echo "$(RED)Error: Nix is not installed$(NC)"; echo "Please install Nix first: https://nixos.org/download.html"; exit 1; }
	@echo "$(GREEN)✓ Nix is installed$(NC)"

# Installation targets
.PHONY: install
install: check-prereqs ## Install Nix environment
	@echo "$(BLUE)Installing Nix environment for $(SYSTEM)...$(NC)"
	@if [ "$(SYSTEM)" = "darwin" ]; then \
		echo "$(YELLOW)Setting up Nix-darwin for MacOS...$(NC)"; \
		nix --experimental-features "nix-command flakes" run nix-darwin -- switch --flake .#$(CONFIG_NAME); \
	else \
		echo "$(YELLOW)Setting up Home Manager for Linux...$(NC)"; \
		nix --experimental-features "nix-command flakes" run home-manager -- switch --flake .#$(CONFIG_NAME); \
	fi
	@echo "$(GREEN)✓ Installation completed$(NC)"

.PHONY: install-darwin
install-darwin: check-prereqs ## Install Nix-darwin (MacOS only)
	@if [ "$(SYSTEM)" != "darwin" ]; then \
		echo "$(RED)Error: This target is only for MacOS$(NC)"; exit 1; \
	fi
	@echo "$(BLUE)Installing Nix-darwin configuration...$(NC)"
	nix --experimental-features "nix-command flakes" run nix-darwin -- switch --flake .#$(CONFIG_NAME)
	@echo "$(GREEN)✓ Nix-darwin installation completed$(NC)"

.PHONY: install-home
install-home: check-prereqs ## Install Home Manager (Linux)
	@echo "$(BLUE)Installing Home Manager configuration...$(NC)"
	nix --experimental-features "nix-command flakes" run home-manager -- switch --flake .#$(CONFIG_NAME)
	@echo "$(GREEN)✓ Home Manager installation completed$(NC)"

# Update targets
.PHONY: update
update: check-prereqs ## Update flake and rebuild environment
	@echo "$(BLUE)Updating Nix environment...$(NC)"
	nix --experimental-features "nix-command flakes" flake update
	@echo "$(GREEN)✓ Flake updated$(NC)"
	$(MAKE) rebuild

.PHONY: rebuild
rebuild: check-prereqs ## Rebuild environment without updating flake
	@echo "$(BLUE)Rebuilding environment...$(NC)"
	@if [ "$(SYSTEM)" = "darwin" ]; then \
		nix --experimental-features "nix-command flakes" run nix-darwin -- switch --flake .#$(CONFIG_NAME); \
	else \
		nix --experimental-features "nix-command flakes" run home-manager -- switch --flake .#$(CONFIG_NAME); \
	fi
	@echo "$(GREEN)✓ Environment rebuilt$(NC)"

# Development targets
.PHONY: shell
shell: check-prereqs ## Enter development shell
	@echo "$(BLUE)Entering development shell...$(NC)"
	nix --experimental-features "nix-command flakes" develop

.PHONY: build
build: check-prereqs ## Build environment
	@echo "$(BLUE)Building environment...$(NC)"
	nix --experimental-features "nix-command flakes" build .#packages.$(NIX_SYSTEM).default

# Testing and validation
.PHONY: check
check: check-prereqs ## Check flake configuration
	@echo "$(BLUE)Checking flake configuration...$(NC)"
	nix --experimental-features "nix-command flakes" flake check
	@echo "$(GREEN)✓ Configuration is valid$(NC)"

.PHONY: test
test: check ## Test environment
	@echo "$(BLUE)Testing environment...$(NC)"
	nix --experimental-features "nix-command flakes" develop --run "echo 'Environment test successful'"
	@echo "$(GREEN)✓ Environment test passed$(NC)"

# Cleanup targets
.PHONY: clean
clean: ## Clean Nix store and temporary files
	@echo "$(BLUE)Cleaning Nix environment...$(NC)"
	nix --experimental-features "nix-command flakes" store gc
	@echo "$(GREEN)✓ Cleanup completed$(NC)"

.PHONY: clean-all
clean-all: ## Clean everything including old generations
	@echo "$(YELLOW)WARNING: This will remove all old Nix generations$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo ""; \
		nix --experimental-features "nix-command flakes" store gc --delete-older-than 7d; \
		echo "$(GREEN)✓ Deep cleanup completed$(NC)"; \
	else \
		echo ""; \
		echo "$(YELLOW)Cleanup cancelled$(NC)"; \
	fi


# Information targets
.PHONY: info
info: ## Show system and configuration information
	@echo "$(BLUE)System Information:$(NC)"
	@echo "  System: $(SYSTEM)"
	@echo "  Architecture: $(ARCH)"
	@echo "  Nix System: $(NIX_SYSTEM)"
	@echo "  Configuration: $(CONFIG_NAME)"
	@echo "  Flake Directory: $(FLAKE_DIR)"
	@echo ""
	@echo "$(BLUE)Nix Information:$(NC)"
	@nix --version

.PHONY: list-generations
list-generations: ## List Nix generations
	@echo "$(BLUE)Listing Nix generations...$(NC)"
	@if [ "$(SYSTEM)" = "darwin" ]; then \
		nix --experimental-features "nix-command flakes" run nix-darwin -- list-generations || true; \
	else \
		home-manager generations || true; \
	fi

# Quick setup targets
.PHONY: quick-setup
quick-setup: check-prereqs ## Quick setup for new systems
	@echo "$(BLUE)Setting up Nix environment...$(NC)"
	$(MAKE) check
	$(MAKE) install
	$(MAKE) test
	@echo "$(GREEN)✓ Quick setup completed$(NC)"

.PHONY: darwin-setup
darwin-setup: quick-setup ## Complete setup for MacOS
	@echo "$(GREEN)✓ MacOS setup completed$(NC)"

.PHONY: linux-setup
linux-setup: quick-setup ## Complete setup for Linux
	@echo "$(GREEN)✓ Linux setup completed$(NC)"

# Utility targets
.PHONY: doctor
doctor: ## Run diagnostic checks
	@echo "$(BLUE)Running diagnostics...$(NC)"
	$(MAKE) check-prereqs
	$(MAKE) check
	@echo "$(BLUE)Checking disk space...$(NC)"
	@df -h /nix 2>/dev/null || df -h / | grep -E "^(/dev|Filesystem)"
	@echo "$(GREEN)✓ Diagnostics completed$(NC)"

.PHONY: version
version: ## Show version information
	@echo "$(BLUE)Nix Environment Version:$(NC)"
	@echo "Nix: $$(nix --version | head -n1)"
	@echo "System: $(NIX_SYSTEM)"
	@echo "Configuration: $(CONFIG_NAME)"
	@if [ -d .git ]; then \
		echo "Git: $$(git describe --tags --always --dirty 2>/dev/null || echo 'unknown')"; \
	fi

# Advanced targets
.PHONY: profile
profile: ## Profile Nix environment performance
	@echo "$(BLUE)Profiling Nix environment...$(NC)"
	@time nix --experimental-features "nix-command flakes" develop --run "echo 'Profile completed'"

.PHONY: search
search: check-prereqs ## Search for packages in nixpkgs
	@read -p "Enter package name to search: " pkg; \
	echo "$(BLUE)Searching for '$$pkg'...$(NC)"; \
	nix --experimental-features "nix-command flakes" search nixpkgs "$$pkg"

# Emergency targets
.PHONY: emergency-rebuild
emergency-rebuild: ## Emergency rebuild with force flag
	@echo "$(YELLOW)WARNING: Emergency rebuild - may overwrite existing configuration$(NC)"
	@read -p "Continue? [y/N] " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo ""; \
		$(MAKE) rebuild; \
	else \
		echo ""; \
		echo "$(YELLOW)Emergency rebuild cancelled$(NC)"; \
	fi

.PHONY: rollback
rollback: ## Rollback to previous generation
	@echo "$(BLUE)Rolling back to previous generation...$(NC)"
	@if [ "$(SYSTEM)" = "darwin" ]; then \
		nix --experimental-features "nix-command flakes" run nix-darwin -- switch --rollback; \
	else \
		home-manager switch --rollback; \
	fi
	@echo "$(GREEN)✓ Rollback completed$(NC)"