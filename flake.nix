{
  description = "Environment's Naxn1a";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # nix-darwin
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    
    # home-manager for user environment
    home-manager.url = "github:nix-community/home-manager";
  };

  # outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  outputs = { self, nix-darwin, nixpkgs, nix-homebrew, home-manager }:
  let
    commonPackages = pkgs: with pkgs; [
      # Version control
      git
      gh

      # Shell
      nushell
      fish

      # Terminal
      starship
      tmux
      zellij

      # Editor
      neovim
      helix

      # CLI Utilities
      lazygit
      lazydocker
      curl
      wget
      jq
      yq
      tree
      btop
      httpie

      # CLI Replacement
      eza
      bat
      fd
      ripgrep
      du-dust
      procs
      sd
      xh
      delta

      # Productivity tools
      fzf
      yazi
      zoxide
      atuin
      mcfly
      cheat
      direnv

      # Container
      docker-compose
      podman
      podman-compose

      # AI/ML
      ollama

      # Package manager
      mise

      # Security tools
      exiftool
      age
      sops
      pass
      keychain
    ];

    # Common home-manager configuration
    commonHomeConfig = { pkgs, ... }: {
      home.packages = commonPackages pkgs;

      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "naxn1a";
            email = "";
          };
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
          fetch.fsckObjects = true;
          receive.fsckObjects = true;
        };
      };

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

      home.stateVersion = "24.05";
    };

  in {
    # nix-darwin
    darwinConfigurations."naxn1a-darwin" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
	      nix-homebrew.darwinModules.nix-homebrew
	      {
	        nix-homebrew = {
	          enable = true;

	          # Apple Silicon Only
	          enableRosetta = true;

	          # User owning the homebrew prefix
	          user = "naxn1a";

	          autoMigrate = true;
	        };
	      }

	      # Homebrew packages
	      {
	        homebrew = {
	          enable = true;
	          brews = [
	            "chezmoi"
	          ];
	          casks = [
	            # Essential app
	            "raycast"
	            "obsidian"
	            "notion"
	            "krita"

	            # Browsers
              "google-chrome"
              "brave-browser"
              # "arc"

	            # Dev tools
	            "zed"
	            "docker-desktop"
              "ngrok"
	            "claude"

	            # Terminal & Utilities
	            "ghostty"
              # "utm"

	            # Security & Privacy
              "mullvad-vpn"

	            # Entertainment
	            "spotify"
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
	        # User configuration
	        users.users.naxn1a = {
	          name = "naxn1a";
	          home = "/Users/naxn1a";
	          shell = nixpkgs.legacyPackages.aarch64-darwin.zsh;
	        };

	        system.primaryUser = "naxn1a";

	        # Shell configuration
	        programs.zsh.enable = true;
	        environment.shells = [ nixpkgs.legacyPackages.aarch64-darwin.zsh ];

	        # System packages
	        environment.systemPackages = commonPackages nixpkgs.legacyPackages.aarch64-darwin;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;
	      }
      ];
    };

    # home-manager
    homeConfigurations."naxn1a-linux" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legactPackages.x86_64-linux;
      modules = [
	      commonHomeConfig
	      {
	        home = {
	          username = "naxn1a";
	          homeDirectory = "/home/naxn1a";
	        };

	        home.packages = with nixpkgs.legacyPackages.x86_64-linux; [
	          gcc
	          gnumake
	          pkg-config
	          openssl
	          libiconv
	        ];
	      }
      ];
    };
  };
}

