{ config, pkgs, lib, inputs, ... }:
let
  username = "ed";
  inherit (config.lib.file) mkOutOfStoreSymlink;

  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config = config.nixpkgs.config;
  };
in {
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  xdg.enable = true;
  xdg.configFile."i3/config".source = ../.config/i3/config;

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";
  home.file.".bashrc".text = builtins.readFile ../.rc/.bashrc;
  home.sessionVariables = {
    KUBE_EDITOR = "nvim";
    GIT_CONFIG_GLOBAL = "$HOME/.config/git/config";
    GDK_DPI_SCALE = 1;
  };

  home.packages = with pkgs; [
    azure-cli
    clipmenu
    code-cursor
    dnsutils
    fd
    fzf
    imagemagick
    go
    jq
    keepassxc
    kubectl
    kubectx
    libcap
    libnotify
    (python310.withPackages (ps: with ps; [
      pip
      numpy
    ]))
    scrot
    shutter
    stern
    terraform
    tmux
    xclip

    inputs.nixpkgs-poetry-2_1_2.legacyPackages.${pkgs.system}.poetry
  ];

  # Services
  services.blueman-applet.enable = true;

  programs = {
    autorandr = import ./programs/autorandr.nix { inherit config pkgs; };
    fzf = import ./programs/fzf.nix { inherit pkgs; };
    gh = import ./programs/gh.nix { inherit pkgs; };
    git = import ./programs/git.nix { inherit username lib; };
    go = import ./programs/go.nix { inherit pkgs; };
    gpg = { enable = true; };
    jq = { enable = true; };
    ssh = import ./programs/ssh.nix { inherit pkgs; };
    yazi = import ./programs/yazi.nix { inherit pkgs; };
  };

  systemd.user.services.dropbox = {
    Unit = {
      Description = "Dropbox service";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.dropbox}/bin/dropbox";
      Restart = "on-failure";
    };
  };
}
