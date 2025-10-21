# Naxn1a's Dotfiles

🚀 **Personal Nix flake for managing cross-platform development environment** on macOS (Darwin) and Linux systems using Nix-Darwin and Home-Manager.

## Overview

This repository contains my complete development environment configuration managed through Nix flakes. It provides a reproducible, declarative setup that works across multiple platforms with consistent tooling and configurations.

## Features

- 🔄 **Cross-platform support**: Works on both macOS (aarch64) and Linux (x86_64)
- 📦 **Comprehensive tooling**: Pre-configured development tools, CLI utilities, and applications
- 🎨 **Consistent shell experience**: Fish, Nushell, and Zsh with unified configurations
- 🛡️ **Security-focused**: Includes security and privacy tools
- 🐳 **Container support**: Docker, Podman, and related utilities
- 🤖 **AI/ML ready**: Ollama and other AI tools pre-configured

## Quick Start

### Prerequisites

- [Nix package manager](https://nixos.org/download.html) with flakes enabled
- Git

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/naxn1a/dotfiles.git ~/.local/share/chezmoi
   cd ~/.local/share/chezmoi
   ```

2. **Install automatically (platform detection):**
   ```bash
   make install
   ```

3. **Or install manually for your platform:**

   **macOS (Darwin):**
   ```bash
   make install-darwin
   ```

   **Linux:**
   ```bash
   make install-linux
   ```

4. **Restart your shell** to see all changes take effect.

## Management Commands

The Makefile provides convenient commands for managing your configuration:

```bash
# Show all available commands
make help

# Install configuration (auto-detects platform)
make install

# Update all packages and rebuild
make update

# Clean Nix store and old artifacts
make clean

# Check system requirements
make check

# Show configuration information
make info
```

## 📦 Included Packages

### Development Tools
- **Version Control**: Git, GitHub CLI (gh), Lazygit
- **Editors**: Neovim, Helix, Zed
- **Terminals**: Ghostty, Tmux, Zellij
- **Shell**: Fish, Nushell, Zsh with Starship prompt

### CLI Utilities
- **Modern Replacements**: `eza` (ls), `bat` (cat), `fd` (find), `ripgrep` (grep), `delta` (diff)
- **System Monitoring**: `btop`, `procs`, `du-dust`
- **Productivity**: `fzf`, `yazi`, `zoxide`, `atuin`, `mcfly`, `cheat`, `direnv`
- **Network**: `curl`, `wget`, `httpie`, `xh`
- **Data**: `jq`, `yq`, `tree`

### Container & Package Management
- **Containers**: Docker, Docker Compose, Podman, Podman Compose
- **Package Managers**: Homebrew (macOS), Mise

### Security & Privacy
- **Security**: Age, Sops, Pass, Exiftool, Keychain
- **Privacy**: Mullvad VPN

### AI & Machine Learning
- **AI Tools**: Ollama, Claude

### Applications (macOS)
- **Essential**: Raycast, Obsidian, Notion
- **Browsers**: Google Chrome, Brave Browser
- **Development**: Docker Desktop, Ngrok
- **Creative**: Krita
- **Entertainment**: Spotify

## Configuration Structure

```
.
├── flake.nix              # Main Nix flake configuration
├── flake.lock             # Lock file for reproducible builds
├── Makefile              # Management commands
└── README.md             # This file
```

### Platform Configurations

#### macOS (Darwin)
- **Target**: `naxn1a-darwin`
- **Architecture**: aarch64-darwin
- **Features**:
  - Nix-Darwin system configuration
  - Homebrew integration with Rosetta support
  - macOS-specific applications via Homebrew casks

#### Linux
- **Target**: `naxn1a-linux`
- **Architecture**: x86_64-linux
- **Features**:
  - Home-Manager user environment
  - Development tools for Linux environments

### Git Configuration

The setup includes a comprehensive Git configuration with:
- Security settings (fsck objects enabled)
- Optimized defaults (rebase pulls, auto setup remote)
- Enhanced diff/merge settings
- Branch and tag sorting preferences

## 🔄 Maintenance

### Updating Packages

```bash
# Update all packages and rebuild
make update

# Or manually:
nix flake update
# Then rebuild for your platform
sudo darwin-rebuild switch --flake .#naxn1a-darwin  # macOS
sudo home-manager switch --flake .#naxn1a-linux     # Linux
```

### Cleaning Up

```bash
# Clean old packages and optimize store
make clean
```

### Troubleshooting

If you encounter issues:

1. **Check system requirements:**
   ```bash
   make check
   ```

2. **Verify Nix installation:**
   ```bash
   nix --version
   ```

3. **Ensure flakes are enabled in your Nix configuration**

## 🤝 Contributing

This is a personal configuration repository, but feel free to:
- Fork and adapt for your own use
- Open issues for bug reports or questions
- Submit pull requests for improvements

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [NixOS/nixpkgs](https://github.com/NixOS/nixpkgs) for the package collection
- [nix-darwin](https://github.com/nix-darwin/nix-darwin) for macOS Nix integration
- [home-manager](https://github.com/nix-community/home-manager) for user environment management
- [nix-homebrew](https://github.com/zhaofengli/nix-homebrew) for Homebrew integration

## 🔗 Links

- [Nix Documentation](https://nixos.org/learn.html)
- [Nix-Darwin](https://github.com/nix-darwin/nix-darwin)
- [Home-Manager](https://github.com/nix-community/home-manager)
- [Flakes](https://nixos.wiki/wiki/Flakes)

---

**Maintainer**: [naxn1a](https://github.com/naxn1a)
**Last Updated**: 2025-10-21