{ config, pkgs, lib, inputs, ... }:
let
  unstable = import <nixpkgs-unstable> {
    system = pkgs.system;
    config = config.nixpkgs.config;
  };
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import ./boot-configuration.nix { inherit pkgs; })
    ];
 
  # Sound
  hardware.firmware = [ pkgs.sof-firmware ];

  # Networking
  networking.hostName = "nixos";
  networking.wireless.enable = false;  # Disable wpa_supplicant since using networkmanager.
  networking.networkmanager = {
    enable = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Enable Bluetooth and Bluetooth manager
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Configure i3 and X11
  services.displayManager.defaultSession = "none+i3";
  services.xserver = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
	    i3lock
    	i3blocks
      ];
    };
    xkb = {
      layout = "gb";
      variant = "";
    };
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable Docker
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ed = {
    isNormalUser = true;
    description = "Ed";
    extraGroups = [ "systemd-network" "network" "networkmanager" "wheel" "docker"  "audio" "video" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alsa-utils
    unstable.claude-code
    dpkg
    feh
    firefox
    gcc14
    gcc14.cc.lib
    glibc
    gnumake
    pkg-config
    ghostty
    gnome-keyring
    gnumake
    neovim
    networkmanagerapplet
    ninja
    openssh
    pciutils
    pkgs.gnome-remote-desktop
    pkgs.xrdp
    remmina
    picom
    rofi
    seahorse
    slack
    tree
    unzip
    v4l-utils
    vlc
    wireguard-tools
    wget
  ];

  environment.variables = {
    LD_LIBRARY_PATH = "${pkgs.gcc14.cc.lib}/lib:${pkgs.lib.makeLibraryPath [ pkgs.zlib pkgs.glibc ]}";
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.gnome-disks.enable = true;
  programs.nm-applet.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.udisks2.enable = true;

  # Enable GnomeKeyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.passwd.enableGnomeKeyring = true;
  services.xserver.windowManager.i3.extraSessionCommands = ''
    eval $(${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --daemonize)
    export SSH_AUTH_SOCK
  '';

  # XRDP?
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "gnome-remote-desktop";
  services.xrdp.openFirewall = true;

  services.resolved = {
    enable = true;
    dnssec = "false";
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
    extraConfig = ''
      DNSStubListener=yes
      ResolveUnicastSingleLabel=yes
      Cache=yes
    '';
  };

  systemd.services.systemd-resolved = {
    serviceConfig = {
      SupplementaryGroups = [ "systemd-network" ];
      BusName = "org.freedesktop.resolve1";
    };
  };

  # Allow VPN traffic
  networking.firewall = {
    allowedUDPPorts = [ 1194 ];
    checkReversePath = false;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
