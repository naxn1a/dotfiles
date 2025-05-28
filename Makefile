# Makefile for cross-platform Nix configuration management
# Usage: make <target>

.PHONY: help install-nix darwin-switch linux-switch update clean check format status

# Default target
help:
	@echo "🚀 Nix Configuration Management"
	@echo ""
	@echo "Available targets:"
	@echo "  help           - Show this help message"
	@echo "  install-nix    - Install Nix package manager"
	@echo "  darwin-switch  - Apply Darwin configuration (macOS)"
	@echo "  linux-switch   - Apply Home Manager configuration (Linux/WSL)"
	@echo "  update         - Update flake lock file"
	@echo "  clean          - Clean old generations"
	@echo "  check          - Check configuration syntax"
	@echo "  format         - Format nix files"
	@echo "  status         - Show system status"
	@echo ""
	@echo "Platform-specific shortcuts:"
	@echo "  mac           - Alias for darwin-switch"
	@echo "  linux         - Alias for linux-switch"

# Install Nix (multi-platform)
install-nix:
	@echo "🔧 Installing Nix package manager..."
	@if command -v nix >/dev/null 2>&1; then \
		echo "✅ Nix is already installed"; \
	else \
		if [[ "$$(uname)" == "Darwin" ]]; then \
			echo "🍎 Installing Nix for macOS..."; \
			sh <(curl -L https://nixos.org/nix/install); \
		else \
			echo "🐧 Installing Nix for Linux..."; \
			sh <(curl -L https://nixos.org/nix/install) --daemon; \
		fi; \
	fi
	@echo "🔄 Reloading shell configuration..."
	@echo "Please run 'source ~/.zshrc' or restart your terminal"

# macOS Darwin configuration
darwin-switch:
	@echo "🍎 Applying Darwin configuration..."
	@if ! command -v darwin-rebuild >/dev/null 2>&1; then \
		echo "📦 Installing nix-darwin..."; \
		nix run nix-darwin -- switch --flake ./nix/flake.nix#naxn1a-darwin; \
	else \
		darwin-rebuild switch --flake ./nix/flake.nix#naxn1a-darwin; \
	fi
	@echo "✅ Darwin configuration applied successfully!"

# Linux/WSL Home Manager configuration  
linux-switch:
	@echo "🐧 Applying Home Manager configuration..."
	@if ! command -v home-manager >/dev/null 2>&1; then \
		echo "📦 Installing Home Manager..."; \
		nix run home-manager -- switch --flake ./nix/flake.nix#naxn1a-linux; \
	else \
		home-manager switch --flake ./nix/flake.nix#naxn1a-linux; \
	fi
	@echo "✅ Home Manager configuration applied successfully!"

# Platform aliases
mac: darwin-switch
linux: linux-switch

# Update flake inputs
update:
	@echo "🔄 Updating flake inputs..."
	nix flake update
	@echo "📝 Updated flake.lock - consider committing changes"

# Clean old generations
clean:
	@echo "🧹 Cleaning old generations..."
	@if [[ "$$(uname)" == "Darwin" ]]; then \
		sudo nix-collect-garbage -d; \
		darwin-rebuild --list-generations | head -n 5; \
	else \
		nix-collect-garbage -d; \
		home-manager generations | head -n 5; \
	fi
	@echo "✅ Cleanup completed!"

# Check configuration
check:
	@echo "🔍 Checking configuration..."
	nix flake check
	@echo "✅ Configuration check passed!"

# Format nix files
format:
	@echo "✨ Formatting nix files..."
	@if command -v nixpkgs-fmt >/dev/null 2>&1; then \
		nixpkgs-fmt ./nix/flake.nix; \
	else \
		echo "Installing nixpkgs-fmt..."; \
		nix shell nixpkgs#nixpkgs-fmt -c nixpkgs-fmt flake.nix; \
	fi
	@echo "✅ Files formatted!"

# Show system status
status:
	@echo "📊 System Status"
	@echo "================"
	@echo "🏗️  Platform: $$(uname -sm)"
	@echo "📦 Nix version: $$(nix --version 2>/dev/null || echo 'Not installed')"
	@echo ""
	@if [[ "$$(uname)" == "Darwin" ]]; then \
		echo "🍎 Darwin Status:"; \
		if command -v darwin-rebuild >/dev/null 2>&1; then \
			echo "   ✅ nix-darwin installed"; \
			echo "   📝 Current generation: $$(darwin-rebuild --list-generations | head -n 1)"; \
		else \
			echo "   ❌ nix-darwin not installed"; \
		fi; \
	fi
	@if command -v home-manager >/dev/null 2>&1; then \
		echo "🏠 Home Manager Status:"; \
		echo "   ✅ home-manager installed"; \
		echo "   📝 Current generation: $$(home-manager generations | head -n 1)"; \
	else \
		echo "🏠 ❌ home-manager not installed"; \
	fi
	@echo ""
	@echo "📁 Configuration files:"
	@ls -la flake.* 2>/dev/null || echo "   No flake files found"

# Quick setup for new machines
setup:
	@echo "🚀 Quick setup for new machine..."
	@echo "Detecting platform..."
	@if [[ "$$(uname)" == "Darwin" ]]; then \
		echo "🍎 macOS detected - running Darwin setup"; \
		make darwin-switch; \
	else \
		echo "🐧 Linux detected - running Home Manager setup"; \
		make linux-switch; \
	fi
	@echo "✅ Setup completed!"

# Development environment
dev:
	@echo "🛠️  Entering development shell..."
	nix develop

# Show flake info
info:
	@echo "📋 Flake Information"
	@echo "==================="
	nix flake show
	
# Rebuild and test
test:
	@echo "🧪 Testing configuration..."
	@if [[ "$$(uname)" == "Darwin" ]]; then \
		darwin-rebuild check --flake ./nix#naxn1a-darwin; \
	else \
		home-manager build --flake .#naxn1a-linux; \
	fi
	@echo "✅ Test passed!"

# Emergency rollback
rollback:
	@echo "⏪ Rolling back to previous generation..."
	@if [[ "$$(uname)" == "Darwin" ]]; then \
		darwin-rebuild --rollback; \
	else \
		home-manager --rollback; \
	fi
	@echo "✅ Rollback completed!"

