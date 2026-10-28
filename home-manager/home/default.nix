{ config, pkgs, lib, inputs, ... }:
let
  username = "ed";
  inherit (config.lib.file) mkOutOfStoreSymlink;

  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config = config.nixpkgs.config;
  };
  nvimTools = with unstable; [
    neovim
    ripgrep
    bash-language-server
    buf
    cue
    dockerfile-language-server
    docker-compose-language-service
    gopls
    helm-ls
    vscode-json-languageserver
    lua-language-server
    nixd
    opentofu
    ruff
    superhtml
    templ
    tflint
    tofu-ls
    typescript
    ty
    yaml-language-server
    rust-analyzer
    rustc
    cargo
    rustfmt
  ];
in {
  imports = [
    # Herdr has no `programs.herdr` HM module, so its config is a plain module
    # imported here rather than an entry in the `programs = { ... }` block below.
    ./programs/herdr.nix
  ];

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  xdg.enable = true;
  xdg.configFile."i3/config".source = ../.config/i3/config;
  # Make autorandr match displays by EDID for all invocations
  # (systemd service, udev hotplug and manual `autorandr --change`).
  xdg.configFile."autorandr/settings.ini".text = ''
    [config]
    match-edid=1
  '';

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";
  home.file.".bashrc".text = builtins.readFile ../.rc/.bashrc;
  # ~/.pi is a plain symlink to home-manager/.pi (see Makefile init);
  # pi mutates files in there, so it's kept out of home-manager.
  home.sessionVariables = {
    KUBE_EDITOR = "nvim";
    GIT_CONFIG_GLOBAL = "$HOME/.config/git/config";
    GDK_DPI_SCALE = 1;
  };

  home.packages = with pkgs; [
    azure-cli
    clipmenu
    unstable.code-cursor
    dbeaver-bin
    dnsutils
    fd
    fzf
    imagemagick
    ghostty
    go
    jq
    keepassxc
    kubectl
    kubectx
    kubeseal
    (pkgs.wrapHelm pkgs.kubernetes-helm { plugins = [ pkgs.kubernetes-helmPlugins.helm-secrets ]; })
    libcap
    libnotify
    lsof
    peek
    pgadmin
    postman
    scrot
    shutter
    stern
    terraform
    tmux
    xclip
    inputs.herdr-nix.packages.${pkgs.system}.default
  ] ++ nvimTools;

  # Services
  services.blueman-applet.enable = true;
  services.autorandr.matchEdid = true;

  programs = {
    autorandr = import ./programs/autorandr.nix { inherit config pkgs; };
    fzf = import ./programs/fzf.nix { inherit pkgs; };
    gh = import ./programs/gh.nix { inherit pkgs; };
    ghostty = import ./programs/ghostty.nix { inherit pkgs; };
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
