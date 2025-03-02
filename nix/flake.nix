{
  description = "Naxn1a development environment";

  inputs = {
    # Core inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # Darwin-specific
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Home Manager for Linux and WSL2
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Common overlays
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs@{ 
    self, 
    nixpkgs, 
    nix-darwin, 
    home-manager, 
    nix-homebrew, 
    rust-overlay,
    ... 
  }: let
    # System types
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
    
    # Helper function to generate configurations for each system
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Shared configuration for all systems
    sharedOverlays = [
      rust-overlay.overlays.default
    ];

    # Common packages for all systems
    commonPackages = pkgs: with pkgs; [
      # Development tools
      git
      gh
      neovim
      tmux

      # Terminal utilities
      bat
      fzf
      ripgrep
      tree
      eza
      fd
      yazi
    ];

    # Shared shell configuration
    sharedShellInit = ''
      export PATH=$HOME/.local/bin:$PATH
      export EDITOR=nvim
    '';

    # Darwin-specific configuration
    darwinConfig = { pkgs, config, ... }: {
      nixpkgs = {
        config = {
          allowUnfree = true;
          allowInsecure = false;
        };
        overlays = sharedOverlays;
      };

      # Darwin-specific packages
      environment.systemPackages = commonPackages pkgs;

      # Darwin-specific homebrew
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
          "ollama"
          "argon2"
        ];
        casks = [
          "kitty"
          "hammerspoon"
          "docker"
          "raycast"
          "discord"
          "obsidian"
          "dotnet-sdk"
          "google-chrome"
          "zen-browser"
          "brave-browser"
          "mullvadvpn"
          "ghostty"
          "ngrok"
          "utm"
        ];
        onActivation = {
          cleanup = "zap";
          autoUpdate = true;
          upgrade = true;
        };
      };

      # Darwin-specific fonts
      fonts.packages = [
	      pkgs.nerd-fonts.jetbrains-mono
      	pkgs.nerd-fonts.fira-mono
      ];

      # Darwin-specific system settings
      system.defaults = {
        dock.autohide = true;
        finder.FXPreferredViewStyle = "Nlsv";
        loginwindow.GuestEnabled = false;
        finder.AppleShowAllExtensions = true;
        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark";
          InitialKeyRepeat = 15;
          KeyRepeat = 2;
        };
      };

      programs.zsh.enable = true;

      system.stateVersion = 6;
    };

    # Linux/WSL2 configuration using home-manager
    homeManagerConfig = { pkgs, config, ... }: {
      home = {
        username = "naxn1a";  # Change this to your username
        homeDirectory = "/home/naxn1a";  # Change this to your home directory
        stateVersion = "23.11";

        packages = commonPackages pkgs;

        sessionVariables = {
          EDITOR = "nvim";
        };
      };

      programs = {
        home-manager.enable = true;

        git = {
          enable = true;
          userName = "";
          userEmail = "";
        };

        zsh = {
          enable = true;
          initExtra = sharedShellInit;
        };

        # Add VSCode for Linux
        vscode = {
          enable = true;
          package = pkgs.vscode;
        };
      };

      # WSL2-specific configuration
      targets.genericLinux.enable = true;
    };

  in {
    # Darwin configuration
    darwinConfigurations = {
      "naxn1a" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";  # Change this according to your Mac's architecture
        modules = [
          darwinConfig
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "naxn1a";  # Change this to your username
              autoMigrate = true;
            };
          }
        ];
      };
    };

    # Linux/WSL2 configuration
    homeConfigurations = {
      "naxn1a" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";  # Change this according to your system
          config.allowUnfree = true;
          overlays = sharedOverlays;
        };
        modules = [ homeManagerConfig ];
      };
    };

    # Development shell for each system
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = sharedOverlays;
      };
    in {
      default = pkgs.mkShell {
        buildInputs = commonPackages pkgs;
        shellHook = sharedShellInit;
      };
    });
  };
}
