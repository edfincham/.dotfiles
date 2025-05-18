{ config, pkgs, lib, ... }:

let 
  azureVpn = pkgs.callPackage /home/ed/.dotfiles/nix-builds/azurevpn.nix {};
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import ./boot-configuration.nix { inherit pkgs; })
      (import ./hardware-camera.nix { inherit pkgs config; })
    ];
 
  # Sound
  hardware.firmware = [ pkgs.sof-firmware ];

  # Networking
  networking.hostName = "nixos";
  networking.wireless.enable = false;  # Disable wpa_supplicant since using networkmanager.

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
    dpkg
    feh
    firefox
    gcc
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

    # Azure VPN Custom Build
    azureVpn
    openresolv
  ];

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
    eval $(${pkgs.gnome.gnome-keyring}/bin/gnome-keyring-daemon --daemonize)
    export SSH_AUTH_SOCK
  '';

  # XRDP?
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "gnome-remote-desktop";
  services.xrdp.openFirewall = true;


  environment.etc."ssl/certs/DigiCert_Global_Root_G2.pem".text = ''
-----BEGIN CERTIFICATE-----
MIIDjjCCAnagAwIBAgIQAzrx5qcRqaC7KGSxHQn65TANBgkqhkiG9w0BAQsFADBh
MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
d3cuZGlnaWNlcnQuY29tMSAwHgYDVQQDExdEaWdpQ2VydCBHbG9iYWwgUm9vdCBH
MjAeFw0xMzA4MDExMjAwMDBaFw0zODAxMTUxMjAwMDBaMGExCzAJBgNVBAYTAlVT
MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
b20xIDAeBgNVBAMTF0RpZ2lDZXJ0IEdsb2JhbCBSb290IEcyMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuzfNNNx7a8myaJCtSnX/RrohCgiN9RlUyfuI
2/Ou8jqJkTx65qsGGmvPrC3oXgkkRLpimn7Wo6h+4FR1IAWsULecYxpsMNzaHxmx
1x7e/dfgy5SDN67sH0NO3Xss0r0upS/kqbitOtSZpLYl6ZtrAGCSYP9PIUkY92eQ
q2EGnI/yuum06ZIya7XzV+hdG82MHauVBJVJ8zUtluNJbd134/tJS7SsVQepj5Wz
tCO7TG1F8PapspUwtP1MVYwnSlcUfIKdzXOS0xZKBgyMUNGPHgm+F6HmIcr9g+UQ
vIOlCsRnKPZzFBQ9RnbDhxSJITRNrw9FDKZJobq7nMWxM4MphQIDAQABo0IwQDAP
BgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjAdBgNVHQ4EFgQUTiJUIBiV
5uNu5g/6+rkS7QYXjzkwDQYJKoZIhvcNAQELBQADggEBAGBnKJRvDkhj6zHd6mcY
1Yl9PMWLSn/pvtsrF9+wX3N3KjITOYFnQoQj8kVnNeyIv/iPsGEMNKSuIEyExtv4
NeF22d+mQrvHRAiGfzZ0JFrabA0UWTW98kndth/Jsw1HKj2ZL7tcu7XUIOGZX1NG
Fdtom/DzMNU+MeKNhJ7jitralj41E6Vf8PlwUHBHQRFXGU7Aj64GxJUTFy8bJZ91
8rGOmaFvE7FBcf6IKshPECBV1/MUReXgRPTqh5Uykw7+U0b6LJ3/iyK5S9kJRaTe
pLiaWN0bfVKfjllDiIGknibVb63dDcY3fe0Dkhvld1927jyNxF1WW6LZZm6zNTfl
MrY=
-----END CERTIFICATE-----
  '';
  security.wrappers = {
    microsoft-azurevpnclient = {
      owner = "root";
      group = "root";
      capabilities = "cap_net_admin,cap_net_raw,cap_net_bind_service,cap_setpcap,cap_setuid,cap_setgid,cap_sys_admin+ep";
      source = "${azureVpn}/bin/microsoft-azurevpnclient";
    };
  };

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

  services.dbus.packages = [
    pkgs.gnome-keyring
    (pkgs.writeTextFile {
      name = "azurevpn-dbus-policy";
      destination = "/share/dbus-1/system.d/org.freedesktop.resolve1.AzureVPN.conf";
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
        "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
        <busconfig>
          <policy user="root">
            <allow own="org.freedesktop.resolve1"/>
            <allow send_destination="org.freedesktop.resolve1"/>
          </policy>

          <!-- Allow all users to set DNS -->
          <policy context="default">
            <allow send_destination="org.freedesktop.resolve1"
                   send_interface="org.freedesktop.resolve1.Manager"
                   send_member="SetLinkDNS"/>
            <allow send_destination="org.freedesktop.resolve1"
                   send_interface="org.freedesktop.resolve1.Manager"
                   send_member="SetLinkDomains"/>
            <allow send_destination="org.freedesktop.resolve1"
                   send_interface="org.freedesktop.resolve1.Manager"
                   send_member="SetLinkDefaultRoute"/>
            <allow send_destination="org.freedesktop.resolve1"
                   send_interface="org.freedesktop.resolve1.Manager"
                   send_member="RevertLink"/>
            <!-- Add these additional permissions -->
            <allow send_destination="org.freedesktop.resolve1"
                   send_interface="org.freedesktop.DBus.Properties"
                   send_member="Get"/>
            <allow send_destination="org.freedesktop.resolve1"
                   send_interface="org.freedesktop.DBus.Properties"
                   send_member="GetAll"/>
            <allow send_destination="org.freedesktop.resolve1"
                   send_interface="org.freedesktop.DBus.Introspectable"
                   send_member="Introspect"/>
            <allow send_destination="org.freedesktop.resolve1"
                   send_interface="org.freedesktop.DBus.Peer"
                   send_member="Ping"/>
          </policy>

          <!-- Specific policy for your user -->
          <policy user="ed">
            <allow send_destination="org.freedesktop.resolve1"/>
          </policy>
        </busconfig>
      '';
    })
  ];

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.freedesktop.resolve1.") == 0 ||
          action.id.indexOf("org.freedesktop.NetworkManager.") == 0) {
        if (subject.programPath &&
            (subject.programPath.indexOf("microsoft-azurevpnclient") >= 0 ||
             subject.programPath.indexOf("openvpn") >= 0)) {
          return polkit.Result.YES;
        }

        if (subject.local && subject.active && subject.isInGroup("networkmanager")) {
          return polkit.Result.YES;
        }
      }

      if (action.id == "org.freedesktop.resolve1.set-dns-servers" ||
          action.id == "org.freedesktop.resolve1.set-domains" ||
          action.id == "org.freedesktop.resolve1.set-default-route" ||
          action.id == "org.freedesktop.resolve1.set-link-dns" ||
          action.id == "org.freedesktop.resolve1.set-link-domains" ||
          action.id == "org.freedesktop.resolve1.set-link-default-route" ||
          action.id == "org.freedesktop.resolve1.revert-link") {
        return polkit.Result.YES;
      }
    });
  '';

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
