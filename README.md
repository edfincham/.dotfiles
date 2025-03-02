# nix

nix + dotfile repository

## Installation

1. Install Nix:

```bash
curl -L https://nixos.org/nix/install | sh
```

2. Clone this repository:

```bash
git clone git@github.com:edfincham/.dotfiles.git
```

3. Initialise home-manager:

```bash
nix run home-manager/master -- init --switch
```

4. Setup dotfile symlinks and build system:

```bash
make init
make rebuild
```

## Daily Usage

If `nix flake update` (or `make update`) is used repeatedly, GitHub may rate limit. To get around this add the following line to `~/.config/nix/nix.conf`

```bash
access-tokens = github.com=$GH_PAT
```

After making changes run:

```bash
make update
make rebuild
```

Run `make help` to see available commands.
