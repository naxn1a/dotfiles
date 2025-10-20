# 🚀 Naxn1a Nix Configuration

> Modern Nix configuration optimized for 2025 - supporting macOS and Linux with cutting-edge development tools

[![Nix](https://img.shields.io/badge/Nix-2.18+-blue.svg)](https://nixos.org/)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/NixOS/nix)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Year](https://img.shields.io/badge/Year-2025-ff69b4.svg)](https://github.com/naxn1a/nix-config)

## 📋 Overview

This is a comprehensive Nix configuration that provides a modern, efficient, and secure development environment for **macOS** and **Linux** systems. Built with performance and productivity in mind for 2025 and beyond.

### 🎯 Key Features

- **🍎 macOS & 🐧 Linux Support** - Optimized for both platforms
- **⚡ Performance First** - Binary caches, optimized builds, fast startup
- **🔒 Security Focused** - Built-in security tools and privacy settings
- **🤖 AI-Ready** - Local AI development with Ollama integration
- **🛠️ Modern Tooling** - 2025's best CLI tools and editors
- **📦 Rich Package Ecosystem** - Development, cloud, and AI tools included
- **🎨 Beautiful Shell** - Starship prompt, zsh, and modern aliases
- **🔄 Easy Management** - Makefile-based installation and maintenance

## ✨ What's Included

### 🖥️ Core Development Tools
- **Editors**: Neovim, Helix, VS Code
- **Shells**: Zsh with modern configuration, Nushell
- **Terminal Multiplexer**: Zellij, Tmux
- **Git**: Enhanced configuration with aliases and security

### 🔧 Modern CLI Replacements (2025 Edition)
- `eza` - Modern `ls` with git integration
- `bat` - `cat` with syntax highlighting
- `fd` - User-friendly `find` alternative
- `ripgrep` - Fast `grep` replacement
- `procs` - Modern `ps` alternative
- `dust` - Intuitive `du` replacement
- `sd` - Intuitive `sed` replacement
- `delta` - Beautiful git diff viewer

### 🚀 Productivity Tools
- **Navigation**: `zoxide` (smart cd), `fzf` (fuzzy finder)
- **History**: `atuin` (sync history), `mcfly` (search history)
- **Cheatsheets**: `cheat` for command help
- **File Management**: `yazi` terminal file manager

### 🐍 Programming Languages
- **Rust** - Complete toolchain with rust-analyzer
- **Go** - Full development environment
- **Node.js 22** - Latest LTS with npm/yarn
- **Python 3.12** - With Poetry and uv package managers
- **Deno & Bun** - Modern JavaScript runtimes

### ☁️ Cloud & Container Tools
- **Docker** & **Docker Compose**
- **Kubernetes** - kubectl, helm, k9s, stern
- **Terraform** - Infrastructure as Code
- **AWS CLI 2** - Cloud management
- **Podman** - Container management

### 🤖 AI/ML Development
- **Ollama** - Local AI model management
- **UV** - Fast Python package manager
- **AI Chat CLI** - Terminal-based AI assistants

### 🔒 Security Tools
- **AGE** - Modern encryption
- **SOPS** - Secrets management
- **Pass** - Password manager
- **GPG** - Encryption and signing
- **Keychain** - SSH key management

### 🍎 macOS Specific
- **Nix-Darwin** - System configuration management
- **Homebrew Integration** - GUI apps and additional tools
- **Privacy Settings** - Enhanced security configurations
- **Performance Optimizations** - Disabled animations, memory management

## 🚀 Quick Start

### Prerequisites

- **Nix** with flakes enabled
- **macOS**: 10.15+ (Catalina or later)
- **Linux**: Any modern distribution

### Installation

#### Method 1: Automatic (Recommended)
```bash
# Clone the repository
git clone <this-repo> ~/.local/share/chezmoi
cd ~/.local/share/chezmoi

# Install for your platform
make install
```

#### Method 2: Manual
```bash
# macOS (Nix-Darwin)
darwin-rebuild switch --flake .#your-hostname

# Linux (Home-Manager)
home-manager switch --flake .#your-username
```

#### Method 3: Quick Install (No Backup)
```bash
make quick-install
```

### Post-Installation

1. **Restart your shell** to see all changes
2. **Configure your Git email** in `~/.gitconfig`
3. **Run `make doctor`** to verify setup
4. **Start exploring** with `make help`

## 📚 Usage

### Daily Commands

```bash
# Update all packages
make update

# Apply configuration changes
make switch

# Test configuration syntax
make test

# Clean up old packages
make clean

# System diagnostics
make doctor
```

### Shell Enhancements

```bash
# Modern aliases
ll                    # ls with details
la                    # ls with hidden files
tree                  # Directory tree
grep                  # Uses ripgrep
find                  # Uses fd
cat                   # Uses bat

# Navigation
z <directory>         # Smart directory jump
cdd                   # Fuzzy directory selection

# Git shortcuts
g                     # Git
gs                    # Git status
ga                    # Git add
gc                    # Git commit
gp                    # Git push
gl                    # Git pull
glog                  # Git log with graph
```

### Development Workflows

```bash
# Enter development shell
make dev-shell

# Start terminal multiplexer
zellij

# AI development
ollama pull llama2    # Download AI model
ollama run llama2     # Run AI model

# Container development
docker compose up     # Start containers
kubectl get pods      # Check Kubernetes
```

## 🏗️ Configuration Structure

```
~/.local/share/chezmoi/
├── flake.nix              # Main configuration file
├── Makefile              # Installation and management
└── README.md             # This file
```

### Key Sections in `flake.nix`

1. **Common Packages** - Shared across all platforms
2. **Home Manager Config** - User environment settings
3. **macOS Configuration** - System settings and Homebrew
4. **Linux Configuration** - User environment for Linux
5. **Development Shells** - Platform-specific dev environments

## 🛠️ Customization

### Adding Packages

Edit `flake.nix` in the `commonPackages` section:

```nix
commonPackages = pkgs: with pkgs; [
  # Your new package here
  new-package
  # ... existing packages
];
```

### macOS Customization

Add Homebrew packages in the macOS section:

```nix
homebrew = {
  brews = [ "new-tool" ];
  casks = [ "new-app" ];
};
```

### Linux Customization

Add Linux-specific packages:

```nix
home.packages = with pkgs; [
  linux-specific-package
];
```

## 🔧 Maintenance

### Regular Tasks

```bash
# Weekly update
make update

# Monthly cleanup
make clean-all

# Quarterly backup
make backup
```

### Performance Optimization

```bash
# Optimize Nix store
nix store optimise

# Clean old generations
nix-collect-garbage -d

# Check for issues
make doctor
```

## 🐛 Troubleshooting

### Common Issues

#### "Nix command not found"
```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

#### "darwin-rebuild not found" (macOS)
```bash
# Install nix-darwin
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
```

#### "home-manager not found" (Linux)
```bash
# Install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
nix-channel --update
```

#### Configuration fails to build
```bash
# Test configuration
make test

# Check syntax
nix flake check

# Get detailed errors
nix build .#darwinConfigurations.$(hostname).system --show-trace
```

#### Memory issues on macOS
```bash
# Disable animations (already configured)
# Increase virtual memory
sudo sysctl -w vm.compressor_mode=4

# Check memory usage
btm  # Better than top
```

### Getting Help

```bash
# Show all commands
make help

# System diagnostics
make doctor

# Configuration info
make info
```

### Rollback

If something goes wrong:

```bash
# Rollback to previous generation
make rollback

# Or restore from backup
make restore
```

## 📖 Advanced Usage

### Custom Development Shells

```bash
# Enter specific development shell
nix develop .#aarch64-darwin  # macOS ARM
nix develop .#x86_64-linux    # Linux x64

# Create your own shell
nix shell nixpkgs#your-package
```

### Profile Management

```bash
# List profiles
nix profile list

# Remove old profile
nix profile remove <profile-number>

# Switch to specific generation
home-manager switch --flake .#user --generation <gen-number>
```

### Binary Caches

The configuration includes multiple binary caches for faster downloads:

- `cache.nixos.org` - Official Nix cache
- `nix-community.cachix.org` - Community packages
- `devenv.cachix.org` - Development environments

## 🤝 Contributing

Contributions are welcome! Please:

1. **Fork** the repository
2. **Create a feature branch**
3. **Make your changes**
4. **Test** with `make test`
5. **Submit a pull request**

### Development Guidelines

- Follow Nix best practices
- Test on both macOS and Linux if possible
- Update documentation for new features
- Use semantic versioning for breaking changes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [NixOS/nixpkgs](https://github.com/NixOS/nixpkgs) - Package collection
- [LnL7/nix-darwin](https://github.com/LnL7/nix-darwin) - macOS support
- [nix-community/home-manager](https://github.com/nix-community/home-manager) - User management
- [starship](https://starship.rs/) - Custom prompt
- All the open source tools included in this configuration

## 📞 Support

If you encounter issues:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Run `make doctor` for system diagnostics
3. Check [GitHub Issues](../../issues)
4. Join the Nix community for general Nix help

---

**💡 Tip:** This configuration is designed to be modular. Feel free to remove packages you don't need and add your own favorites!