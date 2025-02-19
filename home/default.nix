{ config, pkgs, lib, inputs, ... }:
let
  username = "ed";
  inherit (config.lib.file) mkOutOfStoreSymlink;
in {
  programs.home-manager.enable = true;

  xdg.enable = true;
  xdg.configFile."i3/config".source = ../.config/i3/config;

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";
  home.file.".bashrc".text = builtins.readFile ../.rc/.bashrc;

  home.packages = with pkgs; [
    clipmenu
    fd
    feh
    fzf
    htop
    i3
    go
    keepassxc
    kubectl
    kubectx
    libglvnd
    maim
    mesa
    mesa-demos
    neovim
    openssh
    stern
    # terraform
    # terragrunt
    tree

    inputs.nixpkgs-poetry-1_8_5.legacyPackages.${pkgs.system}.poetry
  ];

  # services
  services.blueman-applet.enable = true;
  services.gnome-keyring = import ./services/gnome-keyring.nix { inherit pkgs; };
  services.gpg-agent = import ./services/gpg-agent.nix { inherit pkgs; };

  # packages managed outside home-manager
  xdg.configFile.nvim = {
    source = mkOutOfStoreSymlink
      "../.rc/.vimrc";
    force = true;
  };

  programs = {
    fzf = import ./programs/fzf.nix { inherit pkgs; };
    gh = import ./programs/gh.nix { inherit pkgs; };
    git = import ./programs/git.nix { inherit username lib; };
    go = import ./programs/go.nix { inherit pkgs; };
    gpg = { enable = true; };
    jq = { enable = true; };
    neovim = import ./programs/neovim.nix { inherit pkgs; };
    ssh = import ./programs/ssh.nix { inherit pkgs; };
  };
}
