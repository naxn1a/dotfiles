{
  description = "Naxn1a Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    # nix-darwin for macOS system management
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager for user environment
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-homebrew for better Homebrew integration
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "darwin";
    };

    # Additional useful inputs
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv = {
      url = "github:cachix/devenv/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, darwin, home-manager, nix-homebrew, nix-index-database, devenv, nixvim }:
  let
    # Helper function to generate packages for different systems
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-darwin" "x86_64-darwin"
      "aarch64-linux" "x86_64-linux"
    ];

    # Common packages for all platforms - Enhanced for Expert Engineers
    commonPackages = pkgs: with pkgs; [
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
      openssl

      # Database tools
      sqlite
      # postgresql
      # redis

      # Cloud tools
      # awscli2
      # terraform
      # ansible

      # AI/LLM tools (2025)
      ollama

      # System monitoring (cross-platform)
      btop
    ];

    # Platform-specific packages
    darwinPackages = pkgs: with pkgs; [
      # macOS-specific tools
      m-cli
      reattach-to-user-namespace
    ];

    linuxPackages = pkgs: with pkgs; [
      # Linux-specific development tools
      gcc
      gnumake
      pkg-config
      libiconv
      systemd

      # Package managers
      apt
      snapd

      # Desktop integration
      xdg-utils

      # Additional Linux development tools
      valgrind
      gdb
      strace
      ltrace

      # Linux-specific monitoring
      iotop
    ];

    windowsPackages = pkgs: with pkgs; [
      # Windows-specific tools
      wslu
      powershell

      # Windows development
      mingw-w64
      msvc
    ];

    # Enhanced home-manager configuration for Expert Engineers
    commonHomeConfig = { pkgs, config, ... }: let
      system = pkgs.system;
      isLinux = nixpkgs.lib.hasSuffix "linux" system;
      isDarwin = nixpkgs.lib.hasSuffix "darwin" system;
    in {
      home.packages = commonPackages pkgs
        ++ (if isDarwin then darwinPackages pkgs else [])
        ++ (if isLinux then linuxPackages pkgs else [])
        ++ (if nixpkgs.lib.hasSuffix "windows" system then windowsPackages pkgs else []);

      # Git configuration with advanced features
      programs.git = {
        enable = true;
        userName = "Naxn1a";
        userEmail = "";
        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
          merge.conflictstyle = "diff3";
          diff.tool = "vimdiff";
          core.editor = "nvim";
          branch.sort = "-committerdate";
          tag.sort = "-version:refname";
          rerere.enabled = true;
          rerere.autoUpdate = true;
        };
        lfs.enable = true;
      };

      # Enhanced shell configuration (Linux only)
      programs.zsh = nixpkgs.lib.mkIf isLinux {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        history = {
          size = 10000;
          save = 10000;
          ignoreDups = true;
          ignoreSpace = true;
        };
        initExtra = ''
          # Linux/WSL specific settings
          if grep -qi microsoft /proc/version; then
            export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0.0
            export LIBGL_ALWAYS_INDIRECT=1
            export PATH="/mnt/c/Windows/System32:$PATH"
          fi
          export PATH="$HOME/.local/bin:$PATH"

          # Common configuration
          export EDITOR="nvim"
          export VISUAL="nvim"
          export BROWSER="open"
          export TERM_PROGRAM="wezterm"

          # Enhanced prompt
          eval "$(starship init zsh)"

          # Direnv integration
          eval "$(direnv hook zsh)"

          # Mise integration
          eval "$(mise activate zsh)"

          # Disable Nix command not found handler
          unset command_not_found_handler
        '';
      };

      # Enhanced terminal tools (Linux only)
      programs.bat = nixpkgs.lib.mkIf isLinux {
        enable = true;
        config = {
          theme = "GitHub";
          style = "numbers,changes,header";
          pager = "less -FR";
        };
      };

      programs.eza = nixpkgs.lib.mkIf isLinux {
        enable = true;
        enableZshIntegration = true;
        git = true;
        icons = "auto";
      };

      programs.fzf = nixpkgs.lib.mkIf isLinux {
        enable = true;
        enableZshIntegration = true;
        defaultCommand = "rg --files --hidden --follow --glob '!.git'";
        defaultOptions = [
          "--height 40%"
          "--border"
          "--exact"
          "--cycle"
          "--preview 'bat --style=numbers --color=always {}'"
        ];
      };

      programs.direnv = nixpkgs.lib.mkIf isLinux {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };

      # Nix index for package discovery (Linux only, no comma command)
      programs.nix-index = nixpkgs.lib.mkIf isLinux {
        enable = true;
        enableBashIntegration = false;
        enableZshIntegration = false;
      };

      # Modern development environments (Linux only)
      programs.mise = nixpkgs.lib.mkIf isLinux {
        enable = true;
        enableZshIntegration = true;
        globalConfig = {
          tools = {
            node = "latest";
            uv = "latest";
            python = "latest";
            go = "latest";
            rust = "latest";
            java = "latest";
            dotnet = "latest";
          };
        };
      };

      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };

      home.stateVersion = "24.05";
    };

  in {
    # Enhanced multi-platform configurations
    darwinConfigurations = {
      "naxn1a-darwin" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          # nix-homebrew integration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "naxn1a";
              autoMigrate = true;
            };
          }

          # Enhanced Homebrew packages configuration for 2025
          {
            homebrew = {
              enable = true;
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
                # "spotify"
                # "vlc"
              ];
              onActivation = {
                cleanup = "zap";
                autoUpdate = true;
                upgrade = true;
              };
              global.autoUpdate = true;
            };
          }

          # Enhanced system configuration
          {
            system.primaryUser = "naxn1a";
            ids.gids.nixbld = 350;

            # Modern Nix configuration
            nix = {
              settings = {
                experimental-features = [ "nix-command" "flakes" ];
                trusted-users = [ "root" "naxn1a" ];
                substituters = [
                  "https://cache.nixos.org"
                  "https://nix-community.cachix.org"
                  "https://devenv.cachix.org"
                ];
                trusted-public-keys = [
                  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                  "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CXHQrkxhL4I6EmxC="
                  "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuib0v4DEWCo3gfs7V9DstEBqfE="
                ];
              };
              optimise = {
                automatic = true;
                interval = { Weekday = 0; Hour = 3; Minute = 0; };
              };
              gc = {
                automatic = true;
                interval = { Weekday = 0; Hour = 3; Minute = 0; };
                options = "--delete-older-than 30d";
              };
            };

            # System packages
            environment.systemPackages = commonPackages nixpkgs.legacyPackages.aarch64-darwin;

            # Enhanced macOS system preferences for 2025
            # system = {
            #   defaults = {
            #     dock = {
            #       autohide = true;
            #       show-recents = false;
            #       launchanim = false;
            #       orientation = "bottom";
            #       tilesize = 48;
            #       mru-spaces = false;
            #     };

            #     finder = {
            #       AppleShowAllExtensions = true;
            #       ShowPathbar = true;
            #       ShowStatusBar = true;
            #       FXEnableExtensionChangeWarning = false;
            #       FXPreferredViewStyle = "clmv";
            #     };

            #     trackpad = {
            #       Clicking = true;
            #       TrackpadThreeFingerDrag = true;
            #       ActuationStrength = 0;
            #     };

            #     NSGlobalDomain = {
            #       AppleShowAllExtensions = true;
            #       InitialKeyRepeat = 14;
            #       KeyRepeat = 1;
            #       ApplePressAndHoldEnabled = false;
            #       "com.apple.mouse.tapBehavior" = 1;
            #       "com.apple.swipescrolldirection" = true;
            #     };

            #     # Enhanced security and privacy
            #     universalaccess = {
            #       reduceMotion = true;
            #       reduceTransparency = true;
            #     };
            #   };

            #   keyboard = {
            #     enableKeyMapping = true;
            #     remapCapsLockToEscape = true;
            #   };
            # };

            # Enhanced shell configuration
            programs.zsh.enable = true;
            programs.fish.enable = true;
            environment.shells = with nixpkgs.legacyPackages.aarch64-darwin; [ zsh fish ];

            users.users.naxn1a = {
              name = "naxn1a";
              home = "/Users/naxn1a";
              shell = nixpkgs.legacyPackages.aarch64-darwin.zsh;
            };

            system.stateVersion = 5;
          }
          
          # Home Manager
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              users.naxn1a = commonHomeConfig;
            };
          }
        ];
      };

      # Intel Mac support
      "naxn1a-darwin-intel" = darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        modules = [
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = "naxn1a";
              autoMigrate = true;
            };
          }

          # Homebrew config for Intel Macs
          {
            homebrew = {
              enable = true;
              brews = [ "lazygit" "mise" "chezmoi" ];
              casks = [ "docker-desktop" "raycast" "zed" "claude" ];
              onActivation = {
                cleanup = "zap";
                autoUpdate = true;
                upgrade = true;
              };
            };
          }

          # System config for Intel Macs
          {
            system.primaryUser = "naxn1a";
            nix.settings = {
              experimental-features = [ "nix-command" "flakes" ];
              trusted-users = [ "root" "naxn1a" ];
            };
            environment.systemPackages = commonPackages nixpkgs.legacyPackages.x86_64-darwin;
            programs.zsh.enable = true;
            environment.shells = [ nixpkgs.legacyPackages.x86_64-darwin.zsh ];
            users.users.naxn1a = {
              name = "naxn1a";
              home = "/Users/naxn1a";
              shell = nixpkgs.legacyPackages.x86_64-darwin.zsh;
            };
            system.stateVersion = 5;
          }

          # Home Manager for Intel Macs
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.naxn1a = commonHomeConfig;
            };
          }
        ];
      };
    };

    # Enhanced Linux/WSL/Windows home-manager configurations
    homeConfigurations = {
      # x86_64 Linux (Standard Linux/WSL2)
      "naxn1a-linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          commonHomeConfig
          {
            home = {
              username = "naxn1a";
              homeDirectory = "/home/naxn1a";
            };

            # Additional Linux-specific packages
            home.packages = with nixpkgs.legacyPackages.x86_64-linux; [
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
              snapd

              # Network tools
              networkmanager
              iw
              wireless-tools
            ];

            # Enhanced Linux shell configuration
            programs.zsh.initExtra = ''
              # Linux/WSL2 specific configuration
              export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
              export XDG_DATA_DIRS="$HOME/.local/share:$XDG_DATA_DIRS"

              # WSL2 specific settings
              if grep -qi microsoft /proc/version 2>/dev/null; then
                export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit}' || echo "127.0.0.1"):0.0
                export LIBGL_ALWAYS_INDIRECT=1
                export PULSE_SERVER=tcp:$(grep nameserver /etc/resolv.conf | awk '{print $2}'):0
                export WAYLAND_DISPLAY=""
                export GDK_SCALE=1
                export GDK_DPI_SCALE=1
                echo "🪟 WSL2 environment detected - GUI forwarding configured"
              fi

              # Check for display server
              if [ -n "$WAYLAND_DISPLAY" ]; then
                echo "🖥️ Wayland detected"
              elif [ -n "$DISPLAY" ]; then
                echo "🖥️ X11 detected"
              fi
            '';
          }
        ];
      };

      # ARM64 Linux (Raspberry Pi, ARM servers, Mac M1 Linux VMs)
      "naxn1a-linux-arm" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        modules = [
          commonHomeConfig
          {
            home = {
              username = "naxn1a";
              homeDirectory = "/home/naxn1a";
            };

            # ARM64 Linux specific packages
            home.packages = with nixpkgs.legacyPackages.aarch64-linux; [
              gcc
              gnumake
              pkg-config
              openssl
              libiconv

              # ARM64 specific tools
              raspberrypi-tools
              vcgencmd

              # System monitoring for ARM
              arm-trusted-firmware
              ubootTools
            ];
          }
        ];
      };

      # Windows (WSL2) - Specific configuration for Windows subsystem
      "naxn1a-wsl" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          commonHomeConfig
          {
            home = {
              username = "naxn1a";
              homeDirectory = "/home/naxn1a";
            };

            # Windows/WSL2 specific packages
            home.packages = with nixpkgs.legacyPackages.x86_64-linux; [
              # Windows interoperability tools
              wslu
              wsl-open

              # Development tools for Windows
              mingw-w64
              msvc

              # Windows-specific tools
              powershell
              coreutils
              findutils

              # Additional tools for WSL development
              gcc
              gnumake
              pkg-config
              openssl
            ];

            # Windows/WSL2 specific shell configuration
            programs.zsh.initExtra = ''
              # WSL2 specific configuration
              export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' || echo "127.0.0.1"):0.0
              export LIBGL_ALWAYS_INDIRECT=1
              export PULSE_SERVER=tcp:$(grep nameserver /etc/resolv.conf | awk '{print $2}'):0
              export WAYLAND_DISPLAY=""
              export PATH="/mnt/c/Windows/System32:$PATH"
              export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

              # Windows drive mounting
              alias cdwin="cd /mnt/c"
              alias cdusers="cd /mnt/c/Users"

              # Windows integration aliases
              alias open="wsl-open"
              alias explorer="explorer.exe"
              alias cmd="cmd.exe"
              alias powershell="powershell.exe"

              echo "🪟 WSL2 environment ready - Windows integration enabled"
            '';
          }
        ];
      };
    };

    # Enhanced development shells with devenv integration
    devShells = forAllSystems (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              packages = commonPackages pkgs;

              # Enhanced development environment
              languages = {
                rust = {
                  enable = true;
                  channel = "stable";
                };

                javascript = {
                  enable = true;
                  package = pkgs.nodejs_20;
                };

                python = {
                  enable = true;
                  package = pkgs.python311;
                };

                go = {
                  enable = true;
                  package = pkgs.go;
                };
              };

              # Pre-commit hooks
              pre-commit.hooks = {
                shellcheck.enable = true;
                yamllint.enable = true;
                markdownlint.enable = true;
                rustfmt.enable = true;
                clippy.enable = true;
              };

              # Services for local development
              services.postgres.enable = true;
              services.redis.enable = true;

              # Environment variables
              env = {
                RUST_LOG = "debug";
                NODE_ENV = "development";
              };

              enterShell = ''
                echo "🚀 Expert Development Environment Ready!"
                echo "Platform: ${system}"
                echo "Features: Rust, Node.js, Python, Go, PostgreSQL, Redis"
                echo "Run 'devenv up' to start services"
              '';
            }
          ];
        };

        # Rust-specific development shell
        rust = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              packages = with pkgs; [ rustc cargo cargo-watch cargo-audit clippy rust-analyzer ];

              languages.rust = {
                enable = true;
                channel = "stable";
                components = [ "rustc" "cargo" "rustfmt" "clippy" "rust-src" ];
              };

              enterShell = ''
                echo "🦀 Rust Development Environment Ready!"
                echo "Platform: ${system}"
              '';
            }
          ];
        };

        # Web development shell
        web = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              packages = with pkgs; [ nodejs_20 yarn nodePackages.typescript-language-server ];

              languages.javascript = {
                enable = true;
                package = pkgs.nodejs_20;
              };

              languages.typescript = {
                enable = true;
              };

              enterShell = ''
                echo "🌐 Web Development Environment Ready!"
                echo "Platform: ${system}"
                echo "Node.js: $(node --version)"
              '';
            }
          ];
        };
      });

    # Utility packages for all systems
    packages = forAllSystems (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        # Utility scripts
        install-script = pkgs.writeShellScriptBin "install-nix-env" ''
          #!/usr/bin/env bash
          set -e
          echo "🚀 Installing Nix Environment for ${system}"

          case "${system}" in
            aarch64-darwin|x86_64-darwin)
              echo "🍎 macOS detected"
              nix build .#darwinConfigurations.naxn1a-darwin.system
              sudo ./result/sw/bin/darwin-rebuild switch --flake .#naxn1a-darwin
              ;;
            x86_64-linux|aarch64-linux)
              echo "🐧 Linux detected"
              home-manager switch --flake .#naxn1a-linux
              ;;
            *)
              echo "❌ Unsupported system: ${system}"
              exit 1
              ;;
          esac

          echo "✅ Installation complete!"
        '';

        update-script = pkgs.writeShellScriptBin "update-nix-env" ''
          #!/usr/bin/env bash
          set -e
          echo "🔄 Updating Nix Environment"

          nix flake update
          echo "✅ Flake updated"

          case "${system}" in
            aarch64-darwin|x86_64-darwin)
              sudo darwin-rebuild switch --flake .
              ;;
            x86_64-linux|aarch64-linux)
              home-manager switch --flake .
              ;;
          esac

          echo "✅ Environment updated!"
        '';
      });

    # Formatter for the entire flake
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
  };
}
