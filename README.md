# Naxn1a's dotfiles

## Install Nix and enable flakes
```bash
# MacOS
$ sh <(curl -L https://nixos.org/nix/install)
$ mkdir -p ~/.config/nix
$ echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Linux
$ sh <(curl -L https://nixos.org/nix/install) --daemon

# Windows (WSL2)
$ wsl --install
$ sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

## Clone your config
```bash
$ git clone https://github.com/Naxn1a/dotfiles.git ~/.local/share/chezmoi
```

## Build and activate
```bash
# MacOS
$ darwin-rebuild switch --flake .#naxn1a

# Linux & Windows (WSL2)
$ home-manager switch --flake .#naxn1a
```

## Chezmoi
```bash
# See what changes 
$ chezmoi diff

# Apply the changes
$ chezmoi apply -v
```
