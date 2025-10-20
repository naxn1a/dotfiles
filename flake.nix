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
    # Supported systems: macOS and Linux only
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    # Function to check if system is supported
    isSupportedSystem = system: builtins.elem system supportedSystems;
    # Common packages for all platforms
    commonPackages = pkgs: with pkgs; [
      # Core development tools
      nushell
      gh
      neovim
      tmux
      helix  # Modern editor alternative
      starship

      # Modern CLI utilities
      lazygit
      lazydocker
      curl
      wget
      jq
      yq
      tree
      btop
      httpie
      zellij  # Modern terminal multiplexer

      # Enhanced CLI replacements
      eza      # ls replacement
      bat      # cat replacement
      fd       # find replacement
      ripgrep  # grep replacement
      du-dust  # du replacement
      procs    # ps replacement
      sd       # sed replacement
      delta    # git diff replacement
      gpg-tui  # GPG TUI interface

      # Development and productivity tools
      fzf
      yazi
      zoxide   # Smart directory navigation
      atuin    # Shell history sync
      mcfly    # Shell history search
      cheat    # Command cheatsheets

      # Modern programming languages and tools
      # rustc
      # cargo
      # rust-analyzer
      # go
      # gopls
      # nodejs_22
      # python312
      # poetry
      # deno
      # bun

      # Container and cloud tools
      # docker
      docker-compose
      podman
      podman-compose
      # kubectl
      # helm
      # terraform
      # awscli2

      # AI/ML development tools
      ollama

      # Package manager
      mise
      # uv      # Python package manager

      # Security tools
      age
      sops
      pass
      keychain
    ];

    # Common home-manager configuration
    commonHomeConfig = { pkgs, ... }: {
      home.packages = commonPackages pkgs;

      # Modern Git configuration
      programs.git = {
        enable = true;
        userName = "naxn1a";
        userEmail = "";
        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = true;
          fetch.prune = true;
          push.autoSetupRemote = true;
          commit.verbose = true;
          merge.conflictstyle = "diff3";
          diff.algorithm = "histogram";
          status.showUntrackedFiles = "all";
          branch.sort = "-committerdate";
          tag.sort = "version:refname";

          # Security
          pull.rebase = true;
          fetch.fsckObjects = true;
          receive.fsckObjects = true;
        };
      };

      # Modern tools configuration
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
        defaultCommand = "rg --files --hidden --follow --glob '!.git'";
        defaultOptions = [ "--height 40%" "--layout=reverse" "--border" ];
      };

      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
        options = [ "--cmd cd" ];
      };

      # Security tools configuration
      programs.gpg = {
        enable = true;
        homedir = "${config.home.homeDirectory}/.gnupg";
        settings = {
          default-key = "";
          trust-model = "tofu";
          encrypt-to = "";
        };
      };

      home.stateVersion = "24.05";
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
              "chezmoi"
              "exiftool"
              "gemini-cli"
            ];
            casks = [
              # Essential app
              "docker-desktop"
              "raycast"
              "obsidian"
              "zed"
              "claude"
              "krita"
              # "linear-linear"   # Issue tracking
              "notion"          # Note-taking
              # "slack"
              # "zoom"
              # "vlc"

              # Browsers
              "google-chrome"
              "brave-browser"
              # "arc"             # Modern browser

              # Security & Privacy
              "mullvad-vpn"

              # Dev tools
              "dotnet-sdk"
              "ngrok"

              # Terminal & Utilities
              "ghostty"
              "utm"
              # "postman"
              # "tableplus"       # Database GUI
              # "insomnia"        # API testing
              # "wireshark"       # Network analysis
              # "proxmark"        # Security tools
              # "tailscale"       # VPN
              # "1password"       # Password manager
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

          # Nix configuration optimized
          nix.settings = {
            experimental-features = [ "nix-command" "flakes" "ca-derivations" ];
            trusted-users = [ "root" "naxn1a" ];

            # Performance optimizations
            cores = 0;  # Use all available cores
            max-jobs = "auto";

            # Binary cache configuration
            substituters = [
              "https://cache.nixos.org"
              "https://nix-community.cachix.org"
              "https://devenv.cachix.org"
            ];
            trusted-public-keys = [
              "cache.nixos.org-1:6NCHdD592447YH2G+2Xnl8cAq8F9t2s4Q4KpW+OjMg="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
            ];

            # Auto-optimization
            auto-optimise-store = true;
            keep-derivations = true;
            keep-outputs = true;

            # Build optimization
            sandbox = true;
            build-use-sandbox = true;
            build-use-chroot = true;

            # Storage optimization
            min-free = 1073741824;  # 1GB
            max-free = 10737418240; # 10GB
          };

          # System packages
          environment.systemPackages = commonPackages nixpkgs.legacyPackages.aarch64-darwin;

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

    # Linux home-manager configuration (including WSL)
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

            # WSL specific settings (if running under WSL)
            if [ -f /proc/version ] && grep -qi microsoft /proc/version; then
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

    # Modern development shells for different platforms
    devShells = {
      aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.mkShell {
        buildInputs = with nixpkgs.legacyPackages.aarch64-darwin; [
          # Core development tools
          rustc cargo rust-analyzer
          go gopls
          nodejs_22
          python312 poetry
          deno bun

          # Modern tooling
          zellij fzf eza bat ripgrep fd sd procs
          starship zoxide atuin

          # AI/ML development
          ollama uv

          # Container and cloud
          docker docker-compose kubectl helm

          # Security tools
          age sops

          # Build tools
          gcc gnumake cmake pkg-config
        ];

        shellHook = ''
          echo "🍎 macOS ARM64 Development Environment Ready!"
          echo "🚀 Modern tools: Rust, Go, Node.js, Python, AI/ML support"
          echo "🔧 Enhanced CLI: zellij, starship, zoxide, atuin"
          echo "🐳 Container support: Docker, Kubernetes"
          echo "🤖 AI development: Ollama, UV"
          echo ""
          echo "💡 Quick start:"
          echo "  • zellij    - Start terminal multiplexer"
          echo "  • nvim .    - Open project in Neovim"
          echo "  • cargo run - Run Rust project"
          echo "  • go run .  - Run Go project"
          echo "  • npm start - Start Node.js project"
          echo "  • ollama    - Start AI models"
        '';
      };

      x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
          # Core development tools
          rustc cargo rust-analyzer
          go gopls
          nodejs_22
          python312 poetry
          deno bun

          # Modern tooling
          zellij fzf eza bat ripgrep fd sd procs
          starship zoxide atuin

          # AI/ML development
          ollama uv

          # Container and cloud
          docker docker-compose kubectl helm

          # Security tools
          age sops

          # Build tools
          gcc gnumake cmake pkg-config
        ];

        shellHook = ''
          echo "🐧 Linux x86_64 Development Environment Ready!"
          echo "🚀 Modern tools: Rust, Go, Node.js, Python, AI/ML support"
          echo "🔧 Enhanced CLI: zellij, starship, zoxide, atuin"
          echo "🐳 Container support: Docker, Kubernetes"
          echo "🤖 AI development: Ollama, UV"
          echo ""
          echo "💡 Quick start:"
          echo "  • zellij    - Start terminal multiplexer"
          echo "  • nvim .    - Open project in Neovim"
          echo "  • cargo run - Run Rust project"
          echo "  • go run .  - Run Go project"
          echo "  • npm start - Start Node.js project"
          echo "  • ollama    - Start AI models"
        '';
      };

      aarch64-linux.default = nixpkgs.legacyPackages.aarch64-linux.mkShell {
        buildInputs = with nixpkgs.legacyPackages.aarch64-linux; [
          # Core development tools
          rustc cargo rust-analyzer
          go gopls
          nodejs_22
          python312 poetry
          deno bun

          # Modern tooling
          zellij fzf eza bat ripgrep fd sd procs
          starship zoxide atuin

          # AI/ML development
          ollama uv

          # Container and cloud
          docker docker-compose kubectl helm

          # Security tools
          age sops

          # Build tools
          gcc gnumake cmake pkg-config
        ];

        shellHook = ''
          echo "🐧 Linux ARM64 Development Environment Ready!"
          echo "🚀 Modern tools: Rust, Go, Node.js, Python, AI/ML support"
          echo "🔧 Enhanced CLI: zellij, starship, zoxide, atuin"
          echo "🐳 Container support: Docker, Kubernetes"
          echo "🤖 AI development: Ollama, UV"
          echo ""
          echo "💡 Quick start:"
          echo "  • zellij    - Start terminal multiplexer"
          echo "  • nvim .    - Open project in Neovim"
          echo "  • cargo run - Run Rust project"
          echo "  • go run .  - Run Go project"
          echo "  • npm start - Start Node.js project"
          echo "  • ollama    - Start AI models"
        '';
      };
    };
  };
}
