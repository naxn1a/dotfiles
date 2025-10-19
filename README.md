# Nix Environment Management

A comprehensive, cross-platform Nix environment management system with support for both macOS (via Nix Darwin) and Linux (via Home Manager). This project provides a reproducible development environment with modern CLI tools, development utilities, and platform-specific configurations.

## Features

- 🍎 **macOS Support** - Full Nix Darwin integration with Homebrew
- 🐧 **Linux Support** - Home Manager configuration for Linux environments
- 🛠️ **Modern Toolchain** - 2025-era CLI tools and development utilities
- 🔄 **Cross-Platform** - Consistent experience across different systems
- 📦 **Package Management** - Curated selection of essential tools
- 🎨 **Rich CLI** - Beautiful terminal with modern replacements

## Quick Start

### Prerequisites

- [Nix](https://nixos.org/download.html) with experimental features enabled
- Git for version control

### Installation

1. Clone this repository:
```bash
git clone <your-repo-url>
cd <repo-directory>
```

2. Run the quick setup:
```bash
# For macOS
make darwin-setup

# For Linux
make linux-setup

# Or automatic detection
make quick-setup
```

## Usage

### Makefile Commands

The `Makefile` provides a comprehensive set of commands for managing your Nix environment:

#### Setup & Installation
```bash
make help              # Show all available commands
make install           # Install Nix environment (auto-detects system)
make install-darwin    # Install Nix-darwin (macOS only)
make install-home      # Install Home Manager (Linux)
```

#### Updates & Maintenance
```bash
make update            # Update flake and rebuild environment
make rebuild           # Rebuild environment without updating flake
make check             # Validate flake configuration
make test              # Test environment functionality
```

#### Development
```bash
make shell             # Enter development shell
make build             # Build environment
make search            # Search for packages in nixpkgs
```

#### System Management
```bash
make info              # Show system and configuration info
make list-generations  # List Nix generations
make rollback          # Rollback to previous generation
```

#### Cleanup
```bash
make clean             # Clean Nix store
make clean-all         # Deep clean (removes old generations)
```

#### Diagnostics
```bash
make doctor            # Run diagnostic checks
make version           # Show version information
make profile           # Profile environment performance
```

### Manual Nix Commands

If you prefer to use Nix directly:

```bash
# Enter development shell
nix develop

# Build environment
nix build .#packages.default

# Update flake
nix flake update

# Check configuration
nix flake check

# Rebuild configuration
nix run .#apps.update
```

## Environment Structure

### Core Components

#### flake.nix
The main configuration file that defines:
- **Inputs**: Nixpkgs, Nix Darwin, Home Manager, and utilities
- **Packages**: Curated toolsets for different platforms
- **Shells**: Development environments with all tools
- **Configurations**: System-specific setups for macOS and Linux

#### Makefile
Cross-platform automation tool that provides:
- **System Detection**: Automatically identifies macOS/Linux and architecture
- **Installation Scripts**: Platform-appropriate setup commands
- **Maintenance Tasks**: Updates, cleanup, and diagnostics
- **Emergency Tools**: Rollback and recovery options

### Package Categories

#### Core Shells & Terminals
- **Nushell** - Modern shell with structured data
- **Zsh** - Feature-rich shell with extensive customization
- **Starship** - Minimal, fast, and customizable prompt

#### Modern CLI Replacements
- `eza` - Modern `ls` replacement with colors and icons
- `bat` - `cat` replacement with syntax highlighting
- `fd` - Intuitive `find` replacement
- `ripgrep` - Fast `grep` replacement with advanced features
- `du-dust` - Visual `du` replacement
- `procs` - Modern `ps` replacement
- `sd` - Intuitive `sed` replacement
- `choose` - User-friendly `cut` replacement
- `xh` - Modern HTTP client (curl/httpie replacement)

#### Development Tools
- **Git Ecosystem**: Git, GitHub CLI (`gh`), Lazygit, Delta
- **Editors**: Terminal multiplexers (Tmux, Zellij)
- **Fuzzy Finding**: FZF for interactive filtering
- **Environment**: Direnv for per-directory environment variables
- **Runtime Management**: Mise (modern asdf/rtx replacement)
- **Task Runner**: Just for command automation

#### Container & DevOps
- **Podman** - Daemonless container engine
- **Docker Compose** - Multi-container application orchestration
- **Lazydocker** - Terminal UI for Docker management

#### Security & Networking
- **Network Tools**: nmap, Wireshark CLI
- **Monitoring**: bandwhich, gping for network analysis

#### AI/LLM Tools
- **Ollama** - Local LLM management

### Platform-Specific Packages

#### macOS (Nix Darwin)
- **Apple Frameworks**: Security, CoreFoundation, AppKit
- **Homebrew Integration**: Automatic updates and cleanup
- **GUI Applications**: Raycast, Obsidian, Zed, Claude, etc.
- **Development Tools**: Docker Desktop, ngrok
- **Browsers**: Chrome, Brave
- **Security**: Mullvad VPN
- **Terminal**: Ghostty
- **Productivity**: Notion, Spotify

#### Linux (Home Manager)
- **Development Tools**: GCC, make, pkg-config
- **Desktop Integration**: X11 utilities, libnotify
- **System Monitoring**: inotify-tools, lm_sensors, acpi
- **Package Management**: Flatpak support

## Configuration Details

### System Detection

The Makefile automatically detects:
- **Operating System**: macOS (Darwin) or Linux
- **Architecture**: x86_64 or aarch64 (ARM)
- **Configuration Name**: Hostname (macOS) or username@linux (Linux)

### Configuration Names

The system uses these identifiers:
- **macOS**: Based on hostname (e.g., "MacBook-Pro", "Mac-mini")
- **Linux**: Based on username (e.g., "naxn1a@linux")

### Flake Structure

```
.
├── flake.nix          # Main configuration
├── Makefile           # Automation scripts
├── home.nix           # Home Manager configuration (if exists)
└── README.md          # This file
```

## Development Workflow

### Daily Use

1. **Enter Development Shell**:
   ```bash
   make shell
   # or
   nix develop
   ```

2. **Update Environment**:
   ```bash
   make update
   ```

3. **Test Changes**:
   ```bash
   make check
   make test
   ```

### Adding New Packages

1. Edit `flake.nix` and add packages to the appropriate section
2. Update the flake: `make update`
3. Test the configuration: `make test`
4. Rebuild if needed: `make rebuild`

### Platform-Specific Customization

#### macOS
Add packages to the `essentialPackages` or `homebrew.brews`/`homebrew.casks` arrays in `flake.nix`.

#### Linux
Add packages to the Linux-specific section in `homeConfigurations`.

## Troubleshooting

### Common Issues

1. **Nix Not Found**: Install Nix first from https://nixos.org/download.html
2. **Permission Errors**: Ensure proper Nix configuration and user permissions
3. **Flake Check Fails**: Run `make doctor` for diagnostics
4. **Build Failures**: Check system dependencies and disk space

### Emergency Recovery

```bash
# Rollback to previous working configuration
make rollback

# Emergency rebuild
make emergency-rebuild

# Clean up problematic builds
make clean-all
```

### Getting Help

- `make help` - Show all available commands
- `make doctor` - Run system diagnostics
- `make info` - Display system information

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `make check` and `make test`
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Acknowledgments

- [Nix](https://nixos.org/) - The purely functional package manager
- [Nix Darwin](https://github.com/LnL7/nix-darwin) - Nix modules for macOS
- [Home Manager](https://github.com/nix-community/home-manager) - User environment management
- [Flake Utils](https://github.com/numtide/flake-utils) - Utilities for Nix flakes