{
  description = "Naxn1a Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
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
  };

  outputs = { self, nixpkgs, darwin, home-manager, nix-homebrew }:
  let
    # Common packages for all platforms
    commonPackages = pkgs: with pkgs; [
      # Core tools
      git
      gh
      neovim
      tmux
      zsh
      oh-my-zsh
      
      # CLI utilities
      curl
      wget
      jq
      yq
      tree
      htop
      btop
      httpie
      
      # Modern CLI replacements
      eza      # ls replacement
      bat      # cat replacement
      fd       # find replacement
      ripgrep  # grep replacement
      du-dust  # du replacement
      procs    # ps replacement
      
      # Development tools
      fzf
      direnv
      yazi
      
      # Programming languages
      rustc
      cargo
    ];

    # Common home-manager configuration
    commonHomeConfig = { pkgs, ... }: {
      home.packages = commonPackages pkgs;
      
      programs.git = {
        enable = true;
        userName = "naxn1a";
        userEmail = "";
        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = true;
        };
      };

      home.stateVersion = "23.11";
    };

  in {
    # macOS Darwin configuration
    darwinConfigurations."naxn1a-darwin" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        # nix-homebrew integration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            # Apple Silicon Only
            enableRosetta = true;
            # User owning the Homebrew prefix
            user = "naxn1a";
            # Automatically migrate existing Homebrew installations
            autoMigrate = true;
            # Optional: Specify the path to the Homebrew prefix
            # mutableTaps = false;
            taps = {};
          };
        }

        # Homebrew packages configuration
        {
          homebrew = {
            enable = true;
            brews = [
              "nvm"
              "lazygit"
              "lazydocker"
              "tree"
              "chezmoi"
              "go"
              "pyenv"
              "wget"
              "exiftool"
              "podman"
              "podman-compose"
            ];
            casks = [
              "docker"
              "raycast"
              "discord"
              "obsidian"
              "dotnet-sdk"
              "google-chrome"
              "brave-browser"
              "mullvadvpn"
              "ghostty"
              "ngrok"
              "utm"
              "zed"
              "claude"
            ];
            onActivation = {
              cleanup = "zap";
              autoUpdate = true;
              upgrade = true;
            };
          };
        }
        
        # System configuration
        {
          # Primary user setting (required for nix-darwin)
          system.primaryUser = "naxn1a";

          # Fix nixbld group GID issue
          ids.gids.nixbld = 350;

          # Nix configuration
          nix.settings = {
            experimental-features = [ "nix-command" "flakes" ];
            trusted-users = [ "root" "naxn1a" ];
          };

          # System packages
          environment.systemPackages = commonPackages nixpkgs.legacyPackages.aarch64-darwin;

          # macOS system preferences
          system = {
            defaults = {
              dock = {
                autohide = true;
                show-recents = false;
                launchanim = true;
                orientation = "bottom";
                tilesize = 48;
              };
              
              finder = {
                AppleShowAllExtensions = true;
                ShowPathbar = true;
                ShowStatusBar = true;
              };
              
              trackpad = {
                Clicking = true;
                TrackpadThreeFingerDrag = true;
              };
              
              NSGlobalDomain = {
                AppleShowAllExtensions = true;
                InitialKeyRepeat = 14;
                KeyRepeat = 1;
              };
            };
            
            # Keyboard settings
            keyboard = {
              enableKeyMapping = true;
            };
          };

          # Shell configuration
          programs.zsh.enable = true;
          environment.shells = [ nixpkgs.legacyPackages.aarch64-darwin.zsh ];
          
          # User configuration
          users.users.naxn1a = {
            name = "naxn1a";
            home = "/Users/naxn1a";
            shell = nixpkgs.legacyPackages.aarch64-darwin.zsh;
          };

          system.stateVersion = 4;
        }
        
        # Home Manager for user configuration
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

    # Linux/WSL/Windows home-manager configuration
    homeConfigurations."naxn1a-linux" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        commonHomeConfig
        {
          # Linux-specific configuration
          home = {
            username = "naxn1a";
            homeDirectory = "/home/naxn1a";
          };
          
          # Additional Linux packages
          home.packages = with nixpkgs.legacyPackages.x86_64-linux; [
            # Add Linux-specific packages here
            gcc
            gnumake
            pkg-config
            openssl
            libiconv
          ];

          # Linux-specific shell configuration
          programs.zsh.initExtra = ''
            # Linux-specific configuration
            export PATH="$HOME/.local/bin:$PATH"
            
            # WSL specific settings
            if grep -qi microsoft /proc/version; then
              export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0.0
              export LIBGL_ALWAYS_INDIRECT=1
            fi
          '';
        }
      ];
    };

    # ARM64 Linux (e.g., Raspberry Pi, ARM servers)
    homeConfigurations."naxn1a-linux-arm" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      modules = [
        commonHomeConfig
        {
          home = {
            username = "naxn1a";
            homeDirectory = "/home/naxn1a";
          };
        }
      ];
    };

    # Development shells for different platforms
    devShells = {
      aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.mkShell {
        buildInputs = commonPackages nixpkgs.legacyPackages.aarch64-darwin;
        shellHook = ''
          echo "🍎 macOS Development Environment Ready!"
          echo "Packages: git, neovim, tmux, oh-my-zsh, and more..."
        '';
      };

      x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        buildInputs = commonPackages nixpkgs.legacyPackages.x86_64-linux;
        shellHook = ''
          echo "🐧 Linux Development Environment Ready!"
          echo "Packages: git, neovim, tmux, oh-my-zsh, and more..."
        '';
      };

      aarch64-linux.default = nixpkgs.legacyPackages.aarch64-linux.mkShell {
        buildInputs = commonPackages nixpkgs.legacyPackages.aarch64-linux;
        shellHook = ''
          echo "🐧 ARM64 Linux Development Environment Ready!"
          echo "Packages: git, neovim, tmux, oh-my-zsh, and more..."
        '';
      };
    };
  };
}
