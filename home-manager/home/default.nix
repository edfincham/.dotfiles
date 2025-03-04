{ config, pkgs, lib, inputs, ... }:
let
  username = "ed";
  inherit (config.lib.file) mkOutOfStoreSymlink;
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
  };

  home.packages = with pkgs; [
    clipmenu
    code-cursor
    fd
    fzf
    imagemagick
    go
    keepassxc
    kubectl
    kubectx
    (python310.withPackages (ps: with ps; [
      pip
      numpy
    ]))
    scrot
    stern
    # terraform
    # terragrunt
    xclip

    inputs.nixpkgs-poetry-1_8_5.legacyPackages.${pkgs.system}.poetry
  ];

  # Services
  services.blueman-applet.enable = true;
  # services.gnome-keyring = import ./services/gnome-keyring.nix { inherit pkgs; };
  # services.gpg-agent = import ./services/gpg-agent.nix { inherit pkgs; };

  programs = {
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
  systemd.user.services.gnome-keyring = {
    Unit = {
      Description = "GNOME Keyring Daemon";
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.gnome.gnome-keyring}/bin/gnome-keyring-daemon --start --foreground --components=pkcs11,secrets,ssh";
      Restart = "always";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
