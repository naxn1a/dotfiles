# Brew
brew:
	brew update && brew upgrade && brew cleanup --prune=1

# nixos
nix-run:
	nix run nix-darwin -- switch --flake ./nix/flake.nix#naxn1a
nix-build:
	darwin-rebuild switch --flake ./nix/flake.nix#naxn1a
