# Naxn1a's dotfiles

## Install Nix and enable flakes
```sh
# MacOS
$ sh <(curl -L https://nixos.org/nix/install)

# Linux
$ sh <(curl -L https://nixos.org/nix/install) --daemon

# Windows (WSL2)
$ wsl --install
$ sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

## Clone this repository
```sh
$ git clone https://github.com/naxn1a/dotfiles.git ~/.local/share/chezmoi
```

## Nix
```sh
# 
$ nix-channel --update

# MacOS
$ nix run nix-darwin -- switch --flake .#naxn1a

$ darwin-rebuild switch --flake .#naxn1a

# Linux & Windows (WSL2)
$ nix run home-manager -- init --switch .

$ home-manager switch --flake .#naxn1a
```

## Chezmoi
```sh
# See what changes 
$ chezmoi diff

# Apply the changes
$ chezmoi apply -v
```

