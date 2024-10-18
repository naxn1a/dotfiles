# Naxn1a's dotfiles

## Nix package manager
### Install [nixos](https://nixos.org/) package manager
```bash
# macos
$ sh <(curl -L https://nixos.org/nix/install)

# windows (wsl2) & linux
$ sh <(curl -L https://nixos.org/nix/install) --daemon
```

### Clone repository
```bash
$ git clone https://github.com/Naxn1a/dotfiles.git
```

### Install package
```bash
$ nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/$path#naxn1a
```

## Chezmoi
```bash
$ chezmoi init https://github.com/Naxn1a/dotfiles.git

$ chezmoi diff

$ chezmoi apply -v
```
