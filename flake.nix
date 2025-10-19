{
  description = "Development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowBroken = true;
          };
        };

        # Essential packages that work on both platforms
        essentialPackages = with pkgs; [
          # Core shells and terminals
          nushell
          zsh
          bash
          starship

          # Version control & Git ecosystem
          git
          gh
          lazygit
          delta

          # Editors & Terminal multiplexers
          tmux
          zellij

          # Modern CLI utilities
          curl
          wget
          jq
          yq
          tree
          htop
          btop
          httpie
          bandwhich
          gping

          # Modern CLI replacements (2025 standards)
          eza        # ls replacement
          bat        # cat replacement with themes
          fd         # find replacement
          ripgrep    # grep replacement with advanced features
          du-dust    # du replacement
          procs      # ps replacement
          sd         # sed replacement
          choose     # cut replacement
          xh         # httpie replacement (rust-based)

          # File managers and viewers
          yazi
          joshuto
          glow

          # Development tools
          fzf
          direnv
          mise       # Modern runtime manager (replaces asdf/rtx)
          just       # Modern command runner

          # Programming languages (latest versions)
          rustc
          cargo
          cargo-watch
          cargo-audit
          clippy

          # Container and orchestration
          podman
          podman-compose
          docker-compose
          lazydocker
          # kubectl
          # helm

          # Security and networking
          nmap
          wireshark-cli
          # openssl

          # Database tools
          # sqlite
          # postgresql
          # redis

          # Cloud tools
          # awscli2
          # terraform
          # ansible

          # AI/LLM tools (2025)
          ollama
        ];

        # Platform-specific packages
        platformPackages =
          if pkgs.stdenv.isDarwin then [
            # MacOS-specific packages
            pkgs.darwin.apple_sdk.frameworks.Security
            pkgs.darwin.apple_sdk.frameworks.CoreFoundation
            pkgs.darwin.apple_sdk.frameworks.AppKit
          ] else if pkgs.stdenv.isLinux then [
            # Linux-specific packages
            pkgs.util-linux
            pkgs.systemd
            pkgs.udev
            pkgs.alacritty
            pkgs.firefox
          ] else [];

        allPackages = essentialPackages ++ platformPackages;

      in
      {
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = allPackages;
          shellHook = ''
            echo "Welcome to Nix development environment!"
            echo "System: ${system}"
            echo "Available packages: ${builtins.toString (builtins.length allPackages)}"
          '';
        };

        # Packages
        packages = {
          default = pkgs.buildEnv {
            name = "nix-dev-env";
            paths = allPackages;
          };
        };

        # Apps
        apps = {
          update = {
            type = "app";
            program = toString (pkgs.writeShellScript "update" ''
              echo "Updating Nix environment..."
              nix flake update
              nix flake check
              echo "Update completed!"
            '');
          };
        };
      }) // {

    # Nix Darwin configuration for MacOS
    darwinConfigurations =
      let
        # Darwin configuration function
        mkDarwinConfig = { hostname, system ? "aarch64-darwin" }:
          nix-darwin.lib.darwinSystem {
            inherit system;
            modules = [
              {
                nix.settings.experimental-features = "nix-command flakes";

                # Homebrew integration
                environment.shells = [ pkgs.zsh ];
                environment.systemPackages = with pkgs; [
                  # Homebrew-related packages
                  brew
                  nix-darwin
                ];

                # Enable Homebrew
                homebrew = {
                  enable = true;
                  onActivation = {
                    autoUpdate = true;
                    cleanup = "uninstall";
                    flags = [ "--debug" "--verbose" ];
                  };

                  # Essential Homebrew packages
                  brews = [
                    # Development tools not available in nixpkgs or better versions
                    # "lazygit"
                    # "lazydocker"
                    "chezmoi"
                    # "mise"
                    "gemini-cli"
                    # "warp"
                    # "arc"
                    # "cursor"
                    # "postgres"  # For local development
                    # "redis"     # For local development
                    "exiftool"
                  ];

                  # Homebrew casks
                  casks = [
                    # Essential applications
                    "docker-desktop"
                    "raycast"
                    # "discord"
                    "obsidian"
                    "zed"
                    "claude"

                    # Development tools
                    # "dotnet-sdk"
                    # "postgres"
                    # "tableplus"
                    # "insomnia"
                    # "postman"
                    "ngrok"

                    # Browsers
                    "google-chrome"
                    "brave-browser"
                    # "firefox"
                    # "arc"

                    # Productivity
                    "notion"
                    # "slack"
                    # "linear-linear"
                    # "craft"

                    # Security & Privacy
                    "mullvad-vpn"
                    # "1password"
                    # "little-snitch"

                    # Terminal & Utilities
                    "ghostty"
                    # "kitty"
                    # "wezterm"
                    # "alacritty"
                    # "utm"

                    # Design & Media
                    # "figma"
                    # "pixelmator-pro"
                    # "handmirror"
                    # "cleanshot"

                    # Entertainment
                    "spotify"
                    # "vlc"
                  ];
                };

                # User configuration
                users.users."${hostname}" = {
                  name = hostname;
                  home = "/Users/${hostname}";
                  shell = pkgs.zsh;
                };
              }

              # Home Manager module
              home-manager.darwinModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users."${hostname}" = {
                  imports = [ ./home.nix ];
                };
              }
            ];
          };
      in
      {
        # Example configuration for different Mac systems
        "MacBook-Pro" = mkDarwinConfig { hostname = "naxn1a"; system = "aarch64-darwin"; };
        "Mac-mini" = mkDarwinConfig { hostname = "naxn1a"; system = "x86_64-darwin"; };
      };

    # Home Manager configurations for Linux
    homeConfigurations =
      let
        mkHomeConfig = { username, system ? "x86_64-linux" }:
          home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages."${system}";
            modules = [
              {
                home = {
                  username = username;
                  homeDirectory = "/home/${username}";

                  packages = with pkgs; [
                    # Linux development tools
                    gcc
                    gnumake
                    pkg-config
                    openssl
                    libiconv

                    # Desktop environment tools
                    xclip
                    xsel
                    libnotify

                    # Additional Linux utilities
                    inotify-tools
                    usbutils
                    pciutils
                    lm_sensors
                    acpi

                    # Package managers
                    flatpak
                    # snapd - not available in nixpkgs (system package manager)

                    # Network tools
                    # networkmanager - not available in nixpkgs (system service)
                    # iw - not available in nixpkgs (system tool)
                    # wireless-tools - not available in nixpkgs (system tool)
                  ];

                  # Shell configuration
                  programs = {
                    zsh = {
                        enable = true;
                      };
                    };

                    git = {
                      enable = true;
                      userName = "Naxn1a";
                      userEmail = "";
                    };

                    vim = {
                      enable = true;
                      plugins = with pkgs.vimPlugins; [
                        vim-nix
                        vim-airline
                        vim-airline-themes
                      ];
                    };

                    neovim = {
                      enable = true;
                      vimAlias = true;
                    };
                  };
                };

                # Services
                services = {
                  # Enable user services here
                };
              }
            ];
          };
      in
      {
        "naxn1a@linux" = mkHomeConfig { username = "naxn1a"; system = "x86_64-linux"; };
        "naxn1a@linux-arm" = mkHomeConfig { username = "naxn1a"; system = "aarch64-linux"; };
      };

    # Overlays
    overlays = {
      default = final: prev: {
        # Custom overlays can be added here
      };
    };
  };
}
