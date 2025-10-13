# Naxn1a Nix Environment

A comprehensive Nix flake for managing development environments across multiple platforms (macOS, Linux, and Windows WSL2). This configuration provides a consistent, reproducible development setup with modern tools and utilities.

## 🚀 Quick Start

### Prerequisites

- **Git**: For cloning this repository
- **Nix**: Will be installed automatically if not present
- **Sudo access**: Required for system-level changes on macOS

### Installation

1. **Clone this repository**:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Install the environment**:
   ```bash
   make install
   ```

   This command will:
   - Auto-detect your system (macOS/Linux/WSL2)
   - Install Nix if not already present
   - Update flake inputs
   - Apply the appropriate configuration
   - Set up your development environment

3. **Restart your shell** to load all changes:
   ```bash
   source ~/.zshrc
   # or simply restart your terminal
   ```

## 📋 Supported Systems

| System | Architecture | Configuration | Command |
|--------|--------------|---------------|---------|
| macOS (Apple Silicon) | aarch64 | `naxn1a-darwin` | `make install` |
| macOS (Intel) | x86_64 | `naxn1a-darwin-intel` | `make install` |
| Linux | x86_64 | `naxn1a-linux` | `make install` |
| Linux (ARM64) | aarch64 | `naxn1a-linux-arm` | `make install` |
| Windows (WSL2) | x86_64 | `naxn1a-wsl` | `make install` |

## 🛠️ Available Commands

### Core Commands

```bash
make help          # Show all available commands
make install       # Install complete environment (recommended)
make quick-install # Quick installation (minimal checks)
make update        # Update flake inputs and rebuild
make switch        # Switch to current configuration (no update)
make quick-update  # Quick update (no full rebuild)
```

### Development

```bash
make devenv        # Enter development environment
make build         # Build configuration without switching
make check         # Validate configuration
make test          # Run configuration tests
```

### Maintenance

```bash
make doctor        # Check system health and configuration
make clean         # Clean Nix store (keep last 30 days)
make clean-all     # Aggressive cleanup (removes old generations)
make format        # Format Nix code
make lint          # Lint Nix configuration
make lint-fix      # Auto-fix linting issues
```

### Information

```bash
make info          # Show system and configuration information
make version       # Show version information
make welcome       # Show welcome message and next steps
```

### Utilities

```bash
make backup        # Backup current configuration
```

## 📦 What's Included

### Core Development Tools
- **Shells**: Nushell, Zsh, Bash with Starship prompt
- **Editors**: Neovim with default configuration
- **Version Control**: Git, GitHub CLI, LazyGit, Delta for diff viewing
- **Terminal Multiplexers**: Tmux, Zellij

### Modern CLI Utilities
- **File Operations**: `eza` (ls replacement), `bat` (cat replacement), `fd` (find replacement)
- **Search**: `ripgrep` (grep replacement), `fzf` (fuzzy finder)
- **System Monitoring**: `btop`, `htop`, `bandwhich`
- **Network Tools**: `curl`, `wget`, `httpie`, `xh`

### Development Languages
- **Rust**: rustc, cargo, cargo-watch, cargo-audit, clippy
- **Node.js**: Latest stable version
- **Python**: Latest stable version
- **Go**: Latest stable version

### Container Tools
- **Podman**: Container management
- **Podman Compose**: Multi-container applications
- **Docker Compose**: Docker compose support
- **LazyDocker**: Docker TUI

### Package Management
- **Mise**: Modern runtime manager (replaces asdf/rtx)
- **Direnv**: Environment management per directory
- **Nix Homebrew Integration** (macOS only)

### Platform-Specific Tools

#### macOS
- **Homebrew**: Integrated with Nix for packages not available in nixpkgs
- **Applications**: Docker Desktop, Raycast, Obsidian, Zed, Claude, Ghostty, etc.
- **macOS Utilities**: m-cli for system management

#### Linux/WSL2
- **Development Tools**: GCC, make, pkg-config
- **System Integration**: X11/Wayland support, clipboard utilities
- **Package Managers**: Flatpak, Snap support

## 🏠 Home Manager Configuration

This flake includes comprehensive Home Manager configurations for:

### Shell Environment
- **Zsh**: Enhanced with completions, syntax highlighting, and autosuggestions
- **Starship**: Custom prompt with git integration
- **Direnv**: Automatic environment loading
- **Mise**: Runtime version management

### Git Configuration
- User: "Naxn1a" (email should be configured)
- Default branch: main
- Rebase by default
- Advanced diff and merge tools

### Terminal Tools
- **Bat**: Syntax highlighting with themes
- **eza**: Modern ls with icons and git integration
- **fzf**: Fuzzy finding with file previews
- **ripgrep**: Fast text search

## 🔧 Manual Installation (Alternative)

If you prefer to install without using the Makefile:

### 1. Install Nix (if not already installed)

**macOS**:
```bash
brew install nix
```

**Linux**:
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. Enable Flakes

Add to your `/etc/nix/nix.conf` (or create it):
```
experimental-features = nix-command flakes
```

### 3. Apply Configuration

**macOS**:
```bash
# For Apple Silicon
sudo nix build .#darwinConfigurations.naxn1a-darwin.system
sudo ./result/sw/bin/darwin-rebuild switch --flake .#naxn1a-darwin

# For Intel Macs
sudo nix build .#darwinConfigurations.naxn1a-darwin-intel.system
sudo ./result/sw/bin/darwin-rebuild switch --flake .#naxn1a-darwin-intel

# Cleanup
rm -rf result
```

**Linux**:
```bash
# Standard Linux
home-manager switch --flake .#naxn1a-linux

# WSL2
home-manager switch --flake .#naxn1a-wsl

# ARM64 Linux
home-manager switch --flake .#naxn1a-linux-arm
```

## 🔍 Troubleshooting

### Common Issues

1. **Permission Denied (macOS)**
   - Ensure you have sudo access
   - Try `sudo darwin-rebuild switch --flake .` instead

2. **Nix Command Not Found**
   - Restart your shell or run `source ~/.nix-profile/etc/profile.d/nix.sh`

3. **Flake Check Fails**
   - Run `make doctor` to check system health
   - Ensure all inputs are accessible: `nix flake update`

4. **Home Manager Not Found**
   - Install it: `nix profile install nixpkgs#home-manager`

5. **Build Fails**
   - Check disk space: `df -h`
   - Clean old generations: `make clean`
   - Check flake configuration: `make check`

### Getting Help

- Run `make doctor` for system health check
- Check the flake metadata: `nix flake metadata`
- Validate configuration: `make check`
- View all commands: `make help`

## 🔄 Updates

### Regular Updates
```bash
make update    # Updates flake inputs and rebuilds
```

### Quick Updates
```bash
make quick-update  # Updates without full rebuild
```

### Manual Updates
```bash
nix flake update  # Update inputs only
make switch       # Apply current configuration
```

## 🗂️ Project Structure

```
.
├── flake.nix          # Main configuration file
├── Makefile           # Cross-platform build automation
├── README.md          # This file
└── backups/           # Configuration backups (created by make backup)
```

## 🎯 Development Environments

This flake provides specialized development shells:

### Default Environment
```bash
nix develop          # Includes Rust, Node.js, Python, Go
```

### Rust Environment
```bash
nix develop .#rust   # Rust-specific tools and toolchain
```

### Web Development
```bash
nix develop .#web    # Node.js and TypeScript tools
```

## 📝 Customization

### Adding Packages
Edit `flake.nix` and add packages to the appropriate section:
- `commonPackages`: For all platforms
- `darwinPackages`: macOS only
- `linuxPackages`: Linux only

### Modifying Configuration
- **Git settings**: Modify `programs.git` in `commonHomeConfig`
- **Shell configuration**: Edit `programs.zsh` sections
- **Homebrew (macOS)**: Modify `homebrew.brews` and `homebrew.casks`

### Adding New Systems
1. Add system to `forAllSystems` in `flake.nix`
2. Create new configuration in the appropriate section
3. Update Makefile system detection if needed

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch
3. Test your changes: `make check && make test`
4. Format your code: `make format`
5. Submit a pull request

## 📄 License

This configuration is provided as-is for personal use. Feel free to modify and adapt it to your needs.

## 🔗 Useful Resources

- [Nix Manual](https://nixos.org/manual/nix/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer)