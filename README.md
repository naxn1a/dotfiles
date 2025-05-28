# Naxn1a's dotfiles

## Install Nix and enable flakes
```bash
# MacOS
$ sh <(curl -L https://nixos.org/nix/install)

# Linux
$ sh <(curl -L https://nixos.org/nix/install) --daemon

# Windows (WSL2)
$ wsl --install
$ sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

## Clone this repository
```bash
$ git clone https://github.com/naxn1a/dotfiles.git ~/.local/share/chezmoi
```

## Nix
```bash
# MacOS
$ nix run nix-darwin -- switch --flake .#naxn1a

$ darwin-rebuild switch --flake .#naxn1a

# Linux & Windows (WSL2)
$ nix run home-manager -- init --switch .

$ home-manager switch --flake .#naxn1a
```

## Chezmoi
```bash
# See what changes 
$ chezmoi diff

# Apply the changes
$ chezmoi apply -v
```

