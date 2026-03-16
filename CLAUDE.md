# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles managed as a Nix flake. Configures a cross-platform dev environment for macOS (aarch64-darwin via nix-darwin) and Linux (x86_64-linux via home-manager). The chezmoi CLI is used as the dotfiles manager on top.

## Key Commands

```bash
# Apply configuration (auto-detects platform)
make install

# macOS only
sudo darwin-rebuild switch --flake .#naxn1a-darwin

# Linux only
home-manager switch --flake .#naxn1a-linux

# Update all flake inputs and rebuild
make update

# Upgrade Homebrew, mise, and bun packages (macOS)
make upgrade

# Garbage collect and optimize the Nix store
make clean

# Verify Nix + platform tools are present
make check
```

## Architecture

Everything is defined in a single `flake.nix`:

- **`commonPackages`** — Nix packages installed on both platforms (CLI tools, editors, containers, security tools).
- **`commonHomeConfig`** — Shared home-manager module: git settings, fzf, zoxide.
- **`darwinConfigurations."naxn1a-darwin"`** — macOS target (aarch64-darwin). Adds nix-homebrew for casks/brews that have no Nix equivalent. Homebrew `onActivation.cleanup = "zap"` means unlisted casks/brews are removed on rebuild.
- **`homeConfigurations."naxn1a-linux"`** — Linux target (x86_64-linux). Uses home-manager standalone with extra build tools (gcc, openssl, etc.).

The `config/` directory holds dotfiles that chezmoi manages (e.g., `dot_zshrc` → `~/.zshrc`). These are separate from the Nix configuration.

## Platform Notes

- macOS shell is **zsh** (set via nix-darwin); `.zshrc` lives in `config/dot_zshrc`.
- Homebrew is managed declaratively — add casks/brews to `flake.nix`, not manually via `brew install`.
- `flake.lock` should be committed to pin exact package versions for reproducibility.
- The `*.age`, `*.enc`, and `secrets/` paths are gitignored — secrets are managed with age/sops.
